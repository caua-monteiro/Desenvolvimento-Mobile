import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aula_26_08/service/invertertexto_service.dart';

void main() {
  InverterTextoService service(
    Future<http.Response> Function(http.Request) handler,
  ) {
    final api = InverterTextoService(
      client: MockClient(handler),
      timeout: const Duration(milliseconds: 20),
    );
    addTearDown(api.close);
    return api;
  }

  test('Normaliza entradas e monta as cinco rotas', () async {
    final paths = <String>[];
    final api = service((request) async {
      paths.add(request.url.path);
      expect(request.url.queryParameters['token'], isNotEmpty);
      if (request.url.path.contains('number-to-words')) {
        expect(request.url.queryParameters['number'], '123.45');
        expect(request.url.queryParameters['currency'], 'BRL');
        return http.Response(
          '{"text":"cento e vinte e tres reais e quarenta e cinco centavos"}',
          200,
        );
      }
      if (request.url.path.contains('holidays')) {
        expect(request.url.queryParameters['state'], 'SP');
        return http.Response(
          '[{"name":"Natal","date":"2026-12-25"},{"name":"Ano Novo","date":"2026-01-01"}]',
          200,
        );
      }
      if (request.url.path.contains('email-validator')) {
        return http.Response(
          '{"email":"a+b@exemplo.com","valid_format":true,"valid_mx":false,"disposable":false}',
          200,
        );
      }
      if (request.url.path.contains('cnpj')) {
        return http.Response('{"razao_social":"Empresa"}', 200);
      }
      return http.Response('{"cep":"01001000"}', 200);
    });
    await api.buscaCEP('01001-000');
    await api.converterPorExtenso('123,45', currency: true);
    expect((await api.holidays('2026', state: 'SP')).first['name'], 'Ano Novo');
    expect((await api.emailValidator('a+b@exemplo.com'))['valid_mx'], false);
    await api.cnpj('00.000.000/0001-91');
    expect(paths, [
      '/v1/cep/01001000',
      '/v1/number-to-words',
      '/v1/holidays/2026',
      '/v1/email-validator/a+b@exemplo.com',
      '/v1/cnpj/00000000000191',
    ]);
  });
  for (final code in [400, 401, 403, 404, 422, 429, 500, 503]) {
    test('Erro HTTP $code é convertido em mensagem amigável', () async {
      final api = service((_) async => http.Response('erro interno', code));
      await expectLater(api.buscaCEP('01001000'), throwsA(isA<ApiException>()));
    });
  }
  for (final body in [
    '',
    'null',
    '{}',
    '<html>erro</html>',
    '{"error":"erro"}',
    '{"street":"sem CEP"}',
    '[]',
  ]) {
    test('Resposta vazia/inválida: $body', () async {
      final api = service((_) async => http.Response(body, 200));
      await expectLater(api.buscaCEP('01001000'), throwsA(isA<ApiException>()));
    });
  }
  test('Sem internet e timeout têm mensagens específicas', () async {
    final offline = service(
      (_) async => throw const SocketException('offline'),
    );
    await expectLater(
      offline.buscaCEP('01001000'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'mensagem',
          contains('internet'),
        ),
      ),
    );
    final slow = service((_) => Completer<http.Response>().future);
    await expectLater(
      slow.buscaCEP('01001000'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'mensagem',
          contains('demorou'),
        ),
      ),
    );
  });
  test(
    'Feriados vazios são um resultado válido; e-mail incompleto não',
    () async {
      expect(
        await service((_) async => http.Response('[]', 200)).holidays('2026'),
        isEmpty,
      );
      await expectLater(
        service(
          (_) async => http.Response('{"email":"a@exemplo.com"}', 200),
        ).emailValidator('a@exemplo.com'),
        throwsA(isA<ApiException>()),
      );
    },
  );
  test('Entrada inválida não envia requisição', () async {
    final api = service((_) async {
      fail('Não deve consultar');
    });
    await expectLater(api.buscaCEP('abc'), throwsA(isA<ApiException>()));
    await expectLater(api.cnpj('00000000000192'), throwsA(isA<ApiException>()));
  });
}
