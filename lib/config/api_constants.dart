class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const String registerUrl = '$baseUrl/auth/register/';
  static const String loginUrl = '$baseUrl/auth/login/';
  static const String tokenRefreshUrl = '$baseUrl/auth/token/refresh/';
  static const String currentUserUrl = '$baseUrl/auth/me/';

  static const String tasksUrl = '$baseUrl/tasks/';
  static const String dailyPlansUrl = '$baseUrl/daily-plans/';
  static const String disruptionsUrl = '$baseUrl/disruptions/';
  static const String recoverySessionsUrl = '$baseUrl/recovery-sessions/';
  static const String insightsUrl = '$baseUrl/insights/';
}
