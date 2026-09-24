import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../validation/input_validators.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class InverterTextoService {
  final String _token = '27960|x0Xzfwbvhi2zSqrm2YPV1cploF2tqmcN';
  final http.Client _client;
  final Duration timeout;
  InverterTextoService({
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  void close() => _client.close();

  void _validate(String? error) {
    if (error != null) throw ApiException(error);
  }

  Future<dynamic> _get(
    List<String> path, [
    Map<String, String> query = const {},
  ]) async {
    final uri = Uri(
      scheme: 'https',
      host: 'api.invertexto.com',
      pathSegments: ['v1', ...path],
      queryParameters: {'token': _token, ...query},
    );
    try {
      final response = await _client.get(uri).timeout(timeout);
      switch (response.statusCode) {
        case 200:
          break;
        case 400:
        case 422:
          throw const ApiException(
            'A API não aceitou os dados. Confira os campos e tente novamente.',
          );
        case 401:
        case 403:
          throw const ApiException(
            'Acesso à API não autorizado. Verifique o token e as permissões do plano.',
          );
        case 404:
          throw const ApiException(
            'Nenhum dado encontrado para esta consulta.',
          );
        case 429:
          throw const ApiException(
            'Limite de consultas atingido. Tente novamente mais tarde.',
          );
        default:
          throw ApiException(
            response.statusCode >= 500
                ? 'O serviço está indisponível. Tente novamente mais tarde.'
                : 'Não foi possível concluir a consulta (erro ${response.statusCode}).',
          );
      }
      if (response.body.trim().isEmpty) {
        throw const ApiException(
          'A API retornou uma resposta vazia. Tente novamente.',
        );
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data == null || (data is Map && data.isEmpty)) {
        throw const ApiException('Nenhum dado encontrado para esta consulta.');
      }
      if (data is Map && (data['error'] != null || data['success'] == false)) {
        throw const ApiException(
          'A API não conseguiu realizar a consulta. Confira os dados e tente novamente.',
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException(
        'A consulta demorou demais. Verifique sua conexão e tente novamente.',
      );
    } on SocketException {
      throw const ApiException(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
      );
    } on HandshakeException {
      throw const ApiException(
        'Não foi possível estabelecer uma conexão segura. Tente novamente.',
      );
    } on FormatException {
      throw const ApiException(
        'O serviço retornou uma resposta inválida. Tente novamente mais tarde.',
      );
    }
  }

  Map<String, dynamic> _map(dynamic data, String requiredField) {
    if (data is! Map<String, dynamic> ||
        data[requiredField] == null ||
        data[requiredField].toString().trim().isEmpty) {
      throw const ApiException(
        'A API retornou dados incompletos. Tente novamente.',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> buscaCEP(String? value) async {
    _validate(InputValidators.cep(value));
    return _map(await _get(['cep', value!.trim().replaceAll('-', '')]), 'cep');
  }

  Future<Map<String, dynamic>> converterPorExtenso(
    String? value, {
    bool currency = false,
  }) async {
    _validate(InputValidators.number(value));
    return _map(
      await _get(
        ['number-to-words'],
        {
          'number': value!.trim().replaceAll(',', '.'),
          'language': 'pt',
          if (currency) 'currency': 'BRL',
        },
      ),
      'text',
    );
  }

  Future<List<Map<String, dynamic>>> holidays(
    String value, {
    String? state,
  }) async {
    _validate(InputValidators.year(value));
    final data = await _get(['holidays', value.trim()], {'state': ?state});
    if (data is! List) {
      throw const ApiException(
        'A API retornou uma lista de feriados inválida.',
      );
    }
    return data.map((item) {
        final holiday = _map(item, 'name');
        final date = holiday['date'];
        if (date is! String || DateTime.tryParse(date) == null) {
          throw const ApiException(
            'A API retornou uma data de feriado inválida.',
          );
        }
        return holiday;
      }).toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }

  Future<Map<String, dynamic>> emailValidator(String value) async {
    _validate(InputValidators.email(value));
    final data = _map(await _get(['email-validator', value.trim()]), 'email');
    if ([
      'valid_format',
      'valid_mx',
      'disposable',
    ].any((key) => data[key] is! bool)) {
      throw const ApiException(
        'A API retornou uma validação de e-mail incompleta.',
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> cnpj(String value) async {
    _validate(InputValidators.cnpj(value));
    return _map(
      await _get(['cnpj', InputValidators.normalizeCnpj(value)]),
      'razao_social',
    );
  }
}
