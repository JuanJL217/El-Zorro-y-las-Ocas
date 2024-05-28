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
%macro  MLimpiarPantalla 0
    mov     rdi,cmd_clear
    sub     rsp,8
    call    system
    add     rsp,8
%endmacro
%macro  MEnterParaContinuar 0
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
extern ValidarPersonalizacion
extern ValidarOrientacion

section .data
    mensajeMainMenu             db "        ** MENÚ PRINCIPAL **",10,10,"Bienvenido al juego del Zorro y las Ocas!",10,"Seleccione una opción para jugar (ingresar número de opción)",10,"  0 - Cargar Partida",10,"  1 - Nueva Partida",10,0
    mensajeOpcionInvalida       db "Opción ingresada inválida. Debes ingresar un número de opción.",10,0
    nombreArchivoGuardado       db "partidaGuardada.dat",0
    modoLecturaBinario          db "rb",0
    cmd_clear                   db "clear",0
    mensajeEnterParaContinuar   db "Presione la tecla Enter para continuar.",10,0
    mensajeErrorCargarPartida   db "Hubo un error al cargar la partida. Se iniciará una partida nueva.",10,0
    mensajePersonalizarPartida  db "        ** PERSONALIZACIÓN **",10,10,"Este es el menú de personalización de partida. Si se quiere jugar con las configuraciones por defecto, ingrese salir sin modificar nada.",10,"Seleccione una opción para personalizar.",10,"  0 - Orientación del tablero (actual: %c)",10,"  1 - Símbolo de las Ocas (actual: %c)",10,"  2 - Símbolo del Zorro (actual: %c)",10,"  3 - Salir",10,0
    mensajeIngresarOrientacion  db "Ingrese una orientación. Las opciones se eligen según dónde comienzan las Ocas.",10,"  N - Norte (las ocas comienzan arriba)",10,"  S - Sur (las ocas comienzan abajo)",10,"  E - Este (las ocas comienzan a la derecha)",10,"  O - Oeste (las ocas comienzan a la izquierda)",10,0
    mensajeCaracterInvalido     db "El caracter que se ingresó no es válido.",10,0
    mensajeSeleccionInvalida    db "Ingrese una de las opciones ennumeradas.",10,0
    mensajeIngresarSimboloOcas  db "Ingrese un símbolo para representar las Ocas. No puede ser un espacio ni tampoco el símbolo del zorro.",10,0
    mensajeIngresarSimboloZorro db "Ingrese un símbolo para representar el Zorro. No puede ser un espacio ni tampoco el símbolo de las ocas.",10,0
    orientacionDefault          db "N"
    simboloOcasDefault          db "O"
    simboloZorroDefault         db "X"

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
    MLimpiarPantalla

menuMostrar:
    Mprintf         mensajeMainMenu

menuIngresarOpcion:
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
    je              nuevaPartida
    ; Sino se ingresó una opción inválida
    jmp             menuOpcionInvalida
    
menuOpcionInvalida:
    Mprintf         mensajeOpcionInvalida
    jmp             menuIngresarOpcion

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
    jmp             nuevaPartida

nuevaPartida:
    ; Cargo los valores por defecto y paso al menú de personalización
    mov             rdx,[orientacionDefault]
    mov             [orientacion],rdx
    mov             rdx,[simboloOcasDefault]
    mov             [simboloOcas],rdx
    mov             rdx,[simboloZorroDefault]
    mov             [simboloZorro],rdx

personalizacionMostrar:
    MLimpiarPantalla
    mov             rsi,[orientacion]
    mov             rdx,[simboloOcas]
    mov             rcx,[simboloZorro]
    Mprintf         mensajePersonalizarPartida

personalizacionIngresarOpcion:
    Mgets           inputBuffer
    ; Llamada a rutina externa ValidarPersonalizacion
    mov             rdi,inputBuffer
    sub             rsp,8
    call            ValidarPersonalizacion
    add             rsp,8

    ; Si rax == 0 se ingresó la opción de orientacion
    cmp             rax,0
    je              personalizarOrientacion
    ; Si rax == 1 se ingresó la opción de simbolo ocas
    cmp             rax,1
    je              personalizarOcas
    ; Si rax == 2 se ingresó la opción de simbolo zorro
    cmp             rax,2
    je              personalizarZorro
    ; Si rax == 3 se ingresó la opción de salir
    cmp             rax,3
    je              inicializarPartida
    ; Sino se ingresó una opción inválida
    jmp              personalizacionOpcionInvalida
    
personalizacionOpcionInvalida:
    Mprintf         mensajeOpcionInvalida
    jmp             personalizacionIngresarOpcion

personalizarOrientacion:
    Mprintf         mensajeIngresarOrientacion
orientacionIngresarOpcion:
    Mgets           inputBuffer
    ; Llamada a rutina externa ValidarOrientacion
    mov             rdi,inputBuffer
    sub             rsp,8
    call            ValidarOrientacion
    add             rsp,8

    ; Si rax < 0 se ingresó una opción inválida.
    cmp             rax,0
    jl              orientacionOpcionInvalida
    ; Sino, guardo el primer caracter ingresado como nueva orientación
    mov             rdx,[inputBuffer]
    mov             [orientacion],rdx

    jmp             personalizacionMostrar
orientacionOpcionInvalida:
    Mprintf         mensajeCaracterInvalido
    Mprintf         mensajeSeleccionInvalida
    jmp             orientacionIngresarOpcion

personalizarOcas:
    Mprintf     mensajeIngresarSimboloOcas
ocasIngresarOpcion:
    Mgets           inputBuffer
    ; Si se ingresa el mismo símbolo que para el zorro, es inválido
    mov             rax,[simboloZorro]
    cmp             rax,[inputBuffer]
    je              ocasOpcionInvalida
    ; Si se ingresa un espacio (ascii 32), es inválido
    mov             rax,32
    cmp             rax,[inputBuffer]
    je              ocasOpcionInvalida
    ; Sino, guardo el primer caracter ingresado como nuevo simbolo para las ocas
    mov             rax,[inputBuffer]
    mov             [simboloOcas],rax
    jmp             personalizacionMostrar
ocasOpcionInvalida:
    Mprintf         mensajeCaracterInvalido
    jmp             ocasIngresarOpcion

personalizarZorro:
    Mprintf     mensajeIngresarSimboloZorro
zorroIngresarOpcion:
    Mgets           inputBuffer
    ; Si se ingresa el mismo símbolo que para las ocas, es inválido
    mov             rax,[simboloOcas]
    cmp             rax,[inputBuffer]
    je              zorroOpcionInvalida
    ; Si se ingresa un espacio (ascii 32), es inválido
    mov             rax,32
    cmp             rax,[inputBuffer]
    je              zorroOpcionInvalida
    ; Sino, guardo el primer caracter ingresado como nuevo simbolo para el zorro
    mov             rax,[inputBuffer]
    mov             [simboloZorro],rax
    jmp             personalizacionMostrar
zorroOpcionInvalida:
    Mprintf         mensajeCaracterInvalido
    jmp             zorroIngresarOpcion

inicializarPartida:

turnoOcas:

turnoZorro:
    ret