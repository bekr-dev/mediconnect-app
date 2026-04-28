import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../doctor/doctor_home_screen.dart';

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});
  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _nomProfController = TextEditingController();
  final _ancienneteController = TextEditingController();
  String _specialite = 'Généraliste';
  bool _loading = false;
  bool _showPayment = false;

  final List<String> _specialites = [
    'Généraliste', 'Cardiologue', 'Pédiatre', 'Dermatologue',
    'Gynécologue', 'Neurologue', 'Ophtalmologue', 'Orthopédiste',
  ];

  void _finish() async {
    setState(() { _loading = true; _showPayment = true; });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
      (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF006064), Color(0xFF00838F), Color(0xFFF0F4F8)],
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
                    Text('Espace Médecin', style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Informations professionnelles', style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                        Text('Complétez votre profil médecin', style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.textGrey)),
                        const SizedBox(height: 24),
                        _label('Nom professionnel'),
                        TextField(controller: _nomProfController,
                          decoration: const InputDecoration(
                            hintText: 'Dr. Nom Prénom',
                            prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary))),
                        const SizedBox(height: 16),
                        _label('Ancienneté'),
                        TextField(controller: _ancienneteController,
                          decoration: const InputDecoration(
                            hintText: "Nombre d'années d'expérience",
                            prefixIcon: Icon(Icons.work_history_outlined, color: AppColors.primary))),
                        const SizedBox(height: 16),
                        _label('Spécialité'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _specialite,
                              isExpanded: true,
                              icon: const Icon(Icons.expand_more, color: AppColors.primary),
                              items: _specialites.map((s) => DropdownMenuItem(
                                value: s, child: Text(s, style: GoogleFonts.poppins()))).toList(),
                              onChanged: (v) => setState(() => _specialite = v!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_showPayment) ...[
                          _PaymentSection(),
                          const SizedBox(height: 20),
                        ],
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _finish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006064),
                            ),
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

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
  );
}

class _PaymentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFA726)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.payment, color: Color(0xFFFFA726)),
            const SizedBox(width: 8),
            Text('Ajouter un moyen de paiement', style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: const Color(0xFFE65100))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _PayBtn(icon: Icons.credit_card, label: 'Carte'),
            const SizedBox(width: 8),
            _PayBtn(icon: Icons.account_balance, label: 'Virement'),
            const SizedBox(width: 8),
            _PayBtn(icon: Icons.phone_android, label: 'Mobile'),
          ]),
        ],
      ),
    );
  }
}

class _PayBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PayBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(children: [
          Icon(icon, color: const Color(0xFFFFA726), size: 22),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
        ]),
      ),
    );
  }
}
