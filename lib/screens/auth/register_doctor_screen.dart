import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../doctor/doctor_home_screen.dart';
import '/theme/app_theme.dart';
import 'package:geolocator/geolocator.dart';

class AppValidators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    if (value.length < 6) return 'Minimum 6 caractères';
    if (value.length > 50) return 'Maximum 50 caractères';
    return null;
  }
}

class RegisterDoctorScreen extends StatefulWidget {
  final String? googleUid;
  final String? googleEmail;
  final String? googleName;

  const RegisterDoctorScreen({
    super.key,
    this.googleUid,
    this.googleEmail,
    this.googleName,
  });

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
    final _nomProfCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _ancienneteCtrl = TextEditingController();

  bool _loading = false;
  String? _selectedSpecialite;
  List<String> _specialites = [];
  bool _loadingSpecialites = true;

  LatLng? _selectedLocation;
//  bool _obscure = true;


  bool get _isGoogleUser => widget.googleUid != null;

  @override
  void initState() {
    super.initState();
        _fetchSpecialites();
    if (widget.googleEmail != null) {
      _emailController.text = widget.googleEmail!;
    }
    if (widget.googleName != null) {
      _nomController.text = widget.googleName!;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _nomProfCtrl.dispose();
    _telCtrl.dispose();
    _ancienneteCtrl.dispose();
    super.dispose();
  }


  Future<void> _fetchSpecialites() async {
    final list = await DatabaseService().getSpecialites();
    if (mounted) {
      setState(() {
        _specialites = list;
        _loadingSpecialites = false;
      });
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
          builder: (_) => _MapPickerScreen(initial: _selectedLocation)),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  void _finish() async {
    setState(() => _loading = true);

    try {
      String uid;

      if (_isGoogleUser) {
        uid = widget.googleUid!;
      } else {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        uid = userCredential.user!.uid;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'nom': _nomController.text.trim(),
        'anciennete': _ancienneteCtrl.text.trim(),
        'nomProfessionnel': _nomProfCtrl.text.trim(),
        'role': 'doctor',
        'specialite': _selectedSpecialite,
        'tel': _telCtrl.text.trim(),
        'latitude':_selectedLocation?.latitude,
        'longitude':_selectedLocation?.longitude,
        'authProvider': _isGoogleUser ? 'google' : 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final isFirst = prefs.getBool('is_first_time') ?? true;
      if (isFirst) {
        await prefs.setBool('is_first_time', false);
      }
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
          (r) => false);
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
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
              // ── Header ───────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Espace Médecin',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    if (_isGoogleUser) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'By',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Google',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations personnelles',
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                          ),
                          Text(
                            'Complétez votre profil patient',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: AppColors.textGrey),
                          ),
                          const SizedBox(height: 24),

                          // ── Email/Password: ──
                          if (!_isGoogleUser) ...[
                            _buildLabel('Nom d\'utilisateur'),
                            TextFormField(
                              controller: _usernameController,
                              validator: AppValidators.required,
                              decoration: const InputDecoration(
                                  hintText: 'ex: ahmed_123',
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: AppColors.primary)),
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Email'),
                            TextFormField(
                              controller: _emailController,
                              validator: AppValidators.email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  hintText: 'exemple@mail.com',
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: AppColors.primary)),
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Mot de passe'),
                            TextFormField(
                              controller: _passwordController,
                              validator: AppValidators.password,
                              obscureText: true,
                              decoration: const InputDecoration(
                                  hintText: '••••••••',
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: AppColors.primary)),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Divider(),
                            ),
                          ],

                          // ──  Username Google ──
                          if (_isGoogleUser) ...[
                            _buildLabel('Nom d\'utilisateur'),
                            TextFormField(
                              controller: _usernameController,
                              validator: AppValidators.required,
                              decoration: const InputDecoration(
                                  hintText: 'ex: ahmed_123',
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: AppColors.primary)),
                            ),
                            const SizedBox(height: 16),

                            // Email read-only Google
                            _buildLabel('Email'),
                            TextFormField(
                              controller: _emailController,
                              readOnly: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email_outlined,
                                    color: AppColors.primary),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                suffixIcon: const Icon(Icons.verified,
                                    color: Colors.green, size: 18),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Divider(),
                            ),
                          ],

                          _buildLabel('Nom complet'),
                          TextFormField(
                            controller: _nomController,
                            validator: AppValidators.required,
                            decoration: const InputDecoration(
                                hintText: 'Votre nom complet',
                                prefixIcon: Icon(Icons.person_outline,
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Nom professionnel'),
                          TextFormField(
                            controller: _nomProfCtrl,
                            validator: AppValidators.required,
                            decoration: const InputDecoration(
                                hintText: 'Votre nom professionnel',
                                prefixIcon: Icon(Icons.person_outline,
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Numéro de téléphone'),
                          TextFormField(
                            controller: _telCtrl,
                            validator: AppValidators.required,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                hintText: '+213666666666',
                                prefixIcon: Icon(Icons.height,
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Ancienneté (années)'),
                          TextFormField(
                            controller: _ancienneteCtrl,
                            validator: AppValidators.required,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                hintText: 'ex : 8',
                                prefixIcon: Icon(Icons.height,
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Spécialité'),
                          _loadingSpecialites
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ))
                              : DropdownButtonFormField<String>(
                                  value: _selectedSpecialite,
                                  hint: Text('Choisir une spécialité',
                                      style: GoogleFonts.poppins(
                                          color: AppColors.textGrey)),
                                  items: _specialites
                                      .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s,
                                              style: GoogleFonts.poppins())))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedSpecialite = v),
                                  validator: (v) => v == null
                                      ? 'Veuillez choisir une spécialité'
                                      : null,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                        Icons.local_hospital_outlined,
                                        color: AppColors.primary),
                                  ),
                                ),

                          const SizedBox(height: 20),
                          _buildLabel('Localisation du cabinet'),
                          GestureDetector(
                            onTap: _openMapPicker,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: _selectedLocation != null
                                        ? const Color(0xFF00897B)
                                        : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: _selectedLocation != null
                                        ? const Color(0xFF00897B)
                                        : AppColors.textGrey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedLocation != null
                                          ? '${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}'
                                          : 'Appuyez pour choisir sur la carte',
                                      style: GoogleFonts.poppins(
                                        color: _selectedLocation != null
                                            ? AppColors.textDark
                                            : AppColors.textGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _selectedLocation != null
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_ios,
                                    color: _selectedLocation != null
                                        ? const Color(0xFF00897B)
                                        : AppColors.textGrey,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Terminer ───────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        _finish();
                                      }
                                    },
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      'Terminer',
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
        child: Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark),
        ),
      );
}


class _MapPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const _MapPickerScreen({this.initial});

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
  LatLng? _picked;
  final _mapCtrl = MapController();
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMsg('Activez le service de localisation');
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _showMsg('Permission de localisation refusée');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _picked = loc);
      _mapCtrl.move(loc, 15);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showMsg(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localisation du cabinet',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        actions: [
          if (_picked != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _picked),
              child: Text('Confirmer',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _picked ?? const LatLng(35.6969, -0.6331),
              initialZoom: 13,
              onTap: (_, latlng) => setState(() => _picked = latlng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mediconnect.app',
              ),
              if (_picked != null)
                MarkerLayer(markers: [
                  Marker(
                    point: _picked!,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_pin,
                        color: Color(0xFF00897B), size: 50),
                  ),
                ]),
            ],
          ),
          // Instructions
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 8)
                ],
              ),
              child: Text(
                'Appuyez sur la carte pour sélectionner l\'emplacement de votre cabinet',
                style:
                    GoogleFonts.poppins(fontSize: 12, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Bouton Ma position
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'my_loc',
              onPressed: _locating ? null : _goToMyLocation,
              backgroundColor: Colors.white,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location,
                      color: Color(0xFF00897B)),
            ),
          ),
          // Bouton Confirmer en bas
          if (_picked != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _picked),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Confirmer cette position',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

