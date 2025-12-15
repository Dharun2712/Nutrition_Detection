/// AI Nutrition Assistant - Chat with Gemini AI for personalized advice
library;

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIChatbotPage extends StatefulWidget {
  final Set<String> deficientNutrients;

  const AIChatbotPage({
    super.key,
    this.deficientNutrients = const {},
  });

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isLoading = false;
  
  // GROQ API Configuration - ONLY used for chatbot, NOT for image analysis
  // Image analysis uses HuggingFace ResNet-50 model (see main.dart HuggingFaceService)
  String _provider = 'groq'; // 'gemini' or 'groq'
  static const String _groqApiKey = ''; // TODO: Add your GROQ API key here or use environment variables

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeAI();
    _sendWelcomeMessage();
  }

  Future<String> _sendMessageViaGroq(String userMessage) async {
    try {
      // Prepare nutrition doctor system prompt
      final deficienciesContext = widget.deficientNutrients.isNotEmpty
          ? 'The patient has detected deficiencies in: ${widget.deficientNutrients.join(", ")}. '
          : '';

      final systemPrompt = '''You are Dr. NutriAssist, a professional nutrition and diet doctor with expertise in:
- Nutritional deficiency diagnosis and treatment
- Personalized diet planning
- Vitamin and mineral supplementation
- Food-based therapeutic interventions
- Metabolic health optimization

$deficienciesContext

Your responses must:
• Be clear, concise, and scientifically accurate
• Use bullet points (•) for recommendations and lists
• Structure information with new lines for readability
• Provide actionable dietary advice
• Include specific food sources when recommending nutrients
• Use emojis appropriately (🥗🍊🥛💊) to enhance clarity
• Keep responses under 300 words unless detailed explanation is needed

Always prioritize patient safety and recommend consulting healthcare providers for serious concerns.''';

      // Use actual GROQ Chat Completion API endpoint
      final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      
      final body = {
        'model': 'llama-3.3-70b-versatile', // GROQ's fastest and most efficient model
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage}
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
        'top_p': 0.95,
        'stream': false,
      };

      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map && 
            decoded.containsKey('choices') && 
            decoded['choices'] is List && 
            decoded['choices'].isNotEmpty) {
          final message = decoded['choices'][0]['message'];
          if (message is Map && message.containsKey('content')) {
            return _formatResponse(message['content']);
          }
        }
        return '❌ Unexpected response format from GROQ API';
      } else {
        return '❌ GROQ API request failed: ${resp.statusCode} ${resp.reasonPhrase}\n${resp.body}';
      }
    } catch (e) {
      return '❌ Error calling GROQ API: ${e.toString()}';
    }
  }

  // Format response with proper line breaks and bullet points
  String _formatResponse(String response) {
    // Ensure bullet points are on new lines
    String formatted = response
        .replaceAll('. •', '.\n•')
        .replaceAll(': •', ':\n•')
        .replaceAll('\n\n\n', '\n\n')
        .replaceAll('• ', '\n• ')
        .trim();
    
    // Add spacing after section headers (lines ending with :)
    formatted = formatted.replaceAllMapped(
      RegExp(r'([^\n]):\n([^•\n])', multiLine: true),
      (match) => '${match.group(1)}:\n\n${match.group(2)}',
    );
    
    return formatted;
  }

  void _initializeAI() {
  // Initialize Gemini AI model
  // NOTE: API key inserted from user input. Keep this secure and do not commit to public repos.
  const apiKey = 'AIzaSyBRlIUT10Evv28wxUidA2lrJdw4C39sy-k';
    
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      ],
    );

    // Create context-aware system prompt
    final systemPrompt = '''You are a professional nutritionist AI assistant. 
The user has the following nutritional deficiencies: ${widget.deficientNutrients.join(', ')}.

Your role is to:
1. Provide personalized nutrition advice
2. Suggest specific foods to address their deficiencies
3. Create meal plans based on their dietary needs
4. Answer questions about nutrition, vitamins, and minerals
5. Explain symptoms and benefits clearly

Be concise, friendly, and always prioritize the user's health. Use emojis appropriately to make conversations engaging.''';

    _chat = _model.startChat(history: [
      Content.text(systemPrompt),
      Content.model([TextPart('I understand. I\'m here to help with personalized nutrition advice!')]),
    ]);
  }

  // Load stored settings (provider, API keys)
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final provider = prefs.getString('ai_provider');
      if (provider != null && provider.isNotEmpty) {
        setState(() {
          _provider = provider;
        });
      }
    } catch (_) {
      // ignore
    }
  }

  void _sendWelcomeMessage() {
    final deficienciesText = widget.deficientNutrients.isNotEmpty
        ? '\n\n🔬 **Your Detected Deficiencies:**\n${widget.deficientNutrients.map((n) => '• $n').join('\n')}\n'
        : '';

    setState(() {
      _messages.add(ChatMessage(
        text: '👨‍⚕️ **Welcome to Dr. NutriAssist**\n\n'
            'I\'m your AI nutrition and diet doctor, here to provide personalized recommendations based on scientific evidence.'
            '$deficienciesText'
            '\n💡 **I can help you with:**\n'
            '• Personalized diet plans for your deficiencies\n'
            '• Food recommendations and meal ideas\n'
            '• Understanding vitamin and mineral benefits\n'
            '• Symptom management through nutrition\n'
            '• Supplement guidance\n'
            '\n📝 Ask me anything about nutrition and health!',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // If provider is Groq, attempt Groq call
      if (_provider == 'groq') {
        final groqResp = await _sendMessageViaGroq(text);
        setState(() {
          _messages.add(ChatMessage(
            text: groqResp,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });

        _scrollToBottom();
        return;
      }

      // Send message to Gemini
      final response = await _chat.sendMessage(Content.text(text));

      setState(() {
        _messages.add(ChatMessage(
          text: response.text ?? 'Sorry, I couldn\'t generate a response.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '❌ Error: ${e.toString()}\n\n'
              'Note: Please add your Gemini API key in the code to enable AI features.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Nutrition Assistant'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _initializeAI();
                _sendWelcomeMessage();
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'settings') {
                await showDialog(
                  context: context,
                  builder: (context) => _buildSettingsDialog(context),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Action Buttons
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.indigo[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionButton(
                    '🍽️ Meal Plan',
                    'Create a 7-day meal plan for my deficiencies',
                  ),
                  _buildQuickActionButton(
                    '🥗 Food Suggestions',
                    'What foods should I eat for my deficiencies?',
                  ),
                  _buildQuickActionButton(
                    '📋 Shopping List',
                    'Create a shopping list for nutrient-rich foods',
                  ),
                  _buildQuickActionButton(
                    '👨‍🍳 Recipe',
                    'Suggest a healthy recipe',
                  ),
                ],
              ),
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.indigo[400],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about nutrition...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _sendMessage(_messageController.text),
                  backgroundColor: Colors.indigo,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, String message) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () => _sendMessage(message),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? LinearGradient(
                        colors: [Colors.indigo[400]!, Colors.indigo[600]!],
                      )
                    : null,
                color: message.isUser ? null : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: message.isUser ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsDialog(BuildContext context) {
    final TextEditingController _groqController = TextEditingController();
    return AlertDialog(
      title: const Text('AI Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Provider:'),
              const SizedBox(width: 12),
              FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final prefs = snap.data!;
                  final provider = prefs.getString('ai_provider') ?? _provider;
                  return DropdownButton<String>(
                    value: provider,
                    items: const [
                      DropdownMenuItem(value: 'gemini', child: Text('Gemini')),
                      DropdownMenuItem(value: 'groq', child: Text('Groq')),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      await prefs.setString('ai_provider', v);
                      setState(() {
                        _provider = v;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              final prefs = snap.data!;
              _groqController.text = prefs.getString('groq_api_key') ?? '';
              return TextField(
                controller: _groqController,
                decoration: const InputDecoration(
                  labelText: 'Groq API Key',
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('groq_api_key', _groqController.text.trim());
            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings saved')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
