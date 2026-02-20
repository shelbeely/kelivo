import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/services/api/chat_api_service.dart';

void main() {
  group('sanitizeToolMessages', () {
    test('passes through messages without tool role unchanged', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': 'You are helpful'},
        {'role': 'user', 'content': 'Hello'},
        {'role': 'assistant', 'content': 'Hi there'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      expect(result.length, 3);
      expect(result[0]['role'], 'system');
      expect(result[1]['role'], 'user');
      expect(result[2]['role'], 'assistant');
    });

    test('keeps valid tool messages with matching tool_call_id', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Search for cats'},
        {
          'role': 'assistant',
          'content': '',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
          ],
        },
        {'role': 'tool', 'tool_call_id': 'call_1', 'name': 'search', 'content': 'Found cats'},
        {'role': 'assistant', 'content': 'Here are the results'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      expect(result.length, 4);
      expect(result[2]['role'], 'tool');
      expect(result[2]['tool_call_id'], 'call_1');
    });

    test('drops tool message missing both tool_call_id and name', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {
          'role': 'assistant',
          'content': '',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
          ],
        },
        {'role': 'tool', 'content': ''},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      // Tool message with no tool_call_id, no name, no content => dropped
      expect(result.length, 2);
      expect(result.any((m) => m['role'] == 'tool'), isFalse);
    });

    test('converts tool message missing both ids to assistant when content exists', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {
          'role': 'assistant',
          'content': '',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
          ],
        },
        {'role': 'tool', 'content': 'Some output'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      expect(result.length, 3);
      expect(result[2]['role'], 'assistant');
      expect(result[2]['content'], contains('Some output'));
    });

    test('drops orphaned tool message with no preceding assistant tool_calls', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {'role': 'assistant', 'content': 'Hi'},
        {'role': 'tool', 'tool_call_id': 'call_1', 'name': 'search', 'content': 'result'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      // assistant has no tool_calls, so tool message is orphaned → converted
      expect(result.length, 3);
      expect(result[2]['role'], 'assistant');
      expect(result[2]['content'], contains('result'));
    });

    test('drops tool message whose tool_call_id does not match any call', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {
          'role': 'assistant',
          'content': '',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
          ],
        },
        {'role': 'tool', 'tool_call_id': 'call_WRONG', 'name': 'search', 'content': 'result'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      // tool_call_id doesn't match → converted to assistant
      expect(result.length, 3);
      expect(result[2]['role'], 'assistant');
    });

    test('handles multiple tool calls and results correctly', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {
          'role': 'assistant',
          'content': '',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
            {'id': 'call_2', 'type': 'function', 'function': {'name': 'calc', 'arguments': '{}'}},
          ],
        },
        {'role': 'tool', 'tool_call_id': 'call_1', 'name': 'search', 'content': 'result1'},
        {'role': 'tool', 'tool_call_id': 'call_2', 'name': 'calc', 'content': 'result2'},
        {'role': 'assistant', 'content': 'Done'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      expect(result.length, 5);
      expect(result[2]['role'], 'tool');
      expect(result[3]['role'], 'tool');
    });

    test('regression #298: tool message without preceding assistant tool_calls', () {
      // Scenario from issue #298: after history write/replay, the assistant
      // message loses tool_calls but the tool message remains.
      final messages = <Map<String, dynamic>>[
        {'role': 'system', 'content': 'You are helpful'},
        {'role': 'user', 'content': 'What is the weather?'},
        {'role': 'assistant', 'content': 'Let me check'},
        // ↑ missing tool_calls!
        {'role': 'tool', 'tool_call_id': 'call_abc', 'name': 'get_weather', 'content': 'Sunny, 72°F'},
        {'role': 'assistant', 'content': 'The weather is sunny and 72°F.'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      // The orphaned tool message should be converted, not sent as role=tool
      expect(result.where((m) => m['role'] == 'tool').length, 0);
      // Content should be preserved as assistant
      expect(result.any((m) => m['role'] == 'assistant' && (m['content'] ?? '').toString().contains('Sunny')), isTrue);
    });

    test('when tools disabled: no tool role messages remain', () {
      // Simulate a scenario where tools are disabled but history still has
      // tool messages from a previous session.
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {
          'role': 'assistant',
          'content': 'Checking...',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
          ],
        },
        {'role': 'tool', 'tool_call_id': 'call_1', 'name': 'search', 'content': 'Found it'},
        {'role': 'assistant', 'content': 'Here it is'},
      ];

      // When tools are off, the caller should strip the tools array from the
      // payload.  The sanitizer ensures that any remaining tool messages are
      // still valid (have ids + matching preceding assistant).  The messages
      // above are actually valid, so they survive.  If the assistant message
      // lacked tool_calls (tools disabled scenario from persistence), the
      // orphan logic kicks in:
      final brokenMessages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {'role': 'assistant', 'content': 'Checking...'},
        // tool_calls stripped because tools are off
        {'role': 'tool', 'tool_call_id': 'call_1', 'name': 'search', 'content': 'Found it'},
        {'role': 'assistant', 'content': 'Here it is'},
      ];
      final result = ChatApiService.sanitizeToolMessages(brokenMessages);
      expect(result.where((m) => m['role'] == 'tool').length, 0);
    });

    test('empty content tool message without ids is dropped silently', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {
          'role': 'assistant',
          'content': '',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
          ],
        },
        {'role': 'tool', 'content': '   '},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      expect(result.length, 2);
    });

    test('tool message with name but no tool_call_id and valid preceding calls is kept', () {
      final messages = <Map<String, dynamic>>[
        {'role': 'user', 'content': 'Hello'},
        {
          'role': 'assistant',
          'content': '',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
          ],
        },
        {'role': 'tool', 'name': 'search', 'content': 'Found it'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      // Has name but no tool_call_id – still has pending ids, and since
      // tool_call_id is empty, the "id doesn't match" check is skipped.
      expect(result.length, 3);
      expect(result[2]['role'], 'tool');
    });

    test('non-tool non-assistant messages reset pending tool call ids', () {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'assistant',
          'content': '',
          'tool_calls': [
            {'id': 'call_1', 'type': 'function', 'function': {'name': 'search', 'arguments': '{}'}},
          ],
        },
        {'role': 'user', 'content': 'Wait, never mind'},
        // user message resets pending ids
        {'role': 'tool', 'tool_call_id': 'call_1', 'name': 'search', 'content': 'result'},
      ];
      final result = ChatApiService.sanitizeToolMessages(messages);
      // Tool message is orphaned because user message broke the chain
      expect(result.where((m) => m['role'] == 'tool').length, 0);
    });
  });
}
