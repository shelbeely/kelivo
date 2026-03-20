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
          maxRounds: 1,
          hadToolInteraction: true,
        ),
        isTrue,
      );

      expect(
        AgentLoopPolicy.shouldContinue(
          agentModeEnabled: false,
          currentRound: 0,
          maxRounds: 1,
          hadToolInteraction: true,
        ),
        isFalse,
      );

      expect(
        AgentLoopPolicy.shouldContinue(
          agentModeEnabled: true,
          currentRound: 1,
          maxRounds: 1,
          hadToolInteraction: true,
        ),
        isFalse,
      );

      expect(
        AgentLoopPolicy.shouldContinue(
          agentModeEnabled: true,
          currentRound: 0,
          maxRounds: 1,
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
        maxRounds: 1,
      );
      AgentLoopPolicy.appendContinuationPrompt(
        messages,
        goal: 'Find the best route home.',
        nextRound: 1,
        maxRounds: 1,
      );

      expect(messages.first['role'], 'system');
      expect(messages.first['content'], contains('Kelivo agent mode'));
      expect(messages.last['role'], 'user');
      expect(messages.last['content'], contains('continuation round 1 of 1'));
    });
  });
}
