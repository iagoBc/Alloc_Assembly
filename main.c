#include <stdio.h>
#include "meuAlocador.h"

extern void *topoInicialHeap;
extern void *topo_heap;

int main(){
    void *a, *b, *c, *d;
    iniciaAlocador();

    a = alocaMem(10);
    
    b = alocaMem(10);

    c = alocaMem(10);

    d = alocaMem(10);

    imprimeMapa();

    liberaMem(a);
    liberaMem(b);
    liberaMem(c);
    liberaMem(d);

    imprimeMapa();

    finalizaAlocador();
}