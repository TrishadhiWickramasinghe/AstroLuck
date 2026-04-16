import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:astroluck/core/constants/app_constants.dart';

// ============================================================================
// WHATSAPP PROVIDER
// ============================================================================
class WhatsAppProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  
  bool isLoading = false;
  bool? isConnected;
  String? connectedPhone;
  bool? receiveDailyNumbers;
  bool? receiveAlerts;
  String? notificationTime;
  int? messageCount;
  DateTime? lastMessageSent;
  String? error;

  WhatsAppProvider() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiUrl}/integrations/whatsapp/status',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      isConnected = response.data['connected'] ?? false;
      if (isConnected ?? false) {
        connectedPhone = response.data['phone'];
        receiveDailyNumbers = response.data['receive_daily_numbers'];
        receiveAlerts = response.data['receive_alerts'];
        notificationTime = response.data['notification_time'];
        messageCount = response.data['message_count'];
      }
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }

  Future<Map<String, dynamic>> initiateConnection(String phone) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await _dio.post(
        '${AppConstants.apiUrl}/integrations/whatsapp/initiate',
        data: {'whatsapp_phone': phone},
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      isLoading = false;
      notifyListeners();
      return {
        'success': response.data['success'] ?? false,
        'connection_id': response.data['connection_id'],
      };
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyConnection(String connectionId, String code) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await _dio.post(
        '${AppConstants.apiUrl}/integrations/whatsapp/verify',
        data: {
          'connection_id': connectionId,
          'code': code,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      isLoading = false;
      await _loadStatus();
      return {'success': response.data['success'] ?? false};
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> updatePreferences({
    bool? receiveDailyNumbers,
    bool? receiveAlerts,
    String? notificationTime,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (receiveDailyNumbers != null) data['receive_daily_numbers'] = receiveDailyNumbers;
      if (receiveAlerts != null) data['receive_alerts'] = receiveAlerts;
      if (notificationTime != null) data['notification_time'] = notificationTime;
      
      await _dio.patch(
        '${AppConstants.apiUrl}/integrations/whatsapp/preferences',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      await _loadStatus();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _dio.post(
        '${AppConstants.apiUrl}/integrations/whatsapp/disconnect',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      isConnected = false;
      connectedPhone = null;
      await _loadStatus();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

// ============================================================================
// CALENDAR SYNC PROVIDER
// ============================================================================
class CalendarSyncProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  
  bool isLoading = false;
  List<Map<String, dynamic>> connectedCalendars = [];
  bool? syncLuckyDates;
  bool? syncLuckyTimes;
  bool? syncLotteryDrawings;
  String? error;
  String? filterLotteryType = 'all';

  CalendarSyncProvider() {
    _loadCalendars();
  }

  Future<void> _loadCalendars() async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiUrl}/integrations/calendar/connected',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      connectedCalendars = List<Map<String, dynamic>>.from(
        response.data['calendars'] ?? [],
      );
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }

  Future<Map<String, dynamic>> initiateGoogleAuth() async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await _dio.post(
        '${AppConstants.apiUrl}/integrations/calendar/google/auth-url',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      isLoading = false;
      notifyListeners();
      return {
        'success': response.data['success'] ?? false,
        'auth_url': response.data['auth_url'],
        'connection_id': response.data['connection_id'],
      };
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> updateSyncPreferences({
    bool? syncLuckyDates,
    bool? syncLuckyTimes,
    bool? syncLotteryDrawings,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (syncLuckyDates != null) data['sync_lucky_dates'] = syncLuckyDates;
      if (syncLuckyTimes != null) data['sync_lucky_times'] = syncLuckyTimes;
      if (syncLotteryDrawings != null) data['sync_lottery_drawings'] = syncLotteryDrawings;
      
      // Update preferences for all connected calendars
      for (var calendar in connectedCalendars) {
        await _dio.patch(
          '${AppConstants.apiUrl}/integrations/calendar/${calendar['id']}/preferences',
          data: data,
          options: Options(
            headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
          ),
        );
      }
      
      if (syncLuckyDates != null) this.syncLuckyDates = syncLuckyDates;
      if (syncLuckyTimes != null) this.syncLuckyTimes = syncLuckyTimes;
      if (syncLotteryDrawings != null) this.syncLotteryDrawings = syncLotteryDrawings;
      
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> disconnectCalendar(String calendarId) async {
    try {
      await _dio.post(
        '${AppConstants.apiUrl}/integrations/calendar/disconnect/$calendarId',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      await _loadCalendars();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

// ============================================================================
// PAYMENT PROVIDER
// ============================================================================
class PaymentProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  
  bool isLoading = false;
  Map<String, dynamic>? currentSubscription;
  List<Map<String, dynamic>>? paymentMethods;
  List<Map<String, dynamic>>? paymentHistory;
  double totalSpent = 0.0;
  String? error;

  PaymentProvider() {
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    try {
      final subResponse = await _dio.get(
        '${AppConstants.apiUrl}/integrations/subscription/current',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      currentSubscription = Map<String, dynamic>.from(subResponse.data);
      
      final historyResponse = await _dio.get(
        '${AppConstants.apiUrl}/integrations/payments/history',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      paymentHistory = List<Map<String, dynamic>>.from(
        historyResponse.data['payments'] ?? [],
      );
      
      totalSpent = paymentHistory?.fold(0.0, (sum, payment) {
        return sum + (payment['amount'] as num).toDouble();
      }) ?? 0.0;
      
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
    double amount,
    String? currency,
    String? paymentType,
  ) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await _dio.post(
        '${AppConstants.apiUrl}/integrations/payments/intent',
        data: {
          'amount': amount,
          'currency': currency ?? 'USD',
          'payment_type': paymentType,
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      isLoading = false;
      notifyListeners();
      return response.data;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> cancelSubscription() async {
    try {
      await _dio.post(
        '${AppConstants.apiUrl}/integrations/subscription/downgrade',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      await _loadPaymentData();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

// ============================================================================
// NOTIFICATION PROVIDER
// ============================================================================
class NotificationProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  
  bool isLoading = false;
  bool? emailEnabled;
  bool? smsEnabled;
  bool? pushEnabled;
  String? morningTime;
  String? eveningTime;
  bool? quietHoursEnabled;
  String? quietHoursStart;
  String? quietHoursEnd;
  List<Map<String, dynamic>>? notificationHistory;
  String? error;

  NotificationProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiUrl}/integrations/notifications/preferences',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      emailEnabled = response.data['email_enabled'];
      smsEnabled = response.data['sms_enabled'];
      pushEnabled = response.data['push_enabled'];
      morningTime = response.data['morning_time'];
      eveningTime = response.data['evening_time'];
      quietHoursEnabled = response.data['quiet_hours_enabled'];
      quietHoursStart = response.data['quiet_hours_start'];
      quietHoursEnd = response.data['quiet_hours_end'];
      
      final historyResponse = await _dio.get(
        '${AppConstants.apiUrl}/integrations/notifications/history',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      notificationHistory = List<Map<String, dynamic>>.from(
        historyResponse.data['notifications'] ?? [],
      );
      
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> updatePreferences({
    bool? emailEnabled,
    bool? smsEnabled,
    bool? pushEnabled,
    String? morningTime,
    String? eveningTime,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? phoneNumber,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (emailEnabled != null) data['email_enabled'] = emailEnabled;
      if (smsEnabled != null) data['sms_enabled'] = smsEnabled;
      if (pushEnabled != null) data['push_enabled'] = pushEnabled;
      if (morningTime != null) data['morning_time'] = morningTime;
      if (eveningTime != null) data['evening_time'] = eveningTime;
      if (quietHoursEnabled != null) data['quiet_hours_enabled'] = quietHoursEnabled;
      if (quietHoursStart != null) data['quiet_hours_start'] = quietHoursStart;
      if (quietHoursEnd != null) data['quiet_hours_end'] = quietHoursEnd;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      
      await _dio.patch(
        '${AppConstants.apiUrl}/integrations/notifications/preferences',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      if (emailEnabled != null) this.emailEnabled = emailEnabled;
      if (smsEnabled != null) this.smsEnabled = smsEnabled;
      if (pushEnabled != null) this.pushEnabled = pushEnabled;
      if (morningTime != null) this.morningTime = morningTime;
      if (eveningTime != null) this.eveningTime = eveningTime;
      if (quietHoursEnabled != null) this.quietHoursEnabled = quietHoursEnabled;
      if (quietHoursStart != null) this.quietHoursStart = quietHoursStart;
      if (quietHoursEnd != null) this.quietHoursEnd = quietHoursEnd;
      
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendTestEmail() async {
    try {
      await _dio.post(
        '${AppConstants.apiUrl}/integrations/notifications/test-email',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      await _loadPreferences();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendTestSMS() async {
    try {
      await _dio.post(
        '${AppConstants.apiUrl}/integrations/notifications/test-sms',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

// ============================================================================
// LOTTERY PROVIDER
// ============================================================================
class LotteryProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  
  bool isLoading = false;
  List<Map<String, dynamic>>? userTickets;
  List<Map<String, dynamic>>? ticketResults;
  double totalWinnings = 0.0;
  String? filterLotteryType = 'all';
  String? error;

  LotteryProvider() {
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiUrl}/integrations/lottery/my-tickets',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      userTickets = List<Map<String, dynamic>>.from(response.data['tickets'] ?? []);
      
      final resultsResponse = await _dio.get(
        '${AppConstants.apiUrl}/integrations/lottery/ticket-results',
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      ticketResults = List<Map<String, dynamic>>.from(
        resultsResponse.data['results'] ?? [],
      );
      totalWinnings = resultsResponse.data['total_won'] ?? 0.0;
      
      notifyListeners();
    } catch (e) {
      error = e.toString();
    }
  }

  void setFilterLotteryType(String type) {
    filterLotteryType = type;
    notifyListeners();
  }

  Future<void> verifyTickets(String lotteryType) async {
    isLoading = true;
    notifyListeners();
    
    try {
      await _dio.post(
        '${AppConstants.apiUrl}/integrations/lottery/verify-tickets',
        queryParameters: {'lottery_type': lotteryType},
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      await _loadTickets();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setupAutomation(String lotteryType) async {
    try {
      await _dio.post(
        '${AppConstants.apiUrl}/integrations/lottery/automate-verification',
        data: {'lottery_type': lotteryType},
        options: Options(
          headers: {'Authorization': 'Bearer ${AppConstants.authToken}'},
        ),
      );
      
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
