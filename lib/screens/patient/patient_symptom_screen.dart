import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class PatientSymptomScreen extends StatefulWidget {
  const PatientSymptomScreen({super.key});
  @override
  State<PatientSymptomScreen> createState() => _PatientSymptomScreenState();
}

class _PatientSymptomScreenState extends State<PatientSymptomScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _analyzing = false;
  Color _statusColor = Colors.grey;
  String _statusLabel = '';
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _pulseController.repeat(reverse: true);
    _messages.add({'role': 'ai', 'text': 'Bonjour ! Décrivez vos symptômes et j\'analyserai leur niveau d\'urgence. 🩺'});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _controller.clear();
      _analyzing = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // Simple keyword analysis (sans IA réelle)
    Color resultColor;
    String resultLabel;
    String resultText;

    final lower = text.toLowerCase();
    if (lower.contains('douleur thoracique') || lower.contains('souffle') ||
        lower.contains('inconscient') || lower.contains('sang') || lower.contains('chute')) {
      resultColor = AppColors.danger;
      resultLabel = 'URGENCE';
      resultText = '🔴 Cas urgent détecté ! Vos symptômes nécessitent une attention médicale immédiate. Appelez le 15 ou rendez-vous aux urgences.';
    } else if (lower.contains('fièvre') || lower.contains('douleur') || lower.contains('vomissement') ||
               lower.contains('essoufflement')) {
      resultColor = AppColors.warning;
      resultLabel = 'PROBABLEMENT URGENT';
      resultText = '🟡 Vos symptômes peuvent nécessiter une consultation médicale rapidement. Prenez rendez-vous avec un médecin dès que possible.';
    } else {
      resultColor = AppColors.success;
      resultLabel = 'NON URGENT';
      resultText = '🟢 Vos symptômes ne semblent pas urgents. Continuez à surveiller votre état. Consultez un médecin si les symptômes persistent.';
    }

    setState(() {
      _analyzing = false;
      _statusColor = resultColor;
      _statusLabel = resultLabel;
      _messages.add({'role': 'ai', 'text': resultText});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Analyse IA des symptômes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_statusLabel.isNotEmpty)
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Transform.scale(
                scale: _pulse.value,
                child: Container(
                  margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusLabel, style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_analyzing ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length && _analyzing) {
                  return _TypingBubble();
                }
                final msg = _messages[i];
                return _ChatBubble(text: msg['text']!, isAI: msg['role'] == 'ai');
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Décrivez vos symptômes...',
                      hintStyle: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14),
                      filled: true, fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48, height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isAI;
  const _ChatBubble({required this.text, required this.isAI});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isAI ? Colors.white : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isAI ? const Radius.circular(4) : const Radius.circular(18),
            bottomRight: isAI ? const Radius.circular(18) : const Radius.circular(4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAI) ...[
              const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF7B1FA2)),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(text, style: GoogleFonts.poppins(
                fontSize: 14, color: isAI ? AppColors.textDark : Colors.white, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF7B1FA2)),
          const SizedBox(width: 8),
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7B1FA2))),
          const SizedBox(width: 8),
          Text('Analyse en cours...', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textGrey)),
        ]),
      ),
    );
  }
}
