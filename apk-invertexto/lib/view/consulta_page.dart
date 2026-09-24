import 'package:flutter/material.dart';
import '../service/invertertexto_service.dart';
import '../validation/input_validators.dart';

enum Feature {
  cep(
    'Consultar CEP',
    'Encontre um endereço pelo CEP.',
    Icons.location_on_outlined,
    'CEP',
    '01001-000',
  ),
  number(
    'Número por extenso',
    'Escreva números e valores em português.',
    Icons.edit_note,
    'Número',
    '123 ou 123,45',
  ),
  holidays(
    'Feriados',
    'Consulte feriados nacionais e estaduais.',
    Icons.calendar_month_outlined,
    'Ano',
    '2026',
  ),
  email(
    'Validar e-mail',
    'Verifique formato, domínio e e-mail temporário.',
    Icons.alternate_email,
    'E-mail',
    'nome@dominio.com',
  ),
  cnpj(
    'Consultar CNPJ',
    'Consulte os dados de uma empresa.',
    Icons.business_outlined,
    'CNPJ',
    '00.000.000/0001-91',
  );

  const Feature(this.title, this.description, this.icon, this.label, this.hint);
  final String title, description, label, hint;
  final IconData icon;
}

class ConsultaPage extends StatefulWidget {
  const ConsultaPage({super.key, required this.feature, this.service});
  final Feature feature;
  final InverterTextoService? service;
  @override
  State<ConsultaPage> createState() => _ConsultaPageState();
}

class _ConsultaPageState extends State<ConsultaPage> {
  final _form = GlobalKey<FormState>();
  final _input = TextEditingController();
  late final _service = widget.service ?? InverterTextoService();
  bool _loading = false;
  bool _currency = false;
  String _state = '';
  String? _error;
  Object? _result;
  static const _states = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.feature == Feature.holidays) {
      _input.text = DateTime.now().year.toString();
    }
  }

  @override
  void dispose() {
    _input.dispose();
    if (widget.service == null) _service.close();
    super.dispose();
  }

  String? _validate(String? value) => switch (widget.feature) {
    Feature.cep => InputValidators.cep(value),
    Feature.number => InputValidators.number(value),
    Feature.holidays => InputValidators.year(value),
    Feature.email => InputValidators.email(value),
    Feature.cnpj => InputValidators.cnpj(value),
  };

  void _clearResult() => setState(() {
    _result = null;
    _error = null;
  });

  Future<void> _submit() async {
    if (_loading) return;
    _clearResult();
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final value = _input.text.trim();
      final Object result = await switch (widget.feature) {
        Feature.cep => _service.buscaCEP(value),
        Feature.number => _service.converterPorExtenso(
          value,
          currency: _currency,
        ),
        Feature.holidays => _service.holidays(
          value,
          state: _state.isEmpty ? null : _state,
        ),
        Feature.email => _service.emailValidator(value),
        Feature.cnpj => _service.cnpj(value),
      };
      if (mounted) setState(() => _result = result);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Não foi possível concluir a consulta. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.feature.title)),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(
              widget.feature.icon,
              size: 44,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(widget.feature.description, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _input,
                    enabled: !_loading,
                    autocorrect: false,
                    textInputAction: TextInputAction.search,
                    keyboardType: switch (widget.feature) {
                      Feature.cep || Feature.holidays => TextInputType.number,
                      Feature.number => const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      Feature.email => TextInputType.emailAddress,
                      Feature.cnpj => TextInputType.text,
                    },
                    decoration: InputDecoration(
                      labelText: widget.feature.label,
                      hintText: widget.feature.hint,
                      errorMaxLines: 3,
                    ),
                    validator: _validate,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) => _clearResult(),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (widget.feature == Feature.holidays) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _state,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Estado (opcional)',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Somente nacionais'),
                        ),
                        for (final state in _states)
                          DropdownMenuItem(value: state, child: Text(state)),
                      ],
                      onChanged: _loading
                          ? null
                          : (value) {
                              _clearResult();
                              setState(() => _state = value!);
                            },
                    ),
                  ],
                  if (widget.feature == Feature.number) ...[
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Valor em reais (R\$)'),
                      subtitle: const Text(
                        'Ative para escrever reais e centavos. Sem moeda, a API escreve a parte inteira.',
                      ),
                      value: _currency,
                      onChanged: _loading
                          ? null
                          : (value) {
                              _clearResult();
                              setState(() => _currency = value);
                            },
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(_loading ? 'Consultando…' : 'Consultar'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
            if (_result != null) _buildResult(),
          ],
        ),
      ),
    ),
  );

  String _text(dynamic value) =>
      value == null || value.toString().trim().isEmpty
      ? 'Não informado'
      : value.toString();
  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return _text(value);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Map<String, dynamic> _nested(dynamic value) =>
      value is Map<String, dynamic> ? value : {};
  Widget _details(Map<String, String> values) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Resultado', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final entry in values.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(entry.value),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  Widget _buildResult() {
    if (widget.feature == Feature.holidays) {
      final holidays = _result! as List<Map<String, dynamic>>;
      if (holidays.isEmpty) {
        return const Text('Nenhum feriado encontrado para esta consulta.');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${holidays.length} datas encontradas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final holiday in holidays)
            Card(
              child: ListTile(
                title: Text(_text(holiday['name'])),
                subtitle: Text(
                  '${_date(holiday['date'])} • ${_text(holiday['type'])} • ${_text(holiday['level'])}',
                ),
              ),
            ),
        ],
      );
    }
    final data = _result! as Map<String, dynamic>;
    switch (widget.feature) {
      case Feature.cep:
        return _details({
          'CEP': _text(data['cep']),
          'Logradouro': _text(data['street']),
          'Bairro': _text(data['neighborhood']),
          'Cidade': _text(data['city']),
          'Estado': _text(data['state']),
          'Complemento': _text(data['complement']),
        });
      case Feature.number:
        return _details({'Por extenso': _text(data['text'])});
      case Feature.email:
        return _details({
          'E-mail': _text(data['email']),
          'Formato válido': data['valid_format'] == true ? 'Sim' : 'Não',
          'Domínio com registros de e-mail (MX)': data['valid_mx'] == true
              ? 'Sim'
              : 'Não',
          'Endereço temporário/descartável': data['disposable'] == true
              ? 'Sim'
              : 'Não',
          'Observação':
              'Esta consulta não confirma a existência da caixa postal nem garante a entrega de mensagens.',
        });
      case Feature.cnpj:
        final address = _nested(data['endereco']);
        return _details({
          'CNPJ': _text(data['cnpj']),
          'Razão social': _text(data['razao_social']),
          'Nome fantasia': _text(data['nome_fantasia']),
          'Situação cadastral': _text(_nested(data['situacao'])['nome']),
          'Início das atividades': _date(data['data_inicio']),
          'Atividade principal': _text(
            _nested(data['atividade_principal'])['descricao'],
          ),
          'Logradouro': _text(address['logradouro']),
          'Número': _text(address['numero']),
          'Complemento': _text(address['complemento']),
          'Bairro': _text(address['bairro']),
          'Cidade': _text(address['municipio']),
          'UF': _text(address['uf']),
          'CEP': _text(address['cep']),
          'Telefone': _text(data['telefone1']),
          'E-mail': _text(data['email']),
        });
      case Feature.holidays:
        throw StateError('Resultado tratado acima.');
    }
  }
}
