import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/theme/app_theme.dart';
import '../../models/app_state.dart';
import 'register_choice_screen.dart';
import '../doctor/doctor_home_screen.dart';
import 'dart:developer';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _resetEmailController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  bool _showResetCard = false;
  bool _resetLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Charger le user complet dans AppState (avec cache)
      final appState = context.read<AppState>();
      final user = await appState.loadUserFromFirestore(credential.user!.uid);

      if (user != null) {
  log("=== بيانات المستخدم كاملة من الـ Model ===");
  log(user.toMap().toString()); 
} else {
  log("❌ تحذير: الكائن user قيمته null، لم يتم جلب أي بيانات من Firestore!");
}
      
      if (!mounted) return;

      final role = user?.role;

      if (role == 'doctor') {
        final prefs = await SharedPreferences.getInstance();
          final isFirst = prefs.getBool('is_first_time') ?? true;
          if (isFirst) {
            await prefs.setBool('is_first_time', false);
          }
                if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DoctorHomeScreen()));
      } else {
        await FirebaseAuth.instance.signOut();
        await appState.logout();
        if (!mounted) return;
        _showError('Accès refusé. Contactez l\'administrateur.');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur de connexion';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Email ou mot de passe incorrect';
      } else if (e.code == 'too-many-requests') {
        message = 'Trop de tentatives. Réessayez plus tard';
      } else if (e.code == 'network-request-failed') {
        message = 'Vérifiez votre connexion internet';
      }
      _showError(message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _sendResetEmail() async {
    final email = _resetEmailController.text.trim();
    if (email.isEmpty) {
      _showError('Veuillez entrer votre email');
      return;
    }
    setState(() => _resetLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        _showResetCard = false;
        _resetEmailController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lien envoyé à $email',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } on FirebaseAuthException catch (e) {
      _showError(e.code == 'user-not-found'
          ? 'Aucun compte associé à cet email'
          : 'Erreur lors de l\'envoi');
    } finally {
      if (mounted) setState(() => _resetLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                  Color(0xFF1E88E5)
                ],
                begin: Alignment.topCenter,
                end: Alignment.center,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: 'Medi',
                                          style: GoogleFonts.poppins(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 1)),
                                      TextSpan(
                                          text: 'Connect',
                                          style: GoogleFonts.poppins(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w300,
                                              color:
                                                  Colors.white.withOpacity(0.85),
                                              letterSpacing: 1)),
                                    ]),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Votre santé, notre priorité',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.70),
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: 1.5)),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                                child: Image.asset('assets/images/logo.png',
                                    width: 205,
                                    height: 205,
                                    fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0F4F8),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32)),
                          ),
                          padding: const EdgeInsets.all(28),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Connexion',
                                    style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark)),
                                Text('Bienvenue sur MediConnect',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textGrey)),
                                const SizedBox(height: 24),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _passController,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        color: AppColors.primary),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: AppColors.textGrey),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => setState(() {
                                      _showResetCard = !_showResetCard;
                                      _resetEmailController.clear();
                                    }),
                                    child: Text('Mot de passe oublié ?',
                                        style: GoogleFonts.poppins(
                                            color: AppColors.primary,
                                            fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2))
                                        : Text('Se connecter',
                                            style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Pas encore de compte ? ",
                                        style: GoogleFonts.poppins(
                                            color: AppColors.textGrey,
                                            fontSize: 13)),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterChoiceScreen())),
                                      child: Text("S'inscrire",
                                          style: GoogleFonts.poppins(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showResetCard) ...[
            GestureDetector(
              onTap: () => setState(() => _showResetCard = false),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.lock_reset,
                              color: AppColors.primary, size: 28),
                          const SizedBox(width: 10),
                          Text('Réinitialiser le mot de passe',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark)),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                            'Entrez votre email pour recevoir un lien de réinitialisation.',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: AppColors.textGrey)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _resetEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _showResetCard = false),
                              style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  side: const BorderSide(
                                      color: AppColors.primary)),
                              child: Text('Annuler',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _resetLoading ? null : _sendResetEmail,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: _resetLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text('Envoyer',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
