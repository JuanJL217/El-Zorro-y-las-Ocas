global ValidarMenu
global ValidarPersonalizacion
global ValidarOrientacion

section .data
    menuOpcionCargarPartida             db "0",0
    menuOpcionNuevaPartida              db "1",0

    personalizacionOrientacion          db "0"
    personalizacionOcas                 db "1"
    personalizacionZorro                db "2"
    personalizacionSalir                db "3"

    orientacionNorte                    db "N",0
    orientacionSur                      db "S",0
    orientacionEste                     db "E",0
    orientacionOeste                    db "O",0

section .bss
    bufferEntradaValidar                resq 1

section .text

ValidarMenu:
    mov     rax,[rdi]
    mov     [bufferEntradaValidar],rax

    mov     al,[menuOpcionCargarPartida]
    cmp     al,[bufferEntradaValidar]
    je      menuEligeCargarPartida

    mov     al,[menuOpcionNuevaPartida]
    cmp     al,[bufferEntradaValidar]
    je      menuEligeNuevaPartida

menuOpcionInvalida:
    mov     rax,-1
    ret

menuEligeCargarPartida:
    mov     rax,0
    ret

menuEligeNuevaPartida:
    mov     rax,1
    ret


ValidarPersonalizacion:

    mov     rax,[rdi]
    mov     [bufferEntradaValidar],rax

    mov     al,[personalizacionOrientacion]
    cmp     al,[bufferEntradaValidar]
    je      persoEligeOrientacion

    mov     al,[personalizacionOcas]
    cmp     al,[bufferEntradaValidar]
    je      persoEligeOcas

    mov     al,[personalizacionZorro]
    cmp     al,[bufferEntradaValidar]
    je      persoEligeZorro

    mov     al,[personalizacionSalir]
    cmp     al,[bufferEntradaValidar]
    je      persoEligeSalir

persoOpcionInvalida:
    mov     rax,-1
    ret

persoEligeOrientacion:
    mov     rax,0
    ret

persoEligeOcas:
    mov     rax,1
    ret

persoEligeZorro:
    mov     rax,2
    ret

persoEligeSalir:
    mov     rax,3
    ret


ValidarOrientacion:
    mov     rax,[rdi]
    mov     [bufferEntradaValidar],rax

    mov     al,[orientacionNorte]
    cmp     al,[bufferEntradaValidar]
    je      orientacionEligeNorte

    mov     al,[orientacionSur]
    cmp     al,[bufferEntradaValidar]
    je      orientacionEligeSur

    mov     al,[orientacionEste]
    cmp     al,[bufferEntradaValidar]
    je      orientacionEligeEste

    mov     al,[orientacionOeste]
    cmp     al,[bufferEntradaValidar]
    je      orientacionEligeOeste

orientacionInvalida:
    mov     rax,-1
    ret

orientacionEligeNorte:
    mov     rax,0
    ret

orientacionEligeSur:
    mov     rax,1
    ret

orientacionEligeEste:
    mov     rax,2
    ret

orientacionEligeOeste:
    mov     rax,3
    ret
