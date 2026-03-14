import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habitu/services/fcm_service.dart';

/// When mounted with a [uid], fetches FCM token, saves to Firestore
/// (users/{uid}), and listens for token refresh to keep Firestore updated.
class FcmTokenRegistration extends StatefulWidget {
  final String uid;
  final Widget child;

  const FcmTokenRegistration({
    super.key,
    required this.uid,
    required this.child,
  });

  @override
  State<FcmTokenRegistration> createState() => _FcmTokenRegistrationState();
}

class _FcmTokenRegistrationState extends State<FcmTokenRegistration> {
  StreamSubscription<String>? _tokenSubscription;

  @override
  void initState() {
    super.initState();
    _registerToken();
    final fcm = FcmService();
    _tokenSubscription = fcm.tokenRefreshStream.listen((token) {
      saveFcmTokenToFirestore(widget.uid, token);
    });
  }

  Future<void> _registerToken() async {
    final token = await FcmService().getToken();
    print('FCM Token: $token');
    if (token != null && mounted) {
      await saveFcmTokenToFirestore(widget.uid, token);
    }
  }

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
