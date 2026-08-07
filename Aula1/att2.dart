void main() {
  int numero = 42;
  
  void verificaParOuImpar(int n) => 
      print(n % 2 == 0 ? 'O número $n é PAR.' : 'O número $n é ÍMPAR.');

  verificaParOuImpar(numero);
}
