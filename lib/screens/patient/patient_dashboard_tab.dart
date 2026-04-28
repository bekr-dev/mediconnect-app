import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';

enum UrgencyLevel { none, moderate, urgent }

class PatientDashboardTab extends StatefulWidget {
  const PatientDashboardTab({super.key});

  @override
  State<PatientDashboardTab> createState() => _PatientDashboardTabState();
}

class _PatientDashboardTabState extends State<PatientDashboardTab> {
  final _symptomsCtrl = TextEditingController();
  UrgencyLevel _urgencyLevel = UrgencyLevel.none;
  bool _analysisLoading = false;

  static final _specialties = [
    ('Généraliste', Icons.medical_services_outlined, AppColors.primary),
    ('Cardiologue', Icons.favorite_outline, Colors.red),
    ('Pédiatre', Icons.child_care_outlined, Colors.orange),
    ('Dermatologue', Icons.face_retouching_natural_outlined, Colors.purple),
    ('Neurologue', Icons.psychology_outlined, Colors.teal),
    ('ORL', Icons.hearing_outlined, Colors.green),
  ];

  void _analyzeSymptoms() async {
    if (_symptomsCtrl.text.trim().isEmpty) return;

    setState(() {
      _analysisLoading = true;
      _urgencyLevel = UrgencyLevel.none;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    final text = _symptomsCtrl.text.toLowerCase();

    if (text.contains('douleur poitrine') || text.contains('essoufflement')) {
      _urgencyLevel = UrgencyLevel.urgent;
    } else if (text.contains('fièvre') || text.contains('douleur')) {
      _urgencyLevel = UrgencyLevel.moderate;
    } else {
      _urgencyLevel = UrgencyLevel.none;
    }

    setState(() => _analysisLoading = false);
  }


  Color get _urgencyColor {
    switch (_urgencyLevel) {
      case UrgencyLevel.urgent:
        return AppColors.danger;
      case UrgencyLevel.moderate:
        return AppColors.warning;
      case UrgencyLevel.none:
        return AppColors.success;
    }
  }

  String get _urgencyMessage {
    switch (_urgencyLevel) {
      case UrgencyLevel.urgent:
        return '🔴 Cas urgent';
      case UrgencyLevel.moderate:
        return '🟡 Consultez bientôt';
      case UrgencyLevel.none:
        return '🟢 Pas urgent';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;

    // ✅ CORRIGÉ : utiliser myRendezVous
    final appointments = state.myRendezVous;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Text(
                  'Bonjour ${user?.username ?? ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Symptom input ──
                  TextField(
                    controller: _symptomsCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Décrivez vos symptômes...',
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _analyzeSymptoms,
                    child: _analysisLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Analyser'),
                  ),

                  const SizedBox(height: 10),

                  if (!_analysisLoading &&
                      _symptomsCtrl.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _urgencyColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _urgencyMessage,
                        style: TextStyle(color: _urgencyColor),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ── Next appointment ──
                  if (appointments.isEmpty)
                    const Text("Aucun rendez-vous")
                  else
                    _AppointmentCard(appointment: appointments.first),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final RendezVousModel appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appointment.doctorNom,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            '${appointment.dateTime.day}/${appointment.dateTime.month}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
