import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqApiService {
  final String apiKey;
  final String baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  GroqApiService({required this.apiKey});

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192', // You can also use 'llama3-70b-8192' for better results
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful medical assistant in a doctor appointment app. Provide concise, accurate medical information. For serious concerns, always recommend consulting a healthcare professional. Do not diagnose but help users understand general medical information.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }
}