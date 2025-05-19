.equ PAGINA, 4096                           # Constante para tamanho da página
.equ TAM_BLOCO, 16                          # Constante para tamanho do cabeçalho

.section .data
    .globl topoInicialHeap
    topoInicialHeap: .quad 0     
    .globl topo_heap
    topo_heap:       .quad 0

    strCabecalho: .string "################"
    strOcupado: .string "*"
    strDesocupado: .string "-"
    strFim: .string "\n"

.section .text

    .globl iniciaAlocador
    .globl finalizaAlocador
    .globl alocaMem
    .globl liberaMem
    .globl imprimeMapa

tamanhoAlocado:
    pushq %rbp
    movq %rsp, %rbp

    addq $TAM_BLOCO, %rdi                   # Adiciona o tamanho das informaçoes gerenciais
    addq $PAGINA, %rdi                      # Adiciona o tamanho da PAGINA
    subq $1, %rdi   

    movq %rdi, %rax                         # Numerador (tamanho + PAGINA - 1)
    movq $0, %rdx                           # Zera rdx (parte alta do numerador)
    movq $PAGINA, %rcx                      # Divisor
    divq %rcx                               # rax = quociente, rdx = resto
    
    imul $PAGINA, %rax                      # Multiplica o tamanho da PAGINA com o quociente e retorna rax
    addq $TAM_BLOCO, %rax                   # Adiciona o tamanho do cabeçalho

    popq %rbp
    ret
    
iniciaAlocador: 
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax                          # Syscall brk
    movq $0, %rdi                           # Parâmetro 0 -> consulta topo da heap
    syscall                                 

    movq %rax, topoInicialHeap              # Salva retorno na variável global
    movq %rax, topo_heap                    # Salva retorno na variável global
    
    popq %rbp
    ret

finalizaAlocador:
    pushq %rbp
    movq %rsp, %rbp

    movq $12, %rax                          # Syscall brk
    movq topoInicialHeap, %rdi              # Volta a heap para o tamanho inicial
    syscall                                 

    movq %rax, topo_heap                    # Volta o topo da heap para o tamanho inicial
    
    popq %rbp
    ret

liberaMem:
    pushq %rbp
    movq %rsp, %rbp

    cmpq $0, %rdi                           # Vê se o bloco é NULL
    je .erro_lib                            # Se for NULL retorna -1

    subq $TAM_BLOCO, %rdi                   # Faz rdi apontar para area da var ocupado 
    movb $0, (%rdi)                         # Marca o bloco como desocupado

    movq $0, %rax                           # Retorna 0 pois a liberação foi bem sucedida
    popq %rbp
    ret

    .erro_lib:
        movq $-1, %rax                      # Retorna -1 pois o bloco não existe
        popq %rbp
        ret
    
alocaMem:
    pushq %rbp
    movq %rsp, %rbp

    movq topoInicialHeap, %r8 
    movq topo_heap, %r9       
    cmpq %r9, %r8                           # Se for igual não tem nenhum bloco alocado ainda
    je .primeirobloco

    movq $0, %r9                            # Melhor = NULL

    .procura_melhor:
        cmpq topo_heap, %r8                 # Se chegou no topo da heap saí
        je .achou_melhor    

        cmpq $0, (%r8)                      # Se está ocupado vai para o próximo
        jne .prox

        cmpq 8(%r8), %rdi                   # rdi = bytes a ser alocado
        jg .prox                            # Se rdi > atual->tamanho vai para o próximo 

        cmpq $0, %r9                        # Se melhor ainda é NULL
        je .salva_melhor

        movq 8(%r9), %r10                   # Melhor->tamanho
        cmpq %r10, 8(%r8)                   # Se atual->tamanho >= melhor->tamanho
        jge .prox                           # Melhor ainda tem o melhor tamanho
    
        .salva_melhor:
            movq %r8, %r9                   # Melhor = atual

        .prox:
            movq 8(%r8), %r10               # r10 = atual->tamanho
            addq %r10, %r8                  # Pula os dados
            addq $TAM_BLOCO, %r8            # Pula o cabeçalho do bloco
            jmp .procura_melhor

    .achou_melhor:
        cmpq $0, %r9             
        je .novo_bloco                      # Não achou melhor pula

        movq $1, (%r9)                      # Marca melhor como ocupado
        addq $TAM_BLOCO, %r9                # Pula cabeçalho
        movq %r9, %rax                      # Retorna ponteiro para os dados

        popq %rbp
        ret

    .novo_bloco:
        call tamanhoAlocado                 # Calcula o tamanho a ser alocado para o bloco 
        movq %rax, %r8                      # r8 = tamanho a ser alocado

        movq topo_heap, %r9                 # r9 = topo atual
        addq %r8, %r9                       # Novo topo = tamanho desejado + topo_heap
        movq $12, %rax                      # syscall brk
        movq %r9, %rdi                      # Argumento = novo topo
        syscall

        jmp .incrementa_var
        
    .primeirobloco:
        call tamanhoAlocado                 # Calcula o tamanho a ser alocado para o bloco
        movq %rax, %r8                      # r8 = tamanho a ser alocado

        movq topoInicialHeap, %r9
        addq %r8, %r9                       # Novo topo = tamanho desejado + topoInicialHeap
        movq $12, %rax                      # syscall brk
        movq %r9, %rdi                      # Argumento = novo topo
        syscall

    .incrementa_var:
        cmpq $-1, %rax                      # Compara retorno de brk
        je .erro_brk                        # Se for igual a -1, salta para retorno de NULL

        movq %rax, topo_heap                # Atualiza valor do topo da heap
        subq %r8, %rax                      # Aponta rax para onde esta var ocupado

        movq $1, (%rax)                     # Marca o bloco como ocupado
        subq $TAM_BLOCO, %r8                # r8 = tamanho do campo de dados
        movq %r8, 8(%rax)                   # Escreve o tamanho do bloco na var tamanho

        addq $TAM_BLOCO, %rax               # Aponta rax para area de dados e retorna
        popq %rbp
        ret

    .erro_brk:
        movq $0, %rax                       # Retorna NULL
        popq %rbp
        ret
    
imprimeMapa:
    pushq %rbp
    movq %rsp, %rbp

    movq topoInicialHeap, %rbx              # Ponteiro do topoInicialHeap
    movq topo_heap, %r9                     # Ponteiro do topo_heap
    cmpq %rbx, %r9                          # Se forem iguais nâo possui bloco alocado
    je .fim

    .inicio:
        movq topo_heap, %r9                 # Ponteiro do topo_heap
        cmpq %r9, %rbx                      # Se for igual nâo possui mais nenhum bloco
        je .fim

        mov $strCabecalho, %rdi             # Imprime '#' para o cabeçalho do bloco
        call printf

        movq $0, %r10                       # i = 0
        cmpq $0, (%rbx)                     # Verifica se o bloco esta ocupado
        je .desocupado

    .ocupado:
        cmpq 8(%rbx), %r10                  # i < tamanho do bloco
        jge .prox_bloco                     # Se i for maior ou igual ao tamanho do bloco, salta para o prox bloco

        movq $strOcupado, %rdi              # Imprime '*' até chegar no tamanho do bloco
        call printf

        addq $1, %r10                       # i++
        jmp .ocupado

    .desocupado:
        cmpq 8(%rbx), %r10                  # i < tamanho do bloco
        jge .prox_bloco                     # Se i for maior ou igual ao tamanho do bloco, salta para o prox bloco

        movq $strDesocupado, %rdi           # Imprime '-' até chegar no tamanho do bloco
        call printf

        addq $1, %r10                       # i++
        jmp .desocupado

    .prox_bloco:
        addq 8(%rbx), %rbx                  # Pula os dados
        addq $TAM_BLOCO, %rbx               # Pula o cabeçalho do bloco
        jmp .inicio

    .fim:
        movq $strFim, %rdi
        call printf

        popq %rbp
        ret
