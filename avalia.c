#include <stdio.h>

// Declaração da função assembly
extern void* alocaMem(size_t num_bytes);
extern void iniciaAlocador();
extern void finalizaAlocador();
extern int liberaMem(void* bloco);

int main (int argc, char** argv) {
  void *a,*b,*c,*d,*e;
  
  iniciaAlocador(); 
  // 0) estado inicial

  a=(void *) alocaMem(20);
  
  b=(void *) alocaMem(23);
  
  c=(void *) alocaMem(25);
  
  d=(void *) alocaMem(21);
  
  // 1) Espero ver quatro segmentos ocupados

  liberaMem(b);
   
  liberaMem(d);
   
  // 2) Espero ver quatro segmentos alternando
  //    ocupados e livres

  b=(void *) alocaMem(50);
  
  d=(void *) alocaMem(90);
  
  e=(void *) alocaMem(40);
  
  // 3) Deduzam
	
  liberaMem(c);
   
  liberaMem(a);
  
  liberaMem(b);
  
  liberaMem(d);
  
  liberaMem(e);
  
   // 4) volta ao estado inicial


  finalizaAlocador();
}
