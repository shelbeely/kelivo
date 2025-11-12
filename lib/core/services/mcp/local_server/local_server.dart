import 'dart:async';
import 'dart:convert';
import 'package:mcp_client/mcp_client.dart' as mcp;
import 'inmemory_transport.dart';
import 'tools.dart';

class LocalMcpServerEngine implements LocalMcpServer {
  final Map<String, Tool> _tools = {
    'device_status': DeviceStatusTool(),
    'sensors': SensorsTool(),
    'sms': SmsTool(),
    'location': LocationTool(),
    'contacts': ContactsTool(),
    'calendar': CalendarTool(),
    'alarm': AlarmTool(),
    'device_info': DeviceInfoTool(),
  };
  bool _closed = false;

  @override
  Future<dynamic> handleMessage(dynamic message) async {
    if (_closed) return null;

    if (message is List) {
      final out = <dynamic>[];
      for (final m in message) {
        out.add(await _handleSingle(m));
      }
      return out;
    }
    return await _handleSingle(message);
  }

  Future<Map<String, dynamic>> _handleSingle(dynamic raw) async {
    try {
      if (raw is! Map) {
        return _error(null, code: -32600, message: 'Invalid Request');
      }
      final req = raw.cast<String, dynamic>();
      final id = req['id'];
      final method = (req['method'] ?? '').toString();
      final params = (req['params'] is Map)
          ? (req['params'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};

      switch (method) {
        case mcp.McpProtocol.methodInitialize:
          return _ok(id, result: {
            'serverInfo': {
              'name': '@local/phone',
              'version': '0.1.0',
            },
            'protocolVersion': mcp.McpProtocol.defaultVersion,
            'capabilities': {
              'tools': {'listChanged': false},
            },
          });

        case mcp.McpProtocol.methodListTools:
          return _ok(id, result: {
            'tools': _tools.values
                .map((t) => {
                      'name': t.name,
                      'description': t.description,
                      'inputSchema': t.inputSchema,
                    })
                .toList(),
          });

        case mcp.McpProtocol.methodCallTool:
          final toolName = params['name'] as String?;
          if (toolName == null || !_tools.containsKey(toolName)) {
            return _error(id, code: -32101, message: 'Tool not found: $toolName');
          }
          final arguments = params['arguments'] as Map<String, dynamic>? ?? {};
          final result = await _tools[toolName]!.call(arguments);
          return _ok(id, result: result);

        default:
          if (id == null) {
            return _noop();
          }
          return _error(id, code: -32601, message: 'Method not found: $method');
      }
    } catch (e) {
      return _error(null, code: -32603, message: 'Internal error: $e');
    }
  }

  void close() {
    _closed = true;
  }

  Map<String, dynamic> _ok(dynamic id, {required Map<String, dynamic> result}) {
    return {
      'jsonrpc': '2.0',
      if (id != null) 'id': id,
      'result': result,
    };
  }

  Map<String, dynamic> _error(dynamic id, {required int code, required String message}) {
    return {
      'jsonrpc': '2.0',
      if (id != null) 'id': id,
      'error': {'code': code, 'message': message},
    };
  }

  Map<String, dynamic> _noop() => {'jsonrpc': '2.0'};
}
