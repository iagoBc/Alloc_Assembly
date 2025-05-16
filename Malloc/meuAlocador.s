.section .data
    topoInicialHeap: .quad 0     # variável global (ponteiro void*)
    inicio_heap:     .quad 0
    topo_heap:       .quad 0
    str: .string "%d\n"

.section .bss
    # Definição de offsets
    .equ BLOCO_OCUPADO, 0         # byte 0: ocupado (unsigned char)
    .equ BLOCO_TAMANHO, 4         # bytes 4-7: tamanho (int), após 3 de padding
    .equ BLOCO_PROX, 8            # bytes 8-15: ponteiro para próximo bloco
    .equ TAM_BLOCO, 16            # total de bytes do cabeçalho
    .equ PAGINA, 32             # tamanho de página (alocação em múltiplos)

.section .text
.globl main

tamanhoAlocado:
    pushq %rbp
    movq %rsp, %rbp

    addq $TAM_BLOCO, %rdi
    addq $PAGINA, %rdi
    subq $1, %rdi

    movq %rdi, %rax        # numerador (tamanho + 4096 - 1)
    xorq %rdx, %rdx        # zera RDX (parte alta do numerador)
    movq $PAGINA, %rcx     # divisor
    divq %rcx              # RAX = quociente, RDX = resto
    
    imul $PAGINA, %rax

    popq %rbp
    ret
    
# Função iniciaAlocador: salva topo da heap em topoInicialHeap
iniciaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax        # syscall brk
    movq $0, %rdi         # argumento 0 -> consulta topo da heap
    syscall               # executa syscall

    movq %rax, topoInicialHeap  # salva retorno em variável global

    popq %rbp
    ret

# Função main: chama iniciaAlocador, encerra programa
main:
    pushq %rbp
    movq %rsp, %rbp

    movq $20, %rdi
    call tamanhoAlocado         # executa iniciaAlocador()

    movq %rax, %rdi
    movq $60, %rax              # syscall exit
    syscall

