// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_azure_service_bus_suppression.dart';

const _tracerName = 'dartastic_otel_libs_azure_service_bus';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class AzureServiceBusResult {
  /// Creates a result.
  const AzureServiceBusResult({
    this.namespace,
    this.sku,
    this.entityKind,
    this.queueOrTopic,
    this.subscription,
    this.receiveMode,
    this.messageId,
    this.sessionId,
    this.partitionKey,
    this.messageCount,
    this.bytesTransferred,
    this.deliveryCount,
    this.deadLetterReason,
    this.sequenceNumber,
    this.enqueuedAt,
    this.scheduledEnqueueAt,
    this.lockTokenPresent,
    this.lockLostOnSettle,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `<namespace>.servicebus.windows.net`.
  final String? namespace;

  /// `Basic`, `Standard`, `Premium`.
  final String? sku;

  /// `queue`, `topic`, `subscription`, `rule`.
  final String? entityKind;

  final String? queueOrTopic;
  final String? subscription;

  /// `peek_lock`, `receive_and_delete`.
  final String? receiveMode;

  final String? messageId;
  final String? sessionId;
  final String? partitionKey;

  /// Messages in batch / received / peeked.
  final int? messageCount;

  final int? bytesTransferred;

  /// `delivery_count` on the message.
  final int? deliveryCount;

  /// Dead-letter `reason` (`MaxDeliveryCountExceeded`, `TTLExpiredException`,
  /// `Session filter mismatch`, `HeaderSizeExceeded`, ...).
  final String? deadLetterReason;

  final int? sequenceNumber;

  /// Unix seconds when message was enqueued.
  final int? enqueuedAt;
  final int? scheduledEnqueueAt;

  final bool? lockTokenPresent;

  /// `complete`/`abandon` raised LockLostException (peek-lock expired).
  final bool? lockLostOnSettle;

  /// `MessagingEntityNotFound`, `MessageLockLost`,
  /// `SessionLockLost`, `QuotaExceeded`, `ServerBusy`,
  /// `UnauthorizedAccess`, `MessageSizeExceeded`, `SessionCannotBeLocked`.
  final String? errorCode;
  final String? errorMessage;

  final int? statusCode;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AzureServiceBusCallResult<T> {
  /// Creates a call result.
  const AzureServiceBusCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AzureServiceBusResult? result;
}

/// Wraps an Azure Service Bus call in a CLIENT (publish) or CONSUMER
/// (receive) span. [operation] is one of `send`, `sendBatch`,
/// `scheduleMessage`, `cancelScheduledMessage`, `receive`,
/// `receiveBatch`, `peek`, `peekBySequence`, `complete`, `abandon`,
/// `defer`, `deadLetter`, `renewLock`, `acceptSession`, `setState`,
/// `getState`, `closeSession`, `receiveDeferred`,
/// `manage.queue.create`, `manage.queue.delete`, `manage.queue.list`,
/// `manage.topic.create`, `manage.topic.delete`,
/// `manage.subscription.create`, `manage.subscription.delete`,
/// `manage.rule.create`, `manage.rule.delete`.
Future<T> tracedAzureServiceBus<T>({
  required String operation,
  required Future<AzureServiceBusCallResult<T>> Function() invoke,
}) async {
  if (azureServiceBusInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final isReceive = operation == 'receive' ||
      operation == 'receiveBatch' ||
      operation == 'peek' ||
      operation == 'peekBySequence' ||
      operation == 'receiveDeferred';
  final m = <String, Object>{
    'rpc.system': 'azure_service_bus',
    'rpc.method': operation,
    'azure_service_bus.operation': operation,
  };

  final span = _tracer().startSpan(
    'azure_service_bus $operation',
    kind: isReceive ? SpanKind.consumer : SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.namespace != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.namespace',
          res.namespace!,
        ));
      }
      if (res.sku != null) {
        extras.add(OTelAPI.attributeString('azure_service_bus.sku', res.sku!));
      }
      if (res.entityKind != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.entity.kind',
          res.entityKind!,
        ));
      }
      if (res.queueOrTopic != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.queue_or_topic',
          res.queueOrTopic!,
        ));
      }
      if (res.subscription != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.subscription',
          res.subscription!,
        ));
      }
      if (res.receiveMode != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.receive_mode',
          res.receiveMode!,
        ));
      }
      if (res.messageId != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.message.id',
          res.messageId!,
        ));
      }
      if (res.sessionId != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.session.id',
          res.sessionId!,
        ));
      }
      if (res.partitionKey != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.partition_key',
          res.partitionKey!,
        ));
      }
      if (res.messageCount != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_service_bus.message.count',
          res.messageCount!,
        ));
      }
      if (res.bytesTransferred != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_service_bus.bytes_transferred',
          res.bytesTransferred!,
        ));
      }
      if (res.deliveryCount != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_service_bus.delivery_count',
          res.deliveryCount!,
        ));
      }
      if (res.deadLetterReason != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.dead_letter.reason',
          res.deadLetterReason!,
        ));
      }
      if (res.sequenceNumber != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_service_bus.sequence_number',
          res.sequenceNumber!,
        ));
      }
      if (res.enqueuedAt != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_service_bus.enqueued_at_sec',
          res.enqueuedAt!,
        ));
      }
      if (res.scheduledEnqueueAt != null) {
        extras.add(OTelAPI.attributeInt(
          'azure_service_bus.scheduled_enqueue_at_sec',
          res.scheduledEnqueueAt!,
        ));
      }
      if (res.lockTokenPresent != null) {
        extras.add(OTelAPI.attributeBool(
          'azure_service_bus.lock_token.present',
          res.lockTokenPresent!,
        ));
      }
      if (res.lockLostOnSettle != null) {
        extras.add(OTelAPI.attributeBool(
          'azure_service_bus.lock.lost_on_settle',
          res.lockLostOnSettle!,
        ));
        if (res.lockLostOnSettle!) {
          span.setStatus(
            SpanStatusCode.Error,
            'Service Bus lock lost on settle',
          );
        }
      }
      if (res.errorCode != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.error.code',
          res.errorCode!,
        ));
        span.setStatus(
          SpanStatusCode.Error,
          'Service Bus ${res.errorCode}',
        );
      }
      if (res.errorMessage != null) {
        extras.add(OTelAPI.attributeString(
          'azure_service_bus.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Service Bus HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
