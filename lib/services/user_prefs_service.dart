import 'package:cloud_firestore/cloud_firestore.dart';

const String _setupCompleteField = 'setupComplete';

class UserPrefsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isSetupComplete(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return (doc.data()?[_setupCompleteField] as bool?) ?? false;
  }

  Future<void> setSetupComplete(String uid) async {
    await _firestore.collection('users').doc(uid).set({_setupCompleteField: true});
  }
}
