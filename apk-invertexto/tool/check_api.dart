// Verificação manual: realiza cinco consultas reais e consome a cota da API.
import 'dart:io';
import 'package:aula_26_08/service/invertertexto_service.dart';

Future<void> main() async {
  final api = InverterTextoService();
  try {
    final cep = await api.buscaCEP('01001-000');
    if (cep['city'] != 'São Paulo') throw StateError('CEP inesperado');
    stdout.writeln('CEP: OK');
    final number = await api.converterPorExtenso('123,45', currency: true);
    if (!number['text'].toString().contains('centavos')) {
      throw StateError('Centavos ausentes');
    }
    stdout.writeln('Número por extenso com centavos: OK');
    final holidays = await api.holidays('2026', state: 'SP');
    if (!holidays.any((h) => h['date'] == '2026-07-09')) {
      throw StateError('Feriado estadual ausente');
    }
    stdout.writeln('Feriados nacionais e estaduais: OK');
    await api.emailValidator('teste@example.com');
    stdout.writeln('Validação de e-mail: OK');
    await api.cnpj('00.000.000/0001-91');
    stdout.writeln('Consulta de CNPJ: OK');
  } finally {
    api.close();
  }
}
