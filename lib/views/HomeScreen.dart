import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:order_processing_app/views/CreateOrderScreen.dart';
import 'LoginScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Управление заказами, Чернов Егор, мТЭБ301", style: TextStyle(color: Colors.black)),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(const CreateOrderScreen());
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              child: const CircleAvatar(
                child: Icon(Icons.shopping_cart, color: Colors.black),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(child: Text("ECh")),
              accountName: Text('Чернов Егор'),
              accountEmail: Text("mysecretemail"),
            ),
            ListTile(
              title: Text("Домашняя страница"),
              leading: Icon(Icons.home_outlined),
              trailing: Icon(Icons.arrow_circle_right_outlined),
            ),
            GestureDetector(
              onTap: () {
                Get.to(const CreateOrderScreen());
              },
              child: ListTile(
                title: Text("Оформить перевозку"),
                leading: Icon(Icons.add_business_outlined),
                trailing: Icon(Icons.arrow_circle_right_outlined),
              ),
            ),
            ListTile(
              title: Text("Информация"),
              leading: Icon(Icons.info_outline),
              trailing: Icon(Icons.arrow_circle_right_outlined),
            ),
            Divider(height: 3, color: Colors.grey),
            ListTile(
              title: Text("Помощь"),
              leading: Icon(Icons.help_center_outlined),
              trailing: Icon(Icons.arrow_circle_right_outlined),
            ),
            Divider(height: 5, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: "Выйти из аккаунта",
                    titlePadding: const EdgeInsets.only(top: 20),
                    contentPadding: const EdgeInsets.all(10),
                    middleText: "Вы уверены что хотите выйти?",
                    confirm: TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAll(const LoginScreen());
                        Fluttertoast.showToast(msg: "Вы успешно вышли");
                      },
                      child: const Text("Да"),
                    ),
                    cancel: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text("Нет"),
                    ),
                  );
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
                  "Выйти с аккаунта",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Заказы')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Ошибка"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                String status = snapshot.data!.docs[index]['status'];
                var docId = snapshot.data!.docs[index].id;
                return Card(
                  child: FadeInLeftBig(
                    child: ListTile(
                      title: Text(snapshot.data!.docs[index]['productName']),
                      subtitle: Text(
                        status,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      leading: CircleAvatar(
                        child: Text(index.toString()),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status != 'Услуга оказана')
                            IconButton(
                              icon: const Icon(Icons.assignment_turned_in_outlined),
                              onPressed: () {
                                Get.defaultDialog(
                                  titlePadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                  title: "Изменить статус заказа?",
                                  content: const Text(""),
                                  onCancel: () {},
                                  onConfirm: () async {
                                    EasyLoading.show();
                                    await FirebaseFirestore.instance
                                        .collection('Заказы')
                                        .doc(docId)
                                        .update({'status': 'Услуга оказана'});
                                    Get.back();
                                    EasyLoading.dismiss();
                                  },
                                );
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Удалить заказ",
                                middleText: "Вы уверены, что хотите удалить этот заказ?",
                                confirm: TextButton(
                                  onPressed: () async {
                                    EasyLoading.show();
                                    await FirebaseFirestore.instance
                                        .collection('Заказы')
                                        .doc(docId)
                                        .delete();
                                    Get.back();
                                    EasyLoading.dismiss();
                                    Fluttertoast.showToast(msg: "Заказ удален");
                                  },
                                  child: const Text("Да"),
                                ),
                                cancel: TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text("Нет"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text("Нет доступных заказов"),
          );
        },
      ),
    );
  }
}
