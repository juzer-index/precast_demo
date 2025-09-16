import 'package:flutter/material.dart';
import 'UserScreens/Driver/DriverHomePage.dart' show CheckSession; // to reuse the data holder from main.dart

class CheckInOutPage extends StatefulWidget {
  final CheckSession? initial;

  const CheckInOutPage({super.key, this.initial});

  @override
  State<CheckInOutPage> createState() => _CheckInOutPageState();
}

class _CheckInOutPageState extends State<CheckInOutPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late bool _isCheckedIn;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  @override
  void initState() {
    super.initState();
    // Initialize from incoming session (if any)
    _isCheckedIn = widget.initial?.isCheckedIn ?? false;
    _checkInTime = widget.initial?.checkInTime;
    _checkOutTime = widget.initial?.checkOutTime;
  }

  String _fmtTime(DateTime? t) {
    if (t == null) return '--:--';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _checkIn() {
    setState(() {
      _isCheckedIn = true;
      _checkInTime = DateTime.now();
      _checkOutTime = null;
    });
    _toast('Checked in at ${_fmtTime(_checkInTime)}');
  }

  void _checkOut() {
    if (!_isCheckedIn) {
      _toast('You must check in first');
      return;
    }
    setState(() {
      _isCheckedIn = false;
      _checkOutTime = DateTime.now();
    });
    _toast('Checked out at ${_fmtTime(_checkOutTime)}');
  }

  void _reset() {
    setState(() {
      _isCheckedIn = false;
      _checkInTime = null;
      _checkOutTime = null;
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _saveAndClose() {
    Navigator.pop(
      context,
      CheckSession(isCheckedIn: _isCheckedIn, checkInTime: _checkInTime, checkOutTime: _checkOutTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        _saveAndClose(); // always return current session on back
        return false;
      },
      child: Scaffold(
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
          title: const Text('Check in / Check out',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
              onPressed: () => Navigator.pop(context,
                  CheckSession(isCheckedIn: _isCheckedIn, checkInTime: _checkInTime, checkOutTime: _checkOutTime)),
            ),
          ],
        ),

        // ---------- DRAWER ----------
        drawer: _CheckDrawer(onItemSelected: () => Navigator.pop(context)),

        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              _StatusCard(
                isCheckedIn: _isCheckedIn,
                checkIn: _fmtTime(_checkInTime),
                checkOut: _fmtTime(_checkOutTime),
              ),
              const SizedBox(height: 16),
              _ActionCard(
                isCheckedIn: _isCheckedIn,
                onCheckIn: _checkIn,
                onCheckOut: _checkOut,
                onReset: _reset,
                onSave: _saveAndClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckDrawer extends StatelessWidget {
  final VoidCallback onItemSelected;
  const _CheckDrawer({required this.onItemSelected});

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
                child: Text('Menu', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
              ),
            ),
            ListTile(leading: const Icon(Icons.dashboard_rounded), title: const Text('Dashboard'), onTap: onItemSelected),
            ListTile(leading: const Icon(Icons.access_time_rounded), title: const Text('Check in/Check out'), onTap: onItemSelected),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.settings_rounded), title: const Text('Settings'), onTap: onItemSelected),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isCheckedIn;
  final String checkIn;
  final String checkOut;
  const _StatusCard({required this.isCheckedIn, required this.checkIn, required this.checkOut});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.access_time_rounded, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          Text(
            isCheckedIn ? 'Status: Checked in' : 'Status: Not checked in',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('In:  $checkIn', style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 18),
              Text('Out: $checkOut', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final bool isCheckedIn;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const _ActionCard({
    required this.isCheckedIn,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: isCheckedIn ? null : onCheckIn,
                icon: const Icon(Icons.login_rounded),
                label: const Text('Check in'),
              ),
              ElevatedButton.icon(
                onPressed: isCheckedIn ? onCheckOut : null,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Check out'),
              ),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save & Close'),
          ),
        ],
      ),
    );
  }
}