# Affiche les arguments passés en ligne de commande, un par ligne.
# x86-64, syntaxe AT&T. int main(int argc, char *argv[])
#   argc -> %edi, argv -> %rsi (tableau de pointeurs, 8 octets chacun)
# puts détruit les registres caller-saved (%rdi, %rsi, ...): on garde argc
# et argv dans des registres callee-saved, %rbx et %r12, que main doit
# donc sauver et restaurer. La réservation de 8 octets aligne la pile avant
# chaque appel (l'adresse de retour de main occupe déjà 8 octets).

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(main)
C(main):
    push    %rbx                    # sauve les callee-saved utilisés
    push    %r12
    sub     $8, %rsp                # aligne la pile avant l'appel de puts
    mov     %edi, %ebx              # ebx = argc
    mov     %rsi, %r12              # r12 = argv
1:
    mov     (%r12), %rdi            # argv[i]
    call    C(puts)
    add     $8, %r12                # argv++
    dec     %ebx
    jnz     1b
    xor     %eax, %eax
    add     $8, %rsp
    pop     %r12
    pop     %rbx
    ret
