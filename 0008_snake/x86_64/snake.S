    #include "../../0007_jeu/gfx_consts.h"

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

#define W 30
#define H 20
#define MAX_LEN 600
#define ORIGIN_Y 1
#define TICK0_MS 150
#define TICK_MIN 60

    .text

/* int on_body(int x, int y) */
on_body:
    movl    head(%rip), %ecx
    movl    tail(%rip), %edx
.Lbody_loop:
    cmpl    %ecx, %edx
    je      .Lbody_head
    movl    bx(,%rdx,4), %eax
    cmpl    %edi, %eax
    jne     .Lbody_next
    movl    by(,%rdx,4), %eax
    cmpl    %esi, %eax
    je      .Lbody_yes
.Lbody_next:
    incl    %edx
    cmpl    $MAX_LEN, %edx
    jne     .Lbody_loop
    xorl    %edx, %edx
    jmp     .Lbody_loop
.Lbody_head:
    movl    bx(,%rcx,4), %eax
    cmpl    %edi, %eax
    jne     .Lbody_no
    movl    by(,%rcx,4), %eax
    cmpl    %esi, %eax
    jne     .Lbody_no
.Lbody_yes:
    movl    $1, %eax
    ret
.Lbody_no:
    xorl    %eax, %eax
    ret

/* void place_apple(void) */
place_apple:
    pushq   %rbp
    movq    %rsp, %rbp
#ifdef FIXED_APPLE
    movl    ax(%rip), %eax
    addl    $7, %eax
    cmpl    $W, %eax
    jl      1f
    subl    $W, %eax
1:  movl    %eax, ax(%rip)
    movl    ay(%rip), %eax
    addl    $5, %eax
    cmpl    $H, %eax
    jl      2f
    subl    $H, %eax
2:  movl    %eax, ay(%rip)
.Lfixed_check:
    movl    ax(%rip), %edi
    movl    ay(%rip), %esi
    call    on_body
    testl   %eax, %eax
    je      .Lplace_done
    incl    ax(%rip)
    cmpl    $W, ax(%rip)
    jl      .Lfixed_check
    movl    $0, ax(%rip)
    jmp     .Lfixed_check
#else
.Lrandom:
    movl    $W, %edi
    call    C(gfx_rand)
    movl    %eax, ax(%rip)
    movl    $H, %edi
    call    C(gfx_rand)
    movl    %eax, ay(%rip)
    movl    ax(%rip), %edi
    movl    ay(%rip), %esi
    call    on_body
    testl   %eax, %eax
    jne     .Lrandom
#endif
.Lplace_done:
    popq    %rbp
    ret

/* void init(void) */
init:
    pushq   %rbp
    movq    %rsp, %rbp
    movl    $0, head(%rip)
    movl    $0, tail(%rip)
    movl    $1, len(%rip)
    movl    $W/2, bx(%rip)
    movl    $H/2, by(%rip)
    movl    $1, dx(%rip)
    movl    $0, dy(%rip)
    movl    $3, ax(%rip)
    movl    $3, ay(%rip)
    call    place_apple
    movl    $0, score(%rip)
    movl    $TICK0_MS, tick_ms(%rip)
    movl    $1, alive(%rip)
    popq    %rbp
    ret

/* void step(void) */
step:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
    movl    head(%rip), %eax
    movl    bx(,%rax,4), %ecx
    addl    dx(%rip), %ecx
    movl    %ecx, -4(%rbp)
    movl    by(,%rax,4), %ecx
    addl    dy(%rip), %ecx
    movl    %ecx, -8(%rbp)
    cmpl    $0, -4(%rbp)
    jl      .Ldead
    cmpl    $W, -4(%rbp)
    jge     .Ldead
    cmpl    $0, -8(%rbp)
    jl      .Ldead
    cmpl    $H, -8(%rbp)
    jge     .Ldead
    movl    $0, -12(%rbp)
    movl    ax(%rip), %eax
    cmpl    -4(%rbp), %eax
    jne     1f
    movl    ay(%rip), %eax
    cmpl    -8(%rbp), %eax
    jne     1f
    movl    $1, -12(%rbp)
1:  cmpl    $0, -12(%rbp)
    jne     2f
    incl    tail(%rip)
    cmpl    $MAX_LEN, tail(%rip)
    jl      2f
    movl    $0, tail(%rip)
2:  cmpl    $0, -12(%rbp)
    je      3f
    incl    len(%rip)
3:  movl    -4(%rbp), %edi
    movl    -8(%rbp), %esi
    call    on_body
    testl   %eax, %eax
    jne     .Ldead
    incl    head(%rip)
    cmpl    $MAX_LEN, head(%rip)
    jl      4f
    movl    $0, head(%rip)
4:  movl    head(%rip), %eax
    movl    -4(%rbp), %ecx
    movl    %ecx, bx(,%rax,4)
    movl    -8(%rbp), %ecx
    movl    %ecx, by(,%rax,4)
    cmpl    $0, -12(%rbp)
    je      .Lstep_done
    addl    $10, score(%rip)
    cmpl    $TICK_MIN, tick_ms(%rip)
    jle     5f
    subl    $5, tick_ms(%rip)
5:  call    place_apple
.Lstep_done:
    leave
    ret
.Ldead:
    movl    $0, alive(%rip)
    leave
    ret

/* void turn(int ndx, int ndy) */
turn:
    cmpl    $0, len(%rip)
    jle     .Lturn_set
    movl    dx(%rip), %eax
    negl    %eax
    cmpl    %eax, %edi
    jne     .Lturn_set
    movl    dy(%rip), %eax
    negl    %eax
    cmpl    %eax, %esi
    jne     .Lturn_set
    cmpl    $1, len(%rip)
    jg      .Lturn_done
.Lturn_set:
    movl    %edi, dx(%rip)
    movl    %esi, dy(%rip)
.Lturn_done:
    ret

/* int last_key(void) */
last_key:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    subq    $8, %rsp              /* alignement de pile avant les appels C */

    movq    script(%rip), %rax
    testq   %rax, %rax
    je      .Lkey_live

    movzbl  (%rax), %ebx
    testb   %bl, %bl
    je      .Lkey_none
    incq    %rax
    movq    %rax, script(%rip)

    cmpb    $'L', %bl
    je      .Lkey_left
    cmpb    $'R', %bl
    je      .Lkey_right
    cmpb    $'U', %bl
    je      .Lkey_up
    cmpb    $'D', %bl
    je      .Lkey_down
    movzbl  %bl, %eax
    jmp     .Lkey_return

.Lkey_left:
    movl    $GFX_KEY_LEFT, %eax
    jmp     .Lkey_return
.Lkey_right:
    movl    $GFX_KEY_RIGHT, %eax
    jmp     .Lkey_return
.Lkey_up:
    movl    $GFX_KEY_UP, %eax
    jmp     .Lkey_return
.Lkey_down:
    movl    $GFX_KEY_DOWN, %eax
    jmp     .Lkey_return
.Lkey_none:
    movl    $GFX_KEY_NONE, %eax
    jmp     .Lkey_return

.Lkey_live:
    movl    $GFX_KEY_NONE, %ebx
.Lkey_drain:
    call    C(gfx_key)
    cmpl    $GFX_KEY_NONE, %eax
    je      .Lkey_live_done
    movl    %eax, %ebx
    jmp     .Lkey_drain
.Lkey_live_done:
    movl    %ebx, %eax

.Lkey_return:
    addq    $8, %rsp
    popq    %rbx
    popq    %rbp
    ret

/* void draw(const char *message) */
draw:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $128, %rsp
    movq    %rdi, -120(%rbp)
    movl    $GFX_BLACK, %edi
    call    C(gfx_clear)
    xorl    %edi, %edi
    movl    $ORIGIN_Y, %esi
    movl    $2*W, %edx
    movl    $H, %ecx
    movl    $'.', %r8d
    movl    $GFX_BLUE, %r9d
    call    C(gfx_rect)
    movl    tail(%rip), %eax
    movl    %eax, -4(%rbp)
.Ldraw_body:
    movl    -4(%rbp), %eax
    cmpl    head(%rip), %eax
    je      .Ldraw_head
    movl    bx(,%rax,4), %edi
    leal    (%rdi,%rdi), %edi
    movl    by(,%rax,4), %esi
    addl    $ORIGIN_Y, %esi
    leaq    body_sprite(%rip), %rdx
    call    C(gfx_blit)
    incl    -4(%rbp)
    cmpl    $MAX_LEN, -4(%rbp)
    jl      .Ldraw_body
    movl    $0, -4(%rbp)
    jmp     .Ldraw_body
.Ldraw_head:
    movl    head(%rip), %eax
    movl    bx(,%rax,4), %edi
    leal    (%rdi,%rdi), %edi
    movl    by(,%rax,4), %esi
    addl    $ORIGIN_Y, %esi
    leaq    head_sprite(%rip), %rdx
    call    C(gfx_blit)
    movl    ax(%rip), %edi
    leal    (%rdi,%rdi), %edi
    movl    ay(%rip), %esi
    addl    $ORIGIN_Y, %esi
    leaq    apple_sprite(%rip), %rdx
    call    C(gfx_blit)
    leaq    hud(%rip), %rdi
    movl    $80, %esi
    leaq    format_message(%rip), %rdx
    movq    -120(%rbp), %rcx
    testq   %rcx, %rcx
    jne     .Ldraw_format
    leaq    format_hud(%rip), %rdx
    movl    score(%rip), %ecx
    movl    len(%rip), %r8d
.Ldraw_format:
    xorl    %eax, %eax
    call    C(snprintf)
    xorl    %edi, %edi
    xorl    %esi, %esi
    leaq    hud(%rip), %rdx
    movl    $GFX_WHITE, %ecx
    call    C(gfx_text)
    call    C(gfx_present)
    leave
    ret

    .globl C(main)
C(main):
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    subq    $24, %rsp
    cmpl    $1, %edi
    jle     1f
    movq    8(%rsi), %rax
    movq    %rax, script(%rip)
1:  movl    $2*W, %edi
    movl    $H+ORIGIN_Y, %esi
    call    C(gfx_open)
    testl   %eax, %eax
    jl      .Lmain_fail
    call    init
    call    C(gfx_ticks)
    movq    %rax, -16(%rbp)
.Lmain_loop:
    call    last_key
    movl    %eax, -4(%rbp)
    cmpl    $'q', %eax
    je      .Lmain_quit
    cmpl    $GFX_KEY_LEFT, %eax
    jne     2f
    movl    $-1, %edi
    xorl    %esi, %esi
    call    turn
2:  cmpl    $GFX_KEY_RIGHT, -4(%rbp)
    jne     3f
    movl    $1, %edi
    xorl    %esi, %esi
    call    turn
3:  cmpl    $GFX_KEY_UP, -4(%rbp)
    jne     4f
    xorl    %edi, %edi
    movl    $-1, %esi
    call    turn
4:  cmpl    $GFX_KEY_DOWN, -4(%rbp)
    jne     5f
    xorl    %edi, %edi
    movl    $1, %esi
    call    turn
5:  cmpl    $0, alive(%rip)
    je      6f
    call    step
6:  cmpl    $0, alive(%rip)
    je      .Ldraw_dead
    xorl    %edi, %edi
    call    draw
    movq    script(%rip), %rax
    testq   %rax, %rax
    je      .Lwait
    cmpb    $0, (%rax)
    jne     .Lwait
    movl    $300, %edi
    call    C(gfx_sleep)
    jmp     .Lmain_quit
.Ldraw_dead:
    leaq    lost_message(%rip), %rdi
    call    draw
.Lwait_dead:
    call    last_key
    cmpl    $'q', %eax
    je      .Lmain_quit
    movq    script(%rip), %rdx
    testq   %rdx, %rdx
    je      .Lsleep_dead
    cmpb    $0, (%rdx)
    je      .Lmain_quit
.Lsleep_dead:
    movl    $50, %edi
    call    C(gfx_sleep)
    jmp     .Lwait_dead
.Lwait:
    movq    -16(%rbp), %rax
    addq    tick_ms(%rip), %rax
    movq    %rax, -16(%rbp)
    call    C(gfx_ticks)
    movq    -16(%rbp), %rdi
    subq    %rax, %rdi
    jle     .Lmain_loop
    call    C(gfx_sleep)
    jmp     .Lmain_loop
.Lmain_quit:
    call    C(gfx_close)
    movl    score(%rip), %esi
    movl    len(%rip), %edx
    leaq    final_message(%rip), %rdi
    xorl    %eax, %eax
    call    C(printf)
    xorl    %eax, %eax
    jmp     .Lmain_ret
.Lmain_fail:
    movl    $1, %eax
.Lmain_ret:
    addq    $24, %rsp
    popq    %rbx
    popq    %rbp
    ret

    .section .rodata
format_message: .asciz "%s"
format_hud: .asciz "Score %d  Longueur %d   fleches, q: quitter"
lost_message: .asciz "Perdu. q pour quitter"
final_message: .asciz "Score final: %d, longueur %d\n"
body_sprite: .byte 2, 1, '[', GFX_GREEN, ']', GFX_GREEN
head_sprite: .byte 2, 1, '(', GFX_GREEN, ')', GFX_GREEN
apple_sprite: .byte 2, 1, '@', GFX_RED, ' ', GFX_BLACK

    .bss
    .align 4
bx:      .zero  MAX_LEN * 4
by:      .zero  MAX_LEN * 4
head:    .zero  4
tail:    .zero  4
len:     .zero  4
dx:      .zero  4
dy:      .zero  4
ax:      .zero  4
ay:      .zero  4
score:   .zero  4
tick_ms: .zero  4
alive:   .zero  4
script:  .zero  8
hud:     .zero  80
