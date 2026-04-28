import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';

class PatientMapScreen extends StatefulWidget {
  const PatientMapScreen({super.key});

  @override
  State<PatientMapScreen> createState() => _PatientMapScreenState();
}

class _PatientMapScreenState extends State<PatientMapScreen> {
  final _searchCtrl = TextEditingController();

  String _selectedSpeciality = 'Tous';
  UserModel? _selectedDoctor;
  List<UserModel> _filteredDoctors = [];

  static const _specialties = [
    'Tous', 'Généraliste', 'Cardiologue', 'Pédiatre', 'Dermatologue',
  ];

  static const _center = LatLng(35.9368, 0.0893);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFilter());
  }

  void _updateFilter() {
    final state = context.read<AppState>();

    setState(() {
      if (_searchCtrl.text.isNotEmpty) {
        _filteredDoctors = state.searchDoctors(_searchCtrl.text);
      } else {
        if (_selectedSpeciality == 'Tous') {
          _filteredDoctors = state.allDoctors;
        } else {
          _filteredDoctors = state.allDoctors
              .where((d) => d.specialite == _selectedSpeciality)
              .toList();
        }
      }
    });
  }

  // ✅ CORRIGÉ
  void _requestAppointment(UserModel doctor) {
    context.read<AppState>().ajouterDemandeRendezVous(
      doctor.id,
      doctor.nomProfessionnel ?? '',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande envoyée à ${doctor.nomProfessionnel}'),
        backgroundColor: AppColors.success,
      ),
    );

    setState(() => _selectedDoctor = null);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (_filteredDoctors.isEmpty && _searchCtrl.text.isEmpty) {
      _filteredDoctors = state.allDoctors;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trouver un médecin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _updateFilter(),
                  decoration: const InputDecoration(
                    hintText: 'Nom du médecin...',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 10),

                // FILTERS
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialties.length,
                    itemBuilder: (_, i) {
                      final s = _specialties[i];
                      final selected = s == _selectedSpeciality;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedSpeciality = s);
                          _updateFilter();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s,
                            style: TextStyle(
                              color: selected ? AppColors.primary : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 🗺 MAP
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13,
                onTap: (_, __) => setState(() => _selectedDoctor = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: _filteredDoctors.map((doc) {
                    return Marker(
                      point: LatLng(doc.latitude ?? 0, doc.longitude ?? 0),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDoctor = doc),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // 👨‍⚕️ DOCTOR CARD
          if (_selectedDoctor != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedDoctor!.nomProfessionnel ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_selectedDoctor!.specialite ?? ''),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _requestAppointment(_selectedDoctor!),
                    child: const Text('Demander rendez-vous'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
