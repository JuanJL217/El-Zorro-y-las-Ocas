global copiarTablero

section .data
section .bss
section .text

; copia los 49 bytes comenzando por la direccion en rsi (source)
; a los 49 bytes comenzando por la direccion en rdi (destintation)
copiarTablero:
    mov     rcx,0
copiarTableroBucle:
    cmp     rcx,49
    jge     copiarTableroFin
    mov     dh,[rsi+rcx]
    mov     [rdi+rcx],dh
    inc     rcx
    jmp     copiarTableroBucle
copiarTableroFin:
    ret