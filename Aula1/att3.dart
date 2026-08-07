void main() {
  int a = 5;
  int b = 5;
  
  int calcula(int a, int b) => a == b ? a + b : a * b;
  
  void executa(int a, int b) {
    int c = calcula(a, b);
    print('Valores: A = $a, B = $b');
    print(a == b ? 'Os valores são iguais, somando...' : 'Os valores são diferentes, multiplicando...');
    print('O resultado na variável C é: $c');
  }

  executa(a, b);
}
