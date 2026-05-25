import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../doctor/doctor_home_screen.dart';
import 'login_doctor_screen.dart';

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

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen>
    with SingleTickerProviderStateMixin {

  static const Color _doc = Color(0xFF00897B);
  static const Color _docDark = Color(0xFF00695C);

  int _currentStep = 0;
  bool _loading = false;
  String _verificationId = '';
  final _formKey0 = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _obs1 = true, _obs2 = true;

  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());
  int _resendSec = 0;
  Timer? _resendTimer;

  final _formKey2 = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _onmoCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _nomProfCtrl = TextEditingController();
  String? _specialite;
  List<String> _specialites = [];
  bool _loadingSpecialites = true;

  int _locMethod = 0;
  LatLng _mapCenter = const LatLng(36.7538, 3.0588);
  LatLng? _selectedPos;
  final _wilayaCtrl = TextEditingController();
  final _communeCtrl = TextEditingController();
  final _rueCtrl = TextEditingController();
  final _cabinetNumCtrl = TextEditingController();

  final Map<String, bool> _workDays = {
    'Samedi': true, 'Dimanche': true, 'Lundi': true,
    'Mardi': true, 'Mercredi': true, 'Jeudi': true, 'Vendredi': false,
  };
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  String? _consultDuration;
  String? _consultTarif;

  bool _onmoUploaded = false, _diplomaUploaded = false, _profileUploaded = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  bool get _isGoogleUser => widget.googleUid != null;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
    _fetchSpecialites();
    
    if (widget.googleEmail != null) {
      _emailCtrl.text = widget.googleEmail!;
    }
    if (widget.googleName != null) {
      _nameCtrl.text = widget.googleName!;
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _resendTimer?.cancel();
    _emailCtrl.dispose(); _passCtrl.dispose(); _passConfCtrl.dispose(); _usernameCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpNodes) f.dispose();
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _onmoCtrl.dispose(); _expCtrl.dispose(); _nomProfCtrl.dispose();
    _wilayaCtrl.dispose(); _communeCtrl.dispose(); _rueCtrl.dispose(); _cabinetNumCtrl.dispose();
    _startTimeCtrl.dispose(); _endTimeCtrl.dispose();
    super.dispose();
  }

  
  /* otp */
  Future<void> _sendPhoneOTP() async {
  // استخدم رقم الهاتف من _phoneCtrl
  final phoneNumber = '+213${_phoneCtrl.text.trim()}'; // مثال للجزائر
  
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    timeout: const Duration(seconds: 60),
    
    verificationCompleted: (PhoneAuthCredential credential) async {
      // تم التحقق تلقائياً (Android فقط)
      await FirebaseAuth.instance.signInWithCredential(credential);
      _goTo(2);
    },
    
    verificationFailed: (FirebaseAuthException e) {
      _showMsg('فشل الإرسال: ${e.message}');
    },
    
    codeSent: (String verificationId, int? resendToken) {
      _verificationId = verificationId;
      _startResend();
      _goTo(1); // الانتقال لصفحة إدخال OTP
    },
    
    codeAutoRetrievalTimeout: (String verificationId) {
      _verificationId = verificationId;
    },
  );
}

Future<void> _verifyOtp() async {
  final code = _otpCtrls.map((c) => c.text).join();
  if (code.length != 6) return;
  
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: code,
    );
    
    await FirebaseAuth.instance.signInWithCredential(credential);
    _goTo(2); // الانتقال للخطوة التالية
  } catch (e) {
    _showMsg('كود خاطئ: ${e.toString()}');
  }
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

  void _goTo(int s) {
    _animCtrl.reverse().then((_) {
      setState(() => _currentStep = s);
      _animCtrl.forward();
    });
  }

  void _submitAccount() {
    if (_formKey0.currentState!.validate()) {
      if (_isGoogleUser) {
        _goTo(2);
      } else {
      _sendPhoneOTP();
        _goTo(1);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _otpNodes[0].requestFocus();
        });
      }
    }
  }

/*  void _verifyOtp() {
    if (_otpCtrls.map((c) => c.text).join().length == 6) _goTo(2);
  }*/

  void _submitIdentity() {
    if (_formKey2.currentState!.validate()) _goTo(3);
  }

  void _submitLocation() => _goTo(4);
  void _submitSchedule() => _goTo(5);

  void _finish() async {
    setState(() => _loading = true);

    try {
      String uid;

      if (_isGoogleUser) {
        uid = widget.googleUid!;
      } else {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        uid = userCredential.user!.uid;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'username': _usernameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'nom': _nameCtrl.text.trim(),
        'nomProfessionnel': _nomProfCtrl.text.trim(),
        'numerodetel': _phoneCtrl.text.trim(),
        'onmoNumber': _onmoCtrl.text.trim(),
        'specialite': _specialite,
        'anciennete': _expCtrl.text.trim(),
        'role': 'doctor',
        'isActive': false,
        'latitude': _selectedPos?.latitude,
        'longitude': _selectedPos?.longitude,
        'wilaya': _wilayaCtrl.text.trim(),
        'commune': _communeCtrl.text.trim(),
        'rue': _rueCtrl.text.trim(),
        'cabinetNum': _cabinetNumCtrl.text.trim(),
        'workDays': _workDays,
        'startTime': _startTimeCtrl.text.trim(),
        'endTime': _endTimeCtrl.text.trim(),
        'consultDuration': _consultDuration,
        'consultTarif': _consultTarif,
        'onmoUploaded': _onmoUploaded,
        'diplomaUploaded': _diplomaUploaded,
        'profileUploaded': _profileUploaded,
        'authProvider': _isGoogleUser ? 'google' : 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_time', false);
      
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

  void _startResend() {
    _resendTimer?.cancel();
    setState(() => _resendSec = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSec <= 1) { t.cancel(); setState(() => _resendSec = 0); }
      else setState(() => _resendSec--);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_docDark, _doc, Color(0xFFF0F4F8)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 0.5],
          ),
        ),
        child: SafeArea(child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  if (_currentStep > 0) _goTo(_currentStep - 1);
                  else Navigator.pop(context);
                },
              ),
              Expanded(child: Text('Inscription Médecin',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white))),
              if (_isGoogleUser)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('By', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                    const SizedBox(width: 6),
                    Image.network('https://www.google.com/favicon.ico', height: 16),
                    const SizedBox(width: 4),
                    Text('Google', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white)),
                  ]),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildSteps(),
          ),
          const SizedBox(height: 4),
          Expanded(child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4F8),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: FadeTransition(opacity: _fadeAnim, child: _body()),
          )),
        ])),
      ),
    );
  }

  Widget _body() {
    switch (_currentStep) {
      case 0: return _step0();
      case 1: return _step1();
      case 2: return _step2();
      case 3: return _step3();
      case 4: return _step4();
      case 5: return _step5();
      default: return const SizedBox();
    }
  }

  Widget _buildSteps() {
    final labels = _isGoogleUser 
      ? ['Compte', 'Identité', 'Cabinet', 'Horaires', 'Documents']
      : ['Compte', 'Code', 'Identité', 'Cabinet', 'Horaires', 'Documents'];
    final totalSteps = _isGoogleUser ? 5 : 6;
    
    return Row(children: [
      for (int i = 0; i < totalSteps; i++) ...[
        if (i > 0) Expanded(child: Container(height: 2,
          color: _currentStep >= i ? Colors.white : Colors.white.withValues(alpha: 0.25))),
        _dot(i, labels[i]),
      ],
    ]);
  }

  Widget _dot(int i, String label) {
    final active = _currentStep >= i;
    final current = _currentStep == i;
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: current ? 30 : 24, height: current ? 30 : 24,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.25),
          boxShadow: current ? [BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 8)] : []),
        child: Center(child: Text('${i + 1}', style: GoogleFonts.poppins(
          fontSize: current ? 13 : 11, fontWeight: FontWeight.w700,
          color: active ? _doc : Colors.white70))),
      ),
      const SizedBox(height: 3),
      Text(label, style: GoogleFonts.poppins(fontSize: 8,
        color: Colors.white.withValues(alpha: active ? 1.0 : 0.5), fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _step0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(key: _formKey0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Créer votre compte', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text('Entrez vos identifiants pour commencer', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 8),
        Center(child: Container(width: 80, height: 80,
          decoration: BoxDecoration(color: _doc.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: const Icon(Icons.local_hospital, size: 40, color: _doc))),
        const SizedBox(height: 24),
        _lbl('Nom d\'utilisateur'),
        _field(_usernameCtrl, 'ex: ahmed_123', Icons.person_outline,
          validator: (v) => (v == null || v.isEmpty) ? 'Ce champ est obligatoire' : null),
        const SizedBox(height: 16),
        _lbl('Numéro de téléphone'),
        _field(_phoneCtrl, '0555 123 456', Icons.phone_outlined, keyboard: TextInputType.phone,
          validator: (v) => (v == null || v.isEmpty) ? 'Ce champ est obligatoire' : null),
        const SizedBox(height: 16),
        _lbl('Email'),
        _field(_emailCtrl, _isGoogleUser ? widget.googleEmail! : 'votre@email.com', Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
          readOnly: _isGoogleUser,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ce champ est obligatoire';
            if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
            return null;
          }),
        if (!_isGoogleUser) ...[
          const SizedBox(height: 16),
          _lbl('Mot de passe'),
          TextFormField(controller: _passCtrl, obscureText: _obs1,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ce champ est obligatoire';
              if (v.length < 6) return '6 caractères minimum';
              return null;
            },
            decoration: _inputDeco('Créez un mot de passe', Icons.lock_outline,
              suffix: IconButton(icon: Icon(_obs1 ? Icons.visibility_off : Icons.visibility, color: AppColors.textGrey),
                onPressed: () => setState(() => _obs1 = !_obs1)))),
          const SizedBox(height: 16),
          _lbl('Confirmer le mot de passe'),
          TextFormField(controller: _passConfCtrl, obscureText: _obs2,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ce champ est obligatoire';
              if (v != _passCtrl.text) return 'Les mots de passe ne correspondent pas';
              return null;
            },
            decoration: _inputDeco('Retapez votre mot de passe', Icons.lock_outline,
              suffix: IconButton(icon: Icon(_obs2 ? Icons.visibility_off : Icons.visibility, color: AppColors.textGrey),
                onPressed: () => setState(() => _obs2 = !_obs2)))),
        ],
        const SizedBox(height: 32),
        _btn('Continuer', _submitAccount),
        const SizedBox(height: 16),
        _loginLink(),
      ])),
    );
  }

  Widget _step1() {
    final email = _emailCtrl.text.isNotEmpty ? _emailCtrl.text : 'votre@email.com';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(children: [
        const SizedBox(height: 16),
        Container(width: 90, height: 90,
          decoration: BoxDecoration(color: _doc.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_outlined, size: 44, color: _doc)),
        const SizedBox(height: 24),
        Text('Vérification', textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Text('Un code a été envoyé à $email', textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) => Container(
            width: 48, height: 56, margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
            child: TextFormField(
              controller: _otpCtrls[i], focusNode: _otpNodes[i],
              keyboardType: TextInputType.number, textAlign: TextAlign.center, maxLength: 1,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _doc, width: 2))),
              onChanged: (val) {
                if (val.isNotEmpty && i < 5) _otpNodes[i + 1].requestFocus();
                else if (val.isEmpty && i > 0) _otpNodes[i - 1].requestFocus();
                if (i == 5 && val.isNotEmpty && _otpCtrls.map((c) => c.text).join().length == 6) _verifyOtp();
              },
            ),
          ))),
        const SizedBox(height: 28),
        _btn('Vérifier', _verifyOtp),
        const SizedBox(height: 20),
        _resendSec > 0
          ? Text('Renvoyer dans ${_resendSec}s', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey))
          : GestureDetector(onTap: _sendPhoneOTP,
              child: Text('Renvoyer le code', style: GoogleFonts.poppins(fontSize: 13, color: _doc,
                fontWeight: FontWeight.w600, decoration: TextDecoration.underline))),
      ]),
    );
  }

  Widget _step2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Form(key: _formKey2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Identité professionnelle', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text('Informations obligatoires', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 24),
        _lbl('Nom et prénom complet'),
        _field(_nameCtrl, 'Dr. Nom Prénom', Icons.badge_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Ce champ est obligatoire' : null),
        const SizedBox(height: 16),
        _lbl('Nom professionnel'),
        _field(_nomProfCtrl, 'Nom sur documents', Icons.verified_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Ce champ est obligatoire' : null),
        const SizedBox(height: 16),
        _lbl('Numéro ONMO'),
        _field(_onmoCtrl, 'Ordre National des Médecins', Icons.verified_outlined,
          validator: (v) => (v == null || v.isEmpty) ? 'Ce champ est obligatoire' : null),
        const SizedBox(height: 16),
        _lbl('Spécialité'),
        _loadingSpecialites
          ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          : _dropdown<String>(
              value: _specialite, hint: 'Choisir une spécialité', icon: Icons.medical_services_outlined,
              items: _specialites.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
              onChanged: (v) => setState(() => _specialite = v),
            ),
        const SizedBox(height: 16),
        _lbl('Années d\'expérience'),
        _field(_expCtrl, 'Nombre d\'années', Icons.work_history_outlined, keyboard: TextInputType.number),
        const SizedBox(height: 32),
        _btnNext('Suivant', _submitIdentity),
        const SizedBox(height: 16),
        _loginLink(),
      ])),
    );
  }

  Widget _step3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Localisation du cabinet', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text('Indiquez l\'emplacement de votre cabinet', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _tabBtn(0, Icons.map_outlined, 'Sur la carte', _locMethod == 0)),
          const SizedBox(width: 10),
          Expanded(child: _tabBtn(1, Icons.edit_note, 'Saisie manuelle', _locMethod == 1)),
        ]),
        if (_locMethod == 0) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _doc.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star, size: 14, color: _doc),
              const SizedBox(width: 4),
              Text('Recommandé', style: GoogleFonts.poppins(fontSize: 11, color: _doc, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        _locMethod == 0 ? _mapView() : _manualLocation(),
        const SizedBox(height: 32),
        _btnNext('Suivant', _submitLocation),
      ]),
    );
  }

  Widget _mapView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 260,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _mapCenter,
                  initialZoom: 12,
                  onTap: (_, pos) => setState(() => _selectedPos = pos),
                ),
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.mediconnect.app'),
                  MarkerLayer(markers: [
                    if (_selectedPos != null) Marker(
                      point: _selectedPos!, width: 40, height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ]),
                ],
              ),
              Positioned(
                bottom: 10, right: 10,
                child: FloatingActionButton.small(
                  heroTag: 'my_loc',
                  onPressed: _goToMyLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: _doc),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Icon(_selectedPos != null ? Icons.check_circle : Icons.info_outline,
            color: _selectedPos != null ? _doc : AppColors.textGrey, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(
            _selectedPos != null
              ? 'Position : ${_selectedPos!.latitude.toStringAsFixed(4)}, ${_selectedPos!.longitude.toStringAsFixed(4)}'
              : 'Appuyez sur la carte pour sélectionner l\'emplacement',
            style: GoogleFonts.poppins(fontSize: 12, color: _selectedPos != null ? _doc : AppColors.textGrey),
          )),
        ]),
      ),
    ]);
  }

  Future<void> _goToMyLocation() async {
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
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _selectedPos = LatLng(pos.latitude, pos.longitude));
    } catch (e) {
      _showMsg('Erreur: ${e.toString()}');
    }
  }

  void _showMsg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Widget _manualLocation() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _lbl('Wilaya'),
      _field(_wilayaCtrl, 'Ex: Alger', Icons.map_outlined),
      const SizedBox(height: 14),
      _lbl('Commune / Daïra'),
      _field(_communeCtrl, 'Ex: Bab El Oued', Icons.location_city),
      const SizedBox(height: 14),
      _lbl('Rue / Quartier'),
      _field(_rueCtrl, 'Ex: Rue Didouche Mourad', Icons.signpost_outlined),
      const SizedBox(height: 14),
      _lbl('Numéro du cabinet'),
      _field(_cabinetNumCtrl, 'Ex: N°12, 3ème étage', Icons.door_front_door_outlined),
    ]);
  }

  Widget _tabBtn(int idx, IconData icon, String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _locMethod = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? _doc : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? _doc : Colors.grey.shade300),
          boxShadow: active ? [BoxShadow(color: _doc.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: active ? Colors.white : AppColors.textGrey, size: 20),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textGrey)),
        ]),
      ),
    );
  }

  Widget _step4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Horaires et tarifs', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text('Définissez vos disponibilités', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 24),
        _sectionHeader('Jours de travail', Icons.calendar_month_outlined),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _workDays.entries.map((e) {
          return GestureDetector(
            onTap: () => setState(() => _workDays[e.key] = !e.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: e.value ? _doc : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: e.value ? _doc : Colors.grey.shade300),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(e.value ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 18, color: e.value ? Colors.white : AppColors.textGrey),
                const SizedBox(width: 6),
                Text(e.key, style: GoogleFonts.poppins(fontSize: 13,
                  color: e.value ? Colors.white : AppColors.textGrey, fontWeight: FontWeight.w500)),
              ]),
            ),
          );
        }).toList()),
        const SizedBox(height: 20),
        _sectionHeader('Heures de consultation', Icons.access_time),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Heure début'),
            _timePicker(_startTimeCtrl, '08:00'),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Heure fin'),
            _timePicker(_endTimeCtrl, '17:00'),
          ])),
        ]),
        const SizedBox(height: 16),
        _lbl('Durée moyenne consultation'),
        _dropdown<String>(
          value: _consultDuration, hint: 'Choisir', icon: Icons.timer_outlined,
          items: ['15 min', '30 min', '45 min', '1h'].map((d) =>
            DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _consultDuration = v),
        ),
        const SizedBox(height: 16),
        _lbl('Tarif consultation'),
        _dropdown<String>(
          value: _consultTarif, hint: 'Choisir', icon: Icons.payments_outlined,
          items: ['1000 DA', '1500 DA', '2000 DA', '3000 DA'].map((d) =>
            DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _consultTarif = v),
        ),
        const SizedBox(height: 32),
        _btnNext('Suivant', _submitSchedule),
      ]),
    );
  }

  Widget _timePicker(TextEditingController ctrl, String hint) {
    return TextFormField(
      controller: ctrl, readOnly: true,
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
        if (t != null) ctrl.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      },
      decoration: _inputDeco(hint, Icons.access_time),
    );
  }

  Widget _step5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Documents justificatifs', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        Text('Optionnel maintenant — obligatoire pour la validation', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 24),
        _uploadCard('Photo carte ONMO', Icons.badge_outlined, _onmoUploaded, () => setState(() => _onmoUploaded = !_onmoUploaded)),
        const SizedBox(height: 12),
        _uploadCard('Photo diplôme de médecine', Icons.school_outlined, _diplomaUploaded, () => setState(() => _diplomaUploaded = !_diplomaUploaded)),
        const SizedBox(height: 12),
        _uploadCard('Photo de profil professionnelle', Icons.camera_alt_outlined, _profileUploaded, () => setState(() => _profileUploaded = !_profileUploaded)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFB74D)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 22),
              const SizedBox(width: 8),
              Text('Validation par l\'administrateur', style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFE65100))),
            ]),
            const SizedBox(height: 10),
            _infoLine(Icons.check_circle_outline, 'Numéro ONMO vérifié'),
            _infoLine(Icons.check_circle_outline, 'Documents authentiques'),
            _infoLine(Icons.check_circle_outline, 'Informations correctes'),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule, color: Color(0xFFF57C00), size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text('Votre compte sera activé après vérification (24-48h)',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFF57C00), fontWeight: FontWeight.w500))),
            ]),
          ]),
        ),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _finish,
            style: ElevatedButton.styleFrom(backgroundColor: _doc),
            child: _loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('S\'inscrire', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 48,
          child: OutlinedButton(
            onPressed: _loading ? null : _finish,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _doc.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: Text('Passer les documents', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: _doc)),
          ),
        ),
        const SizedBox(height: 16),
        _loginLink(),
      ]),
    );
  }

  Widget _uploadCard(String label, IconData icon, bool uploaded, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: uploaded ? _doc.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: uploaded ? _doc : Colors.grey.shade300,
            width: uploaded ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: uploaded ? _doc.withValues(alpha: 0.12) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12)),
            child: Icon(uploaded ? Icons.check : icon, color: uploaded ? _doc : AppColors.textGrey, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            Text(uploaded ? 'Fichier ajouté ✓' : 'Appuyez pour ajouter',
              style: GoogleFonts.poppins(fontSize: 12, color: uploaded ? _doc : AppColors.textGrey)),
          ])),
          Icon(uploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
            color: uploaded ? _doc : AppColors.textGrey, size: 24),
        ]),
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: const Color(0xFFF57C00)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF795548))),
      ]),
    );
  }

  Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)));

  Widget _sectionHeader(String text, IconData icon) {
    return Row(children: [
      Expanded(child: Divider(color: Colors.grey.shade300)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: _doc), const SizedBox(width: 6),
          Text(text, style: GoogleFonts.poppins(fontSize: 12, color: _doc, fontWeight: FontWeight.w600)),
        ])),
      Expanded(child: Divider(color: Colors.grey.shade300)),
    ]);
  }

  InputDecoration _inputDeco(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _doc),
      suffixIcon: suffix,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _doc, width: 2)),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: ctrl, 
      keyboardType: keyboard, 
      validator: validator,
      readOnly: readOnly,
      decoration: _inputDeco(hint, icon).copyWith(
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade200 : null,
        suffixIcon: readOnly ? const Icon(Icons.verified, color: Colors.green, size: 18) : null,
      ),
    );
  }

  Widget _dropdown<T>({T? value, required String hint, required IconData icon,
    required List<DropdownMenuItem<T>> items, required void Function(T?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(child: DropdownButton<T>(
        value: value, isExpanded: true,
        hint: Text(hint, style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14)),
        icon: Icon(icon, color: _doc),
        items: items, onChanged: onChanged,
      )),
    );
  }

  Widget _btn(String text, VoidCallback onTap) {
    return SizedBox(width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: _doc),
        child: Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ));
  }

  Widget _btnNext(String text, VoidCallback onTap) {
    return SizedBox(width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: _doc),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
        ]),
      ));
  }

  Widget _loginLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Déjà un compte ? ', style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13)),
      GestureDetector(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginDoctorScreen())),
        child: Text('Se connecter', style: GoogleFonts.poppins(color: _doc, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    ]);
  }
}
