# int64_t gcd(int64_t a, int64_t b)
# System V AMD64: a -> %rdi, b -> %rsi, résultat dans %rax.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(gcd)
C(gcd):
.loop:
    cmpq    %rsi, %rdi
    je      .done

    jg      .a_greater

    subq    %rdi, %rsi
    jmp     .loop

.a_greater:
    subq    %rsi, %rdi
    jmp     .loop

.done:
    movq    %rdi, %rax
    ret
