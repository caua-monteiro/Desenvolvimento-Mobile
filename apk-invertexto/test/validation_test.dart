import 'package:flutter_test/flutter_test.dart';
import 'package:aula_26_08/validation/input_validators.dart';

void main() {
  test('Campos obrigatórios', () {
    for (final validator in [
      InputValidators.cep,
      InputValidators.number,
      InputValidators.year,
      InputValidators.email,
      InputValidators.cnpj,
    ]) {
      expect(validator(null), isNotNull);
      expect(validator('  '), isNotNull);
    }
  });
  test('CEP aceita máscara e rejeita letras ou tamanho incorreto', () {
    for (final value in ['01001000', '01001-000']) {
      expect(InputValidators.cep(value), isNull);
    }
    for (final value in ['123', 'abcdefgh', '01001x000']) {
      expect(InputValidators.cep(value), isNotNull);
    }
  });
  test('Números aceitam sinal e decimal, rejeitam formatos ambíguos', () {
    for (final value in ['0', '-12', '123,45', '123.45']) {
      expect(InputValidators.number(value), isNull);
    }
    for (final value in [
      'NaN',
      '1e3',
      '1.234,56',
      '1,2,3',
      '9999999999999999',
    ]) {
      expect(InputValidators.number(value), isNotNull);
    }
  });
  test('Ano com quatro dígitos dentro do intervalo da tela', () {
    expect(InputValidators.year('2026'), isNull);
    for (final value in ['26', '2026.0', '0000', '2101']) {
      expect(InputValidators.year(value), isNotNull);
    }
  });
  test('Formato de e-mail', () {
    expect(InputValidators.email('aluno+teste@exemplo.com.br'), isNull);
    for (final value in [
      'a@',
      '@teste.com',
      'a b@teste.com',
      'a..b@teste.com',
      'a@-teste.com',
    ]) {
      expect(InputValidators.email(value), isNotNull);
    }
  });
  test('CNPJ numérico e alfanumérico com dígitos verificadores', () {
    for (final value in [
      '00000000000191',
      '00.000.000/0001-91',
      '12.ABC.345/01DE-35',
      '12abc34501de35',
    ]) {
      expect(InputValidators.cnpj(value), isNull, reason: value);
    }
    for (final value in [
      '00000000000000',
      '00000000000192',
      '12ABC34501DE36',
      '123',
      '00 000000000191',
    ]) {
      expect(InputValidators.cnpj(value), isNotNull);
    }
  });
}
