import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String productTitle;
  final String buyerId;
  final String sellerId;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.productTitle,
    required this.buyerId,
    required this.sellerId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(messageServiceProvider).sendMessage(
        conversationId: widget.conversationId,
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold();

    return Scaffold(
      backgroundColor: BoostDriveTheme.backgroundDark,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.productTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Seller Chat', style: TextStyle(fontSize: 12, color: BoostDriveTheme.textDim)),
          ],
        ),
        backgroundColor: BoostDriveTheme.surfaceDark,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ref.watch(messageServiceProvider).streamMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final messages = snapshot.data!.reversed.toList();

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final rawContent = msg['content'] as String;
                    final senderId = msg['sender_id'] as String;

                    // Check for AI marker
                    final isAiMessage = rawContent.startsWith('[AI] ');
                    final displayContent = isAiMessage ? rawContent.substring(5) : rawContent;
                    
                    // ALIGNMENT LOGIC:
                    // Normal Buyer messages -> RIGHT (Orange)
                    // Seller messages -> LEFT (Glass)
                    // AI messages (sent by buyer but representing seller) -> LEFT (Glass)
                    
                    bool isBuyerMessage = senderId == widget.buyerId;
                    
                    // Override if it's an AI message (treat as received from seller)
                    if (isAiMessage) {
                      isBuyerMessage = false; 
                    }

                    return _MessageBubble(
                      content: displayContent,
                      isMe: isBuyerMessage, 
                      alignment: isBuyerMessage ? Alignment.centerRight : Alignment.centerLeft,
                      color: isBuyerMessage ? BoostDriveTheme.primaryBlue : Colors.white.withOpacity(0.05),
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: BoostDriveTheme.surfaceDark,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: BoostDriveTheme.primaryBlue),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final Alignment alignment;
  final Color color;

  const _MessageBubble({
    required this.content,
    required this.isMe,
    required this.alignment,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Text(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
