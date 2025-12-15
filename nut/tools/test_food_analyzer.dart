import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to verify Groq API rate limits and image analysis
/// Run with: dart run tools/test_food_analyzer.dart
void main() async {
  print('🧪 Testing Food Analyzer Model...\n');
  
  // Test API key
  const apiKey = ''; // TODO: Add your GROQ API key here
  
  // Test 1: Check API connectivity
  print('Test 1: API Connectivity');
  await testApiConnectivity(apiKey);
  
  // Test 2: Test with small request
  print('\nTest 2: Small Request Test');
  await testSmallRequest(apiKey);
  
  // Test 3: Token usage estimation
  print('\nTest 3: Token Usage Estimation');
  estimateTokenUsage();
  
  print('\n✅ All tests complete!');
}

Future<void> testApiConnectivity(String apiKey) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {'role': 'user', 'content': 'Say "API OK" if you can read this.'}
        ],
        'max_tokens': 10,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data['choices'][0]['message']['content'];
      print('  ✅ API Connected: $message');
    } else {
      print('  ❌ API Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('  ❌ Connection failed: $e');
  }
}

Future<void> testSmallRequest(String apiKey) async {
  try {
    // Create a tiny 1x1 red pixel image
    final tinyImage = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';
    
    print('  Testing with 1x1 pixel image...');
    
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'What color is this? Reply in 3 words max.'},
              {'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,$tinyImage'}}
            ]
          }
        ],
        'max_tokens': 50,
      }),
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['choices'][0]['message']['content'];
      final usage = data['usage'];
      print('  ✅ Vision API works!');
      print('  📝 Response: $result');
      print('  📊 Tokens: ${usage['total_tokens']} (prompt: ${usage['prompt_tokens']}, completion: ${usage['completion_tokens']})');
    } else {
      final errorMsg = response.body.length > 300 ? response.body.substring(0, 300) + '...' : response.body;
      print('  ❌ Error ${response.statusCode}: $errorMsg');
    }
  } catch (e) {
    print('  ❌ Test failed: $e');
  }
}

void estimateTokenUsage() {
  print('  📏 Estimated token usage per request:');
  print('  ');
  print('  Image Analysis Request:');
  print('    - Prompt text: ~150 tokens');
  print('    - Image (500KB @ 800x600): ~2,000-3,000 tokens');
  print('    - Response (max_tokens: 800): ~300-800 tokens');
  print('    - Total: ~2,450-3,950 tokens');
  print('  ');
  print('  Health Scoring Request:');
  print('    - Prompt text: ~100 tokens');
  print('    - Response (max_tokens: 150): ~50-150 tokens');
  print('    - Total: ~150-250 tokens');
  print('  ');
  print('  Combined Analysis: ~2,600-4,200 tokens per image');
  print('  Rate Limit: 12,000 TPM (tokens per minute)');
  print('  Safe Requests/min: 2-3 analyses');
}
