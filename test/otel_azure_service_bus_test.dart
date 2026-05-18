// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_azure_service_bus/otel_azure_service_bus.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_azure_service_bus-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('send records namespace + topic + sku', () async {
    await tracedAzureServiceBus<String>(
      operation: 'send',
      invoke: () async => const AzureServiceBusCallResult(
        value: 'ok',
        result: AzureServiceBusResult(
          namespace: 'mybus.servicebus.windows.net',
          sku: 'Premium',
          entityKind: 'topic',
          queueOrTopic: 'orders',
          partitionKey: 'tenant_42',
          messageId: 'm_1',
          messageCount: 1,
          bytesTransferred: 1500,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('azure_service_bus send')!);
    expect(a['azure_service_bus.entity.kind'], 'topic');
    expect(a['azure_service_bus.sku'], 'Premium');
  });

  test('receive is CONSUMER kind', () async {
    await tracedAzureServiceBus<String>(
      operation: 'receive',
      invoke: () async => const AzureServiceBusCallResult(
        value: 'ok',
        result: AzureServiceBusResult(
          entityKind: 'subscription',
          queueOrTopic: 'orders',
          subscription: 'fulfillment',
          receiveMode: 'peek_lock',
          messageCount: 10,
          deliveryCount: 1,
        ),
      ),
    );
    expect(
      spans.findSpanByName('azure_service_bus receive')!.kind,
      SpanKind.consumer,
    );
  });

  test('lock-lost on settle sets span error', () async {
    await tracedAzureServiceBus<String>(
      operation: 'complete',
      invoke: () async => const AzureServiceBusCallResult(
        value: 'ok',
        result: AzureServiceBusResult(lockLostOnSettle: true),
      ),
    );
    expect(
      spans.findSpanByName('azure_service_bus complete')!.status,
      SpanStatusCode.Error,
    );
  });

  test('MessageLockLost error sets span error', () async {
    await tracedAzureServiceBus<String>(
      operation: 'renewLock',
      invoke: () async => const AzureServiceBusCallResult(
        value: 'ok',
        result: AzureServiceBusResult(errorCode: 'MessageLockLost'),
      ),
    );
    expect(
      spans.findSpanByName('azure_service_bus renewLock')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutAzureServiceBusInstrumentationAsync(() async {
      await tracedAzureServiceBus<String>(
        operation: 'manage.queue.list',
        invoke: () async => const AzureServiceBusCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('azure_service_bus '), isEmpty);
  });
}
