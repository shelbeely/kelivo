import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/features/home/services/agent_loop_policy.dart';

void main() {
  group('AgentLoopPolicy', () {
    test('normalizes empty goal into fallback instruction', () {
      expect(
        AgentLoopPolicy.normalizeGoal('   '),
        contains('Complete the latest user request'),
      );
    });

    test('continues only when agent mode, rounds remain, and tools were used', () {
      expect(
        AgentLoopPolicy.shouldContinue(
          agentModeEnabled: true,
          currentRound: 0,
          maxRounds: 2,
          hadToolInteraction: true,
        ),
        isTrue,
      );

      expect(
        AgentLoopPolicy.shouldContinue(
          agentModeEnabled: false,
          currentRound: 0,
          maxRounds: 2,
          hadToolInteraction: true,
        ),
        isFalse,
      );

      expect(
        AgentLoopPolicy.shouldContinue(
          agentModeEnabled: true,
          currentRound: 2,
          maxRounds: 2,
          hadToolInteraction: true,
        ),
        isFalse,
      );

      expect(
        AgentLoopPolicy.shouldContinue(
          agentModeEnabled: true,
          currentRound: 0,
          maxRounds: 2,
          hadToolInteraction: false,
        ),
        isFalse,
      );
    });

    test('injects agent system prompt and continuation prompt', () {
      final messages = <Map<String, dynamic>>[
        <String, dynamic>{'role': 'user', 'content': 'Find the best route home.'},
      ];

      AgentLoopPolicy.applyAgentSystemPrompt(
        messages,
        goal: 'Find the best route home.',
        maxRounds: 2,
      );
      AgentLoopPolicy.appendContinuationPrompt(
        messages,
        goal: 'Find the best route home.',
        nextRound: 1,
        maxRounds: 2,
        toolsUsed: const <String>['read_file', 'edit_file'],
        toolResultNotes: const <String>['read_file: inspected main.dart'],
        lastError: 'flutter analyze failed',
        previousResponse: 'I updated the app entry point.',
      );

      expect(messages.first['role'], 'system');
      expect(messages.first['content'], contains('Kelivo agent mode'));
      expect(messages.first['content'], contains('Run an execution loop'));
      expect(messages.first['content'], contains('understand the task'));
      expect(messages.first['content'], contains('make a short plan'));
      expect(
        messages.first['content'],
        contains('inspect the relevant project/context'),
      );
      expect(messages.first['content'], contains('run checks or verification'));
      expect(messages.first['content'], contains('reflect on failures'));
      expect(messages.last['role'], 'user');
      expect(messages.last['content'], contains('continuation round 1 of 2'));
      expect(messages.last['content'], contains('read_file, edit_file'));
      expect(messages.last['content'], contains('flutter analyze failed'));
      expect(
        messages.last['content'],
        contains('I updated the app entry point.'),
      );
    });
  });
}
