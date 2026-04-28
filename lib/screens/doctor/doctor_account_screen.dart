import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class DoctorAccountScreen extends StatelessWidget {
  const DoctorAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200, pinned: true,
          backgroundColor: const Color(0xFF006064), automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF004D40), Color(0xFF26C6DA)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.medical_services, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 12),
                Text('Dr. Hasni', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('Généraliste • 8 ans d\'expérience', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              ]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: Column(children: [
                  _InfoRow(Icons.badge_outlined, 'Nom professionnel', 'Dr. Hasni Ahmed'),
                  _InfoRow(Icons.local_hospital_outlined, 'Spécialité', 'Généraliste'),
                  _InfoRow(Icons.work_history_outlined, 'Ancienneté', '8 ans'),
                  _InfoRow(Icons.star_outline, 'Note', '4.8 / 5.0'),
                ]),
              ),
              const SizedBox(height: 16),
              _MenuItem(icon: Icons.payment_outlined, label: 'Moyens de paiement', onTap: () {}),
              _MenuItem(icon: Icons.schedule_outlined, label: 'Mes horaires', onTap: () {}),
              _MenuItem(icon: Icons.settings_outlined, label: 'Paramètres', onTap: () {}),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Se déconnecter', style: GoogleFonts.poppins(color: AppColors.danger, fontWeight: FontWeight.w600)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF006064), size: 20),
        const SizedBox(width: 14),
        Text(label, style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13)),
        const Spacer(),
        Text(value, style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 13)),
      ]),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF006064)),
        title: Text(label, style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
