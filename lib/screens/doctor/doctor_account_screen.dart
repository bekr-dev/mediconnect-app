import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/models/app_state.dart';
import '/theme/app_theme.dart';
import '../auth/login_screen.dart';

class DoctorAccountScreen extends StatelessWidget {
  const DoctorAccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final appState = context.read<AppState>();
    await FirebaseAuth.instance.signOut();
    await appState.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = context.watch<AppState>().currentUser;

    final nomAffiche = doctor?.nomProfessionnel ?? doctor?.nom ?? 'Médecin';
    final specialite = doctor?.specialite ?? '';
    final anciennete = doctor?.anciennete != null ? '${doctor!.anciennete} ans' : '—';
    final email = doctor?.email ?? '—';
    final tel = doctor?.numerodetel ?? '—';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: const Color(0xFF006064),
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF004D40), Color(0xFF26C6DA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
              child: SafeArea(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.medical_services, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 12),
                  Text(nomAffiche,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  if (specialite.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(specialite,
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                  ],
                ]),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
// ── Infos ──
Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Informations professionnelles',
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
      const SizedBox(height: 16),
      _InfoRow(Icons.badge_outlined, 'Nom professionnel', nomAffiche),
      const Divider(height: 24),
      if (specialite.isNotEmpty) ...[
        _InfoRow(Icons.local_hospital_outlined, 'Spécialité', specialite),
        const Divider(height: 24),
      ],
      _InfoRow(Icons.work_history_outlined, 'Ancienneté', anciennete),
      const Divider(height: 24),
      _InfoRow(Icons.email_outlined, 'Email', email),
      const Divider(height: 24),
      _InfoRow(Icons.phone_outlined, 'Téléphone', tel),
    ],
  ),
),
              const SizedBox(height: 16),
              _MenuItem(icon: Icons.payment_outlined, label: 'Moyens de paiement', onTap: () {}),
              _MenuItem(icon: Icons.schedule_outlined, label: 'Mes horaires', onTap: () {}),
              _MenuItem(icon: Icons.settings_outlined, label: 'Paramètres', onTap: () {}),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _logout(context),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text('Se déconnecter',
                      style: GoogleFonts.poppins(
                          color: AppColors.danger, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF006064).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF006064), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      color: AppColors.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.poppins(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF006064)),
        title: Text(label,
            style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
