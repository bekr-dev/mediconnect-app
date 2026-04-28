import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'doctor_requests_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_messages_screen.dart';
import 'doctor_account_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DoctorDashboard(),
    const DoctorRequestsScreen(),
    const DoctorPatientsScreen(),
    const DoctorMessagesScreen(),
    const DoctorAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil', index: 0, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), color: const Color(0xFF006064)),
                _NavItem(icon: Icons.pending_actions_outlined, activeIcon: Icons.pending_actions, label: 'Demandes', index: 1, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), color: const Color(0xFF006064)),
                _NavItem(icon: Icons.group_outlined, activeIcon: Icons.group, label: 'Patients', index: 2, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), color: const Color(0xFF006064)),
                _NavItem(icon: Icons.message_outlined, activeIcon: Icons.message, label: 'Messages', index: 3, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), color: const Color(0xFF006064)),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Compte', index: 4, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i), color: const Color(0xFF006064)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final Function(int) onTap;
  final Color color;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index, required this.current, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    final bool active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? activeIcon : icon, color: active ? color : AppColors.textGrey, size: 24),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: active ? color : AppColors.textGrey, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        if (active) Container(margin: const EdgeInsets.only(top: 4), width: 4, height: 4,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ]),
    );
  }
}

class _DoctorDashboard extends StatelessWidget {
  const _DoctorDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: const Color(0xFF006064),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF004D40), Color(0xFF00897B), Color(0xFF26C6DA)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                    Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.medical_services, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Dr. Hasni', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('Généraliste', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                      ]),
                      const Spacer(),
                      Stack(children: [
                        IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26), onPressed: () {}),
                        Positioned(right: 10, top: 10, child: Container(width: 8, height: 8,
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle))),
                      ]),
                    ]),
                    const SizedBox(height: 16),
                    Text('Tableau de bord médecin', style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Stats row
              Row(children: [
                Expanded(child: _StatCard(icon: Icons.pending_actions, label: 'Demandes', value: '2', color: const Color(0xFF1565C0))),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.people_outline, label: 'Patients\naujourd\'hui', value: '4', color: const Color(0xFF00897B))),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.message_outlined, label: 'Messages', value: '3', color: const Color(0xFF7B1FA2))),
              ]),
              const SizedBox(height: 24),
              Text('Salle d\'attente - Aujourd\'hui', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: Text('22 Mai 2026', style: GoogleFonts.poppins(color: AppColors.success, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              _WaitingItem(name: 'Mr. Slimane', time: '09:30', index: 1),
              _WaitingItem(name: 'Mr. Hafid', time: '10:00', index: 2),
              _WaitingItem(name: 'Mr. Ahmed', time: '10:30', index: 3),
              _WaitingItem(name: 'Mm. Farah', time: '11:00', index: 4),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey, height: 1.3), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _WaitingItem extends StatelessWidget {
  final String name, time;
  final int index;
  const _WaitingItem({required this.name, required this.time, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: const Color(0xFF00897B).withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: Text('$index', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF00897B)))),
        ),
        const SizedBox(width: 14),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text('plus d\'info', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary)),
        ])),
        Text(time, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.danger)),
      ]),
    );
  }
}
