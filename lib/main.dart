import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:order_processing_app/utils/constants.dart';
import 'package:order_processing_app/views/HomeScreen.dart';
import 'package:order_processing_app/views/LoginScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        this.user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Белый фон для всего приложения
        primarySwatch: Colors.green,
        // Настройка стиля кнопок
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Белый фон для кнопок
            side: BorderSide(color: Colors.green), // Зелёная граница
            foregroundColor: Colors.black, // Чёрный текст
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Скругленные углы
            ),
          ),
        ),
        // Тема для текста
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Чёрный текст
        ),
        // Цвет фона для AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black), // Чёрные иконки на AppBar
          titleTextStyle: TextStyle(color: Colors.black), // Чёрный текст заголовка
        ),
      ),
      builder: EasyLoading.init(),
      home: user != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}
