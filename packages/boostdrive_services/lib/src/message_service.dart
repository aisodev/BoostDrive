import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_core/boostdrive_core.dart';
import 'ai_chat_helper.dart';

class MessageService {
  final _supabase = Supabase.instance.client;

  /// Gets or creates a conversation between buyer and seller for a product
  Future<String> getOrCreateConversation({
    required String productId,
    required String buyerId,
    required String seller_id,
  }) async {
    try {
      // Try to find existing conversation
      final existing = await _supabase
          .from('conversations')
          .select('id')
          .eq('product_id', productId)
          .eq('buyer_id', buyerId)
          .eq('seller_id', seller_id)
          .maybeSingle();

      if (existing != null) {
        return existing['id'] as String;
      }

      // Create new one if not found
      final response = await _supabase
          .from('conversations')
          .insert({
            'product_id': productId,
            'buyer_id': buyerId,
            'seller_id': seller_id,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error getting/creating conversation: $e');
      rethrow;
    }
  }

  /// Sends a message in a conversation
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    try {
      // 1. Send the user's message
      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
      });

      // 2. Check for automatic AI response
      _handleAIResponse(conversationId, senderId, content);

    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
  
  
  
  Future<void> _handleAIResponse(String conversationId, String senderId, String userMessage) async {
    try {
      print('DEBUG: Handling AI response for conversation $conversationId');
      
      // Fetch conversation to get product ID and seller ID
      final conversation = await _supabase
          .from('conversations')
          .select('product_id, seller_id')
          .eq('id', conversationId)
          .single();
          
      final sellerId = conversation['seller_id'] as String;
      
      // AI only responds to the buyer (i.e., when sender is NOT the seller)
      if (senderId == sellerId) {
        print('DEBUG: Sender is the seller, AI will not respond.');
        return;
      }

      print('DEBUG: AI generating response for buyer $senderId');
      final productId = conversation['product_id'] as String;

      // Fetch product details for the AI context
      final productData = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .single();
          
      final product = Product.fromMap(productData);
      print('DEBUG: Product context: ${product.title}');

      // Fetch recent conversation history for context
      final recentMessages = await _supabase
          .from('messages')
          .select('content, sender_id')
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .limit(5);
      
      // Build conversation context
      final conversationHistory = (recentMessages as List)
          .reversed
          .map((m) => '${m['sender_id'] == sellerId ? "Assistant" : "User"}: ${m['content']}')
          .join('\n');

      // Generate response using OpenAI with conversation context
      final aiResponse = await AIChatHelper.generateResponseWithContext(
        userMessage, 
        product,
        conversationHistory,
      );

      if (aiResponse != null && aiResponse.isNotEmpty) {
        print('DEBUG: AI Response generated: $aiResponse');
        // Simulate "typing" delay
        await Future.delayed(const Duration(seconds: 2));

        // Insert AI response as the seller
        // Insert AI response as the buyer (to pass RLS) but marked as AI
        await _supabase.from('messages').insert({
          'conversation_id': conversationId,
          'sender_id': senderId, // Insert as current user (buyer)
          'content': '[AI] $aiResponse', // Marker for UI to detect
        });
        print('DEBUG: AI Response inserted successfully.');
      } else {
        print('DEBUG: AI Response was empty or null.');
      }
    } catch (e) {
      print('DEBUG: AI Error: $e');
    }
  }

  /// Streams messages for a specific conversation
  Stream<List<Map<String, dynamic>>> streamMessages(String conversationId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
  }

  /// Streams active conversations for a user
  Stream<List<Map<String, dynamic>>> streamConversations(String userId) {
    // Note: Supabase stream doesn't support .or() filters
    // We'll filter in the UI layer or use two separate streams
    return _supabase
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  /// Gets a single conversation by ID
  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    return await _supabase
        .from('conversations')
        .select()
        .eq('id', conversationId)
        .single();
  }

  /// Deletes a conversation and all its messages
  Future<void> deleteConversation(String conversationId) async {
    try {
      print('Deleting conversation: $conversationId');
      
      // Delete all messages in the conversation first
      final messagesDeleted = await _supabase
          .from('messages')
          .delete()
          .eq('conversation_id', conversationId)
          .select();
      
      print('Deleted ${messagesDeleted.length} messages');
      
      // Then delete the conversation
      final conversationDeleted = await _supabase
          .from('conversations')
          .delete()
          .eq('id', conversationId)
          .select();
      
      print('Deleted conversation: ${conversationDeleted.length} rows');
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }
}

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});
