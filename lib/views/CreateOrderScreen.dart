import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'HomeScreen.dart';
import 'models/order.dart' as order;
import 'package:order_processing_app/Services/google_sheets_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController buyPriceController = TextEditingController();
  final TextEditingController amountPeopleController = TextEditingController();
  final TextEditingController sellDateController = TextEditingController();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientAddressController = TextEditingController();
  final TextEditingController clientContactController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;
  late GoogleSheetsService googleSheetsService;

  List<order.Transport> transportList = [];
  List<order.District> districtList = [];
  List<order.CargoSize> cargoSizeList = [];

  order.Transport? selectedTransport;
  order.District? selectedDistrict;
  order.CargoSize? selectedCargoSize;

  @override
  void initState() {
    super.initState();
    loadData();
    _initGoogleSheets();
  }

  Future<void> _initGoogleSheets() async {
    try {
      googleSheetsService = await GoogleSheetsService.initialize();
    } catch (e) {
      print("Ошибка инициализации Google Sheets: $e");
      Fluttertoast.showToast(msg: "Ошибка инициализации Google Sheets");
    }
  }

  Future<void> loadData() async {
    List<order.Transport> loadedTransportList = await order.TransportService.getTransports();
    List<order.District> loadedDistricts = await order.DistrictService.getDistricts();
    List<order.CargoSize> loadedCargoSizes = await order.CargoSizeService.getCargoSizes();

    setState(() {
      transportList = loadedTransportList;
      selectedTransport = transportList.isNotEmpty ? transportList.first : null;

      districtList = loadedDistricts;
      selectedDistrict = districtList.isNotEmpty ? districtList.first : null;

      cargoSizeList = loadedCargoSizes;
      selectedCargoSize = cargoSizeList.isNotEmpty ? cargoSizeList.first : null;
    });
  }

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
              _buildTextField(clientContactController, "Контактный телефон клиента"),
              const SizedBox(height: 20),

              _buildDropdown<order.Transport>(
                label: "Транспорт",
                items: transportList,
                selectedItem: selectedTransport,
                onChanged: (value) => setState(() => selectedTransport = value),
              ),
              const SizedBox(height: 20),

              _buildDropdown<order.District>(
                label: "Район доставки",
                items: districtList,
                selectedItem: selectedDistrict,
                onChanged: (value) => setState(() => selectedDistrict = value),
              ),
              const SizedBox(height: 20),

              _buildDropdown<order.CargoSize>(
                label: "Габариты груза",
                items: cargoSizeList,
                selectedItem: selectedCargoSize,
                onChanged: (value) => setState(() => selectedCargoSize = value),
              ),
              const SizedBox(height: 20),

              _buildTextField(buyPriceController, "Стоимость услуги"),
              const SizedBox(height: 20),
              _buildTextField(amountPeopleController, "Число грузчиков"),
              const SizedBox(height: 20),
              _buildTextField(sellDateController, "Дата ожидаемой доставки"),
              const SizedBox(height: 20),

              OutlinedButton(
                onPressed: _createOrder,
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

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? selectedItem,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: selectedItem,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _createOrder() async {
    if (productNameController.text.isEmpty || clientAddressController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Заполните все обязательные поля");
      return;
    }

    EasyLoading.show();
    try {
      order.Order newOrder = order.Order(
        userId: user!.uid,
        clientName: clientNameController.text.trim(),
        productName: productNameController.text.trim(),
        clientAddress: clientAddressController.text.trim(),
        clientContact: clientContactController.text.trim(),
        buyPrice: double.tryParse(buyPriceController.text.trim()) ?? 0,
        amountWorkers: double.tryParse(amountPeopleController.text.trim()) ?? 0,
        sellDate: sellDateController.text.trim(),
        date: DateTime.now(),
        transport: selectedTransport ?? transportList.first,
        district: selectedDistrict ?? districtList.first,
        cargoSize: selectedCargoSize ?? cargoSizeList.first,
      );

      final docRef = await FirebaseFirestore.instance.collection('orders').add(newOrder.toMap());
      final docId = docRef.id;

      final orderData = {
        'userId': newOrder.userId,
        'clientName': newOrder.clientName,
        'productName': newOrder.productName,
        'clientContact': newOrder.clientContact,
        'clientAddress': newOrder.clientAddress,
        'district': newOrder.district.toString(),
        'transport': newOrder.transport.toString(),
        'cargoSize': newOrder.cargoSize.toString(),
        'buyPrice': newOrder.buyPrice,
        'amountWorkers': newOrder.amountWorkers,
        'DateTime': newOrder.date,
        'sellDate': newOrder.sellDate
      };

      try {
        await googleSheetsService.addOrder(orderData, docId);
      } catch (e) {
        print("Ошибка при добавлении заказа в Google Sheets: $e");
        Fluttertoast.showToast(msg: "Заказ создан, но не добавлен в Google Sheets");
      }

      Fluttertoast.showToast(msg: "Заказ успешно создан");
      Get.off(const HomeScreen());
    } catch (e, stackTrace) {
      print("Ошибка при создании заказа: $e");
      print(stackTrace);
      Fluttertoast.showToast(msg: "Ошибка при создании заказа");
    } finally {
      EasyLoading.dismiss();
    }
  }
}