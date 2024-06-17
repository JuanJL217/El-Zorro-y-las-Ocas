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
extern CopiarTablero
extern MostrarTablero
extern VerificarMovimientoZorro
extern ContarOcas
extern CalcularMovimientosZorro
extern FiltrarMovimientosQueNoComenOcas
extern ValidarEntradaTurnoZorro
extern RealizarMovimientoZorro
extern copiarTablero
extern MostrarVectorMovimientos

extern RealizarMovimientoOca    ; mueve la oca en el tablero según el movimiento ingresado en el sil.
extern CalcularMovimientosOca   ; calcula los movimientos de la oca en la pos (dil,sil) y los carga en el vector movimientosPosibles. Si no hay ningun movimiento posible, devuelve -1 en el rax.
extern VerificarMovimientoOcas  ; verifica si hay movimientos posibles para las ocas en el tablero. si no hay movimientos posibles, devuelve 0 en el rax. si hay movimientos posibles, devuelve 1 en el rax.
extern LimpiarMovimientosPosibles
extern ValidarMovimientoOca
extern ValidarPosicionOca
extern ValidarFilaColumna
extern ValidarEntradaElegirOca
extern ValidarPodriaMoverseOca  ; recibe el tablero en rdx. verifica que en la (fila,col) ingresadas en los registros (dil,sil) pueda moverse una oca, sino devuelve -1 en al

section .data
    mensajeMainMenu             db "        ** MENÚ PRINCIPAL **",10,10,"Bienvenido al juego del Zorro y las Ocas!",10,"Seleccione una opción para jugar (ingresar número de opción)",10,"  0 - Cargar Partida",10,"  1 - Nueva Partida",10,0
    mensajeOpcionInvalida       db "Opción ingresada inválida. Debes ingresar un número de opción.",10,0
    mensajeIngresoInvalido      db "El caracter ingresado no representa una acción posible a realizar. Por favor, guíese con los controles mostrados debajo del tablero.",10,0
    mostrarControlesZorro       db "CONTROLES:",10," Ingresar uno de los caracteres indicados entre paréntesis. Los movimientos disponibles en este turno estan mostrados en el tablero con el número correspondiente.",10,"(G) Guardar Partida - (S) Salir del Juego - (1 - 9) Movimiento",10,0
    nombreArchivoGuardado       db "partidaGuardada.dat",0
    modoLecturaBinario          db "rb",0
    modoEscrituraBinario        db "wb",0
    cmd_clear                   db "clear",0
    mensajeEnterParaContinuar   db "Presione la tecla Enter para continuar.",10,0
    mensajeErrorCargarPartida   db "Hubo un error al cargar la partida. Se iniciará una partida nueva.",10,0
    mensajeErrorGuardarPartida  db "Hubo un error al guardar la partida.",10,0
    mensajeExitoGuardarPartida  db "La partida se guardó exitosamente.",10,0
    mensajePersonalizarPartida  db "        ** PERSONALIZACIÓN **",10,10,"Este es el menú de personalización de partida. Si se quiere jugar con las configuraciones por defecto, ingrese salir sin modificar nada.",10,"Seleccione una opción para personalizar.",10,"  0 - Orientación del tablero (actual: %c)",10,"  1 - Símbolo de las Ocas (actual: %c)",10,"  2 - Símbolo del Zorro (actual: %c)",10,"  3 - Salir",10,0
    mensajeIngresarOrientacion  db "Ingrese una orientación. Las opciones se eligen según dónde comienzan las Ocas.",10,"  N - Norte (las ocas comienzan arriba)",10,"  S - Sur (las ocas comienzan abajo)",10,"  E - Este (las ocas comienzan a la derecha)",10,"  O - Oeste (las ocas comienzan a la izquierda)",10,0
    mensajeCaracterInvalido     db "El caracter que se ingresó no es válido.",10,0
    mensajeSeleccionInvalida    db "Ingrese una de las opciones ennumeradas.",10,0
    mensajeIngresarSimboloOcas  db "Ingrese un símbolo para representar las Ocas. No puede ser un espacio ni tampoco el símbolo del zorro.",10,0
    mensajeIngresarSimboloZorro db "Ingrese un símbolo para representar el Zorro. No puede ser un espacio ni tampoco el símbolo de las ocas.",10,0
    mensajeEmpate               db "El juego ha terminado en empate.",10,0
    mensajeGanoZorro            db "El Zorro ha ganado la partida.",10,0
    mensajeGanaronOcas          db "Las Ocas han ganado la partida.",10,0
    controlesOcasElegirOca      db "CONTROLES:",10," Ingresar uno de los caracteres indicados entre paréntesis. Primero, elija una oca para mover.",10,"(G) Guardar Partida - (S) Salir del Juego - (O) Elegir Oca",10,0
    ocasEntradaInvalidaIngresoInicial   db "La entrada ingresada no es válida. Por favor, ingrese una de las opciones indicadas.",10,0
    msjOcasElegirFila           db "Ingrese la fila de la oca que desea mover. (Número del 1 al 7): ",0
    msjOcasElegirCol            db "Ingrese la columna de la oca que desea mover. (Número del 1 al 7): ",0
    msjOcaMovimientoInvalido    db "El movimiento ingresado no es válido. Por favor, ingrese uno de los movimientos posibles mostrados en el tablero.",10,0
    msjOcaNoTieneMovimientosPosibles   db  "La oca seleccionada no tiene movimientos posibles. Por favor, elija otra oca.",10,0
    msjOcaPedirMovimiento       db "Ingrese el número del movimiento que desea realizar, los movimientos disponibles en este turno estan mostrados en el tablero con el número correspondiente.",10,0
    msjNoHayUnaOcaEnLaPos       db "No hay una oca en la posición ingresada. Por favor, elija una posición válida.",10,0
    msjColInvalida              db "La columna ingresada no es válida. Por favor, ingrese un número del 1 al 7.",10,0
    msjFilaInvalida             db "La fila ingresada no es válida. Por favor, ingrese un número del 1 al 7.",10,0
    orientacionDefault          db "N"
    simboloOcasDefault          db "O"
    simboloZorroDefault         db "X"
    orientacionNorte            db "N"
    orientacionSur              db "S"
    orientacionEste             db "E"
    orientacionOeste            db "O"
    caracterGuardarPartida              db "G"
    caracterSalirDelJuego               db "S"
    turnoDelZorro               db 1
    turnoDeLasOcas              db 0
    ; -1 espacios inaccesibles | 0 espacio | 1 oca | 2 zorro 
    tableroNorte                db -1,-1, 1, 1, 1,-1,-1
    tableroNorte1               db -1,-1, 1, 1, 1,-1,-1
    tableroNorte2               db  1, 1, 1, 1, 1, 1, 1
    tableroNorte3               db  1, 0, 0, 0, 0, 0, 1
    tableroNorte4               db  1, 0, 0, 2, 0, 0, 1
    tableroNorte5               db -1,-1, 0, 0, 0,-1,-1
    tableroNorte6               db -1,-1, 0, 0, 0,-1,-1
                                    
    tableroSur                  db -1,-1, 0, 0, 0,-1,-1
    tableroSur1                 db -1,-1, 0, 0, 0,-1,-1
    tableroSur2                 db  1, 0, 0, 2, 0, 0, 1
    tableroSur3                 db  1, 0, 0, 0, 0, 0, 1
    tableroSur4                 db  1, 1, 1, 1, 1, 1, 1
    tableroSur5                 db -1,-1, 1, 1, 1,-1,-1
    tableroSur6                 db -1,-1, 1, 1, 1,-1,-1

    tableroEste                 db -1,-1, 1, 1, 1,-1,-1
    tableroEste1                db -1,-1, 0, 0, 1,-1,-1
    tableroEste2                db  0, 0, 0, 0, 1, 1, 1
    tableroEste3                db  0, 0, 2, 0, 1, 1, 1
    tableroEste4                db  0, 0, 0, 0, 1, 1, 1
    tableroEste5                db -1,-1, 0, 0, 1,-1,-1
    tableroEste6                db -1,-1, 1, 1, 1,-1,-1

    tableroOeste                db -1,-1, 1, 1, 1,-1,-1
    tableroOeste1               db -1,-1, 1, 0, 0,-1,-1
    tableroOeste2               db  1, 1, 1, 0, 0, 0, 0
    tableroOeste3               db  1, 1, 1, 0, 2, 0, 0
    tableroOeste4               db  1, 1, 1, 0, 0, 0, 0
    tableroOeste5               db -1,-1, 1, 0, 0,-1,-1 
    tableroOeste6               db -1,-1, 1, 1, 1,-1,-1

section .bss
    registroDatosPartida    times 0 resb 95 ; Es una etiqueta (apunta a exactamente lo mismo que la etiqueta "tablero")
    ; Variables de partida - en orden específico para poder acceder a todas desde diferentes rutinas
    ; ¡IMPORTANTE! -> TODOS ESTOS DATOS ESTÁN EN UN BYTE CADA UNO, PARA OPERAR CON ELLOS HAY QUE USAR REGISTROS DE 8 BITS (al,bl,cl,dl,ah,bh,ch,dh,...)
    tablero                 times 7 resb 7
    orientacion             resb 1 ; es un char ascii
    simboloOcas             resb 1 ; es un char ascii
    simboloZorro            resb 1 ; es un char ascii
    turnoActual             resb 1 ; es un número (0 Ocas ; 1 Zorro ; 2 Movimiento Extra del Zorro)
    ocasComidas             resb 1 ; es un número (0, 1, 2, ...)
    estadisticasZorro       times 8 resb 1 ; vector de 8 posiciones - una por cada dirección del zorro
    movimientosPosibles     times 8 resb 4 ; vector de 8 elementos (una por cada dirección posible), cada uno con 4 valores (nroMov, fila, col, comeOca?) ; el final de este vector DEBE SER INDICADO con un -1
    ; ¡IMPORTANTE! -> el vector movimientosPosibles es de tamaño variable! Siempre recorrerlo hasta encontrar el -1 (lo que sigue al -1 es basura)                                           
    finMovimientosPosibles  resb 1

    inputBuffer             resb 100
    idArchivoGuardado       resq 1
    qwordTemporal           resq 1
    filaOca                 resb 1
    colOca                  resb 1

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
    mov             rsi,95
    mov             rdx,1
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
    jmp             comenzarTurnoActual

errorPartidaCargarPartida:
    MLimpiarPantalla
    Mprintf         mensajeErrorCargarPartida
    MEnterParaContinuar
    jmp             nuevaPartida

nuevaPartida:
    ; Cargo los valores por defecto y paso al menú de personalización
    mov             al,[orientacionDefault]
    mov             [orientacion],al
    mov             al,[simboloOcasDefault]
    mov             [simboloOcas],al
    mov             al,[simboloZorroDefault]
    mov             [simboloZorro],al
    mov             al,[turnoDelZorro]
    mov             [turnoActual],al
    mov             al,0
    mov             [ocasComidas],al
    mov             al,-1
    mov             [finMovimientosPosibles],al
    mov             qword[estadisticasZorro],0 ;inicializo los 8bytes con 0

    mov             rdi,movimientosPosibles
    sub             rsp,8
    call            LimpiarMovimientosPosibles
    add             rsp,8 

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
    je              inicializarTablero
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
    mov             al,[inputBuffer]
    mov             [orientacion],al

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
    mov             al,[simboloZorro]
    cmp             al,[inputBuffer]
    je              ocasOpcionInvalida
    ; Si se ingresa un espacio (ascii 32), es inválido
    mov             al,32
    cmp             al,[inputBuffer]
    je              ocasOpcionInvalida
    ; Sino, guardo el primer caracter ingresado como nuevo simbolo para las ocas
    mov             al,[inputBuffer]
    mov             [simboloOcas],al
    jmp             personalizacionMostrar
ocasOpcionInvalida:
    Mprintf         mensajeCaracterInvalido
    jmp             ocasIngresarOpcion

personalizarZorro:
    Mprintf     mensajeIngresarSimboloZorro
zorroIngresarOpcion:
    Mgets           inputBuffer
    ; Si se ingresa el mismo símbolo que para las ocas, es inválido
    mov             al,[simboloOcas]
    cmp             al,[inputBuffer]
    je              zorroOpcionInvalida
    ; Si se ingresa un espacio (ascii 32), es inválido
    mov             al,32
    cmp             al,[inputBuffer]
    je              zorroOpcionInvalida
    ; Sino, guardo el primer caracter ingresado como nuevo simbolo para el zorro
    mov             al,[inputBuffer]
    mov             [simboloZorro],al
    jmp             personalizacionMostrar
zorroOpcionInvalida:
    Mprintf         mensajeCaracterInvalido
    jmp             zorroIngresarOpcion

inicializarTablero:
    mov     al,[orientacion]
    cmp     al,[orientacionNorte]
    je      elegirTableroNorte
    cmp     al,[orientacionSur]
    je      elegirTableroSur
    cmp     al,[orientacionEste]
    je      elegirTableroEste
    cmp     al,[orientacionOeste]
    je      elegirTableroOeste

elegirTableroNorte:
    mov     rsi,tableroNorte
    jmp     copiarTableroCorrespondiente
elegirTableroSur:
    mov     rsi,tableroSur
    jmp     copiarTableroCorrespondiente
elegirTableroEste:
    mov     rsi,tableroEste
    jmp     copiarTableroCorrespondiente
elegirTableroOeste:
    mov     rsi,tableroOeste
    jmp     copiarTableroCorrespondiente

copiarTableroCorrespondiente:
    mov     rdi,tablero
    sub     rsp,8
    call    CopiarTablero
    add     rsp,8    

comenzarTurnoActual:
    ; si [turnoActual] == 0 es el turno de las ocas
    cmp     byte[turnoActual],0
    je      turnoOcas
    ; sino ([turnoActual] == 1) es el turno del zorro
    cmp     byte[turnoActual],1
    je      turnoZorro
        ; sino ([turnoActual] == 2) es el turno extra del zorro
    cmp     byte[turnoActual],2
    je      turnoExtraZorro

turnoOcas:
    MLimpiarPantalla

    mov     rdi,movimientosPosibles
    sub     rsp,8
    call    LimpiarMovimientosPosibles
    add     rsp,8 
    mov     rdi,tablero
    sub     rsp,8
    call    MostrarTablero
    add     rsp,8 

    Mprintf controlesOcasElegirOca ;

ocasIngresarJugadaInicial:
    Mgets   inputBuffer
    mov     rdi,inputBuffer
    sub     rsp,8
    call    ValidarEntradaElegirOca 
    add     rsp,8

    cmp     al,-1
    je      ocasIngresoInvalidoInicial

    cmp     al,[caracterGuardarPartida]
    je      guardarPartida

    cmp     al,[caracterSalirDelJuego]
    je      salirDelJuego
    
    jmp     ocasElegirOca

ocasIngresoInvalidoInicial:
    Mprintf ocasEntradaInvalidaIngresoInicial ;
    jmp     ocasIngresarJugadaInicial

ocasElegirOca:
    Mprintf msjOcasElegirFila ;
ocasElegirFila:
    Mgets   inputBuffer
    
    mov     rdi,inputBuffer
    sub     rsp,8
    call    ValidarFilaColumna 
    add     rsp,8
    cmp     al,-1
    je      ocasFilaInvalida
    mov     [filaOca],al

    Mprintf msjOcasElegirCol ;
ocasElegirCol:
    Mgets   inputBuffer
    mov     rdi,inputBuffer
    sub     rsp,8
    call    ValidarFilaColumna 
    add     rsp,8
    cmp     al,-1
    je      ocasColInvalida
    mov     [colOca],al

    mov     dil,[filaOca]
    mov     sil,[colOca]
    mov     rdx,tablero
    sub     rsp,8
    call    ValidarPosicionOca 
    add     rsp,8

    cmp     al,-1
    je      ocasPosicionInvalida
    jmp     ocaCalcularMovimiento

ocasFilaInvalida:
    Mprintf msjFilaInvalida ;
    jmp     ocasElegirFila

ocasColInvalida:
    Mprintf msjColInvalida ;
    jmp     ocasElegirCol

ocasPosicionInvalida:
    Mprintf msjNoHayUnaOcaEnLaPos ;
    jmp     ocasElegirOca

ocaCalcularMovimiento:    
    mov     dil,[filaOca]
    mov     sil,[colOca]
    mov     rdx,tablero
    sub     rsp,8
    call    CalcularMovimientosOca 
    add     rsp,8
    cmp     al,-1
    je      ocaNoTieneMovimientosPosibles

    MLimpiarPantalla
    mov     rdi,tablero
    sub     rsp,8
    call    MostrarTablero
    add     rsp,8 
    
ocaPedirMovimiento:
    Mprintf msjOcaPedirMovimiento
ocaElegirMovimiento:
    Mgets   inputBuffer
    mov     rdi,inputBuffer
    mov     rsi,movimientosPosibles
    sub     rsp,8
    call    ValidarMovimientoOca 
    add     rsp,8
    cmp     rax,-1
    je      ocaMovimientoInvalido
    
    mov     dil,[filaOca]
    mov     sil,[colOca]
    mov     rdx,tablero
    mov     cl,al
    sub     rsp,8
    call    RealizarMovimientoOca
    add     rsp,8
    
    mov     byte[turnoActual],1
    jmp     verificarFinDeLaPartida

    
ocaNoTieneMovimientosPosibles:
    Mprintf msjOcaNoTieneMovimientosPosibles ;
    jmp     ocasElegirOca

ocaMovimientoInvalido:
    Mprintf msjOcaMovimientoInvalido ;
    jmp     ocaElegirMovimiento

turnoZorro:
    MLimpiarPantalla
    mov     rdi,tablero
    sub     rsp,8
    call    CalcularMovimientosZorro
    add     rsp,8 

    mov     rdi,tablero
    sub     rsp,8
    call    MostrarTablero
    add     rsp,8 

    Mprintf mostrarControlesZorro

zorroIngresarJugada:
    Mgets   inputBuffer

    mov     rdi,movimientosPosibles
    mov     rsi,inputBuffer
    sub     rsp,8
    call    ValidarEntradaTurnoZorro
    add     rsp,8

    cmp     al,-1
    je      zorroIngresoInvalido

    cmp     al,[caracterGuardarPartida]
    je      guardarPartida

    cmp     al,[caracterSalirDelJuego]
    je      salirDelJuego

    mov     rdi,tablero
    mov     sil,al
    sub     rsp,8
    call    RealizarMovimientoZorro
    add     rsp,8
    cmp     rax,0
    je      establecerTurnoDeOcas

establecerTurnoExtraZorro:
    mov     al,2
    jmp     finTurnoZorro    

establecerTurnoDeOcas:
    mov     al,0

finTurnoZorro:
    mov     [turnoActual],al
    jmp     verificarFinDeLaPartida

zorroIngresoInvalido:
    Mprintf mensajeIngresoInvalido
    jmp     zorroIngresarJugada

turnoExtraZorro:
    MLimpiarPantalla
    mov     rdi,tablero
    sub     rsp,8
    call    CalcularMovimientosZorro
    add     rsp,8 

    mov     rdi,movimientosPosibles
    sub     rsp,8
    call    FiltrarMovimientosQueNoComenOcas
    add     rsp,8 

    cmp     rax,0 ; no hay movimientos para comer más ocas
    je      establecerTurnoDeOcas

    mov     rdi,tablero
    sub     rsp,8
    call    MostrarTablero
    add     rsp,8 

    Mprintf mostrarControlesZorro
    jmp     zorroIngresarJugada

verificarFinDeLaPartida:
    MLimpiarPantalla
    ; Si ninguna oca tiene movimientos disponibles -> empate
    mov     rdi,tablero
    sub     rsp,8
    call    VerificarMovimientoOcas    ;Falta implementar: (guarda en rax 0 si no hay movimientos disponibles, 1 si hay movimientos disponibles)
    add     rsp,8
    cmp     rax,0
    je      mostrarEmpate

verificarVictoriaOcas:
    ; Si el Zorro no tiene movimientos disponibles, ganaron las Ocas
    mov     rdi,tablero
    sub     rsp,8
    call    VerificarMovimientoZorro
    add     rsp,8
    cmp     rax,0
    je      mostrarVictoriaOcas

verificarVictoriaZorro:
    ; Si quedan menos de 6 Ocas, ganó el Zorro
    mov     al,17
    sub     al,[ocasComidas]

    cmp     rax,6
    jl      mostrarVictoriaZorro

    ; No perdió nadie, ir al turno siguiente
    jmp     comenzarTurnoActual

mostrarEmpate:
    ; Mostrar empate y mostrar estadísticas de fin
    Mprintf mensajeEmpate
    jmp     mostrarEstadisticasFin

mostrarVictoriaZorro:
    ; Mostrar que ganó el Zorro y mostrar estadísticas de fin
    Mprintf mensajeGanoZorro
    jmp     mostrarEstadisticasFin

mostrarVictoriaOcas:
    ; Mostrar que ganaron las Ocas y mostrar estadísticas de fin
    Mprintf mensajeGanaronOcas
    jmp     mostrarEstadisticasFin

mostrarEstadisticasFin:
;Falta implementar
; Mostrar estadísticas de fin y finalizar el juego
    jmp     comenzarTurnoActual

guardarPartida:
    ; Abro el archivo de guardado
    mov             rdi,nombreArchivoGuardado
    mov             rsi,modoEscrituraBinario
    sub             rsp,8
    call            fopen
    add             rsp,8
    ; Si hubo un error, informo al usuario y vuelvo al juego
    cmp             rax,0
    jle             guardarPartidaError
    ; Sino, guardo la partida
    mov             qword[idArchivoGuardado],rax
    mov             rdi,registroDatosPartida
    mov             rsi,95
    mov             rdx,1
    mov             rcx,[idArchivoGuardado]
    sub             rsp,8
    call            fwrite
    add             rsp,8
    mov             qword[qwordTemporal],rax
    ; Cierro el archivo
    mov             rdi,[idArchivoGuardado]
    sub             rsp,8
    call            fclose
    add             rsp,8
    ; Si hubo un error, informo al usuario y vuelvo al juego
    mov             rax,qword[qwordTemporal]
    cmp             rax,0
    jle             guardarPartidaError
    ; Sino, voy hacia el turno correspondiente.
    Mprintf         mensajeExitoGuardarPartida
    MEnterParaContinuar
    jmp             comenzarTurnoActual

guardarPartidaError:
    Mprintf         mensajeErrorGuardarPartida
    MEnterParaContinuar
    jmp             comenzarTurnoActual

salirDelJuego:
    ret