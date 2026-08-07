void main() {
  int a = 5;
  
  int calcFatorial(int n) => n <= 1 ? 1 : n * calcFatorial(n - 1);
  String geraSequencia(int n) => n <= 1 ? '$n' : '$n X ${geraSequencia(n - 1)}';
  
  void exibeFatorial(int n) => 
    print(n < 0 
      ? 'Não existe fatorial de número negativo.' 
      : '$n! = ${geraSequencia(n)} = ${calcFatorial(n)}');
      
  exibeFatorial(a);
}
