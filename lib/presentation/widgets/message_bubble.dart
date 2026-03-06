import 'dart:io';
import 'package:card_recognizer/features/card_recognition/domain/entities/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onPriceButtonPressed;
  final VoidCallback? onBuyButtonPressed;

  const MessageBubble({
    super.key,
    required this.message,
    this.onPriceButtonPressed,
    this.onBuyButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        margin: EdgeInsets.only(
          left: isUser ? 48 : 12,
          right: isUser ? 12 : 48,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ── Avatar + name row ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 2.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUser) ...[
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Card AI',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (isUser) ...[
                    Text(
                      'You',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D9CDB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Bubble ───────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color:
                    isUser
                        ? const Color(0xFF2D9CDB).withValues(alpha: 0.15)
                        : const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color:
                      isUser
                          ? const Color(0xFF2D9CDB).withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image preview
                    if (message.imagePath != null)
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: Image.file(
                          File(message.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 100,
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              ),
                        ),
                      ),

                    // Text content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.grey[200],
                          fontSize: 14.5,
                          height: 1.45,
                        ),
                      ),
                    ),

                    // Action buttons
                    if (message.showPriceButton || message.showBuyButton)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 10,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (message.showPriceButton)
                              _ActionButton(
                                key: const Key('price_button'),
                                icon: Icons.attach_money,
                                label: 'Last Sold Price',
                                gradient: const [
                                  Color(0xFFFF9800),
                                  Color(0xFFF44336),
                                ],
                                onPressed: onPriceButtonPressed,
                              ),
                            if (message.showBuyButton)
                              _ActionButton(
                                key: const Key('buy_button'),
                                icon: Icons.shopping_cart,
                                label: 'Buy Now',
                                gradient: const [
                                  Color(0xFF4CAF50),
                                  Color(0xFF2196F3),
                                ],
                                onPressed: onBuyButtonPressed,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Timestamp ────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onPressed;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.gradient,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
