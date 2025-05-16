#include "meuAlocador.h"  // Inclui o cabeçalho que define a struct Bloco e as funções do alocador.


// Variáveis globais usadas para gerenciar a heap manual:
void* topoInicialHeap = NULL; // Armazena o topo original da heap no início da execução.
Bloco* inicio_heap = NULL;    // Ponteiro para o primeiro bloco da lista ligada de blocos.
Bloco* topo_heap = NULL;      // Ponteiro para o último bloco da lista (usado para anexar novos blocos).


// Função que arredonda o tamanho solicitado para múltiplos de 4096 bytes (tamanho de página)
int tamanhoAlocado(int tamanho){
    size_t total = tamanho + TAM_BLOCO;            // Soma o tamanho dos dados com o tamanho do cabeçalho.
    size_t paginas = (total + PAGINA - 1) / PAGINA; // Calcula o número de páginas necessárias.
    return paginas * PAGINA;                        // Retorna o total de bytes em múltiplos de 4096.
}

// Inicializa o alocador de memória
void iniciaAlocador(){
    topoInicialHeap = sbrk(0);                     // Salva o topo atual da heap.
    printf ("Topo Inicial Heap: %p\n", topoInicialHeap); // Imprime o topo da heap.
    inicio_heap = NULL;                            // Inicializa a lista de blocos como vazia.
    topo_heap = NULL;
}

// Finaliza o alocador, restaurando o topo original da heap
void finalizaAlocador(){
    brk(topoInicialHeap); // Restaura o topo da heap ao estado inicial.
}

// Aloca memória com política de best fit e chamadas a sbrk em múltiplos de 4096
void* alocaMem(int num_bytes){
    Bloco* atual = inicio_heap; // Começa a varredura do início da lista de blocos.
    Bloco* melhor = NULL;       // Ponteiro para o melhor bloco livre encontrado (best fit).

    // Percorre todos os blocos para encontrar o melhor bloco livre (menor possível >= necessário)
    while (atual) {
        if (!atual->ocupado && atual->tamanho >= num_bytes) {  // Bloco livre e suficientemente grande?
            if (!melhor || atual->tamanho < melhor->tamanho) { // É o menor bloco encontrado até agora?
                melhor = atual; // Atualiza o melhor candidato.
            }
        }
        atual = atual->prox; // Avança para o próximo bloco.
    }

    // Se encontrou um bloco adequado, marca como ocupado e retorna o espaço de dados
    if (melhor){
        melhor->ocupado = 1;              // Marca o bloco como ocupado.
        return (void*)(melhor + 1);       // Retorna o endereço logo após o cabeçalho.
    }

    // Nenhum bloco livre adequado: precisa alocar mais memória com sbrk
    size_t total = tamanhoAlocado(num_bytes); // Arredonda o total para múltiplos de 4096.
    Bloco* novo = (Bloco*)sbrk(total);        // Solicita espaço ao sistema via sbrk.

    if (novo == (void*)-1) return NULL;       // Falha na alocação.

    // Inicializa o novo bloco
    novo->ocupado = 1;                         // Marca como ocupado.
    novo->tamanho = total - TAM_BLOCO;         // Calcula o espaço disponível para dados.
    novo->prox = NULL;                         // Ainda não há próximo bloco.

    if (!inicio_heap) inicio_heap = novo;      // Se é o primeiro bloco, inicializa o início da lista.
    else topo_heap->prox = novo;               // Caso contrário, conecta ao final da lista existente.

    topo_heap = novo;                          // Atualiza o topo da lista para o novo bloco.
    return (void*)(novo + 1);                  // Retorna o ponteiro para o espaço de dados.
}

// Libera um bloco de memória anteriormente alocado
int liberaMem(void* bloco) {
    if (!bloco) return -1;                                // Verifica se o ponteiro é válido.
    Bloco* cab = (Bloco*)((char*)bloco - TAM_BLOCO);      // Recupera o ponteiro do cabeçalho do bloco.
    cab->ocupado = 0;                                     // Marca o bloco como livre.
    return 0;
}

void imprimeMapa() {
    Bloco* atual = inicio_heap;

    while (atual){
        // Parte gerencial: TAM_BLOCO bytes representados por '#'
        
        for (int i = 0; i < TAM_BLOCO; i++) printf("#");
        
        

        // Parte de dados do bloco: '+' se ocupado, '-' se livre
        char simbolo = atual->ocupado ? '+' : '-';
        for (int i = 0; i < atual->tamanho; i++) {
            printf("%c", simbolo);
        }

        atual = atual->prox;
    }

    printf("\n");
}
