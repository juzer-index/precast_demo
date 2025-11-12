import 'package:flutter/material.dart';


class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final IconData icon;
  final Color? color;

  const NotificationCard({
    super.key,
    this.title = 'Notification',
    this.subtitle = '',
    this.onTap,
    this.icon = Icons.notifications,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Card(
        color: color ?? Theme.of(context).primaryColorLight,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward),
          onTap: onTap,
        ),
      ),
    );
  }
}
