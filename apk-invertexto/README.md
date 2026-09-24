# InverTexto

Aplicativo Flutter/Dart baseado no projeto desenvolvido em aula, com cinco ferramentas da API Invertexto:

- **Consultar CEP:** endereço a partir de oito dígitos, com ou sem hífen.
- **Número por extenso:** conversão em português; a opção **Valor em reais** inclui reais e centavos. Sem moeda, a API escreve a parte inteira.
- **Feriados:** consulta por ano (1900–2100), com seleção opcional de UF. Inclui feriados e pontos facultativos, identificados na lista.
- **Validar e-mail:** consulta formato, registros MX do domínio e endereço descartável. Não comprova a existência da caixa postal.
- **Consultar CNPJ:** dados cadastrais e endereço; aceita formato numérico e alfanumérico, com validação dos dígitos verificadores.

O token original foi preservado no serviço, conforme solicitado.

## Organização

- `lib/main.dart`: inicialização e tema.
- `lib/view/home_page.dart`: cinco opções na tela inicial.
- `lib/view/consulta_page.dart`: formulários, carregamento e apresentação dos resultados.
- `lib/service/invertertexto_service.dart`: requisições, timeout e tratamento das respostas.
- `lib/validation/input_validators.dart`: validação local dos campos obrigatórios e formatos.
- `test/`: testes de validação, requisições, falhas e interface.

As telas validam antes de consultar, bloqueiam envios durante o carregamento e limpam resultados antigos ao alterar a entrada. Falta de conexão, timeout, erros HTTP, limite de acesso e respostas incompletas possuem mensagens em português. Campos opcionais ausentes aparecem como “Não informado”. Uma lista vazia de feriados é apresentada como ausência de resultados.

## Executar e verificar

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Verificação opcional das cinco APIs reais (consome cinco requisições da cota):

```sh
dart run tool/check_api.dart
```

## Gerar o APK

```sh
flutter build apk --release
```

Saída: `build/app/outputs/flutter-apk/app-release.apk`.

A permissão de internet está no manifesto principal. A configuração de assinatura de desenvolvimento do projeto foi mantida para instalação direta e entrega acadêmica; uma publicação em loja exige uma chave própria de publicação.

## Exemplos para apresentação

| Função | Entrada |
| --- | --- |
| CEP | `01001-000` |
| Por extenso | `123,45` com “Valor em reais” ativado |
| Feriados | `2026`, estado `SP` |
| E-mail | `teste@example.com` |
| CNPJ | `00.000.000/0001-91` |

Teste também campos vazios, CEP curto, CNPJ com dígitos incorretos e consulta sem internet.

## Referências

- https://api.invertexto.com/api-consulta-cep
- https://api.invertexto.com/api-numero-por-extenso
- https://api.invertexto.com/api-feriados
- https://api.invertexto.com/api-validador-email
- https://api.invertexto.com/api-consulta-cnpj
- https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/publicacoes/documentos-tecnicos/cnpj/manual-dv-cnpj.pdf
