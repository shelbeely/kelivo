// Generative UI Demo Page
//
// This page demonstrates the generative UI feature by:
// 1. Gathering real app data (user info, chat counts, etc.)
// 2. Calling the LLM to generate a UI specification
// 3. Rendering it via the GenerativeScreen widget
// 4. Handling button actions to update the UI
//
// See docs/generative-ui-notes.md for full documentation.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/chat_provider.dart';
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
  Screen? _currentScreen;
  bool _isLoading = false;
  String? _error;
  String? _streamingContent;

  @override
  void initState() {
    super.initState();
    // Generate initial screen on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateDashboard();
    });
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

  /// Generate a dashboard screen
  Future<void> _generateDashboard() async {
    final settings = context.read<SettingsProvider>();

    // Check if we have a configured model
    final providerKey = settings.currentModelProvider;
    final modelId = settings.currentModelId;

    if (providerKey == null || modelId == null) {
      // Fall back to sample screen if no model is configured
      setState(() {
        _currentScreen = _createFallbackScreen();
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _streamingContent = null;
    });

    try {
      final config = settings.getProviderConfig(providerKey);
      final service = GenerativeUIService(
        config: config,
        modelId: modelId,
      );

      final userContext = _buildUserContext();
      final appContext = _buildAppContext();

      // Use streaming for better UX
      await for (final progress in service.generateScreenStream(
        instruction: 'Generate a personalized dashboard for this AI chat application. '
            'Show the user\'s stats, recent activity, and quick actions. '
            'Make it feel welcoming and express the AI-powered nature of the app.',
        userContext: userContext,
        appContext: appContext,
        previousScreen: _currentScreen,
      )) {
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
              // Fall back to sample screen
              _currentScreen = _createFallbackScreen();
            });
            break;
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _streamingContent = null;
        // Fall back to sample screen
        _currentScreen = _createFallbackScreen();
      });
    }
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

  /// Handle actions from the generated UI
  void _handleAction(Map<String, dynamic> action) {
    final type = action['type'] as String?;

    switch (type) {
      case 'navigate':
        final screen = action['screen'] as String?;
        _handleNavigation(screen);
        break;
      case 'refresh':
        _generateDashboard();
        break;
      case 'open_settings':
        Navigator.of(context).pushNamed('/settings');
        break;
      case 'start_chat':
        Navigator.of(context).pop(); // Return to main screen to start chat
        break;
      default:
        // Show a snackbar for unhandled actions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action: ${action.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  /// Handle navigation actions
  void _handleNavigation(String? screen) {
    switch (screen) {
      case 'new_chat':
      case 'start_chat':
        Navigator.of(context).pop(); // Return to main chat screen
        break;
      case 'history':
        // Request a history-focused screen from the LLM
        _requestScreen(
          'Show a screen focused on conversation history. '
          'Display recent conversations with timestamps and brief summaries. '
          'Include options to search and filter.',
        );
        break;
      case 'assistants':
        // Request an assistants management screen
        _requestScreen(
          'Show a screen for managing AI assistants. '
          'Display available assistants with their descriptions and capabilities. '
          'Include options to create or configure assistants.',
        );
        break;
      case 'dashboard':
        _generateDashboard();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation to: $screen'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  /// Request a specific screen from the LLM
  Future<void> _requestScreen(String instruction) async {
    final settings = context.read<SettingsProvider>();
    final providerKey = settings.currentModelProvider;
    final modelId = settings.currentModelId;

    if (providerKey == null || modelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No AI model configured. Using static UI.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final config = settings.getProviderConfig(providerKey);
      final service = GenerativeUIService(
        config: config,
        modelId: modelId,
      );

      final userContext = _buildUserContext();
      final appContext = _buildAppContext();

      await for (final progress in service.generateScreenStream(
        instruction: instruction,
        userContext: userContext,
        appContext: appContext,
        previousScreen: _currentScreen,
      )) {
        switch (progress) {
          case _GenerativeUIComplete(:final screen):
            setState(() {
              _currentScreen = screen;
              _isLoading = false;
            });
            break;
          case _GenerativeUIError(:final message):
            setState(() {
              _error = message;
              _isLoading = false;
            });
            break;
          default:
            break;
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generative UI Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _generateDashboard,
            tooltip: 'Regenerate',
          ),
        ],
      ),
      body: _buildBody(),
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

    // Show error with fallback screen
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
                    'Using fallback UI. LLM error: $_error',
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
          Text('Preparing generative UI...'),
        ],
      ),
    );
  }
}
