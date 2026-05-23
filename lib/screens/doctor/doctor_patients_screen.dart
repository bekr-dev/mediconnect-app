import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/models/models.dart';
import '/theme/app_theme.dart';
import 'doctor_home_screen.dart' show StatusBadge, RendezVousDetailSheet;
//import 'doctor_home_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});
  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
//  DateTime _selectedDate = DateTime.now();
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 1)),
  );

  String get _doctorId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<RendezVousModel>> _streamPatients() {
    return FirebaseFirestore.instance
        .collection('rendezVous')
        .where('doctorId', isEqualTo: _doctorId)
        .where('statut', isEqualTo: 'confirme')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RendezVousModel.fromMap(d.data(), d.id))
            .toList());
  }

  bool _isSameDay(DateTime a, DateTimeRange b) =>
      (a.year >= b.start.year &&
          a.month >= b.start.month &&
          a.day >= b.start.day) &&
      (a.year <= b.end.year && a.month <= b.end.month && a.day <= b.end.day);

  Future<void> _pickDate() async {
    final picked = await showDateRangePicker(
      context: context,
      currentDate: DateTime.now(),
      //initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF00897B), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mes patients',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<RendezVousModel>>(
        stream: _streamPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRvs = snapshot.data ?? [];
          final filtered = allRvs
              .where((r) => _isSameDay(r.dateTime, _selectedDateRange))
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.success.withOpacity(0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      '${DateFormat('dd MMMM yyyy').format(_selectedDateRange.start)} - ${DateFormat('dd MMMM yyyy').format(_selectedDateRange.end)}',
                      style: GoogleFonts.poppins(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.expand_more,
                        color: AppColors.success, size: 18),
                  ]),
                ),
              ),
              Text(
                '${filtered.length} patient(s) ',
                style: GoogleFonts.poppins(
                    color: AppColors.textGrey, fontSize: 13),
              ),
              const SizedBox(height: 8),
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(children: [
                      Icon(Icons.event_busy,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text('Aucun patient ',
                          style:
                              GoogleFonts.poppins(color: AppColors.textGrey)),
                    ]),
                  ),
                )
              else
                ...filtered.map((rv) => _PatientCard(rv: rv)),
            ],
          );
        },
      ),
    );
  }
}

class _PatientCard extends StatefulWidget {
  final RendezVousModel rv;
  const _PatientCard({required this.rv});
  @override
  State<_PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<_PatientCard> {
  bool _updating = false;

  Future<void> _marquerTermine() async {
    setState(() => _updating = true);
    try {
      await FirebaseFirestore.instance
          .collection('rendezVous')
          .doc(widget.rv.id)
          .update({
        'statut': 'termine',
        'dateTime': Timestamp.fromDate(DateTime.now()),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Rendez-vous marqué comme terminé',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rv = widget.rv;
    final time = DateFormat('dd/MM/yyyy HH:mm').format(rv.dateTime);
//    '${rv.dateTime.hour.toString().padLeft(2, '0')}:${rv.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.person, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( rv.patientNom,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark)),
                    if (rv.motif.isNotEmpty)
                      Text(rv.motif,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    TextButton(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24))),
                        builder: (_) =>
                            RendezVousDetailSheet(rv: rv, isDoctor: true),
                      ),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0)),
                      child: Text('plus d\'info',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.primary)),
                    ),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(time,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger)),
              StatusBadge(statut: rv.statut),
            ]),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _updating ? null : _marquerTermine,
              icon: _updating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 18),
              label: Text('Marquer comme terminé',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ]),
      ),
    );
  }
}
