import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../auth/login_screen.dart';

class PatientAccountTab extends StatelessWidget {
const PatientAccountTab({super.key});

@override
Widget build(BuildContext context) {
final state = context.watch<AppState>();
final user = state.currentUser;

return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
title: const Text('Mon Compte'),
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
elevation: 0,
automaticallyImplyLeading: false,
),
body: ListView(
padding: const EdgeInsets.all(20),
children: [
// Profile card
Container(
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [AppColors.primary, AppColors.primaryLight],
),
borderRadius: BorderRadius.circular(20),
),
child: Row(
children: [
Container(
width: 70,
height: 70,
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.25),
shape: BoxShape.circle,
),
child: const Icon(Icons.person, color: Colors.white, size: 38),
),
const SizedBox(width: 18),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
user?.nom ?? user?.username ?? 'Patient',
style: const TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight: FontWeight.w700,
),
),
Text(
user?.email ?? '',
style: TextStyle(
color: Colors.white.withOpacity(0.8),
fontSize: 13,
),
),
const SizedBox(height: 6),
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
decoration: BoxDecoration(
color: AppColors.primary,
borderRadius: BorderRadius.circular(20),
),
child: const Text(
'👤 Patient',
style: TextStyle(color: Colors.white, fontSize: 12),
),
),
],
),
),
],
),
),

const SizedBox(height: 24),

// Info card
if (user != null) ...[
_infoCard([
_InfoRow(Icons.badge_outlined, 'Nom', user.nom ?? ''),
_InfoRow(Icons.cake_outlined, 'Date de naissance', user.dateNaissance ?? ''),
_InfoRow(Icons.straighten_outlined, 'Taille', user.taille ?? ''),
_InfoRow(Icons.monitor_weight_outlined, 'Poids', user.poids ?? ''),
_InfoRow(
user.sexe == 'homme' ? Icons.male : Icons.female,
'Sexe',
user.sexe ?? '',
),
]),
const SizedBox(height: 16),
],

_menuTile(Icons.edit_outlined, 'Modifier le profil', () {}),
_menuTile(Icons.payment_outlined, 'Moyens de paiement', () {}),
_menuTile(Icons.notifications_outlined, 'Notifications', () {}),
_menuTile(Icons.help_outline, 'Aide & Support', () {}),

const SizedBox(height: 16),

// Logout
SizedBox(
height: 52,
child: OutlinedButton.icon(
onPressed: () {
state.logout();
Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(builder: (_) => const LoginScreen()),
(_) => false,
);
},
icon: const Icon(Icons.logout, color: AppColors.danger),
label: const Text(
'Se déconnecter',
style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
),
style: OutlinedButton.styleFrom(
side: const BorderSide(color: AppColors.danger),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
),
),

const SizedBox(height: 100),
],
),
);
}

Widget _infoCard(List<Widget> rows) {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
],
),
child: Column(children: rows),
);
}

Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
return Container(
margin: const EdgeInsets.only(bottom: 10),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14),
boxShadow: [
BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
],
),
child: ListTile(
leading: Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: AppColors.primaryLight.withOpacity(0.12),
shape: BoxShape.circle,
),
child: Icon(icon, color: AppColors.primary, size: 20),
),
title: Text(label),
trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
onTap: onTap,
),
);
}
}

class _InfoRow extends StatelessWidget {
final IconData icon;
final String label;
final String value;

const _InfoRow(this.icon, this.label, this.value);

@override
Widget build(BuildContext context) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8),
child: Row(
children: [
Icon(icon, color: AppColors.primary, size: 20),
const SizedBox(width: 12),
Text(label, style: TextStyle(color: AppColors.textGrey)),
const Spacer(),
Text(
value,
style: TextStyle(
fontWeight: FontWeight.w600,
color: AppColors.textDark,
),
),
],
),
);
}
}
