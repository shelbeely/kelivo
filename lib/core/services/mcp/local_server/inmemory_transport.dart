import 'dart:async';

import 'package:mcp_client/mcp_client.dart' as mcp;

// A generic interface for our local server engines
abstract class LocalMcpServer {
  Future<dynamic> handleMessage(dynamic message);
  void close();
}


/// In-memory ClientTransport that directly invokes a local server engine.
class LocalInMemoryClientTransport implements mcp.ClientTransport {
  final LocalMcpServer _server;
  final _messageController = StreamController<dynamic>.broadcast();
  final _closeCompleter = Completer<void>();
  bool _closed = false;

  LocalInMemoryClientTransport(this._server);

  @override
  Stream<dynamic> get onMessage => _messageController.stream;

  @override
  Future<void> get onClose => _closeCompleter.future;

  @override
  void send(dynamic message) {
    if (_closed) return;
    // Process asynchronously to mimic real transport
    Future.microtask(() async {
      final resp = await _server.handleMessage(message);
      if (_closed) return;
      if (resp != null) {
        _messageController.add(resp);
      }
    });
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    try {
      _server.close();
    } catch (_) {}
    if (!_messageController.isClosed) _messageController.close();
    if (!_closeCompleter.isCompleted) _closeCompleter.complete();
  }
}
