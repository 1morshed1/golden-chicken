abstract final class ApiEndpoints {
  static const String baseUrl = 'https://dplss5n1-8000.inc1.devtunnels.ms/api/v1';
  static const String wsBaseUrl = 'wss://dplss5n1-8000.inc1.devtunnels.ms';

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

  // Production — Farms & Sheds
  static const String farms = '/farms';
  static String farmSheds(String farmId) => '/farms/$farmId/sheds';
  static String eggRecords(String shedId) => '/sheds/$shedId/eggs';
  static String chickenRecords(String shedId) => '/sheds/$shedId/chickens';
  static String eggTrends(String shedId) => '/sheds/$shedId/trends/eggs';
  static String mortalityTrends(String shedId) =>
      '/sheds/$shedId/trends/mortality';

  // Tasks
  static const String tasks = '/tasks';
  static String completeTask(String taskId) => '/tasks/$taskId/complete';

  // Market
  static const String marketPrices = '/market/prices';
  static String marketPriceHistory(String productType) =>
      '/market/prices/$productType/history';

  // Insights
  static const String insights = '/insights';
  static String acknowledgeInsight(String insightId) =>
      '/insights/$insightId/acknowledge';

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
