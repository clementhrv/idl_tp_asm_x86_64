#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .section .rodata
.Lone:
    .double 1.0
.Ltwo:
    .double 2.0
.Lfive:
    .double 5.0

    .text
    .globl C(fib)

C(fib):
    # Cas de base : F(0) = 0, F(1) = 1
    cmpq    $1, %rdi
    jle     .base_case

    # Sauvegarde de n et alignement de la pile.
    pushq   %rbx
    subq    $32, %rsp
    movq    %rdi, %rbx

    movsd   .Lfive(%rip), %xmm0
    call    C(sqrt)

    movsd   %xmm0, 0(%rsp)

    # phi = (1 + sqrt(5)) / 2
    movsd   .Lone(%rip), %xmm1
    addsd   %xmm0, %xmm1
    divsd   .Ltwo(%rip), %xmm1
    movsd   %xmm1, 8(%rsp)

    # psi = (1 - sqrt(5)) / 2
    movsd   .Lone(%rip), %xmm1
    subsd   %xmm0, %xmm1
    divsd   .Ltwo(%rip), %xmm1
    movsd   %xmm1, 16(%rsp)

    # Initialisation : phi^0 = 1 et psi^0 = 1
    movsd   .Lone(%rip), %xmm0
    movsd   .Lone(%rip), %xmm1

    movq    %rbx, %rcx

.loop:
    testq   %rcx, %rcx
    jz      .end_loop

    mulsd   8(%rsp), %xmm0
    mulsd   16(%rsp), %xmm1

    decq    %rcx
    jmp     .loop

.end_loop:
    # xmm0 = phi^n
    # xmm1 = psi^n

    subsd   %xmm1, %xmm0

    # F(n) = (phi^n - psi^n) / sqrt(5)
    divsd   0(%rsp), %xmm0

    cvttsd2si %xmm0, %rax

    addq    $32, %rsp
    popq    %rbx
    ret

.base_case:
    movq    %rdi, %rax
    ret

    .section .note.GNU-stack,"",@progbits