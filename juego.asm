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
%macro  MLimpiarPantalla
    mov     rdi,cmd_clear
    sub     rsp,8
    call    system
    add     rsp,8
%endmacro
%macro  MEnterParaContinuar
    mov     rdi,mensajeEnterParaContinuar
    sub     rsp,8
    call    printf
    add     rsp,8
    mov     rdi,inputBuffer
    sub     rsp,8
    call    gets
    add     rsp,8
%endmacro

global main

;Funciones de C
extern printf
extern gets
extern system
extern fopen
extern fread
extern fwrite
extern fclose

;Rutinas externas
extern ValidarMenu

section .data
    mensajeMainMenu             db "Bienvenido al juego del Zorro y las Ocas!\nSeleccione una opción para jugar (ingresar número de opción)",10,"  0 - Cargar Partida",10,"  1 - Nueva Partida",10,0
    mensajeOpcionMenuInvalida   db "Opción ingresada inválida. Debes ingresar un número de opción (0 ó 1).",10,0
    nombreArchivoGuardado       db "partidaGuardada.dat",0
    modoLecturaBinario          db "rb",0
    cmd_clear                   db "clear",0
    mensajeEnterParaContinuar   db "Presione la tecla Enter para continuar.",10,0
    mensajeErrorCargarPartida   db "Hubo un error al cargar la partida. Se iniciará una partida nueva.",10,0

section .bss
    registroDatosPartida    times 0 resb 70 ; Es una etiqueta (apunta a exactamente lo mismo que la etiqueta "tablero")
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
    idArchivoGuardado       resq 1
    qwordTemporal           resq 1

section .text

main:

mostrarMainMenu:
    Mprintf         mensajeMainMenu

ingresarOpcionMenu:
    Mgets           inputBuffer
    ; Llamada a rutina externa ValidarMenu
    mov             rdi,inputBuffer
    sub             rsp,8
    call            ValidarMenu
    add             rsp,8

    ; Si rax == 0 se ingresó la opción de cargar partida
    cmp             rax,0
    je              cargarPartida
    ; Si rax == 1 se ingresó la opción de nueva partida
    cmp             rax,1
    je              preguntarPorPersonalizacion
    ; Sino se ingresó una opción inválida
    jmp              opcionMenuInvalida
    
opcionMenuInvalida:
    Mprintf         mensajeOpcionMenuInvalida
    jmp             ingresarOpcionMenu

cargarPartida:
    ; Abro el archivo de guardado
    mov             rdi,nombreArchivoGuardado
    mov             rsi,modoLecturaBinario
    sub             rsp,8
    call            fopen
    add             rsp,8
    ; Si no existe, informo al usuario y comienzo partida nueva
    cmp             rax,0
    jle             errorPartidaCargarPartida
    ; Sino, cargo la partida
    mov             qword[idArchivoGuardado],rax
    mov             rdi,registroDatosPartida
    mov             rsi,70
    mov             rcx,[idArchivoGuardado]
    sub             rsp,8
    call            fread
    add             rsp,8
    mov             qword[qwordTemporal],rax
    ; Cierro el archivo
    mov             rdi,[idArchivoGuardado]
    sub             rsp,8
    call            fclose
    add             rsp,8
    ; Si hubo un error, informo al usuario y comienzo partida nueva
    mov             rax,qword[qwordTemporal]
    cmp             rax,0
    jle             errorPartidaCargarPartida
    ; Sino, voy hacia el turno correspondiente.
    mov             rax,[turnoActual]
    ; Si rax == 0, es el turno de las Ocas
    cmp             rax,0 
    je              turnoOcas
    ; Sino, es el turno del zorro
    jmp             turnoZorro

errorPartidaCargarPartida:
    MLimpiarPantalla
    Mprintf         mensajeErrorCargarPartida
    MEnterParaContinuar
    jmp             preguntarPorPersonalizacion