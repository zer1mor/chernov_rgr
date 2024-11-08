import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:order_processing_app/utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Восстановление пароля',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
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
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () async {
                  var email = emailController.text.trim();
                  if (email.isEmpty) {
                    EasyLoading.dismiss();
                    return;
                  }

                  EasyLoading.show(status: 'Отправка запроса...');
                  try {
                    EasyLoading.dismiss();
                    Get.snackbar('Успех', 'Ссылка для восстановления пароля отправлена!');
                  } catch (e) {
                    EasyLoading.dismiss();
                    Get.snackbar('Ошибка', 'Не удалось отправить запрос: $e');
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
                  'Восстановить пароль',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 30),
              OutlinedButton(
                onPressed: () {
                  Get.back();
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
                  'Назад',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
