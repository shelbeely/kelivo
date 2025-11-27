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
    // Map common icon names to Material Icons
    final IconData icon = _mapIconName(iconName);
    return Icon(icon, color: color, size: size);
  }

  IconData _mapIconName(String name) {
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
}
