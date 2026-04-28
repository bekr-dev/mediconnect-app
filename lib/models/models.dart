// ===== MODELS (sans base de données) =====

class UserModel {
  final String id;
  final String username;
  final String email;
  final String role; // 'patient' or 'doctor'
  final String? nom;
  final String? dateNaissance;
  final String? sexe;
  final String? taille;
  final String? poids;
  // Doctor fields
  final String? nomProfessionnel;
  final String? specialite;
  final String? anciennete;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.nom,
    this.dateNaissance,
    this.sexe,
    this.taille,
    this.poids,
    this.nomProfessionnel,
    this.specialite,
    this.anciennete,
    this.latitude,
    this.longitude,
  });
}

class RendezVousModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientNom;
  final String doctorNom;
  final DateTime dateTime;
  final String statut; // 'en_attente', 'confirme', 'termine'

  RendezVousModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientNom,
    required this.doctorNom,
    required this.dateTime,
    required this.statut,
  });
}

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String contenu;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.contenu,
    required this.timestamp,
  });
}

// ===== MOCK DATA =====
class MockData {
  static final List<UserModel> doctors = [
    UserModel(
      id: 'd1', username: 'dr_bouanani', email: 'bouanani@med.dz',
      role: 'doctor', nomProfessionnel: 'Dr. Bouanani',
      specialite: 'Cardiologue', anciennete: '12 ans',
      latitude: 35.9306, longitude: 0.0886,
    ),
    UserModel(
      id: 'd2', username: 'dr_hasni', email: 'hasni@med.dz',
      role: 'doctor', nomProfessionnel: 'Dr. Hasni',
      specialite: 'Généraliste', anciennete: '8 ans',
      latitude: 35.9280, longitude: 0.0910,
    ),
    UserModel(
      id: 'd3', username: 'dr_rachdi', email: 'rachdi@med.dz',
      role: 'doctor', nomProfessionnel: 'Dr. Rachdi',
      specialite: 'Pédiatre', anciennete: '15 ans',
      latitude: 35.9260, longitude: 0.0870,
    ),
    UserModel(
      id: 'd4', username: 'dr_mansouri', email: 'mansouri@med.dz',
      role: 'doctor', nomProfessionnel: 'Dr. Mansouri',
      specialite: 'Dermatologue', anciennete: '6 ans',
      latitude: 35.9320, longitude: 0.0930,
    ),
  ];

  static List<RendezVousModel> rendezVous = [
    RendezVousModel(
      id: 'rv1', patientId: 'p1', doctorId: 'd2',
      patientNom: 'Mr. Slimane', doctorNom: 'Dr. Hasni',
      dateTime: DateTime(2026, 5, 22, 9, 30),
      statut: 'confirme',
    ),
    RendezVousModel(
      id: 'rv2', patientId: 'p2', doctorId: 'd2',
      patientNom: 'Mr. Hafid', doctorNom: 'Dr. Hasni',
      dateTime: DateTime(2026, 5, 22, 10, 0),
      statut: 'confirme',
    ),
    RendezVousModel(
      id: 'rv3', patientId: 'p3', doctorId: 'd2',
      patientNom: 'Mr. Ahmed', doctorNom: 'Dr. Hasni',
      dateTime: DateTime(2026, 5, 22, 10, 30),
      statut: 'en_attente',
    ),
    RendezVousModel(
      id: 'rv4', patientId: 'p4', doctorId: 'd2',
      patientNom: 'Mm. Farah', doctorNom: 'Dr. Hasni',
      dateTime: DateTime(2026, 5, 22, 11, 0),
      statut: 'en_attente',
    ),
  ];

  static List<MessageModel> messages = [
    MessageModel(id: 'm1', senderId: 'p1', receiverId: 'd2',
      contenu: 'Bonjour Docteur, j\'ai des douleurs thoraciques.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    MessageModel(id: 'm2', senderId: 'd2', receiverId: 'p1',
      contenu: 'Bonjour, je vous recommande de passer une consultation rapidement.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1))),
  ];
}
