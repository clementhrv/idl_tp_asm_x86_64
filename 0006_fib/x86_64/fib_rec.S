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
    cmpq    $1, %rdi
    jbe     .base_case

    # Réserve 24 octets.
    subq    $24, %rsp

    movq    %rdi, 0(%rsp)

    decq    %rdi
    call    C(fib)

    movq    %rax, 8(%rsp)

    movq    0(%rsp), %rdi
    subq    $2, %rdi
    call    C(fib)

    addq    8(%rsp), %rax

    addq    $24, %rsp
    ret

.base_case:
    movq    %rdi, %rax
    ret