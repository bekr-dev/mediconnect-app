import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../patient/patient_home_screen.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});
  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _nomController = TextEditingController();
  final _dateController = TextEditingController();
  final _tailleController = TextEditingController();
  final _poidsController = TextEditingController();
  String _sexe = 'Homme';
  bool _loading = false;

  void _finish() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
      (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFFF0F4F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Espace Patient', style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informations personnelles', style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text('Complétez votre profil patient', style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.textGrey)),
                        const SizedBox(height: 24),
                        _buildLabel('Nom complet'),
                        TextField(controller: _nomController,
                          decoration: const InputDecoration(
                            hintText: 'Votre nom complet',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.primary))),
                        const SizedBox(height: 16),
                        _buildLabel('Date de naissance'),
                        TextField(controller: _dateController,
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime(1990),
                              firstDate: DateTime(1920),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              _dateController.text =
                                  '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'JJ/MM/AAAA',
                            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary))),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _buildLabel('Taille (cm)'),
                              TextField(controller: _tailleController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '170',
                                  prefixIcon: Icon(Icons.height, color: AppColors.primary))),
                            ])),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _buildLabel('Poids (kg)'),
                              TextField(controller: _poidsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '70',
                                  prefixIcon: Icon(Icons.monitor_weight_outlined, color: AppColors.primary))),
                            ])),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Sexe'),
                        Row(
                          children: [
                            _SexeButton(label: 'Homme', icon: Icons.male, selected: _sexe == 'Homme',
                              onTap: () => setState(() => _sexe = 'Homme')),
                            const SizedBox(width: 12),
                            _SexeButton(label: 'Femme', icon: Icons.female, selected: _sexe == 'Femme',
                              onTap: () => setState(() => _sexe = 'Femme')),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _finish,
                            child: _loading
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Terminer', style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: GoogleFonts.poppins(
      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
  );
}

class _SexeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SexeButton({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : AppColors.textGrey, size: 20),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(
              color: selected ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
