---
name: flutter-best-practices
description: >
  Best practices and patterns for Flutter development. Covers widget architecture,
  state management, performance optimization, and common Flutter patterns to write
  efficient and maintainable Flutter applications.
license: MIT
metadata:
  author: Flutter Community
  version: '1.0.0'
compatibility: flutter>=3.0.0
---

# Flutter Best Practices Skill

This skill provides guidance on Flutter best practices, performance optimization, and common patterns for building high-quality Flutter applications.

## Widget Best Practices

### Use Const Constructors

Always use `const` constructors when possible to improve performance:

```dart
// ✅ Good - uses const
const Text('Hello World')
const SizedBox(height: 16)
const Icon(Icons.home)

// ❌ Bad - missing const
Text('Hello World')
SizedBox(height: 16)
Icon(Icons.home)
```

### Split Widgets into Smaller Components

Extract complex widgets into separate classes for better readability and reusability:

```dart
// ✅ Good - extracted widget
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _HeaderWidget(),
          _ContentWidget(),
          _FooterWidget(),
        ],
      ),
    );
  }
}

// ❌ Bad - everything in one widget
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 100+ lines of nested widgets...
        ],
      ),
    );
  }
}
```

### Prefer StatelessWidget When Possible

Use `StatelessWidget` when the widget doesn't need to maintain state:

```dart
// ✅ Good - stateless for static content
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  const UserAvatar({required this.imageUrl});
  
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(backgroundImage: NetworkImage(imageUrl));
  }
}

// ❌ Bad - unnecessary StatefulWidget
class UserAvatar extends StatefulWidget {
  final String imageUrl;
  const UserAvatar({required this.imageUrl});
  
  @override
  State<UserAvatar> createState() => _UserAvatarState();
}
```

### Use Keys Appropriately

Use keys when you need to preserve state across widget tree changes:

```dart
// ✅ Good - uses ValueKey for list items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListItem(
      key: ValueKey(items[index].id),
      item: items[index],
    );
  },
)

// Keys are especially important when:
// - Reordering list items
// - Adding/removing items from a list
// - Switching between widgets of the same type
```

## State Management Best Practices

### Provider Pattern

```dart
// ✅ Good - proper Provider usage
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch only when you need to rebuild
    final counter = context.watch<CounterProvider>().count;
    
    return Column(
      children: [
        Text('Count: $counter'),
        ElevatedButton(
          onPressed: () {
            // Use read for actions (no rebuild)
            context.read<CounterProvider>().increment();
          },
          child: Text('Increment'),
        ),
      ],
    );
  }
}

// ❌ Bad - unnecessary rebuilds
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This rebuilds the entire widget for any provider change
    final provider = context.watch<CounterProvider>();
    
    return ElevatedButton(
      onPressed: () => provider.increment(),
      child: Text('Increment'), // Doesn't depend on provider!
    );
  }
}
```

### Minimize Rebuilds with Selectors

```dart
// ✅ Good - selective listening
final name = context.select<UserProvider, String>((p) => p.user.name);

// Only rebuilds when name changes, not when other user properties change
```

## Async Best Practices

### Handle Context in Async Operations

Always check if the widget is still mounted before using context:

```dart
// ✅ Good - checks context.mounted
Future<void> loadData() async {
  final data = await fetchData();
  if (!mounted) return; // For StatefulWidget
  // or
  if (!context.mounted) return; // For BuildContext
  
  setState(() {
    _data = data;
  });
}

// ❌ Bad - doesn't check mounted
Future<void> loadData() async {
  final data = await fetchData();
  setState(() {
    _data = data;
  }); // May crash if widget was disposed
}
```

### Use FutureBuilder/StreamBuilder

```dart
// ✅ Good - handles loading, error, and data states
FutureBuilder<User>(
  future: fetchUser(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return ErrorWidget(snapshot.error!);
    }
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    return UserProfile(user: snapshot.data!);
  },
)
```

### Dispose Resources

Always dispose controllers, listeners, and subscriptions:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    _subscription = someStream.listen((data) {
      // Handle data
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _subscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

## Performance Best Practices

### Avoid Expensive Operations in build()

```dart
// ✅ Good - expensive operation in initState
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late List<Item> _items;
  
  @override
  void initState() {
    super.initState();
    _items = _processExpensiveData(widget.data);
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView(children: _items.map((i) => ItemWidget(i)).toList());
  }
}

// ❌ Bad - expensive operation in build
class MyWidget extends StatelessWidget {
  final List<RawData> data;
  
  @override
  Widget build(BuildContext context) {
    final items = _processExpensiveData(data); // Called every rebuild!
    return ListView(children: items.map((i) => ItemWidget(i)).toList());
  }
}
```

### Use ListView.builder for Long Lists

```dart
// ✅ Good - lazy loading with builder
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ❌ Bad - creates all widgets at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

### Cache Network Images

```dart
// ✅ Good - uses cached_network_image or similar
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// ❌ Bad - loads image every time
Image.network(url)
```

## Layout Best Practices

### Use SizedBox for Spacing

```dart
// ✅ Good - explicit spacing with SizedBox
Column(
  children: [
    Text('Hello'),
    const SizedBox(height: 16),
    Text('World'),
  ],
)

// ❌ Bad - using Container for spacing
Column(
  children: [
    Text('Hello'),
    Container(height: 16), // More expensive than SizedBox
    Text('World'),
  ],
)
```

### Avoid Deeply Nested Widgets

```dart
// ✅ Good - extracted methods or widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
    );
  }
  
  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        _buildBody(),
      ],
    );
  }
  
  Widget _buildHeader() => Text('Header');
  Widget _buildBody() => Text('Body');
}

// ❌ Bad - deeply nested
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                Container(
                  child: Column(
                    children: [
                      // ... more nesting
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Error Handling

### Use Try-Catch for Async Operations

```dart
// ✅ Good - handles errors
Future<void> loadData() async {
  try {
    final data = await api.fetchData();
    setState(() => _data = data);
  } on NetworkException catch (e) {
    _showError('Network error: ${e.message}');
  } catch (e) {
    _showError('Unexpected error: $e');
  }
}
```

### Provide Fallbacks for Images

```dart
// ✅ Good - has error fallback
Image.network(
  url,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.broken_image);
  },
)
```

## Testing Best Practices

### Write Testable Code

```dart
// ✅ Good - business logic separated from UI
class CounterLogic {
  int _count = 0;
  int get count => _count;
  
  void increment() => _count++;
  void decrement() => _count--;
}

class CounterWidget extends StatelessWidget {
  final CounterLogic logic;
  const CounterWidget({required this.logic});
  
  @override
  Widget build(BuildContext context) {
    return Text('Count: ${logic.count}');
  }
}

// ❌ Bad - logic tightly coupled with UI
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;
  
  void _increment() {
    // Complex business logic mixed with UI
    if (_count < 100 && DateTime.now().hour > 9) {
      setState(() => _count++);
    }
  }
  
  @override
  Widget build(BuildContext context) => Text('Count: $_count');
}
```

## Accessibility

### Provide Semantic Labels

```dart
// ✅ Good - accessible
Semantics(
  label: 'Close dialog',
  child: IconButton(
    icon: Icon(Icons.close),
    onPressed: () => Navigator.pop(context),
  ),
)

// Use Tooltip for additional context
Tooltip(
  message: 'Close',
  child: IconButton(
    icon: Icon(Icons.close),
    onPressed: () => Navigator.pop(context),
  ),
)
```

## Null Safety

### Use Null-Aware Operators

```dart
// ✅ Good - null-safe
String? name;
final displayName = name ?? 'Guest';
final length = name?.length ?? 0;

// Late initialization for non-nullable that will be set later
late String userId;

void init() {
  userId = fetchUserId();
}
```

## Platform-Specific Code

### Check Platform Appropriately

```dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// ✅ Good - proper platform checks
Widget build(BuildContext context) {
  if (kIsWeb) {
    return WebOnlyFeature();
  }
  if (Platform.isAndroid || Platform.isIOS) {
    return MobileFeature();
  }
  return DesktopFeature();
}
```

## Common Pitfalls to Avoid

1. **Don't rebuild unnecessarily**: Use `const`, selectors, and proper state management
2. **Don't ignore context.mounted**: Always check before using context after async operations
3. **Don't forget to dispose**: Clean up controllers, subscriptions, and listeners
4. **Don't use setState after dispose**: Check `mounted` before calling setState
5. **Don't use BuildContext across async gaps**: Context may be invalid after await
6. **Don't ignore errors**: Always handle exceptions in async operations
7. **Don't over-optimize**: Profile before optimizing - don't guess
8. **Don't use GlobalKey everywhere**: Use them only when necessary

## Performance Profiling

```bash
# Run app in profile mode
flutter run --profile

# Use DevTools for performance analysis
flutter pub global activate devtools
flutter pub global run devtools
```

## Resources

- Flutter Documentation: https://flutter.dev/docs
- Flutter Performance Best Practices: https://docs.flutter.dev/perf/best-practices
- Effective Dart: https://dart.dev/guides/language/effective-dart
- Flutter Widget Catalog: https://docs.flutter.dev/ui/widgets

## Summary

Key takeaways:
1. Use `const` constructors whenever possible
2. Split large widgets into smaller, reusable components
3. Choose StatelessWidget over StatefulWidget when state isn't needed
4. Always dispose resources in StatefulWidget
5. Check `context.mounted` before using context after async operations
6. Use ListView.builder for long lists
7. Separate business logic from UI for testability
8. Handle errors gracefully with try-catch
9. Profile your app before optimizing
10. Follow Material Design guidelines for consistent UX
