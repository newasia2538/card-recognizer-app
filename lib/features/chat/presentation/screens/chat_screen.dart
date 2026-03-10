import 'package:card_recognizer/core/constants/app_constants.dart';
import 'package:card_recognizer/features/chat/presentation/controllers/chat_notifier.dart';
import 'package:card_recognizer/features/chat/presentation/providers/chat_provider.dart';
import 'package:card_recognizer/features/chat/presentation/widgets/message_bubble.dart';
import 'package:card_recognizer/features/chat/presentation/widgets/message_input.dart';
import 'package:card_recognizer/features/chat/presentation/widgets/quick_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openBuyNow(String cardName) async {
    final encodedName = Uri.encodeComponent(cardName);
    final ebayUrl = 'https://www.ebay.com/sch/i.html?_nkw=$encodedName';

    final uri = Uri.parse(ebayUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open browser')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    if (chatState.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  chatState.isLoading
                      ? AppConstants.aiThinkingMessage
                      : AppConstants.aiOnlineMessage,
                  style: TextStyle(
                    color:
                        chatState.isLoading
                            ? const Color(0xFFFFAB40)
                            : const Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            key: const Key(AppConstants.menuButtonKey),
            icon: Icon(Icons.more_vert, color: Colors.grey[400]),
            color: const Color(0xFF1E1E2E),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmation(context, chatNotifier);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppConstants.clearHistory,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child:
                chatState.messages.isEmpty
                    ? _buildEmptyState(chatNotifier)
                    : ListView.builder(
                      key: const Key(AppConstants.chatListKey),
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount:
                          chatState.messages.length +
                          (chatState.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatState.messages.length) {
                          return _buildTypingIndicator();
                        }

                        final message = chatState.messages[index];
                        return MessageBubble(
                          message: message,
                          onPriceButtonPressed:
                              message.showPriceButton &&
                                      message.cardName != null
                                  ? () => chatNotifier.askLastSoldPrice(
                                    message.cardName!,
                                  )
                                  : null,
                          onBuyButtonPressed:
                              message.showBuyButton && message.cardName != null
                                  ? () => _openBuyNow(message.cardName ?? '')
                                  : null,
                        );
                      },
                    ),
          ),
          // Input bar
          MessageInput(
            isLoading: chatState.isLoading,
            onSendText: (text) => chatNotifier.sendTextMessage(text),
            onCameraPressed: () => chatNotifier.pickImageFromCamera(context),
            onGalleryPressed: () => chatNotifier.pickImageFromGallery(context),
            onPasteImage:
                (bytes) => chatNotifier.pasteImageFromClipboard(bytes),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ChatNotifier chatNotifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.style, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo or paste an image of any\ntrading card to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              QuickAction(
                icon: Icons.camera_alt,
                label: AppConstants.camera,
                color: const Color(0xFF2D9CDB),
                action: () => chatNotifier.pickImageFromCamera(context),
              ),
              QuickAction(
                icon: Icons.photo_library,
                label: AppConstants.gallery,
                color: const Color(0xFF6C63FF),
                action: () => chatNotifier.pickImageFromGallery(context),
              ),
              QuickAction(
                icon: Icons.content_paste,
                label: AppConstants.paste,
                color: const Color(0xFFFF9800),
                action: () async {
                  final imageByte = await Pasteboard.image;
                  if (imageByte != null) {
                    await chatNotifier.pasteImageFromClipboard(imageByte);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No image in clipboard')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI is thinking...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, ChatNotifier chatNotifier) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Clear History',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to clear all chat history?',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              TextButton(
                key: const Key(AppConstants.confirmClearButtonKey),
                onPressed: () {
                  chatNotifier.clearChatHistory();
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }
}
