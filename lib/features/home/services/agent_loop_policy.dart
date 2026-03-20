class AgentLoopPolicy {
  static const int defaultMaxContinuationRounds = 1;

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
  }) {
    apiMessages.add(<String, dynamic>{
      'role': 'user',
      'content': _buildContinuationPrompt(
        goal: goal,
        nextRound: nextRound,
        maxRounds: maxRounds,
      ),
    });
  }

  static String _buildAgentSystemPrompt({
    required String goal,
    required int maxRounds,
  }) {
    return '''
You are operating in Android agent mode.

Primary goal: $goal

Act like a proactive agent, not a passive chatbot:
- use available tools when they materially improve the result
- complete the task end-to-end when possible
- avoid asking the user to repeat obvious next steps
- stop once the goal is satisfied or you are blocked by missing information, permissions, or unavailable tools

If you need multiple passes, keep them bounded. The app may allow up to $maxRounds additional continuation round(s) after a tool-assisted response.
'''.trim();
  }

  static String _buildContinuationPrompt({
    required String goal,
    required int nextRound,
    required int maxRounds,
  }) {
    return '''
Continue working autonomously on the same goal:
$goal

This is continuation round $nextRound of $maxRounds.

If the goal is already complete, give the final answer now and stop.
If more tool use or reasoning is still required, do it now without asking for a redundant confirmation.
'''.trim();
  }
}
