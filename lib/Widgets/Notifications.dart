import 'package:flutter/material.dart';
import 'package:GoCastTrack/indexAppBar.dart';
import '../sideBarMenu.dart';
import 'Cards/NotificationCard.dart';
import 'package:GoCastTrack/load_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: IndexAppBar(
        title: 'Notifications',
      ),
        // drawer: width>600? SizedBox(width: MediaQuery.of(context).size.width * 0.2,
        //     child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig))
        //     :SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: ListView(
          children: const [
            NotificationCard(),
            NotificationCard(),
            NotificationCard(),
          ],
        ),
      )


    );
  }
}
