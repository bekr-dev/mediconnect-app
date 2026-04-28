import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';

class DoctorDashboardTab extends StatefulWidget {
const DoctorDashboardTab({super.key});

@override
State<DoctorDashboardTab> createState() => _DoctorDashboardTabState();
}

class _DoctorDashboardTabState extends State<DoctorDashboardTab>
with SingleTickerProviderStateMixin {
late TabController _tabCtrl;

@override
void initState() {
super.initState();
_tabCtrl = TabController(length: 2, vsync: this);
}

@override
void dispose() {
_tabCtrl.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final state = context.watch<AppState>();
final doctor = state.currentUser;
final pending = state.demandesEnAttente;
final waiting = state.myRendezVous
    .where((e) => e.statut == 'confirme')
    .toList();

return Scaffold(
backgroundColor: AppColors.background,
body: CustomScrollView(
slivers: [
SliverAppBar(
expandedHeight: 160,
pinned: true,
backgroundColor: AppColors.primary,
flexibleSpace: FlexibleSpaceBar(
background: Container(
decoration: const BoxDecoration(
gradient: AppColors.primaryGradient,
),
padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
child: Row(
children: [
const Icon(Icons.medical_services, color: Colors.white),
const SizedBox(width: 10),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.end,
children: [
Text(
doctor?.nomProfessionnel ?? 'Médecin',
style: const TextStyle(color: Colors.white, fontSize: 18),
),
Text(
doctor?.specialite ?? '',
style: const TextStyle(color: Colors.white70),
),
],
),
],
),
),
),
bottom: TabBar(
controller: _tabCtrl,
tabs: const [
Tab(text: "Demandes"),
Tab(text: "Salle d'attente"),
],
),
),

SliverFillRemaining(
child: TabBarView(
controller: _tabCtrl,
children: [
// DEMANDES
pending.isEmpty
? _empty("Aucune demande")
    : ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: pending.length,
itemBuilder: (_, i) {
final rv = pending[i];
return _card(rv).animate().fadeIn();
},
),

// SALLE D'ATTENTE
waiting.isEmpty
? _empty("Vide")
    : ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: waiting.length,
itemBuilder: (_, i) {
final rv = waiting[i];
return ListTile(
title: Text(rv.patientNom),
subtitle: Text(rv.statut),
);
},
),
],
),
),
],
),
);
}

Widget _card(RendezVousModel rv) {
return Card(
child: ListTile(
title: Text(rv.patientNom),
subtitle: Text(rv.statut),
trailing: ElevatedButton(
onPressed: () {
context.read<AppState>().confirmerRendezVous(rv.id);
},
child: const Text("Accepter"),
),
),
);
}

Widget _empty(String msg) {
return Center(
child: Text(
msg,
style: TextStyle(color: AppColors.textGrey),
),
);
}
}


