abstract final class ApiEndpoints {
  static const String baseUrl = 'https://api.goldenchicken.ai/api/v1';
  static const String wsBaseUrl = 'wss://api.goldenchicken.ai';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // Chat
  static const String chatSessions = '/chat/sessions';
  static String chatMessages(String sessionId) =>
      '/chat/sessions/$sessionId/messages';
  static String chatStream(String sessionId) =>
      '/chat/sessions/$sessionId/messages/stream';

  // Health
  static const String healthTabs = '/health-tabs';
  static String askHealth(String tabId) => '/health-tabs/$tabId/ask';

  // Production
  static const String farms = '/farms';
  static const String sheds = '/sheds';
  static String eggTrends(String shedId) => '/sheds/$shedId/trends/eggs';

  // Tasks
  static const String tasks = '/tasks';

  // Market
  static const String marketPrices = '/market/prices';

  // Insights
  static const String insights = '/insights';

  // Diagnosis
  static const String diagnosis = '/diagnosis';

  // Weather
  static const String weather = '/weather';

  // Live AI
  static String liveAiStream(String token) =>
      '/api/v1/live-ai/stream?token=$token';

  // Profile
  static const String profile = '/users/me';
}
