import 'package:flutter/material.dart';
import 'package:medicare_app/services/groq_AI.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final GroqApiService _apiService = GroqApiService(
    apiKey: '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',
  );
  bool _isTyping = false;

  final List<String> _quickQuestions = [
    "What are common cold symptoms?",
    "How much water should I drink daily?",
    "How to reduce stress naturally?",
    "Signs I should see a doctor for fever?"
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    _textController.clear();

    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(
        text: text,
        isUser: true,
      ));
      _isTyping = true;
    });

    try {
      final response = await _apiService.generateResponse(text);

      setState(() {
        _isTyping = false;
        _messages.insert(0, ChatMessage(
          text: response,
          isUser: false,
        ));
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.insert(0, ChatMessage(
          text: "Sorry, I encountered an error. Please try again later.",
          isUser: false,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Assistant'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          
          // Typing indicator
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("Medical assistant is typing..."),
                ],
              ),
            ),
            
          const Divider(height: 1.0),
          
          // Quick questions section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Suggested questions:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          
          // Quick question chips with better spacing
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickQuestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                    label: Text(
                      _quickQuestions[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _handleSubmitted(_quickQuestions[index]),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Text composer with improved styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                )
              ],
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration(
                hintText: 'Ask a medical question',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 12.0),
              child: const CircleAvatar(
                child: Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 20,
                ),
                backgroundColor: Colors.green,
                radius: 16,
              ),
            ),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue.shade100 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isUser ? Colors.blue.shade200 : Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.black87 : Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                  child: Text(
                    isUser ? 'You' : 'Medical Assistant',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 12.0),
              child: const CircleAvatar(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
                backgroundColor: Colors.blue,
                radius: 16,
              ),
            ),
        ],
      ),
    );
  }
}