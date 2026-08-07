void main() {
  int a = 10;
  int b = 55;
  int c = 30;

  void imprimeDecrescente(int a, int b, int c) => print(
    a > b && a > c 
      ? (b > c ? '$a, $b, $c' : '$a, $c, $b') 
      : b > a && b > c 
        ? (a > c ? '$b, $a, $c' : '$b, $c, $a') 
        : (a > b ? '$c, $a, $b' : '$c, $b, $a')
  );

  print('Valores recebidos: $a, $b, $c');
  print('Ordem decrescente:');
  imprimeDecrescente(a, b, c);
}
