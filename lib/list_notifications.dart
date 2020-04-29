import 'dart:async';

import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

import 'package:notification_app/notification.dart' as notification;


class NotificationsListWidget extends StatefulWidget {
  NotificationsListWidget({Key key}) : super(key: key);

  @override
  _NotificationsListWidgetState createState() => _NotificationsListWidgetState();
}

class _NotificationsListWidgetState extends State<NotificationsListWidget> {
  List notifications = <List<notification.Notification>>[];
  bool isLoading;
  final db = notification.NotificationDB();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    db.open();

    setState(() {
      this.isLoading = true;
    });
  }

  @override
  void dispose() {
    db.close();

    super.dispose();
  }

  Future<List> _listNotifications() async {   
    return await Future.delayed(Duration(seconds: 1), () => db.listNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My notifications')
      ),
      body: FutureBuilder<List>(
        future: _listNotifications(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                setState(() {});
              },
              child: Container(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    final item = snapshot.data[index];
                    final key = '${item.title}';
                    return Dismissible(
                      key: Key(key),
                      onDismissed: (direction) {
                        setState(() {
                          snapshot.data.removeAt(index);
                          db.deleteNotification(item.id);
                        });

                        Scaffold.of(context)
                            .showSnackBar(SnackBar(
                              content: Text("Notificação removida", style: TextStyle(fontSize: 15),),
                              backgroundColor: Colors.blueAccent,
                            ));
                      },
                      background: DismissBackground(),
                      child: NotificationCardWidget(notificationData: item),
                    );
                  },
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
      ));
  }
}


class NotificationCardWidget extends StatefulWidget {
  final notification.Notification notificationData;

  NotificationCardWidget({Key key, this.notificationData}) : super(key: key);

  @override
  _NotificationCardWidgetState createState() => _NotificationCardWidgetState();
}

class _NotificationCardWidgetState extends State<NotificationCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: FlutterLogo(),
        title: Text(widget.notificationData.title),
        subtitle: Text(widget.notificationData.body),
        onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
          return AlertDialog(
              title: Text(widget.notificationData.title),
              content: Container(
                width: double.maxFinite,
                child: Text(widget.notificationData.body)
              ),
          );
          }
        );
        },
      ),
    );
  }
}

class DismissBackground extends StatelessWidget {
  const DismissBackground({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Text(
        'Removendo notificação',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
      )),
      color: Colors.redAccent,
    );
  }
}