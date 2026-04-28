import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = MockData.rendezVous;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mes patients', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Salle d\'attente – ${patients.length} patients', style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text('22/05/2026', style: GoogleFonts.poppins(color: AppColors.success, fontWeight: FontWeight.w600)),
        ),
        ...patients.map((rv) => _PatientItem(rv: rv)),
      ]),
    );
  }
}

class _PatientItem extends StatelessWidget {
  final RendezVousModel rv;
  const _PatientItem({required this.rv});

  @override
  Widget build(BuildContext context) {
    final time = '${rv.dateTime.hour.toString().padLeft(2,'0')}:${rv.dateTime.minute.toString().padLeft(2,'0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rv.patientNom, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          TextButton(onPressed: () {}, style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0,0)),
            child: Text('plus d\'info', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primary))),
        ])),
        Text(time, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.danger)),
      ]),
    );
  }
}
