// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_azure_service_bus/otel_azure_service_bus.dart';

/// Traces Azure Service Bus calls with OpenTelemetry.
///
/// `otel_azure_service_bus` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Azure Service Bus call in
/// [tracedAzureServiceBus]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'azure-service-bus-example');

  // Wraps an Azure Service Bus call in a CLIENT (publish) or CONSUMER (receive) span.
  final azureServiceBusId = await tracedAzureServiceBus<String>(
    operation: 'manage.queue.create',
    invoke: () async {
      // Make the Azure Service Bus call here, then report what it returned.
      const id = 'azure_service_bus_8f3a2c';
      return const AzureServiceBusCallResult(
          value: id,
          result: AzureServiceBusResult(
              namespace: '<namespace>.servicebus.windows.net',
              sku: 'Basic',
              entityKind: 'queue',
              queueOrTopic: 'orders',
              subscription: 'example',
              receiveMode: 'peek_lock',
              messageId: 'message_8f3a2c',
              sessionId: 'session_8f3a2c',
              partitionKey: 'orders/2026/inv-1042.pdf',
              messageCount: 3,
              bytesTransferred: 512,
              deliveryCount: 3,
              deadLetterReason: 'MaxDeliveryCountExceeded',
              sequenceNumber: 1,
              enqueuedAt: 1,
              scheduledEnqueueAt: 1,
              lockTokenPresent: true,
              lockLostOnSettle: true,
              errorCode: 'MessagingEntityNotFound',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info(
      'tracedAzureServiceBus manage.queue.create returned $azureServiceBusId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAzureServiceBusInstrumentationAsync.
  await runWithoutAzureServiceBusInstrumentationAsync(
    () => tracedAzureServiceBus<String>(
      operation: 'manage.queue.create',
      invoke: () async {
        const id = 'azure_service_bus_8f3a2c';
        return const AzureServiceBusCallResult(
            value: id,
            result: AzureServiceBusResult(
                namespace: '<namespace>.servicebus.windows.net',
                sku: 'Basic',
                entityKind: 'queue',
                queueOrTopic: 'orders',
                subscription: 'example',
                receiveMode: 'peek_lock',
                messageId: 'message_8f3a2c',
                sessionId: 'session_8f3a2c',
                partitionKey: 'orders/2026/inv-1042.pdf',
                messageCount: 3,
                bytesTransferred: 512,
                deliveryCount: 3,
                deadLetterReason: 'MaxDeliveryCountExceeded',
                sequenceNumber: 1,
                enqueuedAt: 1,
                scheduledEnqueueAt: 1,
                lockTokenPresent: true,
                lockLostOnSettle: true,
                errorCode: 'MessagingEntityNotFound',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
