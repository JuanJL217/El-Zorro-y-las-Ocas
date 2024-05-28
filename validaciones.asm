global ValidarMenu

section .data
    menuOpcionCargarPartida             db "0",0
    menuOpcionNuevaPartida              db "1",0

section .bss
    inicioStringValidarMenu             resq 1

section .text

ValidarMenu:
    mov     [inicioStringValidarMenu],rdi
    mov     rcx,1
    mov     rsi,[inicioStringValidarMenu]
    mov     rdi,menuOpcionCargarPartida
    repe cmpsb 
    je      opcionCargarPartida

    mov     rcx,1
    mov     rsi,[inicioStringValidarMenu]
    mov     rdi,menuOpcionNuevaPartida
    repe cmpsb
    je      opcionNuevaPartida

opcionInvalida:
    mov     rax,-1
    ret

opcionCargarPartida:
    mov     rax,0
    ret

opcionNuevaPartida:
    mov     rax,1
    ret

