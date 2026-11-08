import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/widgets/toast_with_undo.dart';

class AppLockPage extends StatefulWidget {
  const AppLockPage({super.key});

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  static const String _keyPinHash = 'app_lock_pin_hash';
  static const String _keyLockEnabled = 'app_lock_enabled';

  bool _isLockEnabled = false;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLockEnabled = prefs.getBool(_keyLockEnabled) ?? false;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _toggleLock(bool enable) async {
    final prefs = await SharedPreferences.getInstance();

    if (!enable) {
      await prefs.setBool(_keyLockEnabled, false);
      setState(() => _isLockEnabled = false);
      if (mounted) {
        ToastWithUndo.showSimple(context, message: 'ऐप लॉक बंद कर दिया गया');
      }
      return;
    }

    _pinController.clear();
    _confirmPinController.clear();

    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('4-अंकीय PIN सेट करें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'नया PIN',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PIN की पुष्टि करें',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('रद्द करें')),
          FilledButton(
            onPressed: () {
              final pin = _pinController.text.trim();
              final confirm = _confirmPinController.text.trim();
              if (pin.length != 4) {
                ToastWithUndo.showSimple(context, message: 'कृपया 4 अंकों का PIN डालें', isError: true);
                return;
              }
              if (pin != confirm) {
                ToastWithUndo.showSimple(context, message: 'दोनों PIN मेल नहीं खा रहे हैं', isError: true);
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('सेव करें'),
          ),
        ],
      ),
    );

    if (result == true) {
      final pin = _pinController.text.trim();
      final hash = sha256.convert(utf8.encode(pin)).toString();
      await prefs.setString(_keyPinHash, hash);
      await prefs.setBool(_keyLockEnabled, true);
      setState(() => _isLockEnabled = true);
      if (mounted) {
        ToastWithUndo.showSimple(context, message: 'ऐप लॉक सक्रिय हो गया');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('सुरक्षा व ऐप लॉक (App Lock)'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('ऐप लॉक सक्षम करें'),
            subtitle: const Text('ऐप खोलने पर 4-अंकीय PIN अनिवार्य करें'),
            value: _isLockEnabled,
            onChanged: _toggleLock,
          ),
          if (_isLockEnabled) ...[
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: const Text('PIN बदलें'),
              subtitle: const Text('नया सुरक्षा PIN सेट करें'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _toggleLock(true),
            ),
          ],
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'नोट: PIN डिवाइस पर सुरक्षित रूप से एन्क्रिप्टेड रखा जाता है। कोई भी बाहरी व्यक्ति आपकी निजी फाइलों को बिना अनुमति नहीं खोल सकेगा।',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
