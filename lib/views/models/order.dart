  import 'package:cloud_firestore/cloud_firestore.dart';

  // Сущность "Заказ"
  class Order {
    final String userId;
    final String clientName;
    final String productName;
    final String clientAddress;
    final String clientContact;
    final Transport? transport;
    final District? district;
    final CargoSize? cargoSize;
    final double buyPrice;
    final double amountWorkers;
    final String sellDate;
    final DateTime date;

    Order({
      required this.userId,
      required this.clientName,
      required this.productName,
      required this.clientAddress,
      required this.clientContact,
      this.transport,
      this.district,
      this.cargoSize,
      required this.buyPrice,
      required this.amountWorkers,
      required this.sellDate,
      required this.date,
    });

    Map<String, dynamic> toMap() {
      return {
        "userId": userId,
        "clientName": clientName,
        "productName": productName,
        "clientAddress": clientAddress,
        "clientContact": clientContact,
        "transport": transport?.name ?? "",
        "district": district?.name ?? "",
        "cargoSize": cargoSize?.label ?? "",
        "buyPrice": buyPrice,
        "amountWorkers": amountWorkers,
        "sellDate": sellDate,
        "date": date.toIso8601String(),
      };
    }

    factory Order.fromFirestore(DocumentSnapshot doc) {
      Map data = doc.data() as Map<String, dynamic>;
      return Order(
        userId: data["userId"] ?? "",
        clientName: data["clientName"] ?? "",
        productName: data["productName"] ?? "",
        clientAddress: data["clientAddress"] ?? "",
        clientContact: data["clientContact"] ?? "",
        transport: data["transport"] != "" ? Transport(data["transport"]) : null,
        district: data["district"] != "" ? District(data["district"]) : null,
        cargoSize: data["cargoSize"] != "" ? CargoSize(data["cargoSize"]) : null,
        buyPrice: (data["buyPrice"] ?? 0).toDouble(),
        amountWorkers: (data["amountWorkers"] ?? 0).toDouble(),
        sellDate: data["sellDate"] ?? "",
        date: DateTime.parse(data["date"] ?? DateTime.now().toIso8601String()),
      );
    }
  }

  class OrderService {
    static final FirebaseFirestore _db = FirebaseFirestore.instance;

    static Future<void> createOrder(Order order) async {
      await _db.collection("orders").add(order.toMap());
    }

    static Stream<List<Order>> getUserOrders(String userId) {
      return _db
          .collection("orders")
          .where("userId", isEqualTo: userId) // 👈 Фильтр по userId
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
    }
  }

  // Сущность "Транспорт"
  class Transport {
    final String name;
    Transport(this.name);

    @override
    String toString() => name;
  }

  class TransportService {
    static Future<List<Transport>> getTransports() async {
      return [
        Transport("S: подойдёт для нескольких коробок (до 300кг)"),
        Transport("M: Увезёт стиральную машину и диван (до 700кг)"),
        Transport("L: Поможет переехать в новую квартиру (до 1400кг)"),
        Transport("XL: Подойдёт для стройматериалов (до 2000кг)"),
      ];
    }
  }

  // Сущность "Район доставки"
  class District {
    final String name;
    District(this.name);

    @override
    String toString() => name;
  }

  class DistrictService {
    static Future<List<District>> getDistricts() async {
      return [
        District("Ленинский"),
        District("Октябрьский"),
        District("Калининский"),
        District("Кировский"),
        District("Дзержинский"),
        District("Заельцовский"),
        District("Советский"),
        District("Первомайский"),
        District("Центральный"),
        District("Железнодорожный"),
        District("Новосибирская область"),
      ];
    }
  }

  // Сущность "Габариты груза"
  class CargoSize {
    final String label;
    CargoSize(this.label);

    @override
    String toString() => label;
  }

  class CargoSizeService {
    static Future<List<CargoSize>> getCargoSizes() async {
      return [
        CargoSize("Маленький (до 300кг)"),
        CargoSize("Средний (до 700кг)"),
        CargoSize("Большой (до 1400кг)"),
        CargoSize("Очень большой (до 2000кг)"),
      ];
    }
  }
