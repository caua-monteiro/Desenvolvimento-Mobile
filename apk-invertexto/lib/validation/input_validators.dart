class InputValidators {
  static String? cep(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Informe o CEP.';
    if (!RegExp(r'^\d{5}-?\d{3}$').hasMatch(text)) {
      return 'Informe um CEP com 8 dígitos (ex.: 01001-000).';
    }
    return null;
  }

  static String? number(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Informe um número.';
    if (!RegExp(r'^-?\d+(?:[.,]\d+)?$').hasMatch(text)) {
      return 'Use um número, sem separador de milhar (ex.: 123,45).';
    }
    if (text.replaceAll(RegExp(r'[^0-9]'), '').length > 15) {
      return 'Informe um número com até 15 dígitos.';
    }
    return null;
  }

  static String? year(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Informe o ano.';
    final year = int.tryParse(text);
    if (!RegExp(r'^\d{4}$').hasMatch(text) ||
        year == null ||
        year < 1900 ||
        year > 2100) {
      return 'Informe um ano entre 1900 e 2100.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Informe o e-mail.';
    final parts = text.split('@');
    if (text.length > 254 ||
        parts.length != 2 ||
        parts.first.length > 64 ||
        !RegExp(
          r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
        ).hasMatch(text) ||
        parts.first.startsWith('.') ||
        parts.first.endsWith('.') ||
        text.contains('..') ||
        parts.last
            .split('.')
            .any(
              (label) =>
                  label.startsWith('-') ||
                  label.endsWith('-') ||
                  label.length > 63,
            )) {
      return 'Informe um e-mail válido (ex.: nome@dominio.com).';
    }
    return null;
  }

  static String normalizeCnpj(String value) =>
      value.trim().toUpperCase().replaceAll(RegExp(r'[./-]'), '');

  static String? cnpj(String? value) {
    final text = (value ?? '').trim().toUpperCase();
    if (text.isEmpty) return 'Informe o CNPJ.';
    if (!RegExp(
      r'^(?:[A-Z0-9]{12}\d{2}|[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2})$',
    ).hasMatch(text)) {
      return 'Informe os 14 caracteres do CNPJ, com ou sem pontuação.';
    }
    final normalized = normalizeCnpj(text);
    if (normalized.split('').toSet().length == 1) {
      return 'CNPJ inválido. Confira os caracteres.';
    }
    final digits = normalized.codeUnits.map((c) => c - 48).toList();
    for (var length = 12; length <= 13; length++) {
      var sum = 0;
      var weight = 2;
      for (var i = length - 1; i >= 0; i--) {
        sum += digits[i] * weight;
        weight = weight == 9 ? 2 : weight + 1;
      }
      final remainder = sum % 11;
      if (digits[length] != (remainder < 2 ? 0 : 11 - remainder)) {
        return 'CNPJ inválido. Confira os dígitos verificadores.';
      }
    }
    return null;
  }
}
