import 'dart:async';
import 'dart:convert';
import 'package:aws_sns_api/sns-2010-03-31.dart' as sns;
import 'package:aws_sqs_api/sqs-2012-11-05.dart' as sqs;

class InboundMessage {
  final String messageId;
  final String? title;
  final String? body;
  final DateTime? timestamp;
  final String? receiptHandle;
  final Map<String, String> attributes;

  InboundMessage({
    required this.messageId,
    this.title,
    this.body,
    this.timestamp,
    this.receiptHandle,
    this.attributes = const {},
  });
}

class AwsNotificationsService {
  final String region;
  final String topicArn;
  final String queueUrl;
  final String? accessKeyId;
  final String? secretAccessKey;
  final String? sessionToken;

  // Optional Cognito: not used directly here, but kept for future enhancement
  final String? cognitoIdentityPoolId;
  final String? cognitoRegion;

  late final sns.SNS _sns;
  late final sqs.SQS _sqs;

  AwsNotificationsService({
    required this.region,
    required this.topicArn,
    required this.queueUrl,
    this.accessKeyId,
    this.secretAccessKey,
    this.sessionToken,
    this.cognitoIdentityPoolId,
    this.cognitoRegion,
  }) {
    final cred = sns.AwsClientCredentials(
      accessKey: accessKeyId ?? '',
      secretKey: secretAccessKey ?? '',
      sessionToken: sessionToken,
    );
    _sns = sns.SNS(region: region, credentials: cred);
    _sqs = sqs.SQS(region: region, credentials: sqs.AwsClientCredentials(
      accessKey: cred.accessKey,
      secretKey: cred.secretKey,
      sessionToken: cred.sessionToken,
    ));
  }

  Future<void> publishToTopic({required String title, required String body, Map<String, String>? attributes}) async {
    // FIFO topics require MessageGroupId and optionally MessageDeduplicationId
    final isFifo = topicArn.endsWith('.fifo');

    final messageMap = {
      'default': body,
      'GCM': jsonEncode({
        'notification': {
          'title': title,
          'body': body,
        }
      }),
      'APNS': jsonEncode({
        'aps': {
          'alert': {'title': title, 'body': body},
          'sound': 'default'
        }
      })
    };

    final message = jsonEncode(messageMap);

    final groupId = isFifo ? (attributes?['groupId'] ?? 'default-group') : null;
    final dedupId = isFifo
        ? (attributes?['dedupId'] ?? DateTime.now().millisecondsSinceEpoch.toString())
        : null;

    // Always include a 'title' attribute for easier UI rendering (SNS->SQS preserves message attributes)
    final mergedAttributes = <String, String>{
      'title': title,
      if (attributes != null) ...attributes,
    };

    await _sns.publish(
      topicArn: topicArn,
      message: message,
      messageStructure: 'json',
      messageGroupId: groupId,
      messageDeduplicationId: dedupId,
      messageAttributes: mergedAttributes.map((k, v) => MapEntry(k, sns.MessageAttributeValue(
        dataType: 'String', stringValue: v,
      ))),
    );
  }

  // Poll SQS for messages and emit them as a stream
  Stream<InboundMessage> pollQueue({Duration waitTime = const Duration(seconds: 20), Duration interval = const Duration(seconds: 1)}) async* {
    while (true) {
      try {
        final resp = await _sqs.receiveMessage(
          queueUrl: queueUrl,
          waitTimeSeconds: waitTime.inSeconds,
          maxNumberOfMessages: 10,
          messageAttributeNames: ['All'],
        );
        final msgs = resp.messages ?? const [];
        for (final m in msgs) {
          // If the SNS subscription delivers raw, body is plain. If not, it's an SNS envelope JSON.
          String? title;
          String? body;
          DateTime? ts;
          Map<String, String> attrs = {};

          if (m.messageAttributes != null) {
            m.messageAttributes!.forEach((k, v) {
              final sv = v.stringValue;
              if (sv != null) attrs[k] = sv;
            });
          }

          if (m.body != null) {
            try {
              final parsed = jsonDecode(m.body!);
              // SNS envelope structure
              if (parsed is Map && parsed.containsKey('Message')) {
                final messageStr = parsed['Message'];

                // Extract message attributes from SNS envelope when raw delivery is disabled
                final envAttrs = parsed['MessageAttributes'];
                if (envAttrs is Map) {
                  envAttrs.forEach((k, v) {
                    // v is { Type: 'String', Value: '...' }
                    try {
                      final val = (v is Map) ? (v['Value']?.toString()) : null;
                      if (val != null) attrs[k] = val;
                    } catch (_) {}
                  });
                }

                // Message could be a JSON string we published with messageStructure=json
                try {
                  final inner = jsonDecode(messageStr);
                  if (inner is Map && inner['default'] != null) {
                    body = inner['default'];
                  } else {
                    body = messageStr.toString();
                  }
                } catch (_) {
                  body = messageStr.toString();
                }
                title = parsed['Subject']?.toString() ?? attrs['title'];
                ts = DateTime.tryParse(parsed['Timestamp']?.toString() ?? '') ?? DateTime.now();
              } else {
                // Raw message
                body = m.body;
                title = attrs['title'];
                ts = DateTime.now();
              }
            } catch (_) {
              body = m.body;
              title = attrs['title'];
              ts = DateTime.now();
            }
          }

          yield InboundMessage(
            messageId: m.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            body: body,
            timestamp: ts,
            receiptHandle: m.receiptHandle,
            attributes: attrs,
          );
        }
      } catch (e) {
        // Backoff on error
        await Future.delayed(const Duration(seconds: 3));
      }
      // Small interval to avoid tight loop when no long-poll
      await Future.delayed(interval);
    }
  }

  Future<void> deleteMessage(String receiptHandle) async {
    await _sqs.deleteMessage(queueUrl: queueUrl, receiptHandle: receiptHandle);
  }

  // Simple connectivity check to surface auth/permission issues early
  Future<void> ping() async {
    await _sqs.getQueueAttributes(
      queueUrl: queueUrl,
      attributeNames: [sqs.QueueAttributeName.queueArn],
    );
  }
}
