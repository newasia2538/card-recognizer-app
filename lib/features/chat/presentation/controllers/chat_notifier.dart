import 'dart:io';

import 'package:card_recognizer/core/constants/app_constants.dart';
import 'package:card_recognizer/core/services/permission_service.dart';
import 'package:card_recognizer/features/card_recognition/domain/entities/chat_message.dart';
import 'package:card_recognizer/features/chat/domain/repositories/ai_repository.dart';
import 'package:card_recognizer/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final AiRepository _aiRepository;
  final Uuid _uuid = const Uuid();

  ChatNotifier({
    required ChatRepository chatRepository,
    required AiRepository aiRepository,
  }) : _chatRepository = chatRepository,
       _aiRepository = aiRepository,
       super(const ChatState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      state = state.copyWith(isLoading: true);
      final messages = await _chatRepository.loadChatHistory();
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load history: $e',
        isLoading: false,
      );
    }
  }

  Future<void> clearChatHistory() async {
    try {
      state = state.copyWith(isLoading: true);
      await _chatRepository.clearChatHistory();
      state = state.copyWith(messages: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to clear history: $e',
        isLoading: false,
      );
    }
  }

  Future<void> sendImage(Uint8List imageBytes, {String? imagePath}) async {
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: '📷 Sent an image for identification',
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      imagePath: imagePath,
      type: MessageType.image,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );
    await _chatRepository.saveChatMessage(userMessage);

    try {
      final response = await _aiRepository.identifyCard(imageBytes);

      // Try to extract card name from response (first line usually)
      final cardName = _extractCardName(response);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        text: response,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        type: MessageType.card,
        cardName: cardName,
        showPriceButton: true,
        showBuyButton: true,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
        lastIdentifiedCard: cardName,
      );
      await _chatRepository.saveChatMessage(aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'Error identifying card: $e',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
      await _chatRepository.saveChatMessage(errorMessage);
    }
  }

  Future<void> askLastSoldPrice(String cardName) async {
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: '💰 Ask the last sold price of "$cardName"',
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );
    await _chatRepository.saveChatMessage(userMessage);

    try {
      final response = await _aiRepository.getLastSoldPrice(cardName);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        text: response,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        cardName: cardName,
        showBuyButton: true,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
      await _chatRepository.saveChatMessage(aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'Error fetching price: $e',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
      await _chatRepository.saveChatMessage(errorMessage);
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );
    await _chatRepository.saveChatMessage(userMessage);

    try {
      final response = await _aiRepository.chat(text);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        text: response,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
      await _chatRepository.saveChatMessage(aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'Error: $e',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
      await _chatRepository.saveChatMessage(errorMessage);
    }
  }

  Future<void> pickImageFromCamera(BuildContext context) async {
    final hasPermission = await PermissionService.requestCamera(context);
    if (!hasPermission) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      await sendImage(bytes, imagePath: image.path);
    }
  }

  Future<void> pickImageFromGallery(BuildContext context) async {
    final hasPermission = await PermissionService.requestGallery(context);
    if (!hasPermission) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      await sendImage(bytes, imagePath: image.path);
    }
  }

  Future<void> pasteImageFromClipboard(Uint8List imageBytes) async {
    await sendImage(imageBytes);
  }

  String _extractCardName(String response) {
    final lines = response.split('\n').where((l) => l.trim().isNotEmpty);
    if (lines.isEmpty) return AppConstants.unknowCard;

    String cardNameLines = lines.firstWhere(
      (s) => s.contains("Card Name"),
      orElse: () => '',
    );
    if (cardNameLines.isEmpty) return AppConstants.unknowCard;

    String cardName = cardNameLines.split(':').last.trim();
    if (cardName.isEmpty) return AppConstants.unknowCard;

    cardName = cardName.replaceAll(RegExp(r'[#*_,]'), '').trim();

    String playerNameLines = lines.firstWhere(
      (s) => s.contains("Player"),
      orElse: () => '',
    );
    if (playerNameLines.isEmpty) return cardName;

    String playerName = playerNameLines.split(':').last.trim();
    if (playerName.isEmpty) {
      return '$cardName - $playerName'.replaceAll(RegExp(r'[#*_,]'), '').trim();
    }

    String setLines = lines.firstWhere(
      (s) => s.contains("Set"),
      orElse: () => '',
    );
    if (setLines.isEmpty) {
      return '$cardName - $playerName'.replaceAll(RegExp(r'[#*_,]'), '').trim();
    }

    String setName = setLines.split(':').last.trim();
    if (setName.isEmpty) return cardName;

    return '$playerName - $setName'.replaceAll(RegExp(r'[#*_,]'), '').trim();
  }
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final String? error;
  final String? lastIdentifiedCard;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.error,
    this.lastIdentifiedCard,
  });

  ChatState.initial()
    : messages = [],
      isLoading = false,
      errorMessage = null,
      error = null,
      lastIdentifiedCard = null;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    String? error,
    String? lastIdentifiedCard,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
      lastIdentifiedCard: lastIdentifiedCard ?? this.lastIdentifiedCard,
    );
  }
}
