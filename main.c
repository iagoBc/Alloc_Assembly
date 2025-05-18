#include <stdio.h>
#include "meuAlocador.h"

extern void *topoInicialHeap;
extern void *inicio_heap;
extern void *topo_heap;

int main(){
    void *a, *b, *c, *d;
    iniciaAlocador();

    a = alocaMem(1000);

    printf("topoInicialHeap = %p\n\n", topoInicialHeap);
    printf("a = %p\n", a);

    b = alocaMem(5000);
    printf("b = %p\n", b);

    liberaMem(a);

    c = alocaMem(5000);
    printf("c = %p\n", c);

    printf("\ntopo_heap = %p\n", topo_heap);

    finalizaAlocador();
}