import 'package:flutter/material.dart';

class EventDetailPage extends StatefulWidget {
  EventDetailPage({Key key}) : super(key: key);

  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evènement'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(),
    );
  }
}
