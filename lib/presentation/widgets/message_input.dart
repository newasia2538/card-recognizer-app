import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';

class MessageInput extends StatefulWidget {
  final Function(String text) onSendText;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final Function(Uint8List imageBytes) onPasteImage;
  final bool isLoading;

  const MessageInput({
    super.key,
    required this.onSendText,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onPasteImage,
    this.isLoading = false,
  });

  @override
  State<MessageInput> createState() => MessageInputState();
}

class MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSendText(text);
    _controller.clear();
  }

  Future<void> _handlePaste() async {
    try {
      final data = await Clipboard.getData('text/plain');
      if (data?.text != null && data!.text!.isNotEmpty) {
        _controller.text = _controller.text + data.text!;
        setState(() {});
        return;
      }
    } catch (_) {}

    // Try to get image data from clipboard
    try {
      final imageByte = await Pasteboard.image;
      if (imageByte != null) {
        widget.onPasteImage(imageByte);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Camera button
              _InputIconButton(
                key: const Key('camera_button'),
                icon: Icons.camera_alt_rounded,
                tooltip: 'Take Photo',
                onPressed: widget.isLoading ? null : widget.onCameraPressed,
              ),

              // Gallery button
              _InputIconButton(
                key: const Key('gallery_button'),
                icon: Icons.photo_library_rounded,
                tooltip: 'Gallery',
                onPressed: widget.isLoading ? null : widget.onGalleryPressed,
              ),

              // Paste button
              _InputIconButton(
                key: const Key('paste_button'),
                icon: Icons.content_paste_rounded,
                tooltip: 'Paste',
                onPressed: widget.isLoading ? null : _handlePaste,
              ),

              const SizedBox(width: 4),

              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: TextField(
                    key: const Key('message_input'),
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !widget.isLoading,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Ask about a card...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Send button
              Container(
                decoration: BoxDecoration(
                  gradient:
                      _controller.text.trim().isNotEmpty && !widget.isLoading
                          ? const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                          )
                          : null,
                  color:
                      _controller.text.trim().isEmpty || widget.isLoading
                          ? Colors.grey[800]
                          : null,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  key: const Key('send_button'),
                  icon:
                      widget.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send_rounded),
                  color: Colors.white,
                  iconSize: 20,
                  onPressed: widget.isLoading ? null : _handleSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _InputIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      color: onPressed != null ? Colors.grey[400] : Colors.grey[700],
      iconSize: 22,
      splashRadius: 20,
      onPressed: onPressed,
    );
  }
}
