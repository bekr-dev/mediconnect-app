import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class DoctorRequestsScreen extends StatefulWidget {
  const DoctorRequestsScreen({super.key});
  @override
  State<DoctorRequestsScreen> createState() => _DoctorRequestsScreenState();
}

class _DoctorRequestsScreenState extends State<DoctorRequestsScreen> {
  List<RendezVousModel> _requests = MockData.rendezVous.where((r) => r.statut == 'en_attente').toList();

  void _accept(RendezVousModel rv) {
    setState(() => _requests.remove(rv));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Rendez-vous de ${rv.patientNom} confirmé !', style: GoogleFonts.poppins()),
      backgroundColor: AppColors.success,
    ));
  }

  void _refuse(RendezVousModel rv) {
    setState(() => _requests.remove(rv));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Demande de ${rv.patientNom} refusée.', style: GoogleFonts.poppins()),
      backgroundColor: AppColors.danger,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Demandes de rendez-vous', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
      ),
      body: _requests.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
              const SizedBox(height: 16),
              Text('Aucune demande en attente', style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 16)),
            ]))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('${_requests.length} demande(s) en attente', style: GoogleFonts.poppins(
                  color: AppColors.textGrey, fontSize: 13)),
                const SizedBox(height: 16),
                ..._requests.map((rv) => _RequestCard(rv: rv, onAccept: () => _accept(rv), onRefuse: () => _refuse(rv))),
              ],
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RendezVousModel rv;
  final VoidCallback onAccept, onRefuse;
  const _RequestCard({required this.rv, required this.onAccept, required this.onRefuse});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.person, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rv.patientNom, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
              Text('${rv.dateTime.day.toString().padLeft(2,'0')}/${rv.dateTime.month.toString().padLeft(2,'0')}/${rv.dateTime.year}  •  ${rv.dateTime.hour.toString().padLeft(2,'0')}:${rv.dateTime.minute.toString().padLeft(2,'0')}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
              TextButton(onPressed: () {}, style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                child: Text('plus d\'info', style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12))),
            ])),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: onRefuse,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Refuser', style: GoogleFonts.poppins(color: AppColors.danger, fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Accepter', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            )),
          ]),
        ]),
      ),
    );
  }
}
