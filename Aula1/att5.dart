void main() {
  bool ehImparMultiploDeTres(int n) => (n % 2 != 0 && n % 3 == 0);
  
  int soma = 0;
  for (int i = 1; i <= 500; i++) {
    soma += ehImparMultiploDeTres(i) ? i : 0;
  }
  
  print('A soma de todos os números ímpares e múltiplos de três de 1 a 500 é: $soma');
}
