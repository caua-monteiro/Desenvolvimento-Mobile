void main() {
  bool ehImpar(int n) => n % 2 != 0;
  
  print('Números ímpares entre 100 e 200:');
  for (int i = 100; i <= 200; i++) {
    ehImpar(i) ? print(i) : null;
  }
}
