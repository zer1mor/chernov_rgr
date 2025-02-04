import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final User? user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> getUserOrders() {
    return FirebaseFirestore.instance
        .collection("orders")
        .where("userId", isEqualTo: user!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Управление заказами, Чернов Егор, мТЭБ301",
          style: TextStyle(color: Colors.black),
        ),
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
        iconTheme: const IconThemeData(color: Colors.black),
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
              title: const Text("Домашняя страница"),
              leading: const Icon(Icons.home_outlined),
              trailing: const Icon(Icons.arrow_circle_right_outlined),
            ),
            GestureDetector(
              onTap: () {
                Get.to(const CreateOrderScreen());
              },
              child: ListTile(
                title: const Text("Оформить перевозку"),
                leading: const Icon(Icons.add_business_outlined),
                trailing: const Icon(Icons.arrow_circle_right_outlined),
              ),
            ),
            const ListTile(
              title: Text("Информация"),
              leading: Icon(Icons.info_outline),
              trailing: Icon(Icons.arrow_circle_right_outlined),
            ),
            const Divider(height: 3, color: Colors.grey),
            const ListTile(
              title: Text("Помощь"),
              leading: Icon(Icons.help_center_outlined),
              trailing: Icon(Icons.arrow_circle_right_outlined),
            ),
            const Divider(height: 5, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(const LoginScreen());
                  Fluttertoast.showToast(msg: "Вы успешно вышли");
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
            .collection('orders')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Ошибка загрузки заказов"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Нет текущих заказов"));
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              try {
                var orderData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String docId = snapshot.data!.docs[index].id;

                String productName = orderData['productName'] ?? 'Без названия';
                String status = orderData['status'] ?? 'Заказ в обработке';
                String clientAddress = orderData['clientAddress'] ?? 'Адрес не указан';
                String transport = orderData['transport'] ?? 'Транспорт не указан';
                String cargoSize = orderData['cargoSize'] ?? 'Размер не указан';
                double buyPrice = (orderData['buyPrice'] as num?)?.toDouble() ?? 0.0;
                String sellDate = (orderData['sellDate']) ?? 'Дата не указана';

                return Card(
                  child: FadeInLeftBig(
                    child: ListTile(
                      title: Text(productName),
                      subtitle: Text(
                        'Статус: $status\nАдрес: $clientAddress\nТранспорт: $transport\nРазмер: $cargoSize\nЦена: ${buyPrice.toStringAsFixed(2)} руб.\nОжидаемая дата доставки: $sellDate',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status != 'Услуга оказана')
                            IconButton(
                              icon: const Icon(Icons.assignment_turned_in_outlined),
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(docId)
                                      .update({'status': 'Услуга оказана'});
                                } catch (e) {
                                  debugPrint('Ошибка при обновлении статуса заказа: $e');
                                }
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance.collection('orders').doc(docId).delete();
                                Fluttertoast.showToast(msg: "Заказ удален");
                              } catch (e) {
                                debugPrint('Ошибка при удалении заказа: $e');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } catch (e) {
                debugPrint('Ошибка при обработке заказа: $e');
                return const Center(child: Text("Ошибка при загрузке заказа"));
              }
            },
          );
        },
      ),
    );
  }
}
