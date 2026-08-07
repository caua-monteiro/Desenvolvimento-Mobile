void main() {
  int a = 10;
  int b = 20;
  int c = 15;
  
  void verificaSoma(int a, int b, int c) => 
      print(a + b < c 
          ? 'A soma de A + B ($a + $b = ${a + b}) é MENOR que C ($c).' 
          : 'A soma de A + B ($a + $b = ${a + b}) NÃO é menor que C ($c).');

  verificaSoma(a, b, c);
}