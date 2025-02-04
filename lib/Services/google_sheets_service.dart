import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class GoogleSheetsService {
  final sheets.SheetsApi _sheetsApi;
  final String spreadsheetId;

  GoogleSheetsService(this._sheetsApi, this.spreadsheetId);

  static Future<GoogleSheetsService> initialize() async {
    final credentials = ServiceAccountCredentials.fromJson(
      jsonDecode(await rootBundle.loadString('assets/service_account.json')),
    );

    final client = await auth.clientViaServiceAccount(
        credentials,
        [sheets.SheetsApi.spreadsheetsScope]
    );

    const spreadsheetId = "1kTRJGhhEXbtkdB0mb3iTYSSZBtDaJ-7n0T8NEY3Hbro";
    final sheetsApi = sheets.SheetsApi(client);

    return GoogleSheetsService(sheetsApi, spreadsheetId);
  }

  Future<void> addOrder(Map<String, dynamic> orderData, String docId) async {
    if (orderData['productName'] == null || orderData['clientAddress'] == null) {
      print("Недостаточно данных для добавления заказа");
      return;
    }

    final values = [
      [
        docId,
        orderData['userId'] ?? 'id не указан',
        orderData['clientName'] ?? 'Имя пользователя не указано',
        orderData['productName'] ?? 'Название услуги не указано',
        orderData['clientContact'] ?? 'Телефон не указан',
        orderData['clientAddress'] ?? 'Адрес не указан',
        orderData['district'] ?? 'Район доставки не указан',
        orderData['transport'] ?? 'Нет данных',
        orderData['cargoSize'] ?? 'Нет данных',
        orderData['buyPrice']?.toString() ?? 'Цена не определена',
        orderData['amountWorkers']?.toString() ?? 'Грузчики не определены',
        orderData['DateTime']?.toString() ?? 'Дата заказа',
        orderData['sellDate']?.toString() ?? 'Ожидаемая дата доставки',
      ]
    ];

    final request = sheets.ValueRange(values: values);
    try {
      await _sheetsApi.spreadsheets.values.append(
        request,
        spreadsheetId,
        'Orders!A:M',
        valueInputOption: 'RAW',
      );
    } catch (e) {
      print("Ошибка при добавлении заказа в Google Sheets: $e");
    }
  }

  Future<void> deleteOrder(String docId) async {
    final range = 'Orders!A:A';
    final response = await _sheetsApi.spreadsheets.values.get(spreadsheetId, range);

    if (response.values == null) return;

    for (var i = 0; i < response.values!.length; i++) {
      if (response.values![i].isNotEmpty && response.values![i][0] == docId) {
        await _sheetsApi.spreadsheets.batchUpdate(
          sheets.BatchUpdateSpreadsheetRequest(
            requests: [
              sheets.Request(
                deleteDimension: sheets.DeleteDimensionRequest(
                  range: sheets.DimensionRange(
                    sheetId: 0,
                    dimension: 'ROWS',
                    startIndex: i,
                    endIndex: i + 1,
                  ),
                ),
              )
            ],
          ),
          spreadsheetId,
        );
        break;
      }
    }
  }
}
