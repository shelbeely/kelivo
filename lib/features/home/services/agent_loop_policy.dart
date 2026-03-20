class AgentLoopPolicy {
  static const int defaultMaxContinuationRounds = 2;
  // Keep only a few tool outputs in the continuation prompt so the next round
  // gets enough signal to reflect/retry without letting prompt size grow
  // uncontrollably across chained execution loops.
  static const int maxToolResultNotesInPrompt = 3;
  static const int maxPreviousResponseLength = 400;

  static String normalizeGoal(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return 'Complete the latest user request using the available context, tools, and attachments.';
  }

  static bool shouldContinue({
    required bool agentModeEnabled,
    required int currentRound,
    required int maxRounds,
    required bool hadToolInteraction,
  }) {
    if (!agentModeEnabled) return false;
    if (!hadToolInteraction) return false;
    if (maxRounds <= 0) return false;
    return currentRound < maxRounds;
  }

  static void applyAgentSystemPrompt(
    List<Map<String, dynamic>> apiMessages, {
    required String goal,
    required int maxRounds,
  }) {
    final prompt = _buildAgentSystemPrompt(goal: goal, maxRounds: maxRounds);
    final systemIndex = apiMessages.indexWhere(
      (message) => (message['role'] ?? '').toString() == 'system',
    );
    if (systemIndex == -1) {
      apiMessages.insert(0, <String, dynamic>{
        'role': 'system',
        'content': prompt,
      });
      return;
    }

    final current = Map<String, dynamic>.from(apiMessages[systemIndex]);
    final existing = (current['content'] ?? '').toString().trim();
    current['content'] = existing.isEmpty ? prompt : '$existing\n\n$prompt';
    apiMessages[systemIndex] = current;
  }

  static void appendContinuationPrompt(
    List<Map<String, dynamic>> apiMessages, {
    required String goal,
    required int nextRound,
    required int maxRounds,
    List<String> toolsUsed = const <String>[],
    List<String> toolResultNotes = const <String>[],
    String? lastError,
    String? previousResponse,
  }) {
    apiMessages.add(<String, dynamic>{
      'role': 'user',
      'content': _buildContinuationPrompt(
        goal: goal,
        nextRound: nextRound,
        maxRounds: maxRounds,
        toolsUsed: toolsUsed,
        toolResultNotes: toolResultNotes,
        lastError: lastError,
        previousResponse: previousResponse,
      ),
    });
  }

  static String _buildAgentSystemPrompt({
    required String goal,
    required int maxRounds,
  }) {
    return '''
You are operating in Kelivo agent mode.

Primary goal: $goal

Run an execution loop, not one-shot answering:
1. understand the task
2. make a short plan
3. inspect the relevant project/context using available tools
4. make changes or take actions
5. run checks or verification when useful
6. reflect on failures or missing information
7. retry when it is productive
8. ask the user only if truly blocked
9. present the result, including what changed and what was verified

Act like a proactive agent, not a passive chatbot:
- use available tools when they materially improve the result
- complete the task end-to-end when possible
- do not stop after the first partial answer if a useful next step is obvious
- avoid asking the user to repeat obvious next steps
- stop once the goal is satisfied or you are blocked by missing information, permissions, or unavailable tools

If you need multiple passes, keep them bounded. The app may allow up to $maxRounds additional continuation round(s) after a tool-assisted response.
'''.trim();
  }

  static String _buildContinuationPrompt({
    required String goal,
    required int nextRound,
    required int maxRounds,
    required List<String> toolsUsed,
    required List<String> toolResultNotes,
    String? lastError,
    String? previousResponse,
  }) {
    final toolsText = toolsUsed.isEmpty ? 'none' : toolsUsed.join(', ');
    final boundedToolNotes = toolResultNotes
        .take(maxToolResultNotesInPrompt)
        .toList(growable: false);
    final toolResultsText = boundedToolNotes.isEmpty
        ? 'none'
        : boundedToolNotes.join('\n- ');
    final errorText = (lastError == null || lastError.trim().isEmpty)
        ? 'none'
        : lastError.trim();
    final responseText =
        (previousResponse == null || previousResponse.trim().isEmpty)
        ? 'none'
        : _clip(previousResponse.trim(), maxPreviousResponseLength);
    return '''
Continue working autonomously on the same goal:
$goal

This is continuation round $nextRound of $maxRounds.

Previous round review:
- tools used: $toolsText
- notable tool outputs:
- $toolResultsText
- last error: $errorText
- current partial result: $responseText

Before continuing:
- reflect briefly on whether the last round made progress
- decide whether to inspect more, make changes, run checks, retry, or ask the user
- prefer another concrete action over a vague status update

If the goal is already complete, give the final answer now and stop.
If more tool use or reasoning is still required, do it now without asking for a redundant confirmation.
If you are blocked, ask one concise unblock question.
'''.trim();
  }

  static String _clip(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}…';
  }
}
