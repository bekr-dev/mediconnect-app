import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class PatientFindDoctorScreen extends StatefulWidget {
  const PatientFindDoctorScreen({super.key});
  @override
  State<PatientFindDoctorScreen> createState() => _PatientFindDoctorScreenState();
}

class _PatientFindDoctorScreenState extends State<PatientFindDoctorScreen> {
  final _searchController = TextEditingController();
  String _selectedSpeciality = 'Tous';
  final List<String> _specialities = ['Tous', 'Généraliste', 'Cardiologue', 'Pédiatre', 'Dermatologue'];
  List<UserModel> _filteredDoctors = MockData.doctors;
  bool _mapView = true;
  String? _selectedDoctorId;

  void _filter() {
    setState(() {
      _filteredDoctors = MockData.doctors.where((d) {
        final matchName = d.nomProfessionnel!.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchSpec = _selectedSpeciality == 'Tous' || d.specialite == _selectedSpeciality;
        return matchName && matchSpec;
      }).toList();
    });
  }

  void _showRdvDialog(UserModel doctor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _RdvSheet(doctor: doctor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20, right: 20, bottom: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Trouver un médecin', style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(_mapView ? Icons.list : Icons.map_outlined, color: Colors.white),
                    onPressed: () => setState(() => _mapView = !_mapView),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _filter(),
                  decoration: InputDecoration(
                    hintText: 'Entrer le nom du médecin',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                // Speciality chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialities.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final sel = _specialities[i] == _selectedSpeciality;
                      return GestureDetector(
                        onTap: () { setState(() => _selectedSpeciality = _specialities[i]); _filter(); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? Colors.white : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_specialities[i], style: GoogleFonts.poppins(
                            fontSize: 13, color: sel ? AppColors.primary : Colors.white,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Map or list
          Expanded(
            child: _mapView ? _buildMap() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(35.9290, 0.0900),
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.mediconnect.app',
        ),
        MarkerLayer(
          markers: _filteredDoctors.map((d) {
            final isSelected = _selectedDoctorId == d.id;
            return Marker(
              point: LatLng(d.latitude!, d.longitude!),
              width: 80,
              height: 80,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedDoctorId = d.id);
                  _showRdvDialog(d);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Icon(Icons.medical_services,
                        color: isSelected ? Colors.white : AppColors.primary, size: 22),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Text(d.nomProfessionnel!, style: GoogleFonts.poppins(
                        fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDoctors.length,
      itemBuilder: (_, i) {
        final d = _filteredDoctors[i];
        return _DoctorCard(doctor: d, onRdv: () => _showRdvDialog(d));
      },
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final UserModel doctor;
  final VoidCallback onRdv;
  const _DoctorCard({required this.doctor, required this.onRdv});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doctor.nomProfessionnel!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark)),
              Text(doctor.specialite!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary)),
              Text('${doctor.anciennete} d\'expérience', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
              Row(children: [
                ...List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < 4 ? Colors.amber : Colors.grey.shade300)),
                Text(' 4.0', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
              ]),
            ]),
          ),
          ElevatedButton(
            onPressed: onRdv,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('RDV', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _RdvSheet extends StatelessWidget {
  final UserModel doctor;
  const _RdvSheet({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.person, color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doctor.nomProfessionnel!, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark)),
              Text(doctor.specialite!, style: GoogleFonts.poppins(color: AppColors.primary)),
              Text(doctor.anciennete! + " d'expérience", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
            ]),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Demande de rendez-vous envoyée à ${doctor.nomProfessionnel} !',
                    style: GoogleFonts.poppins()), backgroundColor: AppColors.success));
              },
              child: Text('Demander un rendez-vous', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Annuler', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
