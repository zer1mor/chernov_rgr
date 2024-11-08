import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:order_processing_app/utils/constants.dart';
import 'package:order_processing_app/views/ForgotPasswordScreen.dart';
import 'package:order_processing_app/views/SignupScreen.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppConstants.appName, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 250,
                width: 250,
                child: Lottie.asset('assets/service.json', fit: BoxFit.cover),
              ),
              FadeInLeft(
                duration: const Duration(milliseconds: 1000),
                child: TextFormField(
                  controller: userEmailController,
                  decoration: InputDecoration(
                    hintText: "Электронная почта",
                    labelText: "Электронная почта",
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInLeft(
                duration: const Duration(milliseconds: 1000),
                child: TextFormField(
                  controller: userPasswordController,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    hintText: "Пароль",
                    labelText: "Пароль",
                    prefixIcon: const Icon(Icons.password_outlined, color: Colors.black),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      child: obscureText
                          ? const Icon(Icons.visibility_outlined, color: Colors.black)
                          : const Icon(Icons.visibility_off_outlined, color: Colors.black),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.to(const ForgotPasswordScreen());
                },
                child: FadeInRight(
                  duration: const Duration(milliseconds: 1000),
                  child: Container(
                    alignment: Alignment.topRight,
                    child: const Text(
                      'Забыли пароль? ',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: OutlinedButton(
                  onPressed: () async {
                    var userEmail = userEmailController.text.trim();
                    var userPassword = userPasswordController.text.trim();
                    EasyLoading.show();
                    try {
                      final User? firebaseuser = (await FirebaseAuth.instance
                          .signInWithEmailAndPassword(email: userEmail, password: userPassword))
                          .user;
                      if (firebaseuser != null) {
                        Get.to(const HomeScreen());
                        EasyLoading.dismiss();
                        Fluttertoast.showToast(msg: "Вы успешно авторизированы");
                      }
                    } on FirebaseAuthException catch (e) {
                      Fluttertoast.showToast(msg: '$e');
                      EasyLoading.dismiss();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Войти',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Get.to(const SignupScreen());
                },
                child: FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(const SignupScreen());
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Регистрация',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
