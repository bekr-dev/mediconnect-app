import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'patient_find_doctor_screen.dart';
import 'patient_appointments_screen.dart';
import 'patient_messages_screen.dart';
import 'patient_account_screen.dart';
import 'patient_symptom_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});
  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _PatientDashboard(),
    const PatientFindDoctorScreen(),
    const PatientAppointmentsScreen(),
    const PatientMessagesScreen(),
    const PatientAccountScreen(),
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
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil', index: 0, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search, label: 'Trouver', index: 1, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Rendez-vous', index: 2, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.message_outlined, activeIcon: Icons.message, label: 'Messages', index: 3, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Compte', index: 4, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
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
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? activeIcon : icon, color: active ? AppColors.primary : AppColors.textGrey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 10, color: active ? AppColors.primary : AppColors.textGrey,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
          if (active) Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4, height: 4,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _PatientDashboard extends StatelessWidget {
  const _PatientDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF26C6DA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Bonjour,', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                              Text('Ahmed Benali', style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                            ]),
                            const Spacer(),
                            Stack(
                              children: [
                                IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26), onPressed: () {}),
                                Positioned(right: 10, top: 10, child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                                )),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Comment vous sentez-vous\naujourd\'hui ?', style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Symptom AI card
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientSymptomScreen())),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text('IA Médicale', style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                            ]),
                            const SizedBox(height: 6),
                            Text('Décrivez vos\nsymptômes', style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Analyser maintenant →', style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                          const Spacer(),
                          const Icon(Icons.medical_information_outlined, color: Colors.white60, size: 70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Actions rapides', style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _QuickAction(icon: Icons.search, label: 'Trouver un\nmédecin', color: AppColors.primary,
                        onTap: () {})),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(icon: Icons.calendar_month, label: 'Mes\nrendez-vous', color: const Color(0xFF00897B),
                        onTap: () {})),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(icon: Icons.video_call_outlined, label: 'Télé-\nconsultation', color: const Color(0xFF7B1FA2),
                        onTap: () {})),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Prochains rendez-vous', style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 14),
                  _AppointmentCard(
                    doctor: 'Dr. Hasni',
                    specialite: 'Généraliste',
                    date: '22 Mai 2026',
                    heure: '09:30',
                    status: 'confirme',
                  ),
                  const SizedBox(height: 12),
                  _AppointmentCard(
                    doctor: 'Dr. Bouanani',
                    specialite: 'Cardiologue',
                    date: '25 Mai 2026',
                    heure: '11:00',
                    status: 'en_attente',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
        ),
        child: Column(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w500, height: 1.3),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String doctor, specialite, date, heure, status;
  const _AppointmentCard({required this.doctor, required this.specialite, required this.date, required this.heure, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool confirmed = status == 'confirme';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.medical_services_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doctor, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text(specialite, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.calendar_today, size: 12, color: AppColors.textGrey),
                const SizedBox(width: 4),
                Text('$date  •  $heure', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: confirmed ? AppColors.success.withOpacity(0.12) : AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(confirmed ? 'Confirmé' : 'En attente',
              style: GoogleFonts.poppins(
                fontSize: 11, color: confirmed ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
