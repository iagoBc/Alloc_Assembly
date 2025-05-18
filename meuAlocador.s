.section .data
    .globl topoInicialHeap
    topoInicialHeap: .quad 0     # variável global (ponteiro void*)
    .globl inicio_heap
    inicio_heap:     .quad 0
    .globl topo_heap
    topo_heap:       .quad 0

    str: .string "teste%d\n" 

.section .bss
    # Definição de offsets
    .equ TAM_BLOCO, 16            # total de bytes do cabeçalho
    .equ PAGINA, 4096             # tamanho de página (alocação em múltiplos)

.section .text

.globl iniciaAlocador
.globl finalizaAlocador
.globl alocaMem
.globl liberaMem
.globl imprimeMapa

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

    movq inicio_heap, %rax    # atual = inicio_heap
    movq $0, %rcx             # melhor = NULL

loop:
    cmpq $0, %rax             # while (atual)
    je fora_loop    

    cmpb $0, (%rax)           # if (!atual->ocupado)
    jne avanca_prox

    movq 4(%rax), %rdx        # rdx = atual->tamanho
    cmpq %rdx, %rdi
    jg avanca_prox

    cmpq $0, %rcx             # se melhor ainda é NULL
    je salva_melhor

    movq 4(%rcx), %r8         # r8 = melhor->tamanho
    cmpq %rdx, %r8            # se melhor->tamanho > atual->tamanho
    jg salva_melhor           # atual é melhor

    jmp avanca_prox
  
salva_melhor:
    movq %rax, %rcx           # melhor = atual

avanca_prox:
    movq 8(%rax), %rax        # atual = atual->prox
    jmp loop

fora_loop:
    cmpq $0, %rcx             # if (melhor)
    je novo_bloco

    movb $1, (%rcx)           # melhor->ocupado = 1

    addq $TAM_BLOCO, %rcx
    movq %rcx, %rax # return (void*)(melhor + 1)

    popq %rbp
    ret

novo_bloco:
    call tamanhoAlocado     #retorno em %rax
    movq %rax, %rdi         #rdi = tamanho a ser alocado
    movq %rdi, %r10         #r9 = tamanho a ser alocado

    cmpq $0, topo_heap
    je primeirobloco

    movq topo_heap, %r8
    addq $TAM_BLOCO, %r10
    addq %r10, %r8 #tem o valor do topo da heap
    movq $12, %rax
    movq %r8, %rdi
    syscall

    jmp continuar
    
primeirobloco:
    movq topoInicialHeap, %r8
    addq $TAM_BLOCO, %r10
    addq %r10, %r8 #tem o valor do topo da heap
    movq $12, %rax
    movq %r8, %rdi
    syscall

continuar:
    cmpq $-1, %rax         # compara retorno de sbrk com -1
    je erro_sbrk           # se for igual, salta para retorno de NULL

    subq %r10, %rax

    movb $1, (%rax)               # marca como ocupado (1 byte)
    subq $TAM_BLOCO, %r10         # tamanho do campo de dados
    movq %r10, 4(%rax)            # escreve o tamanho do bloco 
    
    movq inicio_heap, %r8
    cmpq $0, %r8
    je inicioheap

    movq topo_heap, %r8
    addq %r10, %r8 #tem o valor do topo da heap
    addq $TAM_BLOCO, %r8
    movq %r8, topo_heap

    cmpq $inicio_heap, %rax #se atual é o primeirobloco
    je fim

novo_prox:
    movq inicio_heap, %r13
    movq 8(%r13), %r14
    cmpq $0, %r14
    je prox

achar_prox_null:
    movq %r14, %r13
    movq 8(%r13), %r14
    cmpq $0, %r14
    jne achar_prox_null

prox:
    movq %rax, 8(%r13)
    jmp fim

inicioheap:
    movq %rax, inicio_heap

    movq %rax, %r11
    addq $TAM_BLOCO, %r10
    addq %r10, %r11
    addq %r11, topo_heap

    movq $0, 8(%rax)

fim:
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

