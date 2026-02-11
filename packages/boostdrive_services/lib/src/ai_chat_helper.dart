import 'package:boostdrive_core/boostdrive_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIChatHelper {
  static const String _apiKey = '';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String?> generateResponse(String message, Product product) async {
    return generateResponseWithContext(message, product, '');
  }

  static Future<String?> generateResponseWithContext(
    String message, 
    Product product,
    String conversationHistory,
  ) async {
    // For now, we use strictly defined rule-based responses as requested by the user.
    return _getFallbackResponse(message, product);
  }

  // Strictly defined rule-based responses
  static String _getFallbackResponse(String message, Product product) {
    final lowerMsg = message.toLowerCase().trim();
    print('DEBUG: AIChatHelper analyzing message: "$lowerMsg"');
    
    String response;
    // 1. Availability
    if (lowerMsg.contains('available') || lowerMsg == "is this still available?") {
      response = "Yes, the ${product.title} is currently available! 😊";
    }
    // 2. Condition
    else if (lowerMsg.contains('condition') || lowerMsg == "what's the condition like?") {
      response = "The ${product.title} is in ${product.condition} condition. it's a great deal! 😊";
    }
    // 3. More Info
    else if (lowerMsg.contains('tell me more') || lowerMsg == "can you tell me more about this product?") {
      response = "Certainly! The ${product.title} is listed for N\$ ${product.price.toStringAsFixed(2)}. It's located in ${product.location}. What specific details would you like to know?";
    }
    // 4. Location
    else if (lowerMsg.contains('location') || lowerMsg.contains('where') || lowerMsg == "where is it located?") {
      response = "The ${product.title} is located in ${product.location}. We can arrange a viewing there! 😊";
    }
    // 5. Best Price & Unknown Questions
    else if (lowerMsg.contains('best price') || lowerMsg.contains('discount') || lowerMsg == "what's your best price?") {
      response = "I cannot confirm that at the moment, let's wait for the actual seller to come online and respond to you";
    }
    // Default response for ANY other questions
    else {
      response = "I cannot confirm that at the moment, let's wait for the actual seller to come online and respond to you";
    }

    print('DEBUG: AIChatHelper response: "$response"');
    return response;
  }
}
