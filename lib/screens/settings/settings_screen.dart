import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitu/core/ist_time.dart';
import 'package:habitu/services/fcm_service.dart';
import 'package:habitu/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _fcm = FcmService();
  final _local = NotificationService();

  String? _fcmToken;
  String? _fcmError;
  bool _loadingToken = false;
  bool _scheduling10s = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    setState(() {
      _loadingToken = true;
      _fcmError = null;
    });
    try {
      final t = await _fcm.getToken();
      if (!mounted) return;
      setState(() {
        _fcmToken = t;
        _fcmError = (t == null || t.isEmpty) ? 'Permission denied or unavailable' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fcmToken = null;
        _fcmError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loadingToken = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF141418),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          _SectionTitle('NOTIFICATIONS'),
          _Card(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Timezone', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Forced: ${IstTime.ianaZone} (IST everywhere)',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ),
                const Divider(color: Color(0x22FFFFFF), height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Request permissions', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'FCM (push) + Local notifications',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      await _fcm.requestPermission();
                      await _local.requestPermission();
                      if (!mounted) return;
                      _toast('Permission request sent');
                    },
                    child: const Text('Request', style: TextStyle(color: Colors.cyanAccent)),
                  ),
                ),
                const Divider(color: Color(0x22FFFFFF), height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Test local (now)', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Shows an immediate local notification',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      await _local.requestPermission();
                      await _local.showTestNow();
                      if (!mounted) return;
                      _toast('Triggered local notification');
                    },
                    child: const Text('Send', style: TextStyle(color: Colors.cyanAccent)),
                  ),
                ),
                const Divider(color: Color(0x22FFFFFF), height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Test local (10s)', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Keep app open ~10s, then a notification appears',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  trailing: _scheduling10s
                      ? const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                          ),
                        )
                      : TextButton(
                          onPressed: () async {
                            setState(() => _scheduling10s = true);
                            try {
                              await _local.requestPermission();
                              await _local.scheduleTestInSeconds(seconds: 10);
                              if (!mounted) return;
                              _toast('Notification sent after 10s');
                            } catch (e) {
                              if (!mounted) return;
                              _toast('Error: $e');
                            } finally {
                              if (mounted) setState(() => _scheduling10s = false);
                            }
                          },
                          child: const Text('Start', style: TextStyle(color: Colors.cyanAccent)),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle('PUSH (FCM) TEST'),
          if (_fcmError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _fcmError!,
                style: TextStyle(color: Colors.orange.withValues(alpha: 0.9), fontSize: 12),
              ),
            ),
          _Card(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('FCM token', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    _fcmToken ?? ( _fcmError ?? 'Loading…'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: _fcmToken != null ? 11 : 13,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: _loadingToken
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                        )
                      : TextButton(
                          onPressed: _loadToken,
                          child: const Text('Load', style: TextStyle(color: Colors.cyanAccent)),
                        ),
                ),
                const Divider(color: Color(0x22FFFFFF), height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Copy token', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Use it in Firebase Console / your backend to send a test push',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  trailing: TextButton(
                    onPressed: (_fcmToken == null || _fcmToken!.isEmpty)
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: _fcmToken!));
                            if (!mounted) return;
                            _toast('FCM token copied');
                          },
                    child: const Text('Copy', style: TextStyle(color: Colors.cyanAccent)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('DIAGNOSTICS'),
          _Card(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('What’s implemented', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    'Habit reminders (daily IST), local tests, FCM token helpers',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

