import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mediconnect/screens/doctor/doctor_chats_list_screen.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';
import '/theme/app_theme.dart';
import 'doctor_requests_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_account_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _DoctorDashboard(),
      const DoctorRequestsScreen(),
      const DoctorPatientsScreen(),
      const DoctorChatsListScreen(),
      const DoctorAccountScreen(),
    ];
    // Charger le user depuis le cache si pas encore chargé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      if (appState.currentUser == null) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) appState.loadUserFromFirestore(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Accueil',
                    index: 0,
                    current: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(
                    icon: Icons.pending_actions_outlined,
                    activeIcon: Icons.pending_actions,
                    label: 'Demandes',
                    index: 1,
                    current: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(
                    icon: Icons.group_outlined,
                    activeIcon: Icons.group,
                    label: 'Patients',
                    index: 2,
                    current: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(
                    icon: Icons.message_outlined,
                    activeIcon: Icons.message,
                    label: 'Messages',
                    index: 3,
                    current: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
                _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Compte',
                    index: 4,
                    current: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final Function(int) onTap;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.index,
      required this.current,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF006064);
    final bool active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? activeIcon : icon,
            color: active ? color : AppColors.textGrey, size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10,
                color: active ? color : AppColors.textGrey,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        if (active)
          Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration:
                  const BoxDecoration(color: color, shape: BoxShape.circle)),
      ]),
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────────

class _DoctorDashboard extends StatefulWidget {
  const _DoctorDashboard();
  @override
  State<_DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<_DoctorDashboard> {
  DateTime _selectedDate = DateTime.now();

  String get _doctorId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ── Stream des rendez-vous du docteur ──
  Stream<List<RendezVousModel>> _streamRendezVous() {
    return FirebaseFirestore.instance
        .collection('rendezVous')
        .where('doctorId', isEqualTo: _doctorId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => RendezVousModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00897B),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final doctor = appState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<RendezVousModel>>(
        stream: _streamRendezVous(),
        builder: (context, snapshot) {
          final allRvs = snapshot.data ?? [];
          final now = DateTime.now();

          final pendingCount =
              allRvs.where((r) => r.statut == 'en_attente').length;

          // Patients = mواعيد مؤكدة مستقبلية فقط
          final patientCount =
              allRvs.where((r) => r.statut == 'confirme').length;

          // Rendez-vous du jour sélectionné (confirme seulement)
          final todayRvs = allRvs
              .where((r) =>
                  r.statut == 'confirme' &&
                  _isSameDay(r.dateTime, _selectedDate))
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          return CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF006064),
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Color(0xFF004D40),
                    Color(0xFF00897B),
                    Color(0xFF26C6DA)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.medical_services,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor != null
                                        ? (doctor.nomProfessionnel ??
                                            doctor.nom ??
                                            'Médecin')
                                        : 'Médecin',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    doctor?.specialite ?? '',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ]),
                            const Spacer(),
                            Stack(children: [
                              IconButton(
                                  icon: const Icon(Icons.notifications_outlined,
                                      color: Colors.white, size: 26),
                                  onPressed: () {}),
                              if (pendingCount > 0)
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                            ]),
                          ]),
                          const SizedBox(height: 16),
                          Text('Tableau de bord médecin',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stats ──
                      Row(children: [
                        Expanded(
                            child: _StatCard(
                                icon: Icons.pending_actions,
                                label: 'Demandes',
                                value: '$pendingCount',
                                color: const Color(0xFF1565C0))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _StatCard(
                                icon: Icons.people_outline,
                                label: 'Patients\nà venir',
                                value: '$patientCount',
                                color: const Color(0xFF00897B))),
                        const SizedBox(width: 12),
                        const Expanded(
                            child: _StatCard(
                                icon: Icons.message_outlined,
                                label: 'Messages',
                                value: '—',
                                color: Color(0xFF7B1FA2))),
                      ]),
                      const SizedBox(height: 24),

                      // ── Salle d'attente ──
                      Text("Salle d'attente",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(height: 8),

                      // Date picker chip
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.3))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(
                              DateFormat('dd MMMM yyyy').format(_selectedDate),
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
                      const SizedBox(height: 12),

                      // Liste des rendez-vous du jour
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator()))
                      else if (todayRvs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(children: [
                              Icon(Icons.event_available,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text('Aucun rendez-vous ce jour',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textGrey)),
                            ]),
                          ),
                        )
                      else
                        ...todayRvs.asMap().entries.map((e) => _WaitingItem(
                              rv: e.value,
                              index: e.key + 1,
                            )),
                    ]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)
          ]),
      child: Column(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10, color: AppColors.textGrey, height: 1.3),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

// ── Waiting Item ──────────────────────────────────────────────────────────────

class _WaitingItem extends StatelessWidget {
  final RendezVousModel rv;
  final int index;
  const _WaitingItem({required this.rv, required this.index});

  @override
  Widget build(BuildContext context) {
    final time =
        '${rv.dateTime.hour.toString().padLeft(2, '0')}:${rv.dateTime.minute.toString().padLeft(2, '0')}';
    final isTermine = rv.statut == 'termine';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ]),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Center(
                    child: Text('$index',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00897B)))),
              ),
              const SizedBox(width: 14),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rv.patientNom,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      TextButton(
                        onPressed: () => _showDetails(context, rv),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0)),
                        child: Text('plus d\'info',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.primary)),
                      ),
                    ]),
              ),
              Text(time,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger)),
            ]),
          ),
          if (isTermine)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6)),
                child: Text('terminé',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, RendezVousModel rv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => RendezVousDetailSheet(rv: rv, isDoctor: true),
    );
  }
}

// ── Fiche détail rendez-vous (réutilisable) ───────────────────────────────────

class RendezVousDetailSheet extends StatefulWidget {
  final RendezVousModel rv;
  final bool isDoctor;
  const RendezVousDetailSheet(
      {super.key, required this.rv, this.isDoctor = false});

  @override
  State<RendezVousDetailSheet> createState() => _RendezVousDetailSheetState();
}

class _RendezVousDetailSheetState extends State<RendezVousDetailSheet> {
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
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rv = widget.rv;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(rv.dateTime);
    final createdStr = DateFormat('dd/MM/yyyy').format(rv.createdAt);

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Text('Détail du rendez-vous',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const Spacer(),
              StatusBadge(statut: rv.statut),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            _DetailRow(Icons.person_outline, 'Patient', rv.patientNom),
            _DetailRow(
                Icons.medical_services_outlined, 'Médecin', rv.doctorNom),
            _DetailRow(
                Icons.local_hospital_outlined, 'Spécialité', rv.specialite),
            _DetailRow(Icons.category_outlined, 'Type', rv.type),
            _DetailRow(Icons.note_alt_outlined, 'Motif', rv.motif),
            _DetailRow(Icons.payment_outlined, 'Paiement', rv.modePaiement),
            _DetailRow(Icons.calendar_today, 'Date & Heure', dateStr),
            _DetailRow(Icons.tag, 'N° Rendez-vous', '#${rv.rendezVousnum}'),
            _DetailRow(Icons.schedule_outlined, 'Créé le', createdStr),
            if (rv.raisonRefus != null)
              _DetailRow(
                  Icons.cancel_outlined, 'Raison annulation', rv.raisonRefus!),
            const SizedBox(height: 16),
            if (widget.isDoctor && rv.statut == 'confirme')
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _updating ? null : _marquerTermine,
                  icon: _updating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                  label: Text('Marquer comme terminé',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
              ),
            const SizedBox(height: 8),
          ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF006064), size: 18),
        const SizedBox(width: 12),
        Text('$label :',
            style:
                GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value.isNotEmpty ? value : '—',
              style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String statut;
  const StatusBadge({super.key, required this.statut});
  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    switch (statut) {
      case 'en_attente':
        bg = Colors.orange;
        label = 'En attente';
        break;
      case 'confirme':
        bg = AppColors.success;
        label = 'Confirmé';
        break;
      case 'termine':
        bg = Colors.blueGrey;
        label = 'Terminé';
        break;
      case 'annuler':
        bg = AppColors.danger;
        label = 'Annulé';
        break;
      default:
        bg = Colors.grey;
        label = statut;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 12, color: bg, fontWeight: FontWeight.w600)),
    );
  }
}
