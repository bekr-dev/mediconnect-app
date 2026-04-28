import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';

class PatientAppointmentsTab extends StatelessWidget {
const PatientAppointmentsTab({super.key});

@override
Widget build(BuildContext context) {
final state = context.watch<AppState>();
final confirmed = state.myAppointments;

return Scaffold(
backgroundColor: AppColors.background,
appBar: AppBar(
title: const Text('Mes Rendez-vous'),
backgroundColor: AppColors.primary,
foregroundColor: Colors.white,
elevation: 0,
automaticallyImplyLeading: false,
),
body: confirmed.isEmpty
? _emptyState()
    : ListView(
padding: const EdgeInsets.all(20),
children: [
Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
decoration: BoxDecoration(
color: AppColors.success,
borderRadius: BorderRadius.circular(20),
),
child: const Text(
'22/05/2026',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.w700,
fontSize: 15,
),
textAlign: TextAlign.center,
),
),
const SizedBox(height: 16),
...confirmed.map((appt) => _AppointmentItem(appointment: appt)),
const SizedBox(height: 80),
],
),
);
}

Widget _emptyState() {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textGrey),
const SizedBox(height: 16),
Text(
'Aucun rendez-vous confirmé',
style: TextStyle(
color: AppColors.textGrey,
fontSize: 16,
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 8),
Text(
'Demandez un rendez-vous depuis la carte',
style: TextStyle(color: AppColors.textGrey, fontSize: 13),
),
],
),
);
}
}

class _AppointmentItem extends StatelessWidget {
final RendezVousModel appointment;
const _AppointmentItem({required this.appointment});

@override
Widget build(BuildContext context) {
final time =
'${appointment.dateTime.hour}h${appointment.dateTime.minute.toString().padLeft(2, '0')}';

return Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
),
],
),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: AppColors.primaryLight.withOpacity(0.15),
shape: BoxShape.circle,
),
child: Icon(
Icons.medical_services_rounded,
color: AppColors.primary,
size: 22,
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
appointment.doctorNom,
style: TextStyle(
fontWeight: FontWeight.w700,
fontSize: 15,
color: AppColors.textDark,
),
),
const SizedBox(height: 2),
Text(
'Plus d\'info',
style: TextStyle(
color: AppColors.accent,
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
],
),
),
Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
time,
style: TextStyle(
color: AppColors.primary,
fontWeight: FontWeight.w700,
fontSize: 16,
),
),
const SizedBox(height: 4),
Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
decoration: BoxDecoration(
color: AppColors.success.withOpacity(0.12),
borderRadius: BorderRadius.circular(10),
),
child: Text(
'Confirmé',
style: TextStyle(
color: AppColors.success,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),
),
],
),
],
),
);
}
}

