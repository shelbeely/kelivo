// Generative UI Renderer
//
// This file implements the Material Design 3 Expressive renderer that transforms
// Screen/Block schema objects into Flutter widgets.
//
// Key responsibilities:
// - Map expressive metadata (emphasis, surface, motion) to M3 design tokens
// - Handle button actions via onAction callback
// - Respect reduced motion settings
// - Apply consistent styling across all block types
//
// See docs/generative-ui-notes.md for full documentation.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'schema.dart';

// ===========================================================================
// Token Mappings
// ===========================================================================

/// Get border radius based on emphasis level
double _radiusForEmphasis(Emphasis? emphasis) {
  switch (emphasis) {
    case Emphasis.hero:
      return 28;
    case Emphasis.primary:
      return 20;
    case Emphasis.secondary:
      return 16;
    case Emphasis.tertiary:
      return 12;
    case null:
      return 16;
  }
}

/// Get elevation based on emphasis level
double _elevationForEmphasis(Emphasis? emphasis) {
  switch (emphasis) {
    case Emphasis.hero:
      return 0;
    case Emphasis.primary:
      return 2;
    case Emphasis.secondary:
      return 1;
    case Emphasis.tertiary:
      return 0;
    case null:
      return 1;
  }
}

/// Get padding based on emphasis level
EdgeInsets _paddingForEmphasis(Emphasis? emphasis) {
  switch (emphasis) {
    case Emphasis.hero:
      return const EdgeInsets.all(24);
    case Emphasis.primary:
      return const EdgeInsets.all(20);
    case Emphasis.secondary:
      return const EdgeInsets.all(16);
    case Emphasis.tertiary:
      return const EdgeInsets.all(12);
    case null:
      return const EdgeInsets.all(16);
  }
}

/// Get text style for hero headline based on emphasis
TextStyle _headlineStyleForEmphasis(BuildContext context, Emphasis? emphasis) {
  final theme = Theme.of(context);
  switch (emphasis) {
    case Emphasis.hero:
      return theme.textTheme.displayMedium ?? const TextStyle(fontSize: 45);
    case Emphasis.primary:
      return theme.textTheme.headlineSmall ?? const TextStyle(fontSize: 24);
    case Emphasis.secondary:
      return theme.textTheme.titleMedium ?? const TextStyle(fontSize: 16);
    case Emphasis.tertiary:
      return theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    case null:
      return theme.textTheme.titleLarge ?? const TextStyle(fontSize: 22);
  }
}

/// Get background color based on surface type
Color _backgroundForSurface(BuildContext context, Surface? surface) {
  final cs = Theme.of(context).colorScheme;
  switch (surface) {
    case Surface.surface:
      return cs.surface;
    case Surface.surfaceVariant:
      return cs.surfaceContainerHighest;
    case Surface.primary:
      return cs.primaryContainer;
    case Surface.secondary:
      return cs.secondaryContainer;
    case Surface.tertiary:
      return cs.tertiaryContainer;
    case null:
      return cs.surface;
  }
}

/// Get foreground (text) color based on surface type
Color _foregroundForSurface(BuildContext context, Surface? surface) {
  final cs = Theme.of(context).colorScheme;
  switch (surface) {
    case Surface.surface:
      return cs.onSurface;
    case Surface.surfaceVariant:
      return cs.onSurfaceVariant;
    case Surface.primary:
      return cs.onPrimaryContainer;
    case Surface.secondary:
      return cs.onSecondaryContainer;
    case Surface.tertiary:
      return cs.onTertiaryContainer;
    case null:
      return cs.onSurface;
  }
}

/// Get animation duration based on motion type
Duration _durationForMotion(Motion? motion, MotionScheme? screenMotion) {
  final effective = motion ?? _motionFromScheme(screenMotion);
  switch (effective) {
    case Motion.expressive:
      return const Duration(milliseconds: 400);
    case Motion.standard:
      return const Duration(milliseconds: 250);
    case Motion.reduced:
      return const Duration(milliseconds: 100);
    case null:
      return const Duration(milliseconds: 250);
  }
}

/// Get animation curve based on motion type
Curve _curveForMotion(Motion? motion, MotionScheme? screenMotion) {
  final effective = motion ?? _motionFromScheme(screenMotion);
  switch (effective) {
    case Motion.expressive:
      return Curves.easeOutBack;
    case Motion.standard:
      return Curves.easeInOut;
    case Motion.reduced:
      return Curves.linear;
    case null:
      return Curves.easeInOut;
  }
}

/// Convert screen motion scheme to block motion
Motion? _motionFromScheme(MotionScheme? scheme) {
  switch (scheme) {
    case MotionScheme.expressive:
      return Motion.expressive;
    case MotionScheme.standard:
      return Motion.standard;
    case MotionScheme.reduced:
      return Motion.reduced;
    case null:
      return null;
  }
}

// ===========================================================================
// Main Renderer Widget
// ===========================================================================

/// Renders a generative UI Screen specification
class GenerativeScreen extends StatelessWidget {
  final Screen spec;
  final void Function(Map<String, dynamic> action)? onAction;
  final bool isLoading;
  final String? error;
  final bool reduceMotion;

  const GenerativeScreen({
    super.key,
    required this.spec,
    this.onAction,
    this.isLoading = false,
    this.error,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating UI...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error generating UI',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final effectiveMotion = reduceMotion ? MotionScheme.reduced : spec.motionScheme;

    // Separate edge-hugging buttons from other content
    final List<Block> contentBlocks = [];
    final List<ButtonBlock> edgeHuggingButtons = [];

    for (final block in spec.blocks) {
      if (block is ButtonBlock && block.layout == ButtonLayout.edgeHugging) {
        edgeHuggingButtons.add(block);
      } else {
        contentBlocks.add(block);
      }
    }

    return SafeArea(
      child: Column(
        children: [
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < contentBlocks.length; i++) ...[
                    _BlockRenderer(
                      block: contentBlocks[i],
                      screenMotion: effectiveMotion,
                      onAction: onAction,
                      animationDelay: Duration(milliseconds: 50 * i),
                    ),
                    if (i < contentBlocks.length - 1) const SizedBox(height: 12),
                  ],
                  // Add bottom padding for edge-hugging buttons
                  if (edgeHuggingButtons.isNotEmpty) const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Edge-hugging buttons at bottom
          if (edgeHuggingButtons.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < edgeHuggingButtons.length; i++) ...[
                    _ButtonBlockWidget(
                      block: edgeHuggingButtons[i],
                      screenMotion: effectiveMotion,
                      onAction: onAction,
                      isEdgeHugging: true,
                    ),
                    if (i < edgeHuggingButtons.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Block Renderers
// ===========================================================================

class _BlockRenderer extends StatelessWidget {
  final Block block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;
  final Duration animationDelay;

  const _BlockRenderer({
    required this.block,
    this.screenMotion,
    this.onAction,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final duration = _durationForMotion(block.motion, screenMotion);
    final curve = _curveForMotion(block.motion, screenMotion);

    Widget child;

    switch (block) {
      case HeroBlock():
        child = _HeroBlockWidget(
          block: block,
          screenMotion: screenMotion,
        );
      case CardBlock():
        child = _CardBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case TextBlock():
        child = _TextBlockWidget(
          block: block,
          screenMotion: screenMotion,
        );
      case ListBlock():
        child = _ListBlockWidget(
          block: block,
          screenMotion: screenMotion,
        );
      case ButtonBlock():
        child = _ButtonBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case CheckboxBlock():
        child = _CheckboxBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case SwitchBlock():
        child = _SwitchBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case ChipBlock():
        child = _ChipBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case ProgressBlock():
        child = _ProgressBlockWidget(
          block: block,
          screenMotion: screenMotion,
        );
      case DividerBlock():
        child = _DividerBlockWidget(
          block: block,
          screenMotion: screenMotion,
        );
      case IconButtonBlock():
        child = _IconButtonBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case FabBlock():
        child = _FabBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case TextFieldBlock():
        child = _TextFieldBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case SliderBlock():
        child = _SliderBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case BadgeBlock():
        child = _BadgeBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case ImageBlock():
        child = _ImageBlockWidget(
          block: block,
          screenMotion: screenMotion,
        );
      case AvatarBlock():
        child = _AvatarBlockWidget(
          block: block,
          screenMotion: screenMotion,
        );
      case RowBlock():
        child = _RowBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case ColumnBlock():
        child = _ColumnBlockWidget(
          block: block,
          screenMotion: screenMotion,
          onAction: onAction,
        );
      case SpacerBlock():
        child = _SpacerBlockWidget(
          block: block,
        );
    }

    // Apply entrance animation
    if (screenMotion != MotionScheme.reduced && block.motion != Motion.reduced) {
      child = child
          .animate(delay: animationDelay)
          .fadeIn(duration: duration, curve: curve)
          .slideY(begin: 0.05, end: 0, duration: duration, curve: curve);
    }

    return child;
  }
}

// ===========================================================================
// Hero Block Widget
// ===========================================================================

class _HeroBlockWidget extends StatelessWidget {
  final HeroBlock block;
  final MotionScheme? screenMotion;

  const _HeroBlockWidget({
    required this.block,
    this.screenMotion,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = _radiusForEmphasis(block.emphasis ?? Emphasis.hero);
    final padding = _paddingForEmphasis(block.emphasis ?? Emphasis.hero);
    final bgColor = _backgroundForSurface(context, block.surface ?? Surface.primary);
    final fgColor = _foregroundForSurface(context, block.surface ?? Surface.primary);
    final headlineStyle = _headlineStyleForEmphasis(context, block.emphasis ?? Emphasis.hero);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.icon != null && block.icon!.isNotEmpty) ...[
            _IconWidget(iconName: block.icon!, color: fgColor, size: 48),
            const SizedBox(height: 16),
          ],
          Text(
            block.headline,
            style: headlineStyle.copyWith(color: fgColor),
          ),
          if (block.subhead != null && block.subhead!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              block.subhead!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: fgColor.withOpacity(0.8),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// Card Block Widget
// ===========================================================================

class _CardBlockWidget extends StatelessWidget {
  final CardBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _CardBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = _radiusForEmphasis(block.emphasis);
    final elevation = _elevationForEmphasis(block.emphasis);
    final padding = _paddingForEmphasis(block.emphasis);

    Color bgColor;
    Color borderColor = Colors.transparent;

    switch (block.variant) {
      case CardVariant.elevated:
        bgColor = cs.surface;
        break;
      case CardVariant.filled:
        bgColor = _backgroundForSurface(context, block.surface ?? Surface.surfaceVariant);
        break;
      case CardVariant.outlined:
        bgColor = cs.surface;
        borderColor = cs.outline;
        break;
      case null:
        bgColor = cs.surface;
    }

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderColor != Colors.transparent
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      color: bgColor,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (block.headline != null && block.headline!.isNotEmpty) ...[
              Text(
                block.headline!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
            ],
            if (block.body != null)
              for (final bodyBlock in block.body!) ...[
                _BlockRenderer(
                  block: bodyBlock,
                  screenMotion: screenMotion,
                  onAction: onAction,
                ),
                const SizedBox(height: 8),
              ],
            if (block.actions != null && block.actions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final action in block.actions!)
                    _ButtonBlockWidget(
                      block: action,
                      screenMotion: screenMotion,
                      onAction: onAction,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Text Block Widget
// ===========================================================================

class _TextBlockWidget extends StatelessWidget {
  final TextBlock block;
  final MotionScheme? screenMotion;

  const _TextBlockWidget({
    required this.block,
    this.screenMotion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fgColor = _foregroundForSurface(context, block.surface);

    TextStyle style;
    switch (block.variant) {
      case TextVariant.headline:
        style = theme.textTheme.headlineSmall ?? const TextStyle(fontSize: 24);
        break;
      case TextVariant.title:
        style = theme.textTheme.titleMedium ?? const TextStyle(fontSize: 16);
        break;
      case TextVariant.body:
        style = theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
        break;
      case TextVariant.label:
        style = theme.textTheme.labelMedium ?? const TextStyle(fontSize: 12);
        break;
      case null:
        style = theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    }

    return Text(
      block.text,
      style: style.copyWith(color: fgColor),
    );
  }
}

// ===========================================================================
// List Block Widget
// ===========================================================================

class _ListBlockWidget extends StatelessWidget {
  final ListBlock block;
  final MotionScheme? screenMotion;

  const _ListBlockWidget({
    required this.block,
    this.screenMotion,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDense = block.dense ?? false;
    final radius = _radiusForEmphasis(block.emphasis);
    final bgColor = _backgroundForSurface(context, block.surface);
    final fgColor = _foregroundForSurface(context, block.surface);

    return Container(
      decoration: BoxDecoration(
        color: bgColor == cs.surface ? Colors.transparent : bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < block.items.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isDense ? 4 : 8,
                horizontal: isDense ? 8 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      color: fgColor.withOpacity(0.6),
                      fontSize: isDense ? 12 : 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      block.items[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: fgColor,
                            fontSize: isDense ? 13 : 14,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < block.items.length - 1 && !isDense)
              Divider(
                height: 1,
                color: cs.outlineVariant.withOpacity(0.3),
              ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// Button Block Widget
// ===========================================================================

class _ButtonBlockWidget extends StatelessWidget {
  final ButtonBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;
  final bool isEdgeHugging;

  const _ButtonBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
    this.isEdgeHugging = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    void handlePress() {
      if (onAction != null) {
        onAction!(block.action);
      }
    }

    Widget button;

    switch (block.role) {
      case ButtonRole.primaryAction:
        button = FilledButton(
          onPressed: handlePress,
          style: FilledButton.styleFrom(
            minimumSize: isEdgeHugging ? const Size.fromHeight(56) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isEdgeHugging ? 16 : 12),
            ),
          ),
          child: Text(block.label),
        );
        break;
      case ButtonRole.secondaryAction:
        button = OutlinedButton(
          onPressed: handlePress,
          style: OutlinedButton.styleFrom(
            minimumSize: isEdgeHugging ? const Size.fromHeight(56) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isEdgeHugging ? 16 : 12),
            ),
          ),
          child: Text(block.label),
        );
        break;
      case ButtonRole.destructive:
        button = FilledButton(
          onPressed: handlePress,
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
            minimumSize: isEdgeHugging ? const Size.fromHeight(56) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isEdgeHugging ? 16 : 12),
            ),
          ),
          child: Text(block.label),
        );
        break;
      case null:
        // Default to text button for unspecified role
        button = TextButton(
          onPressed: handlePress,
          style: TextButton.styleFrom(
            minimumSize: isEdgeHugging ? const Size.fromHeight(56) : null,
          ),
          child: Text(block.label),
        );
    }

    return button;
  }
}

// ===========================================================================
// Icon Mapping Utility
// ===========================================================================

/// Maps icon names to Material Icons
/// This is a static utility function used by multiple widget classes
IconData mapIconName(String name) {
  final normalized = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  // Common icon mappings
  const iconMap = <String, IconData>{
    'home': Icons.home,
    'dashboard': Icons.dashboard,
    'settings': Icons.settings,
    'user': Icons.person,
    'person': Icons.person,
    'chat': Icons.chat,
    'message': Icons.message,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'heart': Icons.favorite,
    'check': Icons.check,
    'close': Icons.close,
    'add': Icons.add,
    'remove': Icons.remove,
    'edit': Icons.edit,
    'delete': Icons.delete,
    'search': Icons.search,
    'menu': Icons.menu,
    'info': Icons.info,
    'warning': Icons.warning,
    'error': Icons.error,
    'help': Icons.help,
    'notification': Icons.notifications,
    'bell': Icons.notifications,
    'calendar': Icons.calendar_today,
    'clock': Icons.access_time,
    'time': Icons.access_time,
    'location': Icons.location_on,
    'map': Icons.map,
    'phone': Icons.phone,
    'email': Icons.email,
    'mail': Icons.mail,
    'camera': Icons.camera_alt,
    'image': Icons.image,
    'photo': Icons.photo,
    'video': Icons.videocam,
    'music': Icons.music_note,
    'audio': Icons.audiotrack,
    'file': Icons.insert_drive_file,
    'folder': Icons.folder,
    'download': Icons.download,
    'upload': Icons.upload,
    'share': Icons.share,
    'link': Icons.link,
    'wifi': Icons.wifi,
    'bluetooth': Icons.bluetooth,
    'battery': Icons.battery_full,
    'power': Icons.power_settings_new,
    'refresh': Icons.refresh,
    'sync': Icons.sync,
    'cloud': Icons.cloud,
    'sun': Icons.wb_sunny,
    'moon': Icons.nightlight,
    'sparkles': Icons.auto_awesome,
    'magic': Icons.auto_awesome,
    'ai': Icons.smart_toy,
    'robot': Icons.smart_toy,
    'brain': Icons.psychology,
    'lightbulb': Icons.lightbulb,
    'idea': Icons.lightbulb,
    'trending': Icons.trending_up,
    'analytics': Icons.analytics,
    'chart': Icons.bar_chart,
    'graph': Icons.show_chart,
    'wallet': Icons.account_balance_wallet,
    'money': Icons.attach_money,
    'payment': Icons.payment,
    'creditcard': Icons.credit_card,
    'shopping': Icons.shopping_cart,
    'cart': Icons.shopping_cart,
    'bag': Icons.shopping_bag,
    'gift': Icons.card_giftcard,
    'ticket': Icons.confirmation_number,
    'tag': Icons.local_offer,
    'lock': Icons.lock,
    'unlock': Icons.lock_open,
    'key': Icons.vpn_key,
    'security': Icons.security,
    'shield': Icons.shield,
    'verified': Icons.verified,
    'thumbsup': Icons.thumb_up,
    'thumbsdown': Icons.thumb_down,
    'like': Icons.thumb_up,
    'dislike': Icons.thumb_down,
    'comment': Icons.comment,
    'send': Icons.send,
    'forward': Icons.arrow_forward,
    'back': Icons.arrow_back,
    'up': Icons.arrow_upward,
    'down': Icons.arrow_downward,
    'expand': Icons.expand_more,
    'collapse': Icons.expand_less,
    'fullscreen': Icons.fullscreen,
    'minimize': Icons.minimize,
    'maximize': Icons.crop_square,
    'copy': Icons.content_copy,
    'paste': Icons.content_paste,
    'cut': Icons.content_cut,
    'undo': Icons.undo,
    'redo': Icons.redo,
    'save': Icons.save,
    'print': Icons.print,
    'export': Icons.ios_share,
    'import': Icons.download,
    'filter': Icons.filter_list,
    'sort': Icons.sort,
    'list': Icons.list,
    'grid': Icons.grid_view,
    'table': Icons.table_chart,
    'code': Icons.code,
    'terminal': Icons.terminal,
    'bug': Icons.bug_report,
    'api': Icons.api,
    'database': Icons.storage,
    'server': Icons.dns,
    'globe': Icons.language,
    'world': Icons.public,
    'flag': Icons.flag,
    'bookmark': Icons.bookmark,
    'archive': Icons.archive,
    'trash': Icons.delete,
    'recycle': Icons.delete_forever,
    'restore': Icons.restore,
    'history': Icons.history,
    'recent': Icons.history,
    'new': Icons.fiber_new,
    'hot': Icons.whatshot,
    'fire': Icons.local_fire_department,
    'water': Icons.water_drop,
    'leaf': Icons.eco,
    'tree': Icons.park,
    'mountain': Icons.terrain,
    'beach': Icons.beach_access,
    'travel': Icons.flight,
    'plane': Icons.flight,
    'car': Icons.directions_car,
    'bus': Icons.directions_bus,
    'train': Icons.train,
    'bike': Icons.directions_bike,
    'walk': Icons.directions_walk,
    'run': Icons.directions_run,
    'sports': Icons.sports,
    'game': Icons.sports_esports,
    'controller': Icons.sports_esports,
    'trophy': Icons.emoji_events,
    'medal': Icons.military_tech,
    'crown': Icons.emoji_events,
    'smile': Icons.sentiment_satisfied,
    'happy': Icons.sentiment_satisfied,
    'sad': Icons.sentiment_dissatisfied,
    'angry': Icons.sentiment_very_dissatisfied,
    'neutral': Icons.sentiment_neutral,
    'celebration': Icons.celebration,
    'party': Icons.celebration,
    'cake': Icons.cake,
    'coffee': Icons.coffee,
    'restaurant': Icons.restaurant,
    'food': Icons.fastfood,
    'drink': Icons.local_bar,
    'wine': Icons.wine_bar,
    'beer': Icons.sports_bar,
    'health': Icons.health_and_safety,
    'medical': Icons.medical_services,
    'hospital': Icons.local_hospital,
    'pill': Icons.medication,
    'fitness': Icons.fitness_center,
    'gym': Icons.fitness_center,
    'weight': Icons.monitor_weight,
    'sleep': Icons.bedtime,
    'bed': Icons.bed,
    'house': Icons.house,
    'building': Icons.apartment,
    'office': Icons.business,
    'school': Icons.school,
    'university': Icons.account_balance,
    'bank': Icons.account_balance,
    'store': Icons.store,
    'shop': Icons.storefront,
    'factory': Icons.factory,
    'construction': Icons.construction,
    'tools': Icons.build,
    'wrench': Icons.build,
    'hammer': Icons.hardware,
    'brush': Icons.brush,
    'paint': Icons.format_paint,
    'palette': Icons.palette,
    'art': Icons.palette,
    'design': Icons.design_services,
    'creative': Icons.auto_fix_high,
  };

  return iconMap[normalized] ?? Icons.circle;
}

// ===========================================================================
// Icon Widget Helper
// ===========================================================================

class _IconWidget extends StatelessWidget {
  final String iconName;
  final Color color;
  final double size;

  const _IconWidget({
    required this.iconName,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon = mapIconName(iconName);
    return Icon(icon, color: color, size: size);
  }
}

// ===========================================================================
// Checkbox Block Widget
// ===========================================================================

class _CheckboxBlockWidget extends StatefulWidget {
  final CheckboxBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _CheckboxBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  @override
  State<_CheckboxBlockWidget> createState() => _CheckboxBlockWidgetState();
}

class _CheckboxBlockWidgetState extends State<_CheckboxBlockWidget> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.block.checked;
  }

  @override
  void didUpdateWidget(_CheckboxBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.checked != widget.block.checked) {
      _checked = widget.block.checked;
    }
  }

  void _handleChange(bool? value) {
    if (widget.block.disabled == true) return;
    setState(() {
      _checked = value ?? false;
    });
    if (widget.onAction != null) {
      final action = widget.block.action ?? {};
      widget.onAction!({
        'type': 'checkbox_change',
        'checked': _checked,
        ...action,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.label != null) {
      return CheckboxListTile(
        value: _checked,
        onChanged: widget.block.disabled == true ? null : _handleChange,
        title: Text(widget.block.label!),
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      );
    }
    return Checkbox(
      value: _checked,
      onChanged: widget.block.disabled == true ? null : _handleChange,
    );
  }
}

// ===========================================================================
// Switch Block Widget
// ===========================================================================

class _SwitchBlockWidget extends StatefulWidget {
  final SwitchBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _SwitchBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  @override
  State<_SwitchBlockWidget> createState() => _SwitchBlockWidgetState();
}

class _SwitchBlockWidgetState extends State<_SwitchBlockWidget> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.block.selected;
  }

  @override
  void didUpdateWidget(_SwitchBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.selected != widget.block.selected) {
      _selected = widget.block.selected;
    }
  }

  void _handleChange(bool value) {
    if (widget.block.disabled == true) return;
    setState(() {
      _selected = value;
    });
    if (widget.onAction != null) {
      final action = widget.block.action ?? {};
      widget.onAction!({
        'type': 'switch_change',
        'selected': _selected,
        ...action,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.label != null) {
      return SwitchListTile(
        value: _selected,
        onChanged: widget.block.disabled == true ? null : _handleChange,
        title: Text(widget.block.label!),
        dense: true,
      );
    }
    return Switch(
      value: _selected,
      onChanged: widget.block.disabled == true ? null : _handleChange,
    );
  }
}

// ===========================================================================
// Chip Block Widget
// ===========================================================================

class _ChipBlockWidget extends StatefulWidget {
  final ChipBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _ChipBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  @override
  State<_ChipBlockWidget> createState() => _ChipBlockWidgetState();
}

class _ChipBlockWidgetState extends State<_ChipBlockWidget> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.block.selected ?? false;
  }

  @override
  void didUpdateWidget(_ChipBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.selected != widget.block.selected) {
      _selected = widget.block.selected ?? false;
    }
  }

  void _handleSelect(bool selected) {
    if (widget.block.disabled == true) return;
    setState(() {
      _selected = selected;
    });
    if (widget.onAction != null) {
      final action = widget.block.action ?? {};
      widget.onAction!({
        'type': 'chip_select',
        'selected': _selected,
        'label': widget.block.label,
        ...action,
      });
    }
  }

  void _handlePressed() {
    if (widget.block.disabled == true) return;
    if (widget.onAction != null) {
      final action = widget.block.action ?? {};
      widget.onAction!({
        'type': 'chip_pressed',
        'label': widget.block.label,
        ...action,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? avatar;
    if (widget.block.icon != null) {
      avatar = Icon(mapIconName(widget.block.icon!), size: 18);
    }

    switch (widget.block.variant) {
      case ChipVariant.filter:
        return FilterChip(
          label: Text(widget.block.label),
          selected: _selected,
          onSelected: widget.block.disabled == true ? null : _handleSelect,
          avatar: avatar,
        );
      case ChipVariant.input:
        return InputChip(
          label: Text(widget.block.label),
          selected: _selected,
          onSelected: widget.block.disabled == true ? null : _handleSelect,
          avatar: avatar,
          onPressed: widget.block.disabled == true ? null : _handlePressed,
        );
      case ChipVariant.suggestion:
        return ActionChip(
          label: Text(widget.block.label),
          onPressed: widget.block.disabled == true ? null : _handlePressed,
          avatar: avatar,
        );
      case ChipVariant.assist:
      case null:
        return ActionChip(
          label: Text(widget.block.label),
          onPressed: widget.block.disabled == true ? null : _handlePressed,
          avatar: avatar,
        );
    }
  }
}

// ===========================================================================
// Progress Block Widget
// ===========================================================================

class _ProgressBlockWidget extends StatelessWidget {
  final ProgressBlock block;
  final MotionScheme? screenMotion;

  const _ProgressBlockWidget({
    required this.block,
    this.screenMotion,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget progress;
    switch (block.variant) {
      case ProgressVariant.circular:
        progress = block.value != null
            ? CircularProgressIndicator(value: block.value)
            : const CircularProgressIndicator();
        break;
      case ProgressVariant.linear:
      case null:
        progress = block.value != null
            ? LinearProgressIndicator(value: block.value)
            : const LinearProgressIndicator();
    }

    if (block.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(block.label!, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          progress,
        ],
      );
    }

    return progress;
  }
}

// ===========================================================================
// Divider Block Widget
// ===========================================================================

class _DividerBlockWidget extends StatelessWidget {
  final DividerBlock block;
  final MotionScheme? screenMotion;

  const _DividerBlockWidget({
    required this.block,
    this.screenMotion,
  });

  @override
  Widget build(BuildContext context) {
    if (block.label != null) {
      return Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              block.label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      );
    }
    return Divider(
      indent: block.inset == true ? 16 : 0,
      endIndent: block.inset == true ? 16 : 0,
    );
  }
}

// ===========================================================================
// Icon Button Block Widget
// ===========================================================================

class _IconButtonBlockWidget extends StatelessWidget {
  final IconButtonBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _IconButtonBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  void _handlePressed() {
    if (block.disabled == true) return;
    if (onAction != null) {
      final action = block.action ?? {};
      onAction!({
        'type': 'icon_button_pressed',
        'icon': block.icon,
        ...action,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = mapIconName(block.icon);

    Widget button;
    if (block.filled == true) {
      button = IconButton.filled(
        icon: Icon(icon),
        onPressed: block.disabled == true ? null : _handlePressed,
        tooltip: block.tooltip,
      );
    } else {
      button = IconButton(
        icon: Icon(icon),
        onPressed: block.disabled == true ? null : _handlePressed,
        tooltip: block.tooltip,
      );
    }

    return button;
  }
}

// ===========================================================================
// FAB Block Widget
// ===========================================================================

class _FabBlockWidget extends StatelessWidget {
  final FabBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _FabBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  void _handlePressed() {
    if (onAction != null) {
      final action = block.action ?? {};
      onAction!({
        'type': 'fab_pressed',
        ...action,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = block.icon != null
        ? Icon(mapIconName(block.icon!))
        : null;

    switch (block.size) {
      case FabSize.small:
        return FloatingActionButton.small(
          onPressed: _handlePressed,
          child: icon,
        );
      case FabSize.large:
        return FloatingActionButton.large(
          onPressed: _handlePressed,
          child: icon,
        );
      case FabSize.extended:
        return FloatingActionButton.extended(
          onPressed: _handlePressed,
          icon: icon,
          label: Text(block.label ?? ''),
        );
      case FabSize.regular:
      case null:
        return FloatingActionButton(
          onPressed: _handlePressed,
          child: icon,
        );
    }
  }
}

// ===========================================================================
// TextField Block Widget
// ===========================================================================

class _TextFieldBlockWidget extends StatefulWidget {
  final TextFieldBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _TextFieldBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  @override
  State<_TextFieldBlockWidget> createState() => _TextFieldBlockWidgetState();
}

class _TextFieldBlockWidgetState extends State<_TextFieldBlockWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.value);
  }

  @override
  void didUpdateWidget(_TextFieldBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.value != widget.block.value) {
      _controller.text = widget.block.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit(String value) {
    if (widget.onAction != null) {
      widget.onAction!({
        'type': 'text_field_submit',
        'value': value,
        if (widget.block.fieldId != null) 'fieldId': widget.block.fieldId,
      });
    }
  }

  void _handleChange(String value) {
    if (widget.onAction != null) {
      widget.onAction!({
        'type': 'text_field_change',
        'value': value,
        if (widget.block.fieldId != null) 'fieldId': widget.block.fieldId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadingIcon = widget.block.leadingIcon != null
        ? Icon(mapIconName(widget.block.leadingIcon!))
        : null;
    final trailingIcon = widget.block.trailingIcon != null
        ? Icon(mapIconName(widget.block.trailingIcon!))
        : null;

    final decoration = InputDecoration(
      labelText: widget.block.label,
      hintText: widget.block.placeholder,
      prefixIcon: leadingIcon,
      suffixIcon: trailingIcon,
      errorText: widget.block.errorText,
      helperText: widget.block.helperText,
      border: widget.block.variant == TextFieldVariant.outlined
          ? const OutlineInputBorder()
          : null,
      filled: widget.block.variant == TextFieldVariant.filled,
    );

    return TextField(
      controller: _controller,
      decoration: decoration,
      enabled: widget.block.disabled != true,
      readOnly: widget.block.readOnly == true,
      onSubmitted: _handleSubmit,
      onChanged: _handleChange,
    );
  }
}

// ===========================================================================
// Slider Block Widget
// ===========================================================================

class _SliderBlockWidget extends StatefulWidget {
  final SliderBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _SliderBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  @override
  State<_SliderBlockWidget> createState() => _SliderBlockWidgetState();
}

class _SliderBlockWidgetState extends State<_SliderBlockWidget> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.block.value;
  }

  @override
  void didUpdateWidget(_SliderBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.value != widget.block.value) {
      _value = widget.block.value;
    }
  }

  void _handleChange(double value) {
    if (widget.block.disabled == true) return;
    setState(() {
      _value = value;
    });
  }

  void _handleChangeEnd(double value) {
    if (widget.onAction != null) {
      widget.onAction!({
        'type': 'slider_change',
        'value': value,
        if (widget.block.fieldId != null) 'fieldId': widget.block.fieldId,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slider = Slider(
      value: _value,
      min: widget.block.min ?? 0,
      max: widget.block.max ?? 1,
      divisions: widget.block.divisions,
      label: widget.block.label ?? _value.toStringAsFixed(2),
      onChanged: widget.block.disabled == true ? null : _handleChange,
      onChangeEnd: widget.block.disabled == true ? null : _handleChangeEnd,
    );

    if (widget.block.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.block.label!, style: Theme.of(context).textTheme.labelMedium),
          slider,
        ],
      );
    }

    return slider;
  }
}

// ===========================================================================
// Badge Block Widget
// ===========================================================================

class _BadgeBlockWidget extends StatelessWidget {
  final BadgeBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _BadgeBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = block.child != null
        ? _BlockRenderer(
            block: block.child!,
            screenMotion: screenMotion,
            onAction: onAction,
          )
        : const SizedBox.shrink();

    return Badge(
      label: block.label != null && block.label!.isNotEmpty
          ? Text(block.label!)
          : null,
      child: child,
    );
  }
}

// ===========================================================================
// Image Block Widget
// ===========================================================================

class _ImageBlockWidget extends StatelessWidget {
  final ImageBlock block;
  final MotionScheme? screenMotion;

  const _ImageBlockWidget({
    required this.block,
    this.screenMotion,
  });

  BoxFit _parseFit(String? fit) {
    switch (fit?.toLowerCase()) {
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'fitwidth':
      case 'fit_width':
        return BoxFit.fitWidth;
      case 'fitheight':
      case 'fit_height':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaledown':
      case 'scale_down':
        return BoxFit.scaleDown;
      default:
        return BoxFit.contain;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = _radiusForEmphasis(block.emphasis);
    final fit = _parseFit(block.fit);

    Widget image;
    if (block.src.startsWith('http://') || block.src.startsWith('https://')) {
      image = Image.network(
        block.src,
        width: block.width,
        height: block.height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: block.width,
            height: block.height ?? 100,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image),
          );
        },
      );
    } else {
      // Assume it's an asset path
      image = Image.asset(
        block.src,
        width: block.width,
        height: block.height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: block.width,
            height: block.height ?? 100,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: image,
    );
  }
}

// ===========================================================================
// Avatar Block Widget
// ===========================================================================

class _AvatarBlockWidget extends StatelessWidget {
  final AvatarBlock block;
  final MotionScheme? screenMotion;

  const _AvatarBlockWidget({
    required this.block,
    this.screenMotion,
  });

  @override
  Widget build(BuildContext context) {
    final size = block.size ?? 40;
    final cs = Theme.of(context).colorScheme;
    final bgColor = _backgroundForSurface(context, block.surface ?? Surface.primary);
    final fgColor = _foregroundForSurface(context, block.surface ?? Surface.primary);

    Widget? child;
    ImageProvider? backgroundImage;

    if (block.imageUrl != null) {
      backgroundImage = NetworkImage(block.imageUrl!);
    } else if (block.initials != null) {
      child = Text(
        block.initials!,
        style: TextStyle(
          color: fgColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (block.icon != null) {
      final icon = mapIconName(block.icon!);
      child = Icon(icon, size: size * 0.5, color: fgColor);
    } else {
      child = Icon(Icons.person, size: size * 0.5, color: fgColor);
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor,
      backgroundImage: backgroundImage,
      child: backgroundImage == null ? child : null,
    );
  }
}

// ===========================================================================
// Row Block Widget
// ===========================================================================

class _RowBlockWidget extends StatelessWidget {
  final RowBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _RowBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  MainAxisAlignment _parseMainAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spacebetween':
      case 'space_between':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
      case 'space_around':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
      case 'space_evenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = block.spacing ?? 8;

    return Row(
      mainAxisAlignment: _parseMainAxisAlignment(block.mainAxisAlignment),
      crossAxisAlignment: _parseCrossAxisAlignment(block.crossAxisAlignment),
      children: [
        for (int i = 0; i < block.children.length; i++) ...[
          _BlockRenderer(
            block: block.children[i],
            screenMotion: screenMotion,
            onAction: onAction,
          ),
          if (i < block.children.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

// ===========================================================================
// Column Block Widget
// ===========================================================================

class _ColumnBlockWidget extends StatelessWidget {
  final ColumnBlock block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _ColumnBlockWidget({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  MainAxisAlignment _parseMainAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spacebetween':
      case 'space_between':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
      case 'space_around':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
      case 'space_evenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.start;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = block.spacing ?? 8;

    return Column(
      mainAxisAlignment: _parseMainAxisAlignment(block.mainAxisAlignment),
      crossAxisAlignment: _parseCrossAxisAlignment(block.crossAxisAlignment),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < block.children.length; i++) ...[
          _BlockRenderer(
            block: block.children[i],
            screenMotion: screenMotion,
            onAction: onAction,
          ),
          if (i < block.children.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

// ===========================================================================
// Spacer Block Widget
// ===========================================================================

class _SpacerBlockWidget extends StatelessWidget {
  final SpacerBlock block;

  const _SpacerBlockWidget({
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    if (block.size != null) {
      return SizedBox(height: block.size, width: block.size);
    }
    return const Spacer();
  }
}
