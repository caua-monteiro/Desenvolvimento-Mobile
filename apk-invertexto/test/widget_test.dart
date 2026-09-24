import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aula_26_08/main.dart';
import 'package:aula_26_08/view/consulta_page.dart';
import 'package:aula_26_08/service/invertertexto_service.dart';

void main() {
  testWidgets(
    'Os cinco botões abrem seus formulários sem consultar automaticamente',
    (tester) async {
      await tester.pumpWidget(const InverTextoApp());
      for (final feature in Feature.values) {
        await tester.ensureVisible(find.text(feature.title));
        await tester.tap(find.text(feature.title));
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Consultar'), findsOneWidget);
        expect(find.text('Consultando…'), findsNothing);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('CEP valida vazio, bloqueia reenvio e apresenta resultado', (
    tester,
  ) async {
    var calls = 0;
    final pending = Completer<http.Response>();
    final service = InverterTextoService(
      client: MockClient((_) {
        calls++;
        return pending.future;
      }),
    );
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(
        home: ConsultaPage(feature: Feature.cep, service: service),
      ),
    );
    await tester.tap(find.text('Consultar'));
    await tester.pump();
    expect(find.text('Informe o CEP.'), findsOneWidget);
    expect(calls, 0);
    await tester.enterText(find.byType(TextFormField), '01001-000');
    await tester.tap(find.text('Consultar'));
    await tester.pump();
    expect(find.text('Consultando…'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(calls, 1);
    pending.complete(
      http.Response(
        '{"cep":"01001000","city":"São Paulo","state":"SP"}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('São Paulo'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '123');
    await tester.pump();
    expect(find.text('São Paulo'), findsNothing);
  });

  testWidgets('Erro de API aparece e permite tentar novamente', (tester) async {
    final service = InverterTextoService(
      client: MockClient((_) async => http.Response('', 429)),
    );
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(
        home: ConsultaPage(feature: Feature.email, service: service),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'teste@exemplo.com');
    await tester.tap(find.text('Consultar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Limite de consultas'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  for (final scenario in [
    (
      Feature.holidays,
      '2026',
      '[{"name":"Natal","date":"2026-12-25","type":"feriado","level":"nacional"}]',
      'Natal',
    ),
    (
      Feature.email,
      'a@exemplo.com',
      '{"email":"a@exemplo.com","valid_format":true,"valid_mx":false,"disposable":false}',
      'Domínio com registros de e-mail (MX)',
    ),
    (
      Feature.cnpj,
      '00000000000191',
      '{"cnpj":"00000000000191","razao_social":"Empresa teste","situacao":{"nome":"Ativa"},"endereco":null}',
      'Empresa teste',
    ),
    (
      Feature.number,
      '123',
      '{"text":"cento e vinte e tres"}',
      'cento e vinte e tres',
    ),
  ]) {
    testWidgets('Apresenta resultado de ${scenario.$1.title}', (tester) async {
      final service = InverterTextoService(
        client: MockClient((_) async => http.Response(scenario.$3, 200)),
      );
      addTearDown(service.close);
      await tester.pumpWidget(
        MaterialApp(
          home: ConsultaPage(feature: scenario.$1, service: service),
        ),
      );
      await tester.enterText(find.byType(TextFormField), scenario.$2);
      await tester.tap(find.text('Consultar'));
      await tester.pumpAndSettle();
      expect(find.text(scenario.$4), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Sair durante uma consulta não causa erro de estado', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    final service = InverterTextoService(
      client: MockClient((_) => pending.future),
    );
    addTearDown(service.close);
    await tester.pumpWidget(
      MaterialApp(
        home: ConsultaPage(feature: Feature.cep, service: service),
      ),
    );
    await tester.enterText(find.byType(TextFormField), '01001000');
    await tester.tap(find.text('Consultar'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete(http.Response('{"cep":"01001000"}', 200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
