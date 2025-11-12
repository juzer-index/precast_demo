import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:GoCastTrack/utils/aws_notifications_service.dart';
import 'package:GoCastTrack/utils/cognito_credentials.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, String> attributes;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.attributes = const {},
  });
}

class NotificationsProvider extends ChangeNotifier {
  final List<AppNotification> _messages = [];
  List<AppNotification> get messages => List.unmodifiable(_messages);

  AwsNotificationsService? _service;
  StreamSubscription<InboundMessage>? _sub;

  String _status = 'Idle';
  String get status => _status;

  Future<void> initFromEnv() async {
    if (_service != null) return;

    _status = 'Initializing...';
    notifyListeners();
    print('[NotificationsProvider] Initializing...');

    final region = const String.fromEnvironment('AWS_REGION', defaultValue: '')
        .isNotEmpty
        ? const String.fromEnvironment('AWS_REGION')
        : (dotenv.env['AWS_REGION'] ?? '');
    final topicArn = const String.fromEnvironment('AWS_SNS_TOPIC_ARN', defaultValue: '')
        .isNotEmpty
        ? const String.fromEnvironment('AWS_SNS_TOPIC_ARN')
        : (dotenv.env['AWS_SNS_TOPIC_ARN'] ?? '');
    final queueUrl = const String.fromEnvironment('AWS_SQS_QUEUE_URL', defaultValue: '')
        .isNotEmpty
        ? const String.fromEnvironment('AWS_SQS_QUEUE_URL')
        : (dotenv.env['AWS_SQS_QUEUE_URL'] ?? '');
    final cognitoPoolId = const String.fromEnvironment('AWS_COGNITO_IDENTITY_POOL_ID', defaultValue: '')
        .isNotEmpty
        ? const String.fromEnvironment('AWS_COGNITO_IDENTITY_POOL_ID')
        : (dotenv.env['AWS_COGNITO_IDENTITY_POOL_ID'] ?? '');

    if (region.isEmpty || topicArn.isEmpty || queueUrl.isEmpty) {
      _status = 'Error: Missing AWS config in .env or --dart-define';
      print('[NotificationsProvider] $_status');
      notifyListeners();
      return;
    }
    print('[NotificationsProvider] AWS config found.');

    String? accessKey;
    String? secretKey;
    String? sessionToken;

    if (cognitoPoolId.isNotEmpty) {
      _status = 'Fetching credentials from Cognito...';
      notifyListeners();
      print('[NotificationsProvider] Cognito Pool ID found, fetching credentials...');
      try {
        final cognitoProvider = CognitoCredentialsProvider(
          identityPoolId: cognitoPoolId,
          region: region,
        );
        final creds = await cognitoProvider.getCredentials();
        accessKey = creds.accessKeyId;
        secretKey = creds.secretAccessKey;
        sessionToken = creds.sessionToken;
        print('[NotificationsProvider] Cognito credentials fetched successfully.');
      } catch (e) {
        _status = 'Error: Failed to get credentials from Cognito.\n$e';
        print('[NotificationsProvider] $_status');
        notifyListeners();
        return;
      }
    } else {
      // Fallback to static credentials if Cognito is not configured
      print('[NotificationsProvider] No Cognito Pool ID found, falling back to static credentials...');
      accessKey = const String.fromEnvironment('AWS_ACCESS_KEY_ID', defaultValue: '')
          .isNotEmpty
          ? const String.fromEnvironment('AWS_ACCESS_KEY_ID')
          : dotenv.env['AWS_ACCESS_KEY_ID'];
      secretKey = const String.fromEnvironment('AWS_SECRET_ACCESS_KEY', defaultValue: '')
          .isNotEmpty
          ? const String.fromEnvironment('AWS_SECRET_ACCESS_KEY')
          : dotenv.env['AWS_SECRET_ACCESS_KEY'];
      sessionToken = const String.fromEnvironment('AWS_SESSION_TOKEN', defaultValue: '')
          .isNotEmpty
          ? const String.fromEnvironment('AWS_SESSION_TOKEN')
          : dotenv.env['AWS_SESSION_TOKEN'];
    }

    if ((accessKey ?? '').isEmpty || (secretKey ?? '').isEmpty) {
      _status = 'Error: AWS credentials not found.';
      print('[NotificationsProvider] $_status');
      notifyListeners();
      return;
    }
    print('[NotificationsProvider] AWS credentials available.');

    _service = AwsNotificationsService(
      region: region,
      topicArn: topicArn,
      queueUrl: queueUrl,
      accessKeyId: accessKey,
      secretAccessKey: secretKey,
      sessionToken: sessionToken,
    );
    print('[NotificationsProvider] Service initialized.');
  }

  Future<void> startListening() async {
    print('[NotificationsProvider] startListening called.');
    await stopListening();
    _status = 'Idle';

    await initFromEnv();
    if (_service == null) {
      print('[NotificationsProvider] startListening failed: service is null.');
      return;
    }

    try {
      _status = 'Pinging SQS...';
      notifyListeners();
      print('[NotificationsProvider] Pinging SQS...');
      await _service!.ping();
      print('[NotificationsProvider] SQS ping successful.');
    } catch (e) {
      _status = 'Error: SQS ping failed. Check credentials and permissions.\n$e';
      print('[NotificationsProvider] $_status');
      notifyListeners();
      return;
    }

    _status = 'Listening...';
    notifyListeners();
    print('[NotificationsProvider] Starting SQS poll...');

    _sub = _service!.pollQueue().listen((msg) {
      print('[NotificationsProvider] Received message: ${msg.messageId}');
      final notif = AppNotification(
        id: msg.messageId,
        title: msg.title ?? 'Notification',
        body: msg.body ?? '',
        timestamp: msg.timestamp ?? DateTime.now(),
        attributes: msg.attributes,
      );
      _messages.insert(0, notif);
      if (msg.receiptHandle != null) {
        print('[NotificationsProvider] Deleting message: ${msg.messageId}');
        _service!.deleteMessage(msg.receiptHandle!);
      }
      notifyListeners();
    }, onError: (e) {
      _status = 'Error: SQS poll failed.\n$e';
      print('[NotificationsProvider] $_status');
      notifyListeners();
    }, onDone: () {
      _status = 'Stopped';
      print('[NotificationsProvider] SQS poll stream closed.');
      notifyListeners();
    });
  }

  Future<void> stopListening() async {
    if (_sub != null) {
      print('[NotificationsProvider] Stopping SQS listener.');
      await _sub!.cancel();
      _sub = null;
    }
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendTest(String title, String body, {Map<String, String>? attributes}) async {
    print('[NotificationsProvider] Sending test message...');
    await initFromEnv();
    if (_service == null) {
      _status = 'Error: Cannot send test message, service not initialized.';
      print('[NotificationsProvider] $_status');
      notifyListeners();
      return;
    }
    try {
      await _service!.publishToTopic(title: title, body: body, attributes: attributes);
      print('[NotificationsProvider] Test message published successfully.');
    } catch (e) {
      _status = 'Error: Failed to publish test message.\n$e';
      print('[NotificationsProvider] $_status');
      notifyListeners();
    }
  }
}
