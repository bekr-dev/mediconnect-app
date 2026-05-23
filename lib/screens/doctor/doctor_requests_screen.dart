import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/models/models.dart';
import '/theme/app_theme.dart';
import 'doctor_home_screen.dart' show StatusBadge, RendezVousDetailSheet;

class DoctorRequestsScreen extends StatelessWidget {
  const DoctorRequestsScreen({super.key});

  String get _doctorId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<RendezVousModel>> _streamRequests() {
    return FirebaseFirestore.instance
        .collection('rendezVous')
        .where('doctorId', isEqualTo: _doctorId)
        .where('statut', isEqualTo: 'en_attente')
        //.orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RendezVousModel.fromMap(d.data(), d.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Demandes de rendez-vous',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<RendezVousModel>>(
        stream: _streamRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 80, color: AppColors.success),
                    const SizedBox(height: 16),
                    Text('Aucune demande en attente',
                        style: GoogleFonts.poppins(
                            color: AppColors.textGrey, fontSize: 16)),
                  ]),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('${requests.length} demande(s) en attente',
                  style: GoogleFonts.poppins(
                      color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 16),
              ...requests.map((rv) => _RequestCard(rv: rv)),
            ],
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RendezVousModel rv;
  const _RequestCard({required this.rv});

  Future<void> _acceptWithDate(BuildContext context) async {
    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    // 1. Choisir la date
    pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF00897B), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !context.mounted) return;

    // 2. Choisir l'heure
    pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF00897B), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null || !context.mounted) return;

    final confirmedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    try {
      await FirebaseFirestore.instance
          .collection('rendezVous')
          .doc(rv.id)
          .update({
        'statut': 'confirme',
        'dateTime': Timestamp.fromDate(confirmedDateTime),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Rendez-vous confirmé le ${DateFormat('dd/MM/yyyy à HH:mm').format(confirmedDateTime)}',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _refuseWithReason(BuildContext context) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Refuser la demande',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Indiquez la raison du refus :',
              style:
                  GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ex: Pas disponible à cette date...',
              hintStyle:
                  GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
                style: GoogleFonts.poppins(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('Confirmer le refus',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('rendezVous')
          .doc(rv.id)
          .update({
        'statut': 'annuler',
        'raisonRefus': ctrl.text.trim().isNotEmpty
            ? ctrl.text.trim()
            : 'Refusé par le médecin',
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Demande de ${rv.patientNom} refusée.',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.person, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rv.patientNom,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textDark)),
                    if (rv.specialite.isNotEmpty)
                      Text(rv.specialite,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textGrey)),
                    if (rv.motif.isNotEmpty)
                      Text('Motif: ${rv.motif}',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          child: RendezVousDetailSheet(rv: rv, isDoctor: false),
                        ),
                      ),
                      /*
                              showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24))),
                        builder: (_) =>
                            RendezVousDetailSheet(rv: rv, isDoctor: false),
                      ),*/
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0)),
                      child: Text('plus d\'info',
                          style: GoogleFonts.poppins(
                              color: AppColors.primary, fontSize: 12)),
                    ),
                  ]),
            ),
            StatusBadge(statut: rv.statut),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _refuseWithReason(context),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                child: Text('Refuser',
                    style: GoogleFonts.poppins(
                        color: AppColors.danger, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _acceptWithDate(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                child: Text('Accepter',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
