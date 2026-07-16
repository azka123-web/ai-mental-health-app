import 'package:flutter/material.dart'; // Flutter UI components
import 'services/chat_service.dart'; // backend/chat API service

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key}); // constructor

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  // user input control karne ke liye

  final ChatService chatService = ChatService();
  // AI backend service call karne ke liye

  final List<Map<String, String>> _messages = [];
  // chat messages store (user + bot)

  List<String> symptoms = [];
  // user ke symptoms collect karne ke liye

  bool isLoading = false;
  // loading indicator show karne ke liye

  bool sessionFinished = false;
  // jab analysis complete ho jaye to input disable

  static const Color lightNavyBlue = Color(0xFF1D3557);
  // custom theme color

  @override
  void initState() {
    super.initState();
    _resetToInitialState();
    // screen start hote hi chat reset
  }

  void _resetToInitialState() {
    setState(() {
      _messages.clear(); // purani messages delete
      symptoms.clear(); // symptoms reset
      sessionFinished = false; // session active
      isLoading = false; // loading off

      _messages.add({
        'role': 'bot',
        'text': "Hello! I am MindEase+ AI. I'm here to listen. Please describe how you've been feeling lately (e.g., 'I feel tired and can't sleep')."
        // initial bot greeting message
      });
    });
  }

  void _showResetConfirmation() {
    // reset confirmation dialog show karna
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Start New Session?"),
          content: const Text("This will clear your current conversation and analysis."),
          actions: [

            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(), // dialog close
            ),

            TextButton(
              child: const Text("Reset", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // dialog close
                _resetToInitialState(); // chat reset
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    String text = _controller.text.trim();
    // user input

    if (text.isEmpty || sessionFinished) return;
    // empty ya session finished ho to ignore

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      // user message add

      _controller.clear();
      // input clear
    });

    String lowerText = text.toLowerCase();
    // lowercase conversion for matching

    // ---------------- GREETING CHECK ----------------
    if (lowerText == "hi" || lowerText == "hello" || lowerText == "hey") {
      _addBotMessage("Hi there! How can I help you today? Please tell me about any symptoms or feelings you are experiencing.");
      return;
    }

    // ---------------- END SESSION CHECK ----------------
    if (lowerText == "no" || lowerText == "none" || lowerText == "that is all" || lowerText == "that's it") {
      if (symptoms.isEmpty) {
        _addBotMessage("I haven't recorded any symptoms yet. Please tell me how you feel before we proceed.");
      } else {
        _analyzeSymptoms(); // AI analysis start
      }
      return;
    }

    symptoms.add(text);
    // symptom list me add

    // ---------------- AUTO ANALYSIS TRIGGER ----------------
    if (lowerText.contains(" and that's all") || lowerText.contains(" no more")) {
      _analyzeSymptoms();
    } else {
      setState(() => isLoading = true); // loading start

      await Future.delayed(const Duration(milliseconds: 1000));
      // fake delay (typing effect)

      setState(() => isLoading = false); // loading stop

      _addBotMessage("I've noted that. Are there any other physical or emotional symptoms? (Type 'No' to get your analysis).");
    }
  }

  Future<void> _analyzeSymptoms() async {
    setState(() => isLoading = true); // loading start

    String combinedSymptoms = symptoms.join(". ");
    // symptoms combine into one string

    try {
      String reply = await chatService.sendMessage(combinedSymptoms);
      // AI model call

      String formattedReply = reply
          .replaceAll('disease:', 'Disease:')
          .replaceAll('severity:', 'Severity:')
          .replaceAll('suggestion:', 'Suggestion:');
      // formatting labels

      setState(() {
        isLoading = false;
        _messages.add({'role': 'bot', 'text': formattedReply});
        // bot response add

        sessionFinished = true;
        // session lock
      });

    } catch (e) {
      setState(() => isLoading = false);

      // 🔥 DEBUG PRINT (IMPORTANT)
      print("❌ API CONNECTION ERROR: $e");

      // user-friendly message
      _addBotMessage(
        "Connection failed. Please check server or network.\nError: $e",
      );
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'role': 'bot', 'text': text});
      // bot message add function
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightNavyBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "MindEase+ AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "New Session",
            onPressed: _showResetConfirmation,
          ),
        ],
      ),

      body: Container(
        color: const Color(0xFFF1F4F8),

        child: Column(
          children: [

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,

                itemBuilder: (_, i) {
                  final msg = _messages[i];
                  final isUser = msg['role'] == 'user';

                  final isAnalysis = !isUser && msg['text']!.contains("Disease:");
                  // check analysis message

                  return _buildChatBubble(msg['text']!, isUser, isAnalysis);
                },
              ),
            ),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CircularProgressIndicator(color: lightNavyBlue),
              ),

            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser, bool isAnalysis) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      // user right side, bot left side

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),

        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),

        decoration: BoxDecoration(
          color: isUser ? lightNavyBlue : Colors.white,
          // user = blue, bot = white

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(18),
          ),
        ),

        child: isAnalysis
            ? RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
            children: _buildFormattedText(text),
          ),
        )
            : Text(
          text,
          textAlign: isUser ? TextAlign.left : TextAlign.justify,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildFormattedText(String text) {
    List<TextSpan> spans = [];

    spans.add(const TextSpan(
      text: "Based on our conversation:\n\n",
      style: TextStyle(fontWeight: FontWeight.bold),
    ));

    final labels = ["Disease:", "Severity:", "Suggestion:"];

    text.split(' ').forEach((word) {
      bool isLabel = labels.any((label) => word.startsWith(label));

      if (isLabel) {
        spans.add(TextSpan(
          text: "$word ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else {
        spans.add(TextSpan(text: "$word "));
      }
    });

    spans.add(const TextSpan(text: "\n\n"));
    spans.add(const TextSpan(
      text: "Note: ",
      style: TextStyle(fontWeight: FontWeight.bold),
    ));

    spans.add(const TextSpan(
      text:
      "This is an AI-generated assessment for preliminary screening. It is not a clinical diagnosis. If you are in immediate distress, please contact emergency services or a mental health professional.",
    ));

    return spans;
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 25),

      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),

      child: Row(
        children: [

          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !sessionFinished,

              onSubmitted: (_) => _sendMessage(),

              decoration: InputDecoration(
                hintText: sessionFinished ? "Session Locked" : "Type your feelings...",
                filled: true,
                fillColor: const Color(0xFFF1F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: sessionFinished ? null : _sendMessage,

            child: CircleAvatar(
              radius: 24,
              backgroundColor: sessionFinished ? Colors.grey : lightNavyBlue,
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}