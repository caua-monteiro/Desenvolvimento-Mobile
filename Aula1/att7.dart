void main() {
  int n = 7; // Valor de N recebido
  
  void imprimeLinhaTabuada(int i, int n) => print('$i x $n = ${i * n}');
  
  void tabuada(int num) {
    num >= 1 && num <= 10 ? () {
      print('Tabuada do $num:');
      for (int i = 0; i <= 10; i++) {
        imprimeLinhaTabuada(i, num);
      }
    }() : print('Valor $num inválido. N deve ser de 1 a 10.');
  }

  tabuada(n);
}
