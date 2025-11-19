import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicestuff/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _dobCtrl = TextEditingController(); // store as simple string (e.g. 01/01/2000)

  bool _loading = true;
  String? _error;

  final _auth = FirebaseAuth.instance;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    _emailCtrl.text = user.email ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _dobCtrl.text = data['dob'] ?? '';
      }
    } catch (_) {
      // ignore, dob is optional
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _updateEmail() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      await user.updateEmail(_emailCtrl.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated')),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to update email: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_passwordCtrl.text.trim().length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      await user.updatePassword(_passwordCtrl.text.trim());
      _passwordCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to update password: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveDob() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
            {'dob': _dobCtrl.text.trim()},
            SetOptions(merge: true),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DOB saved')),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to save DOB';
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Email
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _updateEmail,
              child: const Text('Update Email'),
            ),

            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _updatePassword,
              child: const Text('Update Password'),
            ),

            const SizedBox(height: 16),

            // DOB
            TextField(
              controller: _dobCtrl,
              decoration: const InputDecoration(
                  labelText: 'Date of Birth (e.g. 01/01/2000)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveDob,
              child: const Text('Save DOB'),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Logout
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: _logout,
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }
}
