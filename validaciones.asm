global ValidarMenu
global ValidarPersonalizacion
global ValidarOrientacion
global ValidarEntradaTurnoZorro

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

    caracterGuardarPartida              db "G"
    caracterSalirDelJuego               db "S"

section .bss
    bufferEntradaValidar                resq 1
    dirVectMovimientos                  resq 1
    movimientoIngresado                 resb 1
    iterador                            resq 1

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

; recibe en rdi la dirección del vector de movimientosPosibles (con los movimientos previamente calculados)
; recibe en rsi la dirección del ingreso del usuario por teclado
; Valida la entrada del usuario durante el turno del Zorro y devuelve un código en rax
; Si se ingresó "guardar partida", devuelve G (ASCII)
; Si se ingresó "salir", devuelve S (ASCII)
; Si se ingresó un movimientoPosible, devuelve el número de ese movimiento (nro del 1 al 9)
; Sino, la entrada del usuario es inválida. Se devuelve -1.
ValidarEntradaTurnoZorro:
    mov     [dirVectMovimientos],rdi
    mov     rax,[rsi]
    mov     [bufferEntradaValidar],rax
    
    mov     al,[caracterGuardarPartida]
    cmp     al,[bufferEntradaValidar]
    je      IngresaGuardarPartida

    mov     al,[caracterSalirDelJuego]
    cmp     al,[bufferEntradaValidar]
    je      IngresaSalirDelJuego

    mov     al,[bufferEntradaValidar]
    sub     al,48                       ; convierto el nro ascii ingresado (nro del 1 al 9) en un int
    mov     [movimientoIngresado],al

loopValidarMovimientoIngresado:

    mov     rax,0
    mov     rdi,[dirVectMovimientos]    ; verifico si llegue al final del vector de movimientos
    mov     al,[rdi]
    cmp     al,-1
    je      IngresoInvalido

    cmp     al,[movimientoIngresado]    ; verifico si el caracter ingresado es un movimientoPosible
    je      IngresaMovimientoValido

    mov     rdi,[dirVectMovimientos]
    add     rdi,4 ; desplazo al siguiente elemento del vector movimientosPosibles
    mov     [dirVectMovimientos],rdi
    jmp     loopValidarMovimientoIngresado

IngresaGuardarPartida:
    mov     rax,0
    mov     al,[caracterGuardarPartida]
    ret

IngresaSalirDelJuego:
    mov     rax,0
    mov     al,[caracterSalirDelJuego]
    ret

IngresaMovimientoValido:
    ret

IngresoInvalido:
    mov     rax,-1
    ret