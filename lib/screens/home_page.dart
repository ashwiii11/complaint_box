// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'complaint_form.dart';
import 'suggestion_page.dart';
import 'admin_dashboard.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _authSvc = AuthService();
  bool _isAdmin = false;
  bool _loading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = _authSvc.currentUser;
    if (user == null) {
      setState(() {
        _isAdmin = false;
        _loading = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      _isAdmin = data?['role'] == 'admin';
    } else {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email ?? 'anonymous',
        'role': 'user',
      });
      _isAdmin = false;
    }

    setState(() {
      _loading = false;
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isAdmin
        ? const AdminDashboard()
        : FadeTransition(opacity: _fadeAnimation, child: _buildUserHome(context));
  }

  Widget _buildUserHome(BuildContext context) {
    final user = _authSvc.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Complaint Box'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 241, 128, 68), Color.fromARGB(255, 176, 104, 27)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome, ${user?.email?.split('@')[0] ?? "Guest"} 👋',
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildDashboardCard(
                      context,
                      title: "Write Complaint",
                      icon: Icons.edit_note_rounded,
                      color: Colors.deepOrangeAccent,
                      onTap: () => _navigateWithSlide(context, const ComplaintForm()),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Suggestion Counter",
                      icon: Icons.lightbulb_outline_rounded,
                      color: Colors.purpleAccent,
                      onTap: () => _navigateWithSlide(context, const SuggestionsPage()),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "About App",
                      icon: Icons.info_outline_rounded,
                      color: const Color.fromARGB(255, 150, 45, 0),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("About"),
                            content: const Text(
                                "This Complaint Box app allows students or employees to submit complaints and suggestions easily. Admins can view all submissions and act accordingly."),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close")),
                            ],
                          ),
                        );
                      },
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Logout",
                      icon: Icons.exit_to_app_rounded,
                      color: Colors.redAccent,
                      onTap: () async {
                        await _authSvc.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateWithSlide(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: page,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
