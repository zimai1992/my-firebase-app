import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/gemini_service.dart';
import 'package:myapp/providers/medicine_provider.dart';
import 'package:myapp/services/subscription_service.dart';
import 'package:myapp/screens/paywall_screen.dart';

class PharmacistChatScreen extends StatefulWidget {
  const PharmacistChatScreen({super.key});

  @override
  State<PharmacistChatScreen> createState() => _PharmacistChatScreenState();
}

class _PharmacistChatScreenState extends State<PharmacistChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _gemini = GeminiService();
  bool _isLoading = false;
  int _questionsAsked = 0;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text:
          "Hello! I'm your AI pharmacist. Ask me anything about your medicines, interactions, side effects, or how to take them properly. 💊",
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final subscription = context.read<SubscriptionService>();

    if (!subscription.isPremium && _questionsAsked >= 3) {
      _showPremiumRequired();
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _questionsAsked++;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final medicines = context.read<MedicineProvider>().medicines;
      final response = await _gemini.askPharmacist(text, medicines);

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
              text: 'Sorry, I encountered an error. Please try again.',
              isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _showPremiumRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💎 Upgrade to Premium'),
        content: const Text(
            'Get unlimited AI pharmacist consultations, advanced drug analysis, and detailed health reports.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const PaywallScreen()));
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionService>();
    final remaining =
        subscription.isPremium ? 999 : (3 - _questionsAsked).clamp(0, 3);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Pharmacist'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: subscription.isPremium
                    ? Colors.amber.withOpacity(0.2)
                    : theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: subscription.isPremium
                        ? Colors.amber
                        : theme.primaryColor.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  subscription.isPremium ? 'PREMIUM' : '$remaining LEFT',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: subscription.isPremium
                          ? Colors.amber[900]
                          : theme.primaryColor,
                      letterSpacing: 1.1),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primaryColor.withOpacity(0.5)),
                  ),
                  const SizedBox(width: 12),
                  Text('Typing...',
                      style: TextStyle(
                          color: theme.primaryColor.withOpacity(0.5),
                          fontSize: 13,
                          fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser
              ? theme.primaryColor
              : (theme.brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : (theme.brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1E293B)),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
            top: BorderSide(color: theme.dividerColor.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Ask your pharmacist...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: theme.primaryColor,
            radius: 24,
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
