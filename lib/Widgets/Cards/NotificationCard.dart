import 'package:flutter/material.dart';


class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        color: Theme.of(context).primaryColorLight,
        child: ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Title'),
          subtitle: const Text('This is the notification message.'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Handle notification tap
          },
        ),
      ),
    );
  }
}
