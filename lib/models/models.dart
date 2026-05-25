import 'package:cloud_firestore/cloud_firestore.dart';

// ===== USER MODEL =====
class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? nom;
  final String? dateNaissance;
  final String? sexe;
  final String? taille;
  final String? poids;
  final String? nomProfessionnel;
  final String? specialite;
  final String? anciennete;
  final String? numerodetel;
  final String? onmoNumber;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final String? wilaya;
  final String? commune;
  final String? rue;
  final String? cabinetNum;
  final Map<String, bool>? workDays;
  final String? startTime;
  final String? endTime;
  final String? consultDuration;
  final String? consultTarif;
  final bool onmoUploaded;
  final bool diplomaUploaded;
  final bool profileUploaded;
  final String? authProvider;
  final DateTime? createdAt;

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
    this.onmoNumber,
    this.isActive = false,
    this.latitude,
    this.longitude,
    this.wilaya,
    this.commune,
    this.rue,
    this.cabinetNum,
    this.workDays,
    this.startTime,
    this.endTime,
    this.consultDuration,
    this.consultTarif,
    this.onmoUploaded = false,
    this.diplomaUploaded = false,
    this.profileUploaded = false,
    this.authProvider,
    this.createdAt,
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
      onmoNumber: map['onmoNumber'],
      isActive: map['isActive'] ?? false,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      wilaya: map['wilaya'],
      commune: map['commune'],
      rue: map['rue'],
      cabinetNum: map['cabinetNum'],
      workDays: map['workDays'] != null ? Map<String, bool>.from(map['workDays']) : null,
      startTime: map['startTime'],
      endTime: map['endTime'],
      consultDuration: map['consultDuration'],
      consultTarif: map['consultTarif'],
      onmoUploaded: map['onmoUploaded'] ?? false,
      diplomaUploaded: map['diplomaUploaded'] ?? false,
      profileUploaded: map['profileUploaded'] ?? false,
      authProvider: map['authProvider'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate() 
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'role': role,
      'nom': nom,
      'isActive': isActive,
      'onmoUploaded': onmoUploaded,
      'diplomaUploaded': diplomaUploaded,
      'profileUploaded': profileUploaded,
      if (dateNaissance != null) 'dateNaissance': dateNaissance,
      if (sexe != null) 'sexe': sexe,
      if (taille != null) 'taille': taille,
      if (poids != null) 'poids': poids,
      if (nomProfessionnel != null) 'nomProfessionnel': nomProfessionnel,
      if (specialite != null) 'specialite': specialite,
      if (anciennete != null) 'anciennete': anciennete,
      if (numerodetel != null) 'numerodetel': numerodetel,
      if (onmoNumber != null) 'onmoNumber': onmoNumber,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (wilaya != null) 'wilaya': wilaya,
      if (commune != null) 'commune': commune,
      if (rue != null) 'rue': rue,
      if (cabinetNum != null) 'cabinetNum': cabinetNum,
      if (workDays != null) 'workDays': workDays,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (consultDuration != null) 'consultDuration': consultDuration,
      if (consultTarif != null) 'consultTarif': consultTarif,
      if (authProvider != null) 'authProvider': authProvider,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
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
  final String statut;
  final int rendezVousnum;
  final String? raisonRefus;
  final double? prix;

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
    this.prix,
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
      prix: map['prix'] != null ? (map['prix'] as num).toDouble() : null,
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
      if (prix != null) 'prix': prix,
    };
  }

  RendezVousModel copyWith({
    String? statut,
    DateTime? dateTime,
    String? raisonRefus,
    double? prix,
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
      prix: prix ?? this.prix,
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
          .where('isActive', isEqualTo: true)
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
