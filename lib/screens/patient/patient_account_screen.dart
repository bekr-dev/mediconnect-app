import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class PatientAccountScreen extends StatelessWidget {
  const PatientAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.primary,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF26C6DA)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.person, color: Colors.white, size: 45),
                ),
                const SizedBox(height: 12),
                Text('Ahmed Benali', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('Patient', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
              ]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _InfoCard(items: [
                {'icon': 'person', 'label': 'Nom', 'value': 'Ahmed Benali'},
                {'icon': 'calendar_today', 'label': 'Date de naissance', 'value': '15/03/1990'},
                {'icon': 'height', 'label': 'Taille / Poids', 'value': '175 cm / 72 kg'},
                {'icon': 'male', 'label': 'Sexe', 'value': 'Homme'},
              ]),
              const SizedBox(height: 16),
              _MenuItem(icon: Icons.settings_outlined, label: 'Paramètres', onTap: () {}),
              _MenuItem(icon: Icons.help_outline, label: 'Aide', onTap: () {}),
              _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Confidentialité', onTap: () {}),
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

class _InfoCard extends StatelessWidget {
  final List<Map<String, String>> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(children: items.asMap().entries.map((e) {
        final item = e.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: e.key < items.length - 1 ? Border(bottom: BorderSide(color: Colors.grey.shade100)) : null),
          child: Row(children: [
            Icon(_getIcon(item['icon']!), color: AppColors.primary, size: 20),
            const SizedBox(width: 14),
            Text(item['label']!, style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13)),
            const Spacer(),
            Text(item['value']!, style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 13)),
          ]),
        );
      }).toList()),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'person': return Icons.person_outline;
      case 'calendar_today': return Icons.calendar_today_outlined;
      case 'height': return Icons.height;
      case 'male': return Icons.male;
      default: return Icons.info_outline;
    }
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
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
