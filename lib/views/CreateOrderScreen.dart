import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'HomeScreen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();
  final TextEditingController clientContactController = TextEditingController();
  final TextEditingController buyPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController sellDateController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Создать заказ"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTextField(productNameController, "Название услуги перевозки"),
              const SizedBox(height: 20),
              _buildTextField(clientNameController, "Имя клиента"),
              const SizedBox(height: 20),
              _buildTextField(clientAddressController, "Адрес клиента"),
              const SizedBox(height: 20),
              _buildTextField(clientContactController, "Телефон клиента"),
              const SizedBox(height: 20),
              _buildTextField(buyPriceController, "Стоимость услуги"),
              const SizedBox(height: 20),
              _buildTextField(sellPriceController, "Число грузчиков"),
              const SizedBox(height: 20),
              _buildTextField(sellDateController, "Дата оформления услуги"),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () async {
                  EasyLoading.show();
                  try {
                    double? buyPrice = double.tryParse(buyPriceController.text.trim());
                    double? sellPrice = double.tryParse(sellPriceController.text.trim());
                    double? profit = (sellPrice != null && buyPrice != null) ? sellPrice - buyPrice : null;

                    Map<String, dynamic> userOrderMap = {
                      'userId': user?.uid,
                      'productName': productNameController.text.trim(),
                      'clientName': clientNameController.text.trim(),
                      'clientAddress': clientAddressController.text.trim(),
                      'clientContact': clientContactController.text.trim(),
                      'buyPrice': buyPrice ?? 0,
                      'sellPrice': sellPrice ?? 0,
                      'sellDate': sellDateController.text.trim(),
                      'date': DateTime.now(),
                      'profit': profit ?? 0,
                      'status': "Ожидание",
                    };

                    await FirebaseFirestore.instance.collection('Заказы').add(userOrderMap);

                    Fluttertoast.showToast(msg: "Заказ успешно создан");
                    Get.off(const HomeScreen());
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Ошибка при создании заказа");
                  } finally {
                    EasyLoading.dismiss();
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Оформить заказ на перевозку"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
