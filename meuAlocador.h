 // Protótipos (seção 6.1.2 e Projeto de Implementação 6.2)
void iniciaAlocador();   // Executa syscall brk para obter o endereço do topo
                         // corrente da heap e o armazena em uma
                         // variável global, topoInicialHeap.
void finalizaAlocador(); // Executa syscall brk para restaurar o valor
                         // original da heap contido em topoInicialHeap.
int liberaMem(void* bloco); // indica que o bloco está livre.
void* alocaMem(int num_bytes); // 1. Procura um bloco livre com tamanho maior ou
                               //    igual à num_bytes.
                               // 2. Se encontrar, indica que o bloco está
                               //    ocupado e retorna o endereço inicial do bloco;
                               // 3. Se não encontrar, abre espaço
                               //    para um novo bloco, indica que o bloco está
                               //    ocupado e retorna o endereço inicial do bloco.
void imprimeMapa();       // imprime um mapa da memória da região da heap.
                          // Cada byte da parte gerencial do nó deve ser impresso
                          // com o caractere "#". O caractere usado para
                          // a impressão dos bytes do bloco de cada nó depende
                          // se o bloco estiver livre ou ocupado. Se estiver livre, imprime o
                          // caractere -". Se estiver ocupado, imprime o caractere "+".
