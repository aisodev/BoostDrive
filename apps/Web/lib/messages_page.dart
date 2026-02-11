import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesPage extends ConsumerStatefulWidget {
  final String? initialConversationId;
  
  const MessagesPage({super.key, this.initialConversationId});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  String? _selectedConversationId;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialConversationId != null) {
      _selectedConversationId = widget.initialConversationId;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedConversationId == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await ref.read(messageServiceProvider).sendMessage(
        conversationId: _selectedConversationId!,
        senderId: user.id,
        content: _messageController.text.trim(),
      );

      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view messages')),
      );
    }

    return Scaffold(
      backgroundColor: BoostDriveTheme.backgroundDark,
      body: Row(
        children: [
          // Conversations List
          SizedBox(
            width: 350,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Messages',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: _buildConversationList(user.id)),
                ],
              ),
            ),
          ),
          // Chat View
          Expanded(
            child: _selectedConversationId == null
                ? _buildEmptyState()
                : _buildChatView(user.id),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String conversationId, String productTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Conversation', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this conversation? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(messageServiceProvider).deleteConversation(conversationId);
        
        // If the deleted conversation was selected, clear selection
        if (_selectedConversationId == conversationId) {
          setState(() {
            _selectedConversationId = null;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conversation deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete conversation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildConversationList(String userId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ref.watch(messageServiceProvider).streamConversations(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'No conversations yet',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        // Filter conversations to only show where user is buyer or seller
        final allConversations = snapshot.data!;
        final conversations = allConversations.where((conv) {
          final buyerId = conv['buyer_id'] as String?;
          final sellerId = conv['seller_id'] as String?;
          return buyerId == userId || sellerId == userId;
        }).toList();

        if (conversations.isEmpty) {
          return const Center(
            child: Text(
              'No conversations yet',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
          itemBuilder: (context, index) {
            final conv = conversations[index];
            final isSelected = conv['id'] == _selectedConversationId;

            return ListTile(
              selected: isSelected,
              selectedTileColor: BoostDriveTheme.primaryBlue.withOpacity(0.1),
              title: Text(
                conv['product_title'] ?? 'Product',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                conv['last_message'] ?? 'Start a conversation',
                style: const TextStyle(color: Colors.white54),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: isSelected ? BoostDriveTheme.primaryBlue : Colors.red.withOpacity(0.7),
                ),
                tooltip: 'Delete conversation',
                hoverColor: Colors.red.withOpacity(0.2),
                onPressed: () => _showDeleteConfirmation(conv['id'], conv['product_title'] ?? 'this conversation'),
              ),
              onTap: () {
                setState(() {
                  _selectedConversationId = conv['id'];
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatView(String userId) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: ref.read(messageServiceProvider).getConversation(_selectedConversationId!),
            builder: (context, convSnapshot) {
              if (!convSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final conversation = convSnapshot.data!;
              final buyerId = conversation['buyer_id'] as String;
              final sellerId = conversation['seller_id'] as String;

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: ref.watch(messageServiceProvider).streamMessages(_selectedConversationId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  
                  final messages = snapshot.data!.reversed.toList();
                  return _buildMessageList(messages, buyerId, sellerId, userId);
                },
              );
            },
          ),
        ),
        const Divider(height: 1, color: Colors.white10),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                mini: true,
                onPressed: _sendMessage,
                backgroundColor: BoostDriveTheme.primaryBlue,
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList(List<Map<String, dynamic>> messages, String buyerId, String sellerId, String currentUserId) {
    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final senderId = msg['sender_id'] as String;
        
        // STRICT ALIGNMENT: 
        // Buyer messages (senderId == buyerId) -> RIGHT
        // Seller/AI messages (senderId == sellerId) -> LEFT
        final isBuyerMessage = senderId == buyerId;
        
        return Align(
          alignment: isBuyerMessage ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
            decoration: BoxDecoration(
              // Buyer messages: Orange gradient
              gradient: isBuyerMessage ? const LinearGradient(
                colors: [BoostDriveTheme.primaryBlue, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              // Seller/AI messages: Glassmorphism
              color: isBuyerMessage ? null : Colors.white.withOpacity(0.05),
              boxShadow: isBuyerMessage ? [
                BoxShadow(
                  color: BoostDriveTheme.primaryBlue.withOpacity(0.3), 
                  blurRadius: 8, 
                  offset: const Offset(0, 4)
                )
              ] : [],
              border: isBuyerMessage ? null : Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isBuyerMessage ? 16 : 4),
                bottomRight: Radius.circular(isBuyerMessage ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: isBuyerMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Label logic: only show label for the message that isn't from the viewer
                // to keep it looking clean.
                if (senderId != currentUserId)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      isBuyerMessage ? 'Buyer' : 'Seller / AI Assistant',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Text(
                  msg['content'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Select a conversation to start messaging',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
