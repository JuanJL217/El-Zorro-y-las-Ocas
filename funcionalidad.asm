%macro Mprintf 1
    mov     rdi,%1
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro
%macro Mprintf 2
    mov     rdi,%1
    mov     rsi,%2
    sub     rsp,8
    call    printf
    add     rsp,8
%endmacro

global CopiarTablero
global MostrarTablero
global VerificarMovimientoOcas ; verifica si hay movimientos posibles para las ocas en el tablero. si no hay movimientos posibles, devuelve 0 en el rax. si hay movimientos posibles, devuelve 1 en el rax.
global VerificarMovimientoZorro
global ContarOcas
global CalcularMovimientosZorro
global RealizarMovimientoZorro
global FiltrarMovimientosQueNoComenOcas
global RealizarMovimientoOca ; mueve la oca en el tablero según el movimiento ingresado en el sil.
global CalcularMovimientosOca ; calcula los movimientos de la oca en la pos (dil,sil) y los carga en el vector movimientosPosibles. Si no hay ningun movimiento posible, devuelve -1 en el rax.
global LimpiarMovimientosPosibles
global SiEsValidoMovAlmacenar

extern printf

section .data
    ; como se representan diferentes elementos en el tablero
    repZorro                db 2
    repOcas                 db 1
    repEspacio              db 0
    simboloEspacio          db " "
    simboloInaccesible      db "#"
    caracterNorte           db 'N'
    caracterOeste           db 'O'
    caracterEste            db 'E'
    caracterSur             db 'S'

    longitudFila            dq 7
    longitudElemento        dq 1

    nuevaLinea              db 10,0
    mostrarLineaColumnas    db "[ ] 1  2  3  4  5  6  7 [ ]",10,0
    mostrarElemento         db " %c ",0
    mostrarFila             db " %li ",0

    ; ANSI
    ANSIBoldOn                      db 27,"[1m",0
    ANSIItalicOn                    db 27,"[3m",0
    ANSIBoldOff                     db 27,"[22m",0
    ANSIItalicOff                   db 27,"[23m",0
    ANSIResetColor                  db 27,"[0m",0
    
    ANSIColorOcas                   db 27,"[38;5;24m",0
    ANSIColorZorro                  db 27,"[38;5;88m",0
    ANSIColorInaccesible            db 27,"[38;5;231m",0
    ANSIColorMarco                  db 27,"[38;5;255m",0
    ANSIColorMostrarMovimiento      db 27,"[38;5;8m",0

section .bss
    iteradorFila            resq 1
    iteradorCol             resq 1
    dirTablero              resq 1
    dirVectMovimientos      resq 1
    dirVectEstadisticas     resq 1
    simboloZorro            resb 1
    simboloOcas             resb 1
    filaZorro               resq 1
    colZorro                resq 1
    movActual               resb 1
    contador                resq 1
    numActual               resq 1
    iterador                resq 1
    orientacion             resb 1


section .text

; copia los 49 bytes comenzando por la direccion en rsi (source)
; a los 49 bytes comenzando por la direccion en rdi (destintation)
CopiarTablero:
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

; busca la posición del zorro en el tablero que incia en la direccion rdi
; devuelve la fila en rax y la columna en rbx
; devuelve valores para usar directamente en código, es decir números entre 0 y 6
; si no se encuentra el zorro, devuelve -1 en rax (no debería pasar nunca)
buscarZorro:
    mov     qword[iteradorFila],0
    mov     qword[iteradorCol],0
buscarZorroBucle:
    cmp     qword[iteradorCol],7
    jge     buscarZorroProximaFila

    mov     rax,qword[longitudElemento]
    imul    rax,qword[iteradorCol]

    mov     rbx,qword[longitudFila]
    imul    rbx,qword[iteradorFila]

    add     rax,rbx
    add     rax,rdi

    mov     bl,byte[rax]
    cmp     bl,[repZorro]
    je      buscarZorroEncontrado

    inc     qword[iteradorCol]
    jmp     buscarZorroBucle

buscarZorroProximaFila:
    cmp     qword[iteradorFila],7
    jge     buscarZorroNoEncontrado
    inc     qword[iteradorFila]
    mov     qword[iteradorCol],0
    jmp     buscarZorroBucle

buscarZorroNoEncontrado:
    mov     rax,-1
    ret
    
buscarZorroEncontrado:
    mov     rbx,[iteradorCol]
    mov     rax,[iteradorFila]
    ret

; recibe en rdi la direccion del tablero
;
MostrarTablero:
    mov     [dirTablero],rdi
    add     rdi,50 ; simbolo ocas
    mov     al,[rdi]
    mov     [simboloOcas],al
    add     rdi,1 ; simbolo zorro
    mov     al,[rdi]
    mov     [simboloZorro],al
    add     rdi,11 ; me muevo hasta la posicion de movimientos posibles
    mov     [dirVectMovimientos],rdi

    Mprintf ANSIColorMarco
    Mprintf mostrarLineaColumnas
    Mprintf ANSIResetColor
                                            ; marco las líneas que se pueden copiar y pegar para hacer
    mov     qword[iteradorFila],0           ; la estructura de un loop que itera sobre todo el tablero
    mov     qword[iteradorCol],0            ;
   
    Mprintf ANSIColorMarco
    mov     r8,[iteradorFila]
    inc     r8
    Mprintf mostrarFila,r8
    Mprintf ANSIResetColor

mostrarTableroLoop:
    cmp    qword[iteradorCol],7
    je     mostrarTableroProximaFila

    sub     rsp,8
    call    buscarFilColEnMovPosibles
    add     rsp,8

    cmp     rax,0
    je      mostrarElementoEnTablero

    mov     rdx,qword[longitudElemento]
    imul    rdx,qword[iteradorCol]

    mov     rbx,qword[longitudFila]
    imul    rbx,qword[iteradorFila]

    add     rdx,rbx
    add     rdx,[dirTablero]
                                            ; aqui ingresar lógica para cada elemento del tablero
                                            ; el elemento está cargado en el registro bl
    mov     bl,byte[rdx]
    sub     rsp,8
    call    identificarSimbolo
    add     rsp,8

mostrarElementoEnTablero:
    Mprintf mostrarElemento,rdx
    Mprintf ANSIResetColor
    Mprintf ANSIItalicOff

    inc     qword[iteradorCol]              ;
    jmp     mostrarTableroLoop              ;

mostrarTableroProximaFila:                  ;
    Mprintf ANSIColorMarco
    mov     r8,[iteradorFila]
    inc     r8
    Mprintf mostrarFila,r8
    Mprintf ANSIResetColor
    Mprintf nuevaLinea

    inc     qword[iteradorFila]             ;
    mov     qword[iteradorCol],0            ;

    cmp     qword[iteradorFila],7           ;
    jge     mostrarTableroFin               ;

    Mprintf ANSIColorMarco
    mov     r8,[iteradorFila]
    inc     r8
    Mprintf mostrarFila,r8
    Mprintf ANSIResetColor

    jmp     mostrarTableroLoop              ;

mostrarTableroFin:
    Mprintf ANSIColorMarco
    Mprintf mostrarLineaColumnas
    Mprintf ANSIResetColor
    ret

;   en bl está el código del elemento en tablero
;   devuelve en al el caracter que representa ese elemento
identificarSimbolo:
    mov     rax,0
    cmp     bl,-1
    je      esInaccesible
    cmp     bl,0
    je      esEspacio
    cmp     bl,1
    je      esOca
    cmp     bl,2
    je      esZorro
esInaccesible:
    Mprintf ANSIColorInaccesible
    mov     dl,[simboloInaccesible]
    ret
esEspacio:
    mov     dl,[simboloEspacio]
    ret
esOca:
    Mprintf ANSIColorOcas
    mov     dl,[simboloOcas]
    ret
esZorro:
    Mprintf ANSIColorZorro
    mov     dl,[simboloZorro]
    ret

VerificarMovimientoOcas:
; Falta implementar
    mov     rax,1
    ret

; recibe en rdi la dirección del tablero
; guarda en rax 0 si no hay movimientos disponibles, 1 si hay movimientos disponibles
VerificarMovimientoZorro:
    mov     [dirTablero],rdi     
    
    sub     rsp,8
    call    CalcularMovimientosZorro
    add     rsp,8

    mov     rdi,[dirTablero]
    add     rdi,62              
    mov     [dirVectMovimientos],rdi

    mov     al,byte[dirVectMovimientos]
    cmp     al,-1
    je      zorroNoTieneMovimientosDisponibles
    mov     rax,1
    ret

zorroNoTieneMovimientosDisponibles:
    mov     rax,0
    ret

; rdi = tablero
; guarda en movimientosPosibles los movimientos que puede realizar el zorro desde su posición
CalcularMovimientosZorro:
    mov     [dirTablero],rdi
    sub     rsp,8
    call    buscarZorro
    add     rsp,8
    mov     [filaZorro],rax
    mov     [colZorro],rbx

    add     rdi,62              
    ; rdi = movimientosPosibles
    mov     [dirVectMovimientos],rdi

    mov     qword[iteradorFila],-1
    mov     qword[iteradorCol],-1
    mov     byte[movActual],1

movimientoFilaBucle:
    cmp     qword[iteradorCol],1
    jg      movimientoProxFila

    ; rax = (c + j)
    mov     rax,qword[colZorro]
    add     rax,qword[iteradorCol]

    ; si salgo de la matriz, sig movimiento
    cmp     rax,0
    jl      calcProxMov
    cmp     rax,6
    jg      calcProxMov

    imul    rax,qword[longitudElemento]
    
    ; rbx = (f + i)
    mov     rbx,qword[filaZorro]
    add     rbx,qword[iteradorFila]
    
    ; si salgo de la matriz, sig fila
    cmp     rbx,0
    jl      movimientoProxFila
    cmp     rbx,6
    jg      movimientoProxFila

    imul    rbx,qword[longitudFila]

    add     rax,rbx
    add     rax,[dirTablero]
    mov     bl,byte[rax]

    cmp     bl,0
    jne     verSiComeOca
    
    ; hay un movimiento que no come oca
    mov     rbx,[dirVectMovimientos]
    mov     al,byte[movActual]
    mov     byte[rbx],al
    ; rax = (f + i)
    mov     rax,qword[filaZorro]
    add     rax,qword[iteradorFila]
    mov     byte[rbx+1],al
    ; rax = (c + j)
    mov     rax,qword[colZorro]
    add     rax,qword[iteradorCol]  
    mov     byte[rbx+2],al

    mov     byte[rbx+3],0

    mov     rax,[dirVectMovimientos]
    add     rax,4
    mov     [dirVectMovimientos],rax
    jmp     calcProxMov

verSiComeOca:
    cmp     bl,1
    jne     calcProxMov

    ; rax = j*2 + c
    mov     rax,qword[iteradorCol]
    imul    rax,2
    add     rax,qword[colZorro]

    ; si salgo de la matriz, sig movimiento
    cmp     rax,0
    jl      calcProxMov
    cmp     rax,6
    jg      calcProxMov

    imul    rax,qword[longitudElemento]

    ; rbx = i*2 + f
    mov     rbx,qword[iteradorFila]
    imul    rbx,2
    add     rbx,qword[filaZorro]

    ; si salgo de la matriz, sig fila
    cmp     rbx,0
    jl      movimientoProxFila
    cmp     rbx,6
    jg      movimientoProxFila


    imul    rbx,qword[longitudFila]
        
    add     rax,rbx
    add     rax,[dirTablero]
    mov     bl,byte[rax]
    cmp     bl,0
    jne     calcProxMov
    ; hay un movimiento que si come oca
    mov     rbx,[dirVectMovimientos]
    mov     al,byte[movActual]
    mov     byte[rbx],al
    ; rbx = (f + 2i)
    mov     rax,0
    mov     rax,qword[iteradorFila]
    imul    rax,2
    add     rax,qword[filaZorro]
    mov     byte[rbx+1],al
    ; rax = (c + 2j)
    mov     rax,0
    mov     rax,qword[iteradorCol] 
    imul    rax,2
    add     rax,qword[colZorro]
    mov     byte[rbx+2],al

    mov     byte[rbx+3],1

    mov     rax,[dirVectMovimientos]
    add     rax,4
    mov     [dirVectMovimientos],rax

    jmp     calcProxMov

calcProxMov:
    inc     qword[iteradorCol]
    inc     byte[movActual]
    jmp     movimientoFilaBucle
movimientoProxFila:
    inc     qword[iteradorFila]
    cmp     qword[iteradorFila],1
    jg      finCalcMovimientos
    
    mov     qword[iteradorCol],-1
    jmp     movimientoFilaBucle

finCalcMovimientos:
    mov     rbx,[dirVectMovimientos]
    mov     byte[rbx],-1
    ret

; rdi = tablero
; sil = nroMov (validado previamente)
; actualiza la posición del zorro según el numero de movimiento ingresado (debe ser valido)
; si NO comio una oca, devuelve 0 en rax
; si comio una oca, actualiza ocasComidas y devuelve en rax 1 
RealizarMovimientoZorro:
    mov     [dirTablero],rdi
    sub     rsp,8
    call    buscarZorro
    add     rsp,8
    mov     [filaZorro],rax
    mov     [colZorro],rbx
    add     rdi,54
    mov     [dirVectEstadisticas],rdi
    add     rdi,8             
    mov     [dirVectMovimientos],rdi
    mov     [movActual],sil

    mov     rax,[dirVectMovimientos]
zorroBuscarMovEnMovPosibles:

    mov     bl,byte[rax]    ; bl = nro de mov posible
    cmp     bl,-1
    je      movNoPosible    ; (No debería pasar nunca)
    cmp     bl,sil
    je      movEncontrado

    add     rax,4           ; siguiente movimientoPosible
    jmp     zorroBuscarMovEnMovPosibles

movNoPosible:
    ret

movEncontrado:
    ; guardo la posición del movimiento actual
    mov     [dirVectMovimientos],rax

agregarEstadistica:
    cmp     byte[movActual],5
    jl      restarUno
    dec     byte[movActual]
restarUno:
    dec     byte[movActual]
    mov     rax,0
    mov     al,byte[movActual]
    add     rax,[dirVectEstadisticas]
    inc     byte[rax]

    ; saco el zorro de su posición anterior.
    mov     r8,[filaZorro] ;fila guardada como qword
    imul    r8,[longitudFila]
    mov     r9,[colZorro] ;columna guardada como qword
    imul    r9,[longitudElemento]
    add     r8,r9
    add     r8,[dirTablero]

    mov     al,byte[repEspacio]
    mov     byte[r8],al ; dejo un espacio en la posición del zorro

    ; pongo el zorro en la nueva posición.
    mov     rax,[dirVectMovimientos]
    mov     r8,0
    mov     r8b,[rax+1]         ;fila guardada como byte
    imul    r8,[longitudFila]
    mov     r9,0
    mov     r9b,[rax+2]          ;columna guardada como byte
    imul    r9,[longitudElemento]
    add     r8,r9
    add     r8,[dirTablero]

    mov     bl,byte[repZorro]
    mov     byte[r8],bl

    ; verifico si fue un movimiento para comer una oca
    ; si lo fue, remuevo la oca de su lugar e incremento
    ; la variable ocasComidas
    mov     r11b,[rax+3]
    cmp     r11b,0        ; 1=movComerOca 0=movNormal
    je      finRealizarMovimiento
    ; calculo la posicion de la oca comida como
    ; (anteriorPosZorro + nuevaPosZorro) / 2
    mov     rax,[dirVectMovimientos]
    mov     r8,0
    mov     r8b,[rax+1]
    add     r8,[filaZorro]

    mov     rdx,0
    mov     rax,r8
    mov     r10,2
    idiv    r10
    mov     r8,rax

    imul    r8,[longitudFila]

    mov     rax,[dirVectMovimientos]
    mov     r9,0
    mov     r9b,[rax+2]
    add     r9,[colZorro]

    mov     rdx,0
    mov     rax,r9
    mov     r10,2
    idiv    r10
    mov     r9,rax

    imul    r9,[longitudElemento]
    add     r8,r9
    add     r8,[dirTablero]

    mov     bl,byte[repEspacio]
    mov     byte[r8],bl

    mov     rax,[dirTablero]
    add     rax,53 ; rax = dirOcasComidas
    mov     bl,byte[rax]
    inc     bl
    mov     byte[rax],bl

finRealizarMovimiento:
    mov     rax,0
    mov     al,r11b

    ret

; recibe en rdi el vector movimientosPosibles
; debe guardar en movimientosPosibles sólo los movimientos posibles que sean para comer ocas.
; devuelve en el rax la cantidad de movimientos que comen ocas disponibles.
; si no hay movimientos disponibles para comer ocas, devuelve 0.
FiltrarMovimientosQueNoComenOcas:
    mov     [dirVectMovimientos],rdi
    mov     qword[contador],0

buscarMovimientosComedores:
    cmp     byte[rdi],-1
    je      finBuscarMovimientosComedores

    cmp     byte[rdi+3],1
    jne     sigMovimiento

    inc     qword[contador]
    mov     eax,dword[rdi]
    mov     rbx,[dirVectMovimientos]
    mov     [rbx],eax
    add     qword[dirVectMovimientos],4

sigMovimiento:
    add     rdi,4
    jmp     buscarMovimientosComedores

finBuscarMovimientosComedores:
    cmp     qword[contador],0
    je      finFiltrarMovimientos
    ; si había movimientos para comer ocas, actualizo el final del vector movimientoPosibles
    mov     rbx,[dirVectMovimientos]
    add     rbx,4
    mov     byte[rbx],-1

finFiltrarMovimientos:
    mov     rax,qword[contador]
    ret



;Busca en el vector de movimientos posibles si está la posicion actual de la matriz
;numero representado como ASCII del movimiento correspondiente en el registro rdx y un 0 en rax
;rax = -1 si no encontro la posicion
buscarFilColEnMovPosibles:
    Mprintf ANSIColorMostrarMovimiento
    Mprintf ANSIItalicOn
    mov     qword[iterador],0
    mov     rax,-1 ;por default no se encuentra nada
    mov     rbx,0  ;limpio los registros por las dudas
    mov     rcx,0 

buscarFilColEnMovPosiblesLoop:

    mov     rcx,[iterador]
    imul    rcx,4 
    add     rcx,[dirVectMovimientos]
    mov     bl,byte[rcx]
    cmp     bl,-1                       ;se llego al final del vector de movimientos
    je      finalizarBusquedaSinMovimiento

    mov     [numActual],bl

    mov     rbx,[iteradorFila]
    cmp     bl,byte[rcx+1]
    jne     incrementarIterador

    mov     rbx,[iteradorCol]
    cmp     bl,byte[rcx+2]
    jne     incrementarIterador

    add     qword[numActual],48         ; para representar el numero como caracter
    mov     rdx,[numActual]
    mov     rax,0
    jmp     finalizarBusqueda

incrementarIterador:
    inc     qword[iterador]
    jmp     buscarFilColEnMovPosiblesLoop

finalizarBusquedaSinMovimiento:
    Mprintf ANSIResetColor
finalizarBusqueda:
    mov     qword[iterador],0
    ret

LimpiarMovimientosPosibles:
    mov     byte[rdi],-1
    inc     rdi

    mov     rcx,31
loopLimpiarMovimientosPosibles:
    mov     byte[rdi],0
    inc     rdi
    loop    loopLimpiarMovimientosPosibles
    ret

RealizarMovimientoOca:
    mov     [dirTablero],rdx
    add     rdx,62
    mov     [dirVectMovimientos],rdx
    mov     [movActual],cl
    ; dil = [filaOca]
    ; sil = [colOca]
    mov     rax,[dirVectMovimientos]
ocaBuscarMovEnMovPosibles:

    mov     bl,byte[rax]    ; bl = nro de mov posible
    cmp     bl,-1
    je      movNoPosible    ; (No debería pasar nunca)
    cmp     bl,[movActual]
    je      ocaMovEncontrado

    add     rax,4           ; siguiente movimientoPosible
    jmp     ocaBuscarMovEnMovPosibles

ocaMovEncontrado:
    mov     r8,0
    mov     r8b,[rax+1]          ;nuevaFila guardada como byte
    imul    r8,[longitudFila]
    mov     r9,0
    mov     r9b,[rax+2]          ;nuevaCol guardada como byte
    imul    r9,[longitudElemento]
    add     r8,r9
    add     r8,[dirTablero]

    mov     al,byte[repOcas]
    mov     byte[r8],al ; dejo una oca en la nueva pos

    ; saco la oca de su posición anterior.
    mov     r8,0
    mov     r8b,dil ;anteriorFila guardada como qword
    imul    r8,[longitudFila]
    mov     r9,0
    mov     r9b,sil ;anteriorColumna guardada como qword
    imul    r9,[longitudElemento]
    add     r8,r9
    add     r8,[dirTablero]

    mov     al,byte[repEspacio]
    mov     byte[r8],al ; dejo un espacio en la anterior pos
    ret

CalcularMovimientosOca:
    ; precondicion: el vectorMovimientos debe estar previamente limpio (todos ceros, excepto el primer byte que debe ser -1)
    ; calcula los movimientos de la oca en la pos (dil,sil) y los carga en el vector movimientosPosibles. Si no hay ningun movimiento posible, devuelve -1 en el al.
    ; Set inicial de dirTablero, dirVectMovimientos, orientacion, iterador
    mov     [dirTablero],rdx
    add     rdx,62
    mov     [dirVectMovimientos],rdx
    mov     qword[iterador],2
    mov     rdx,[dirTablero]
    add     rdx,49

    mov     al,[rdx]
    mov     [orientacion],al


    ;Recorro las cuatro posiciones cardinales de la oca para ver si incluir o no ese movimiento
    dec     dil
    sub     rsp,8
    call    SiEsValidoMovAlmacenar
    add     rsp,8

    inc     dil
    dec     sil
    sub     rsp,8
    call    SiEsValidoMovAlmacenar
    add     rsp,8

    add     sil,2
    sub     rsp,8
    call    SiEsValidoMovAlmacenar
    add     rsp,8

    inc     dil
    dec     sil
    sub     rsp,8
    call    SiEsValidoMovAlmacenar
    add     rsp,8

    dec     dil

    mov     rax,0 ; Hacer que devuelva -1 en el rax si no tiene mov disponibles
    mov     r8,[dirVectMovimientos]
    mov     al,[r8]
    mov     byte[r8],-1
    ret

SiEsValidoMovAlmacenar: 
    mov     rdx,[dirTablero]
    mov     rax,0                 ; rax = fila
    mov     al,dil
    mov     rcx,0                 ; rcx = columna
    mov     cl,sil 

    cmp     al,0
    jl      IngresoInvalido
    cmp     al,6
    jg      IngresoInvalido
    cmp     cl,0
    jl      IngresoInvalido
    cmp     cl,6
    jg      IngresoInvalido

    mov     r9,0
    mov     r9b,[orientacion]   
    cmp     r9b,[caracterNorte]
    je      NorteNoValido
    cmp     r9b,[caracterOeste]
    je      OesteNoValido
    cmp     r9b,[caracterEste]
    je      EsteNoValido
    cmp     r9b,[caracterSur]
    je      SurNoValido
EsValidaOrientacion:

    imul    rax,[longitudFila]
    imul    rcx,[longitudElemento]
    add     rax,rcx
    add     rdx,rax

    mov     al,[repEspacio]
    cmp     al,[rdx]
    jne     IngresoInvalido

AlmacenarMovOca:
    mov     rbx,0 ;
    mov     rbx,qword[iterador]
    mov     r10,[dirVectMovimientos]

    mov     byte[r10],bl
    mov     byte[r10+1],dil
    mov     byte[r10+2],sil
    mov     byte[r10+3],0

    add     qword[iterador],2
    add     qword[dirVectMovimientos],4
    ret

IngresoInvalido:
    add     qword[iterador],2
    ret

NorteNoValido:
    cmp     qword[iterador],2
    je      IngresoInvalido
    jmp     EsValidaOrientacion

OesteNoValido:
    cmp     qword[iterador],4
    je      IngresoInvalido
    jmp     EsValidaOrientacion

EsteNoValido:
    cmp     qword[iterador],6
    je      IngresoInvalido
    jmp     EsValidaOrientacion

SurNoValido:
    cmp     qword[iterador],8
    je      IngresoInvalido
    jmp     EsValidaOrientacion

