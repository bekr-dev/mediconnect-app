import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/theme/app_theme.dart';
import 'doctor_messages_screen.dart';

class DoctorChatsListScreen extends StatefulWidget {
  const DoctorChatsListScreen({super.key});

  @override
  State<DoctorChatsListScreen> createState() => _DoctorChatsListScreenState();
}

class _DoctorChatsListScreenState extends State<DoctorChatsListScreen> {
  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  void _navigateToChat(String doctorId, String doctorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorMessagesScreen(
          doctorId: doctorId,
          doctorName: doctorName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ قسم الأطباء المقبولين
          _buildAcceptedDoctorsSection(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(color: Colors.black12, thickness: 1),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Discussions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),

          // ✅ قسم المحادثات - يقرأ من chats مباشرة
          Expanded(
            child: _buildRecentChatsSection(),
          ),
        ],
      ),
    );
  }

  // ✅ قسم الأطباء المقبولين (بدون تغيير)
  Widget _buildAcceptedDoctorsSection() {
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rendezVous')
            .where('doctorId', isEqualTo: _myUid)
            .where('statut', isEqualTo: 'confirme')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final docs = snapshot.data!.docs;
          final Map<String, String> uniqueDoctors = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final docId = data['patientId'] ?? '';
            final docNom = data['patientNom'] ?? 'patient';
            if (docId.isNotEmpty) {
              uniqueDoctors[docId] = docNom;
            }
          }

          if (uniqueDoctors.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aucun patient disponible pour le moment',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textGrey),
              ),
            );
          }

          final doctorIds = uniqueDoctors.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: doctorIds.length,
            itemBuilder: (context, index) {
              final id = doctorIds[index];
              final name = uniqueDoctors[id]!;

              return GestureDetector(
                onTap: () => _navigateToChat(id, name),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 65,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                            ),
                            child: const Icon(Icons.person,
                                color: AppColors.primary, size: 28),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ المشكلة الرئيسية كانت هنا - الآن يقرأ من chats مباشرة
  Widget _buildRecentChatsSection() {
    return StreamBuilder<QuerySnapshot>(
      // ✅ تغيير: نقرأ من chats حيث المستخدم مشارك
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: _myUid)
          .orderBy('lastTimestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 64, color: AppColors.textGrey.withOpacity(0.5)),
                const SizedBox(height: 12),
                Text(
                  'Aucune discussion active',
                  style: GoogleFonts.poppins(color: AppColors.textGrey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            // ✅ استخراج ID الطرف الآخر (الطبيب)
            final participants = List<String>.from(data['participants'] ?? []);
            final doctorId = participants.lastWhere(
              (id) => id != _myUid,
              orElse: () => '',
            );

            final lastMessage = data['lastMessage'] ?? '';
            final lastTimestamp = data['lastTimestamp'] as Timestamp?;

            if (doctorId.isEmpty) return const SizedBox();

            return FutureBuilder<DocumentSnapshot>(
              // ✅ جلب اسم الطبيب من users
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(doctorId)
                  .get(),
              builder: (context, userSnap) {
                String doctorName = 'patient';

                if (userSnap.hasData && userSnap.data!.exists) {
                  final uData = userSnap.data!.data() as Map<String, dynamic>?;
                  doctorName =
                      uData?['nom'] ?? uData?['username'] ?? doctorName;
                }

                // ✅ تنسيق الوقت
                String timeText = '';
                if (lastTimestamp != null) {
                  final dt = lastTimestamp.toDate();
                  final now = DateTime.now();
                  if (dt.day == now.day &&
                      dt.month == now.month &&
                      dt.year == now.year) {
                    timeText = TimeOfDay.fromDateTime(dt).format(context);
                  } else {
                    timeText = '${dt.day}/${dt.month}';
                  }
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    onTap: () => _navigateToChat(doctorId, doctorName),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: AppColors.primary, size: 24),
                    ),
                    title: Text(
                      doctorName,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textDark),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textGrey),
                    ),
                    // ✅ إضافة وقت آخر رسالة
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timeText,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.arrow_forward_ios,
                            size: 12, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart'; // تأكد من مسار الـ UserModel الخاص بك
import 'patient_messages_screen.dart'; // صفحة المحادثة التي قمت بإنشائها سابقاً

class PatientChatsListScreen extends StatefulWidget {
  const PatientChatsListScreen({super.key});

  @override
  State<PatientChatsListScreen> createState() => _PatientChatsListScreenState();
}

class _PatientChatsListScreenState extends State<PatientChatsListScreen> {
  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // دالة مساعدة للانتقال لصفحة المحادثة ديناميكياً
  void _navigateToChat(String doctorId, String doctorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientMessagesScreen(
            // ملاحظة: تأكد من تعديل صفحة PatientMessagesScreen لتستقبل هذه المتغيرات ديناميكياً بدلاً من 'd2' وثابت 'Dr. Hasni'
             doctorId: doctorId,
             doctorName: doctorName,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Messages',
          style: GoogleFonts.poppins(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1️⃣ الجزء العلوي: الأطباء الذين قبلوا الموعد (مستدير أفقي مثل استوري فيسبوك)
          _buildAcceptedDoctorsSection(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(color: Colors.black12, thickness: 1),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Discussions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),

          // 2️⃣ الجزء السفلي: قائمة المحادثات النشطة حالياً
          Expanded(
            child: _buildRecentChatsSection(),
          ),
        ],
      ),
    );
  }

  // باني قسم الأطباء المقبولين (الرول الأفقي)
  Widget _buildAcceptedDoctorsSection() {
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rendezVous')
            .where('patientId', isEqualTo: _myUid)
            .where('statut', isEqualTo: 'confirme') // المواعيد المقبولة فقط
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          // استخراج الأطباء بشكل فريد (منع التكرار إذا كان هناك أكثر من موعد مقبول مع نفس الطبيب)
          final docs = snapshot.data!.docs;
          final Map<String, String> uniqueDoctors = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final docId = data['doctorId'] ?? '';
            final docNom = data['doctorNom'] ?? 'Médecin';
            if (docId.isNotEmpty) {
              uniqueDoctors[docId] = docNom;
            }
          }

          if (uniqueDoctors.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aucun médecin disponible pour le moment',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textGrey),
              ),
            );
          }

          final doctorIds = uniqueDoctors.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: doctorIds.length,
            itemBuilder: (context, index) {
              final id = doctorIds[index];
              final name = uniqueDoctors[id]!;

              return GestureDetector(
                onTap: () => _navigateToChat(id, name),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 65,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                            ),
                            child: const Icon(Icons.person,
                                color: AppColors.primary, size: 28),
                          ),
                          // نقطة خضراء تشبه المتصلين حالياً في فيسبوك
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // باني قسم قائمة المحادثات (رأسي)
  Widget _buildRecentChatsSection() {
    return StreamBuilder<QuerySnapshot>(
      // جلب جميع الرسائل المتعلقة بالمستخدم الحالي
      stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: true) // الأحدث أولاً
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // تصفية المحادثات الفرعية واستخراج آخر رسالة مع كل طبيب تواصلت معه
        final Map<String, Map<String, dynamic>> activeChats = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final sender = data['senderId'] ?? '';
          final receiver = data['receiverId'] ?? '';
          final contenu = data['contenu'] ?? '';
          final timestamp = data['timestamp'] as Timestamp?;

          // إذا كنت أنا المرسل، فالطرف الآخر هو المستقبل (الطبيب) والعكس بالعكس
          String chatPartnerId = '';
          if (sender == _myUid) {
            chatPartnerId = receiver;
          } else if (receiver == _myUid) {
            chatPartnerId = sender;
          }

          // إذا كانت المحادثة تخصني ولم نقم بتخزين آخر رسالة لهذا الطبيب بعد (لأننا رتبناها تنازلياً بالأحدث)
          if (chatPartnerId.isNotEmpty &&
              !activeChats.containsKey(chatPartnerId)) {
            activeChats[chatPartnerId] = {
              'lastMessage': contenu,
              'timestamp': timestamp,
              // سنضع اسماً افتراضياً يتم تحديثه أو جلب كوليكشن المواعيد لمعرفته، أو يمكنك عمل جلب لإسم الطبيب لاحقاً
              'doctorName': 'Dr. Professionnel',
            };
          }
        }

        if (activeChats.isEmpty) {
          return Center(
            child: Text(
              'Aucune discussion active',
              style: GoogleFonts.poppins(color: AppColors.textGrey),
            ),
          );
        }

        final partnerIds = activeChats.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: partnerIds.length,
          itemBuilder: (context, index) {
            final docId = partnerIds[index];
            final chatData = activeChats[docId]!;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                onTap: () => _navigateToChat(docId, chatData['doctorName']),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 24),
                ),
                title: FutureBuilder<DocumentSnapshot>(
                  // جلب اسم الطبيب الحقيقي ديناميكياً من كوليكشن المستخدمين بدلاً من الإسم الافتراضي
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(docId)
                      .get(),
                  builder: (context, userSnap) {
                    String name = chatData['doctorName'];
                    if (userSnap.hasData && userSnap.data!.exists) {
                      final uData =
                          userSnap.data!.data() as Map<String, dynamic>?;
                      name =
                          uData?['nomProfessionnel'] ?? uData?['nom'] ?? name;
                    }
                    return Text(
                      name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textDark),
                    );
                  },
                ),
                subtitle: Text(
                  chatData['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textGrey),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}
*/
