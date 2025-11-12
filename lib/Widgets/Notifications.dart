import 'package:flutter/material.dart';
import 'package:GoCastTrack/indexAppBar.dart';
import 'Cards/NotificationCard.dart';
import 'package:provider/provider.dart';
import '../Providers/NotificationsProvider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Start SQS polling when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().startListening();
    });
  }

  @override
  void dispose() {
    // Optionally keep listening in background; here we stop when leaving page
    // context.read<NotificationsProvider>().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const IndexAppBar(title: 'Notifications'),
      body: RefreshIndicator(
        onRefresh: () => provider.startListening(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.yellow.shade100,
                child: Text(
                  'Status: ${provider.status}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            if (provider.messages.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No notifications yet')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final m = provider.messages[index];
                    return NotificationCard(
                      title: m.title,
                      subtitle: m.body,
                      onTap: () {},
                    );
                  },
                  childCount: provider.messages.length,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await provider.sendTest('Test from app', 'Hello from Flutter');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Test message published')),
            );
          }
        },
        label: const Text('Send test'),
        icon: const Icon(Icons.send),
      ),
    );
  }
}
