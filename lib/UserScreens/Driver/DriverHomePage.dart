import 'package:flutter/material.dart';
import '../../check_in_out_page.dart';

void main() {
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4FC3F7); // sky-blue like the reference
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      home: const HomePage(driverId: 37, jobNumber: 15, loadsDone: 32),
    );
  }
}

class HomePage extends StatefulWidget {
  final int driverId;
  final int jobNumber;
  final int loadsDone;

  const HomePage({
    super.key,
    required this.driverId,
    required this.jobNumber,
    required this.loadsDone,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Small data holder for passing state between pages.
class CheckSession {
  final bool isCheckedIn;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  const CheckSession({required this.isCheckedIn, this.checkInTime, this.checkOutTime});
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // State mirrored from the Check In/Out page
  CheckSession _session = const CheckSession(isCheckedIn: false);

  String _fmtTime(DateTime? t) {
    if (t == null) return '--:--';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'Menu',
        ),
        title: const Text('Driver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            tooltip: 'Notifications',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('No new notifications'))),
          ),
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            tooltip: 'Home',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('You are on Home'))),
          ),
        ],
      ),

      // ---------- DRAWER ----------
      drawer: _DriverDrawer(onItemSelected: () => Navigator.pop(context)),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add, size: 28),
      ),

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header band like the reference
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome, driver', style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: 16),
                    _IdCard(driverId: widget.driverId),
                  ],
                ),
              ),
            ),

            // Dashboard grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.crossAxisExtent > 700 ? 3 : 2;
                  return SliverGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.05,
                    children: [
                      DashboardTile(
                        icon: Icons.local_shipping_rounded,
                        title: 'Load Tracker',
                        subtitle: 'Load number: ${widget.jobNumber}',
                        onTap: () {},
                      ),
                      DashboardTile(
                        icon: Icons.call_rounded,
                        title: 'Report / Contact',
                        subtitle: 'Reach admin\nor supervisor',
                        onTap: () {},
                      ),
                      DashboardTile(
                        icon: Icons.history_rounded,
                        title: 'Load history',
                        subtitle: 'Loads: ${widget.loadsDone}',
                        onTap: () {},
                      ),

                      CheckSummaryTile(
                        statusText: _session.isCheckedIn
                            ? 'Checked in at ${_fmtTime(_session.checkInTime)}'
                            : (_session.checkOutTime != null
                            ? 'Checked out at ${_fmtTime(_session.checkOutTime)}'
                            : 'Checked out'),
                        onTap: () async {
                          final result = await Navigator.push<CheckSession>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckInOutPage(initial: _session),
                            ),
                          );
                          if (result != null && mounted) {
                            setState(() => _session = result);
                          }
                        },
                      ),

                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverDrawer extends StatelessWidget {
  final VoidCallback onItemSelected;
  const _DriverDrawer({required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Welcome, driver',
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
              ),
            ),
            ListTile(leading: const Icon(Icons.dashboard_rounded), title: const Text('Dashboard'), onTap: onItemSelected),
            ListTile(leading: const Icon(Icons.local_shipping_rounded), title: const Text('Active load'), onTap: onItemSelected),
            ListTile(leading: const Icon(Icons.history_rounded), title: const Text('Load History'), onTap: onItemSelected),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.settings_rounded), title: const Text('Settings'), onTap: onItemSelected),
            ListTile(leading: const Icon(Icons.logout_rounded), title: const Text('Logout'), onTap: onItemSelected),
          ],
        ),
      ),
    );
  }
}

class _IdCard extends StatelessWidget {
  final int driverId;
  const _IdCard({required this.driverId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text('ID: $driverId',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          Material(
            color: theme.colorScheme.primary.withOpacity(.12),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.info_rounded, color: theme.colorScheme.primary),
              tooltip: 'Driver info',
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 6))],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 11,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white, size: 36),
                    const Spacer(),
                    Text(title, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home card that just opens the Check In/Out page.
// Replace the `_CheckSummaryTile` widget with:
class CheckSummaryTile extends StatelessWidget {
  final String statusText;
  final VoidCallback onTap;
  const CheckSummaryTile({super.key, required this.statusText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                flex: 11,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time_rounded, color: Colors.white, size: 36),
                      const Spacer(),
                      Text('Check in / out', style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 9,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      statusText,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
