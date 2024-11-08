import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:order_processing_app/views/LoginScreen.dart';

signUpUser(String userName, String userEmail, String userPassword) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: userEmail,
      password: userPassword,
    );

    User? user = userCredential.user;

    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        'userName': userName,
        'userEmail': userEmail,
        'createdAt': DateTime.now(),
        'userId': user.uid,
      }).then((value) {
        FirebaseAuth.instance.signOut();
        Get.to(const LoginScreen());
      });
    }
  } on FirebaseAuthException catch (e) {
    Fluttertoast.showToast(msg: e.message ?? 'Произошла ошибка');
  }
}
