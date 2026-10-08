# int64_t fib(int64_t n)
# n      -> %rdi
# retour -> %rax

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(fib)

C(fib):
    # a = 0, b = 1
    xorl    %eax, %eax
    movl    $1, %ecx

.loop:
    testq   %rdi, %rdi
    jz      .done

    # a, b = b, a + b
    movq    %rax, %rdx
    addq    %rcx, %rdx
    movq    %rcx, %rax
    movq    %rdx, %rcx
    decq    %rdi
    jmp     .loop

.done:
    ret
