import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:notification_app/local_notification.dart';
import 'package:notification_app/notification.dart' as notification;

final client = MqttServerClient('192.168.1.15', '1');

notification.Notification _processMqttMessage(String subscriptionMessage) {
  List<String> splittedMessage = subscriptionMessage.split('&');

  var mqttNotification = new notification.Notification(
    title: splittedMessage[0],
    body: splittedMessage[1]
  );

  return mqttNotification;
}


Future<void> runMqttServerClient(BuildContext context) async {
  LocalNotification notify = LocalNotification(context);
  notification.NotificationDB db = notification.NotificationDB();

  client.autoReconnect = true;

  client.onAutoReconnect = onAutoReconnect;

  client.onConnected = onConnected;

  client.onSubscribed = onSubscribed;

  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      .keepAliveFor(60)
      .withWillTopic('willtopic')
      .withWillMessage('My Will message')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  print('EXAMPLE::Mosquitto client connecting....');
  client.connectionMessage = connMess;

  try {
    await client.connect();
    await db.open();
  } on Exception catch (e) {
    print('EXAMPLE::client exception - $e');
    client.disconnect();
    db.close();
  }

  if (client.connectionStatus.state == MqttConnectionState.connected) {
    print('EXAMPLE::Mosquitto client connected');
  } else {
    print(
        'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }

  print('EXAMPLE::Subscribing to the test/lol topic');
  const topic = 'test/lol';
  client.subscribe(topic, MqttQos.atMostOnce);

  client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
    final MqttPublishMessage recMess = c[0].payload;
    final pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print(
        'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');

    var mqttNotification = _processMqttMessage(pt);

    await db.insertNotification(mqttNotification).then((r) {
      notify.showNotification(c[0].topic, mqttNotification.title);
    });
  });

  print('EXAMPLE::Sleeping....');
  await MqttUtilities.asyncSleep(120);
}

void onSubscribed(String topic) {
  print('EXAMPLE::Subscription confirmed for topic $topic');
}

void onAutoReconnect() {
  print(
      'EXAMPLE::onAutoReconnect client callback - Client auto reconnection sequence will start');
}

void onConnected() {
  print(
      'EXAMPLE::OnConnected client callback - Client connection was sucessful');
}

void pong() {
  print('EXAMPLE::Ping response client callback invoked - you may want to disconnect your broker here');
}
