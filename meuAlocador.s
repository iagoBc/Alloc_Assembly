.section .data
    topoInicialHeap: .quad 0     # variável global (ponteiro void*)
    inicio_heap:     .quad 0
    topo_heap:       .quad 0
    str: .string "TESTE\n"
    str1: .string "A: %p\n"
    str2: .string "topoInicialHeap: %p\n"
    str3: .string "topo_heap: %p\n"
    str4: .string "inicio_heap: %p\n"

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

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax        # syscall brk
    movq topoInicialHeap, %rdi
    syscall               # executa syscall

    popq %rbp
    ret

alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq inicio_heap, %rax    # Bloco* atual = inicio_heap
    movq $0, %rcx             # Bloco* melhor = NULL

loop:
    cmpq $0, %rax             # while (atual)
    je fora_loop

    cmpb $0, (%rax)           # if (!atual->ocupado) - campo 'ocupado' é byte
    jne avanca_prox

    movq 4(%rax), %rdx        # atual->tamanho
    cmpq %rdi, %rdx           # atual->tamanho >= num_bytes ?
    jl avanca_prox

    cmpq $0, %rcx             # se melhor ainda é NULL
    je salva_melhor

    movq 4(%rcx), %r8         # melhor->tamanho
    cmpq %r8, %rdx            # atual->tamanho < melhor->tamanho ?
    jge avanca_prox

salva_melhor:
    movq %rax, %rcx           # melhor = atual

avanca_prox:
    movq 8(%rax), %rax        # atual = atual->prox
    jmp loop

fora_loop:
    cmpq $0, %rcx             # if (melhor)
    je bloco_inicial

    movb $1, (%rcx)           # melhor->ocupado = 1

    lea TAM_BLOCO(%rcx), %rax # return (void*)(melhor + 1)

    popq %rbp
    ret

bloco_inicial:
    call tamanhoAlocado #retorno em %rax
    movq %rax, %rdi #rdi = tamanho a ser alocado
    movq %rdi, %rcx #rcx = tamanho a ser alocado

    movq topoInicialHeap, %r8
    addq %rdi, %r8 #tem o valor do topo da heap
    movq $12, %rax
    movq %r8, %rdi
    syscall

    cmpq $-1, %rax         # compara retorno de sbrk com -1
    je erro_sbrk           # se for igual, salta para retorno de NULL

     movq topoInicialHeap, %rax    # %rax = início do novo bloco (antigo topo)
    movb $1, (%rax)               # marca como ocupado (1 byte)
    subq $TAM_BLOCO, %rcx         # tamanho do campo de dados
    movq %rcx, 4(%rax)            # escreve o tamanho do bloco
    movq $0, 8(%rax)              # prox = NULL
    
    # if (!inicio_heap) inicio_heap = novo;
    movq inicio_heap, %r8
    cmpq $0, %r8
    jne conecta_fim

    movq %rax, inicio_heap
    jmp continua

    conecta_fim:
    movq topo_heap, %r9
    movq %rax, 8(%r9)     # topo_heap->prox = novo

    continua:
    movq %rax, topo_heap

    # return (void*)(novo + 1)
    addq $TAM_BLOCO, %rax

    popq %rbp
    ret

erro_sbrk:
    movq $0, %rax          # retorna NULL
    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

    cmpq $0, %rdi          # if (!bloco)
    je return_1        # return -1 se bloco == NULL

    subq $16, %rdi         # cab = bloco - TAM_BLOCO
    movb $0, (%rdi)        # cab->ocupado = 0 (offset 0)

    movq $0, %rax          # return 0
    jmp fim_mem

return_1:
    movq $-1, %rax         # return -1

fim_mem:
    popq %rbp
    ret

main:
    pushq %rbp
    movq %rsp, %rbp

    call iniciaAlocador
    
    movq topoInicialHeap, %rsi
    movq $str2, %rdi
    call printf

    movq $1000, %rdi
    call alocaMem

    movq %rax, %rbx
    movq %rax, %rdi
    movq $str, %rsi
    call strcpy


    movq %rbx, %rdi
    call printf 

    movq topo_heap, %rsi
    movq $str3, %rdi
    call printf

    movq inicio_heap, %rsi
    movq $str4, %rdi
    call printf
    
    call finalizaAlocador


    movq %rax, %rdi
    movq $60, %rax              # syscall exit
    syscall
