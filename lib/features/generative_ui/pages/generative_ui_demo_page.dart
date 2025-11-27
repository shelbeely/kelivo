// Generative UI Demo Page
//
// This page demonstrates the Cline-like generative UI feature:
// 1. Maintains a conversation session with the LLM
// 2. User interactions are sent back to the LLM as events
// 3. LLM responds with updated UI based on user actions
// 4. Creates an interactive, conversational UI experience
//
// See docs/generative-ui-notes.md for full documentation.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/assistant_provider.dart';
import '../../../core/services/chat/chat_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../generative_ui/schema.dart';
import '../../../generative_ui/renderer.dart';
import '../../../generative_ui/llm_service.dart';

class GenerativeUIDemoPage extends StatefulWidget {
  const GenerativeUIDemoPage({super.key});

  @override
  State<GenerativeUIDemoPage> createState() => _GenerativeUIDemoPageState();
}

class _GenerativeUIDemoPageState extends State<GenerativeUIDemoPage> {
  GenerativeUISession? _session;
  Screen? _currentScreen;
  bool _isLoading = false;
  String? _error;
  String? _streamingContent;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize session on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Get the device type for UI context
  String _getDeviceType() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        // Check for tablet based on screen size
        final size = MediaQuery.of(context).size;
        final isTablet = size.shortestSide >= 600;
        return isTablet ? 'tablet' : 'mobile';
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'desktop';
      default:
        return 'mobile';
    }
  }

  /// Build user context from current app state
  GenerativeUIUserContext _buildUserContext() {
    final settings = context.read<SettingsProvider>();
    final brightness = Theme.of(context).brightness;

    return GenerativeUIUserContext(
      deviceType: _getDeviceType(),
      isDarkMode: brightness == Brightness.dark,
      reducedMotion: MediaQuery.of(context).disableAnimations,
      locale: settings.appLocaleForMaterialApp?.languageCode,
    );
  }

  /// Build app context from real app data
  GenerativeUIAppContext _buildAppContext() {
    final userProvider = context.read<UserProvider>();
    final chatService = context.read<ChatService>();
    final assistantProvider = context.read<AssistantProvider>();

    // Get real data from the app
    final conversations = chatService.conversations;
    final assistants = assistantProvider.assistants;

    // Get recent topic titles (last 5)
    final recentTopics = conversations
        .take(5)
        .map((c) => c.title)
        .where((t) => t.isNotEmpty)
        .toList();

    return GenerativeUIAppContext(
      userName: userProvider.name.isNotEmpty ? userProvider.name : null,
      chatCount: conversations.length,
      assistantCount: assistants.length,
      recentTopics: recentTopics.isNotEmpty ? recentTopics : null,
    );
  }

  /// Initialize the conversation session
  Future<void> _initSession() async {
    final settings = context.read<SettingsProvider>();
    final providerKey = settings.currentModelProvider;
    final modelId = settings.currentModelId;

    if (providerKey == null || modelId == null) {
      // Fall back to sample screen if no model is configured
      setState(() {
        _currentScreen = _createFallbackScreen();
        _isLoading = false;
        _error = 'No AI model configured. Using static demo UI.';
      });
      return;
    }

    final config = settings.getProviderConfig(providerKey);
    final userContext = _buildUserContext();

    setState(() {
      _session = GenerativeUISession(
        config: config,
        modelId: modelId,
        userContext: userContext,
      );
    });

    // Start with a dashboard request
    await _sendMessage(
      'Generate a personalized dashboard for this AI chat application. '
      'Show the user\'s stats, recent activity, and quick actions. '
      'Make it feel welcoming and interactive. Include some form inputs '
      'and toggles so the user can interact with the UI.',
    );
  }

  /// Send a text message to the LLM
  Future<void> _sendMessage(String text) async {
    if (_session == null) {
      await _initSession();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _streamingContent = null;
    });

    try {
      final appContext = _buildAppContext();

      await for (final progress in _session!.sendMessage(
        text: text,
        appContext: appContext,
      )) {
        _handleProgress(progress);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        if (_currentScreen == null) {
          _currentScreen = _createFallbackScreen();
        }
      });
    }
  }

  /// Send a user interaction event to the LLM
  Future<void> _sendInteraction(Map<String, dynamic> action) async {
    if (_session == null) {
      // Handle locally if no session
      _handleLocalAction(action);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _streamingContent = null;
    });

    try {
      final event = UIInteractionEvent.fromAction(action);
      final appContext = _buildAppContext();

      await for (final progress in _session!.sendInteraction(
        event: event,
        appContext: appContext,
      )) {
        _handleProgress(progress);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Handle progress updates from LLM
  void _handleProgress(GenerativeUIProgress progress) {
    switch (progress) {
      case _GenerativeUILoading():
        // Already showing loading
        break;
      case _GenerativeUIStreaming(:final partialContent):
        setState(() {
          _streamingContent = partialContent;
        });
        break;
      case _GenerativeUIComplete(:final screen):
        setState(() {
          _currentScreen = screen;
          _isLoading = false;
          _streamingContent = null;
        });
        break;
      case _GenerativeUIError(:final message):
        setState(() {
          _error = message;
          _isLoading = false;
          _streamingContent = null;
          if (_currentScreen == null) {
            _currentScreen = _createFallbackScreen();
          }
        });
        break;
    }
  }

  /// Handle actions locally when no LLM session
  void _handleLocalAction(Map<String, dynamic> action) {
    final type = action['type'] as String?;

    switch (type) {
      case 'navigate':
        final screen = action['screen'] as String?;
        if (screen == 'new_chat') {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to: $screen')),
          );
        }
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action: ${action.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  /// Handle actions from the generated UI
  void _handleAction(Map<String, dynamic> action) {
    final type = action['type'] as String?;

    // Handle special navigation actions locally
    if (type == 'navigate') {
      final screen = action['screen'] as String?;
      if (screen == 'new_chat' || screen == 'start_chat') {
        Navigator.of(context).pop();
        return;
      }
    }

    // Send all other actions to the LLM
    _sendInteraction(action);
  }

  /// Create a fallback screen when LLM is not available
  Screen _createFallbackScreen() {
    final userProvider = context.read<UserProvider>();
    final chatService = context.read<ChatService>();
    final assistantProvider = context.read<AssistantProvider>();

    return createSampleDashboardScreen(
      userName: userProvider.name.isNotEmpty ? userProvider.name : null,
      chatCount: chatService.conversations.length,
      assistantCount: assistantProvider.assistants.length,
    );
  }

  /// Send a custom message from the input field
  void _submitMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _sendMessage(text);
  }

  /// Reset the conversation
  void _resetSession() {
    _session?.clearHistory();
    setState(() {
      _currentScreen = null;
      _error = null;
      _streamingContent = null;
    });
    _initSession();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generative UI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _resetSession,
            tooltip: 'Reset Conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: _buildBody(),
          ),

          // Message input at bottom (Cline-like)
          if (_session != null) _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask for UI changes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitMessage(),
                enabled: !_isLoading,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _isLoading ? null : _submitMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final cs = Theme.of(context).colorScheme;

    // Show streaming content while generating
    if (_isLoading && _streamingContent != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Generating UI...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _streamingContent!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show error banner with current screen
    if (_error != null) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.onErrorContainer, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: cs.onErrorContainer,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentScreen != null
                ? GenerativeScreen(
                    spec: _currentScreen!,
                    onAction: _handleAction,
                    reduceMotion: MediaQuery.of(context).disableAnimations,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    // Show the generated screen
    if (_currentScreen != null) {
      return GenerativeScreen(
        spec: _currentScreen!,
        onAction: _handleAction,
        isLoading: _isLoading,
        reduceMotion: MediaQuery.of(context).disableAnimations,
      );
    }

    // Initial loading state
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Starting generative UI session...'),
        ],
      ),
    );
  }
}
