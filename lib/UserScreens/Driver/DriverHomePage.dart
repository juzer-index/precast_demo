import 'package:GoCastTrack/indexAppBar.dart';
import 'package:flutter/material.dart';
import '../CheckInOut.dart';
import '../../sideBarMenu.dart';
import '../../themeData.dart';
import '../../loadTracker.dart';
import '../../load_history.dart';
import '../../load_model.dart';
import '../../Widgets/Notifications.dart';

class DriverHomePage extends StatefulWidget {
  final int driverId;
  final int activeLoad;
  final int prevLoads;
  final dynamic tenantConfig;

  const DriverHomePage({
    super.key,
    required this.driverId,
    required this.activeLoad,
    required this.prevLoads,
    required this.tenantConfig,
  });

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<LoadData> loads = [];

  // Mirror check-in/out state from secondary page
  CheckSession _session = const CheckSession(isCheckedIn: false);

  void addLoadData(LoadData load) {
    setState(() {
      for (int i = 0; i < loads.length; i++) {
        if (loads[i].loadID == load.loadID) {
          loads.removeAt(i);
          break;
        }
      }
    });
    setState(() {
      loads.add(load);
    });
  }

  String _fmtTime(DateTime? t) {
    if (t == null) return '--:--';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final bool isWide = size.width >= 1000; // desktop/web breakpoint


    final content = CustomScrollView(
      slivers: [
        // Header band
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: isWide
                  ? const BorderRadius.only(
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              )
                  : const BorderRadius.only(
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
                    subtitle: 'Active Load: ${widget.activeLoad}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoadTrack(
                              tenantConfig: widget.tenantConfig,
                            )
                        ),
                      );
                    },
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
                    subtitle: 'Previous Loads: ${widget.prevLoads}',
                    onTap: () {},
                  ),
                  // Check-in / Check-out summary card
                  CheckSummaryTile(
                    statusText: _session.isCheckedIn
                        ? 'Checked in at ${_fmtTime(_session.checkInTime)}'
                        : (_session.checkOutTime != null
                        ? 'Checked out at ${_fmtTime(_session.checkOutTime)}'
                        : 'Not checked in'),
                    onTap: () async {
                      final result = await Navigator.push<CheckSession>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckInOutPage(initial: _session, tenantConfig: widget.tenantConfig),
                        ),
                      );
                      if (result != null && mounted) {
                        setState(() => _session = result);
                      }
                    },
                  ),
                  DashboardTile(
                    icon: Icons.work,
                    title: 'Work Queue',
                    subtitle: 'Upcoming Tasks: 0',
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: IndexAppBar(
        // backgroundColor: theme.primaryColor,
        title: 'Driver',
      ),
      // Mobile/tablet: use drawer. Desktop/web: Row layout (like homepage).
      drawer: isWide ? null : SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
      body: isWide
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar fixed on the left
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 260, maxWidth: 300),
            child: SideBarMenu(context, loads, addLoadData, widget.tenantConfig),
          ),
          const VerticalDivider(width: 1),
          // Main content
          Expanded(child: content),
        ],
      )
          : content,
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
            color: theme.primaryColor.withOpacity(.12),
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.info_rounded, color: theme.primaryColor),
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
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white, size: 36),
                    const Spacer(),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
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

class CheckSummaryTile extends StatelessWidget {
  final String statusText;
  final VoidCallback onTap;
  const CheckSummaryTile({super.key, required this.statusText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
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
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time_rounded, color: Colors.white, size: 36),
                      const Spacer(),
                      Text(
                        'Check in / Check out',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
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
