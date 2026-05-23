import 'package:cloud_firestore/cloud_firestore.dart';

// ===== USER MODEL =====
class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? nom;
  // Patient fields
  final String? dateNaissance;
  final String? sexe;
  final String? taille;
  final String? poids;
  // Doctor fields
  final String? nomProfessionnel;
  final String? specialite;
  final String? anciennete;
  final String? numerodetel;
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
    this.numerodetel,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'patient',
      nom: map['nom'],
      dateNaissance: map['dateNaissance'],
      sexe: map['sexe'],
      taille: map['taille'],
      poids: map['poids'],
      nomProfessionnel: map['nomProfessionnel'],
      specialite: map['specialite'],
      anciennete: map['anciennete'],
      numerodetel: map['numerodetel'],
      latitude:
          map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null
          ? (map['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'nom': nom,
      if (dateNaissance != null) 'dateNaissance': dateNaissance,
      if (sexe != null) 'sexe': sexe,
      if (taille != null) 'taille': taille,
      if (poids != null) 'poids': poids,
      if (nomProfessionnel != null) 'nomProfessionnel': nomProfessionnel,
      if (specialite != null) 'specialite': specialite,
      if (anciennete != null) 'anciennete': anciennete,
      if (numerodetel != null) 'numerodetel': numerodetel,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

// ===== RENDEZ-VOUS MODEL =====
class RendezVousModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String patientNom;
  final String doctorNom;
  final String specialite;
  final String type;
  final String motif;
  final String modePaiement;
  final DateTime dateTime;
  final DateTime createdAt;
  final String statut; // 'en_attente', 'confirme', 'annuler', 'termine'
  final int rendezVousnum;
  final String? raisonRefus;

  RendezVousModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientNom,
    required this.doctorNom,
    this.specialite = '',
    this.type = '',
    this.motif = '',
    this.modePaiement = '',
    required this.dateTime,
    required this.createdAt,
    required this.statut,
    this.rendezVousnum = 0,
    this.raisonRefus,
  });

  factory RendezVousModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return RendezVousModel(
      id: docId,
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      patientNom: map['patientNom'] ?? '',
      doctorNom: map['doctorNom'] ?? '',
      specialite: map['specialite'] ?? '',
      type: map['type'] ?? '',
      motif: map['motif'] ?? '',
      modePaiement: map['modePaiement'] ?? '',
      dateTime: parseDate(map['dateTime']),
      createdAt: parseDate(map['createdAt']),
      statut: map['statut'] ?? 'en_attente',
      rendezVousnum: map['rendezVousnum'] ?? 0,
      raisonRefus: map['raisonRefus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientNom': patientNom,
      'doctorId': doctorId,
      'doctorNom': doctorNom,
      'specialite': specialite,
      'type': type,
      'motif': motif,
      'modePaiement': modePaiement,
      'dateTime': Timestamp.fromDate(dateTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'statut': statut,
      'rendezVousnum': rendezVousnum,
      if (raisonRefus != null) 'raisonRefus': raisonRefus,
    };
  }

  RendezVousModel copyWith({
    String? statut,
    DateTime? dateTime,
    String? raisonRefus,
  }) {
    return RendezVousModel(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      patientNom: patientNom,
      doctorNom: doctorNom,
      specialite: specialite,
      type: type,
      motif: motif,
      modePaiement: modePaiement,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt,
      statut: statut ?? this.statut,
      rendezVousnum: rendezVousnum,
      raisonRefus: raisonRefus ?? this.raisonRefus,
    );
  }
}

// ===== MESSAGE MODEL =====
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

// ===== DATABASE SERVICE =====
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<UserModel>> getDoctors() async {
    try {
      var snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getSpecialites() async {
    try {
      final snap = await _db.collection('specialite').get();
      return snap.docs
          .map((d) => d.data()['nom']?.toString() ?? d.id)
          .toList();
    } catch (e) {
      return ['Généraliste', 'Cardiologue', 'Pédiatre', 'Dermatologue'];
    }
  }
}
