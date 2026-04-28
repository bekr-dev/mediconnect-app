import 'package:flutter/foundation.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
// ── Auth State ─────────────────────────
UserModel? _currentUser;

UserModel? get currentUser => _currentUser;
bool get isLoggedIn => _currentUser != null;
bool get isDoctor => _currentUser?.role == 'doctor';
bool get isPatient => _currentUser?.role == 'patient';

// ── Doctors ────────────────────────────
List<UserModel> get allDoctors =>
MockData.doctors.where((d) => d.role == 'doctor').toList();

List<UserModel> searchDoctors(String query) {
if (query.isEmpty) return allDoctors;
return allDoctors.where((d) =>
(d.nomProfessionnel ?? '').toLowerCase().contains(query.toLowerCase()) ||
(d.specialite ?? '').toLowerCase().contains(query.toLowerCase())
).toList();
}

// ── Rendez-vous ────────────────────────


List<RendezVousModel> get myAppointments {
if (_currentUser == null) return [];

return MockData.rendezVous.where((rv) {
return rv.patientId == _currentUser!.id &&
rv.statut == 'confirme';
}).toList();
}

List<RendezVousModel> get myRendezVous {
if (isPatient) {
return MockData.rendezVous
    .where((rv) => rv.patientId == _currentUser!.id)
    .toList();
} else if (isDoctor) {
return MockData.rendezVous
    .where((rv) => rv.doctorId == _currentUser!.id)
    .toList();
}
return [];
}

List<RendezVousModel> get demandesEnAttente {
return MockData.rendezVous
    .where((rv) => rv.statut == 'en_attente')
    .toList();
}

void confirmerRendezVous(String id) {
final index =
MockData.rendezVous.indexWhere((rv) => rv.id == id);

if (index != -1) {
final old = MockData.rendezVous[index];

MockData.rendezVous[index] = RendezVousModel(
id: old.id,
patientId: old.patientId,
doctorId: old.doctorId,
patientNom: old.patientNom,
doctorNom: old.doctorNom,
dateTime: old.dateTime,
statut: 'confirme',
);

notifyListeners();
}
}

void ajouterDemandeRendezVous(String doctorId, String doctorNom) {
MockData.rendezVous.add(
RendezVousModel(
id: 'rv${MockData.rendezVous.length + 1}',
patientId: _currentUser?.id ?? 'p_new',
doctorId: doctorId,
patientNom: _currentUser?.username ?? 'Patient',
doctorNom: doctorNom,
dateTime: DateTime.now().add(const Duration(days: 1)),
statut: 'en_attente',
),
);

notifyListeners();
}

// ── Messages ───────────────────────────
List<MessageModel> get myMessages => MockData.messages;

void envoyerMessage(String receiverId, String contenu) {
MockData.messages.add(
MessageModel(
id: 'm${MockData.messages.length + 1}',
senderId: _currentUser?.id ?? '',
receiverId: receiverId,
contenu: contenu,
timestamp: DateTime.now(),
),
);

notifyListeners();
}

// ── Auth ───────────────────────────────
bool login(String username, String password) {
if (username.contains('dr')) {
_currentUser = MockData.doctors.first;
} else {
_currentUser = UserModel(
id: 'p1',
username: username,
email: 'patient@test.com',
role: 'patient',
nom: 'Utilisateur',
);
}

notifyListeners();
return true;
}

void logout() {
_currentUser = null;
notifyListeners();
}
}

