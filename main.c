#include <stdio.h>
#include "meuAlocador.h"

int main(){
    void *a, *b, *c, *d;
    iniciaAlocador();

    a = alocaMem(10);
    liberaMem(a);

    b = alocaMem(40);

    c = alocaMem(40);

    d = alocaMem(40);

    imprimeMapa();

    
    
    liberaMem(b);
    liberaMem(c);
    liberaMem(d);

    imprimeMapa();

    finalizaAlocador();
}