global ValidarMenu

section .data
    menuOpcionCargarPartida             db "0",0
    menuOpcionNuevaPartida              db "1",0

section .bss
    bufferEntrada                       resb 100

section .text

ValidarMenu:
    Mgets   bufferEntrada

    mov     rcx,1
    mov     rsi,bufferEntrada
    mov     rdi,menuOpcionCargarPartida
    repe cmpsb 
    je      opcionCargarPartida

    mov     rcx,1
    mov     rsi,bufferEntrada
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

