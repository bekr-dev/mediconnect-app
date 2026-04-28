import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class PatientAppointmentsScreen extends StatelessWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rdvs = MockData.rendezVous;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mes rendez-vous', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF26C6DA)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_month, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${rdvs.length} rendez-vous', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('prévus ce mois', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Text('22 Mai 2026', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
          const SizedBox(height: 10),
          ...rdvs.map((rv) => _RdvCard(rv: rv)),
        ],
      ),
    );
  }
}

class _RdvCard extends StatelessWidget {
  final RendezVousModel rv;
  const _RdvCard({required this.rv});

  @override
  Widget build(BuildContext context) {
    final confirmed = rv.statut == 'confirme';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: confirmed ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.medical_services_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rv.doctorNom, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text('${rv.dateTime.hour.toString().padLeft(2,'0')}:${rv.dateTime.minute.toString().padLeft(2,'0')}',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: confirmed ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(confirmed ? 'Confirmé' : 'En attente',
              style: GoogleFonts.poppins(
                fontSize: 11, color: confirmed ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Plus d\'info', style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12)),
          ),
        ]),
      ]),
    );
  }
}
