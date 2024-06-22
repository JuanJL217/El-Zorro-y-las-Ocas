global ValidarMenu
global ValidarPersonalizacion
global ValidarOrientacion
global ValidarEntradaTurnoZorro
global ValidarEntradaTunroZorroExtra
global ValidarMovimientoOca
global ValidarPosicionOca
global ValidarFilaColumna
global ValidarEntradaElegirOca
global ValidarPodriaMoverseOca

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
    caracterTerminarTurno               db "T"
    caracterElegirOca                   db "O"

    repOcas                             db 1
    repEspacio                          db 0
    longitudElemento                    dq 1
    longitudFila                        dq 7

section .bss
    dirVectMovimientos                  resq 1
    movimientoIngresado                 resb 1
    iterador                            resq 1
    caracterAValidar                    resb 1

section .text

ValidarMenu:
    mov     al,[rdi]
    mov     [caracterAValidar],al

    mov     al,[menuOpcionCargarPartida]
    cmp     al,[caracterAValidar]
    je      menuEligeCargarPartida

    mov     al,[menuOpcionNuevaPartida]
    cmp     al,[caracterAValidar]
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

    mov     al,[rdi]
    mov     [caracterAValidar],al

    mov     al,[personalizacionOrientacion]
    cmp     al,[caracterAValidar]
    je      persoEligeOrientacion

    mov     al,[personalizacionOcas]
    cmp     al,[caracterAValidar]
    je      persoEligeOcas

    mov     al,[personalizacionZorro]
    cmp     al,[caracterAValidar]
    je      persoEligeZorro

    mov     al,[personalizacionSalir]
    cmp     al,[caracterAValidar]
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
    mov     al,[rdi]
    mov     [caracterAValidar],al

    mov     al,[orientacionNorte]
    cmp     al,[caracterAValidar]
    je      orientacionEligeNorte

    mov     al,[orientacionSur]
    cmp     al,[caracterAValidar]
    je      orientacionEligeSur

    mov     al,[orientacionEste]
    cmp     al,[caracterAValidar]
    je      orientacionEligeEste

    mov     al,[orientacionOeste]
    cmp     al,[caracterAValidar]
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
    mov     [caracterAValidar],rax
    
    mov     al,[caracterGuardarPartida]
    cmp     al,[caracterAValidar]
    je      IngresaGuardarPartida

    mov     al,[caracterSalirDelJuego]
    cmp     al,[caracterAValidar]
    je      IngresaSalirDelJuego

    mov     al,[caracterAValidar]
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

ValidarEntradaTunroZorroExtra:
    mov     [dirVectMovimientos],rdi
    mov     rax,[rsi]
    mov     [caracterAValidar],rax
    
    mov     al,[caracterTerminarTurno]
    cmp     al,[caracterAValidar]
    je      IngresaTerminarTurno

    jmp     ValidarEntradaTurnoZorro

IngresaTerminarTurno:
    mov     rax,0
    mov     al,[caracterTerminarTurno]
    ret

ValidarMovimientoOca:
    ; valida que la entrada del usuario sea un movimiento posible para la oca. si es valido, devuelve el nro de mov en el al. si no es valido devuelve -1 en el al
    mov     al,[rdi]
    sub     al,48
    mov     [movimientoIngresado],al
    mov     [dirVectMovimientos],rsi
    jmp     loopValidarMovimientoIngresado

    
ValidarPosicionOca:
    ; recibe el tablero en rdx. verifica que en la (fila,col) ingresadas en los registros (dil,sil) haya una oca. si no hay una oca, devuelve -1 en el al.
    mov     rax,0                 ; rax = fila
    mov     al,dil
    mov     rcx,0                 ; rcx = columna
    mov     cl,sil

    imul    rax,[longitudFila]
    imul    rcx,[longitudElemento]
    add     rax,rcx
    add     rdx,rax

    mov     al,[repOcas]
    cmp     al,[rdx]
    jne     IngresoInvalido
   
    ret
    

ValidarFilaColumna:
    ; verifica que la entrada sea un número del 1 al 7 inclusive, y lo devuelve en el al. sino devuelve -1 en el al.
    mov     rax,0
    mov     al,[rdi]

    sub     al,48
    cmp     al,1
    jl      IngresoInvalido
    cmp     al,7
    jg      IngresoInvalido

    dec     al
    
    ret


ValidarEntradaElegirOca:
    ; verifica que la entrada sea G, S o O y lo devuelve en el al. sino devuelve -1 en el al.
    ; mov rdi,inputBuffer [ char* ]
    mov     al,[rdi]
    mov     [caracterAValidar],al

    mov     al,[caracterGuardarPartida]
    cmp     al,[caracterAValidar]
    je      IngresaGuardarPartida

    mov     al,[caracterSalirDelJuego]
    cmp     al,[caracterAValidar]
    je      IngresaSalirDelJuego

    mov     al,[caracterElegirOca]
    cmp     al,[caracterAValidar]
    je      IngresaElegirOca

    jmp     IngresoInvalido

IngresaElegirOca:
    mov     rax,0
    mov     al,[caracterElegirOca]
    ret