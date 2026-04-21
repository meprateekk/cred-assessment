import 'package:dio/dio.dart';

import '../models/bill_scenario.dart';
import '../models/bills_section.dart';
import 'mock_bill_payloads.dart';

class BillRepository {
  BillRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  final Dio _dio;

  Future<BillsSection> fetchSection(BillScenario scenario) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(scenario.endpoint);
      final data = response.data;
      if (data == null) {
        throw const FormatException('Empty response');
      }

      return BillsSection.fromJson(data, scenario);
    } on DioException {
      return BillsSection.fromJson(_fallbackFor(scenario), scenario);
    }
  }

  Map<String, dynamic> _fallbackFor(BillScenario scenario) {
    switch (scenario) {
      case BillScenario.twoItems:
        return mock1Payload;
      case BillScenario.manyItems:
        return mock2Payload;
    }
  }
}
