%macro Mprintf 1
    mov     rdi,%1
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro
%macro  Mgets   1
    mov     rdi,%1
    sub     rsp,8
    call    gets
    add     rsp,8
%endmacro 


global main
extern printf
extern gets

section .data
    mensajeMainMenu             db "Bienvenido al juego del Zorro y las Ocas!\nSeleccione una opción para jugar (ingresar número de opción)",10,"  0 - Cargar Partida",10,"  1 - Nueva Partida",10,0
    mensajeOpcionMenuInvalida   db "Opción ingresada inválida. Debes ingresar un número de opción (0 ó 1).",10,0

section .bss
    ; Variables de partida - en orden específico para poder acceder a todas desde diferentes rutinas
    tablero                 times 7 resb 7
    orientacion             resb 1
    simboloOcas             resb 1
    simboloZorro            resb 1
    turnoActual             resb 1
    ocasComidas             resb 1
    movimientosZorro        times 8 resb 1 ; vector de 8 posiciones - una por cada dirección del zorro
    movimientosPosibles     times 8 resb 1 ; vector de 8 posiciones - una por cada dirección del zorro
    inputBuffer             resb 100

section .text

main:

mostrarMainMenu:
    Mprintf         mensajeMainMenu

ingresarOpcionMenu:
    Mgets           inputBuffer

    sub             rsp,8
    call            ValidarMenu inputBuffer ; Valida si el primer caracter ingresado por el usuario es una opción válida
    add             rsp,8

    ; Si rax == -1 se ingresó una opción inválida
    cmp             rax,-1
    je              opcionMenuInvalida
    ; Si rax == 0 se ingresó la opción de cargar partida
    cmp             rax,0
    je              cargarPartida
    ; Si rax == 1 se ingresó la opción de nueva partida
    cmp             rax,1
    je              nuevaPartida

opcionMenuInvalida:
    Mprintf         mensajeOpcionMenuInvalida
    jmp             ingresarOpcionMenu