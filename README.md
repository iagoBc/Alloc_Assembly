
# Alocador de Memória em Assembly x86_64

Este projeto implementa um alocador de memória dinâmico simples em Assembly (`x86_64 Linux`), gerenciado por blocos com cabeçalhos, utilizando chamadas de sistema (`syscall brk`) para manipular o topo da heap. Ele é funcionalmente semelhante a uma versão customizada de `malloc` e `free`.

## Funcionalidades

- Inicialização e finalização do alocador
- Alocação de memória com política de **Best Fit**
- Liberação de memória
- Impressão do mapa da heap
- Alocação feita em múltiplos de páginas (4096 bytes)

## Estrutura do Bloco

Cada bloco de memória contém um **cabeçalho** de 16 bytes (valor de `TAM_BLOCO`) com as seguintes informações:

- **Byte 0**: Ocupado (1) ou livre (0)
- **Bytes 8-15**: Tamanho do bloco de dados (em bytes)

A área de dados vem logo após esse cabeçalho.

## Instruções de Uso

### 1. `iniciaAlocador`

Inicializa o alocador salvando o topo atual da heap em variáveis globais.

```asm
.globl iniciaAlocador
```

### 2. `finalizaAlocador`

Restaura o topo da heap ao valor salvo inicialmente, efetivamente liberando toda a memória alocada pelo alocador.

```asm
.globl finalizaAlocador
```

### 3. `alocaMem`

Aloca memória usando a política de **Best Fit**:

- Percorre todos os blocos livres existentes procurando o menor bloco que possa satisfazer a requisição.
- Se nenhum bloco adequado for encontrado, um novo bloco é alocado no final da heap com o tamanho arredondado para múltiplos de página.
- Retorna o ponteiro para a área de dados do bloco.

```asm
.globl alocaMem
```

### 4. `liberaMem`

Libera um bloco de memória previamente alocado:

- Marca o bloco como livre alterando o byte de controle.
- Retorna `0` se sucesso, ou `-1` se o ponteiro fornecido for nulo.

```asm
.globl liberaMem
```

### 5. `imprimeMapa`

Imprime um mapa visual da heap:

- Cada bloco é representado por uma linha:
  - `################` representa o cabeçalho
  - `*` representa bytes ocupados
  - `-` representa bytes livres

```asm
.globl imprimeMapa
```

Exemplo de saída:
```
################***************
################--------------
```

## Constantes

```asm
.equ PAGINA, 4096      # Tamanho da página
.equ TAM_BLOCO, 16     # Tamanho do cabeçalho do bloco
```

## Dependências

- Linux x86_64
- `gcc`, `make`, `as`, `ld`
- `printf` da biblioteca C para saída

## Autor

Iago Cardoso Bariuka — Ciência da Computação @ UFPR
