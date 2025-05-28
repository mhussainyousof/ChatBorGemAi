import 'package:flutter/foundation.dart' show debugPrint, immutable, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_chat_bot/provider/ui_state_providers.dart';
import 'package:google_sign_in/google_sign_in.dart';
  
@immutable
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn; // Make nullable for web

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? (kIsWeb ? null : GoogleSignIn());

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web implementation
        final googleProvider = GoogleAuthProvider();
         googleProvider.setCustomParameters({
        'prompt': 'select_account'  
      });
        return await _firebaseAuth.signInWithPopup(googleProvider);
        
      } else {
        // Mobile implementation
        final googleUser = await _googleSignIn?.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _firebaseAuth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return null;
    }
  }

  Future<void> signout(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      if (!kIsWeb) {
        await _googleSignIn?.signOut();
      }
      await _firebaseAuth.signOut();
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}