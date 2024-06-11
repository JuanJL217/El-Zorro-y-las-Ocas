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
global VerificarMovimientoOcas
global VerificarMovimientoZorro
global ContarOcas
global CalcularMovimientosZorro
global RealizarMovimientoZorro

extern printf

section .data
    ; como se representan diferentes elementos en el tablero
    repZorro                db 2
    repOcas                 db 1
    repEspacio              db 0
    simboloEspacio          db " "
    simboloInaccesible      db "#"

    longitudFila            dq 7
    longitudElemento        dq 1

    nuevaLinea              db 10,0
    mostrarLineaColumnas    db "[ ] 1  2  3  4  5  6  7 [ ]",10,0
    mostrarElemento         db " %c ",0
    mostrarFila             db " %li ",0

    ; ANSI
    ANSIBoldOn              db 27,"[1m",0
    ANSIBoldOff             db 27,"[22m",0
    ANSIResetColor          db 27,"[0m",0
    ANSIColorMarco          db 27,"[38;5;88m",0

section .bss
    iteradorFila            resq 1
    iteradorCol             resq 1
    dirTablero              resq 1
    dirVectMovimientos      resq 1
    simboloZorro            resb 1
    simboloOcas             resb 1
    filaZorro               resq 1
    colZorro                resq 1
    movActual               resb 1

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
    cmp     qword[iteradorCol],7            ;
    jge     mostrarTableroProximaFila       ;
    mov     rax,qword[longitudElemento]
    imul    rax,qword[iteradorCol]

    mov     rbx,qword[longitudFila]
    imul    rbx,qword[iteradorFila]

    add     rax,rbx
    add     rax,[dirTablero]
                                            ; aqui ingresar lógica para cada elemento del tablero
                                            ; el elemento está cargado en el registro bl
    mov     bl,byte[rax]
    sub     rsp,8
    call    identificarSimbolo
    add     rsp,8

    Mprintf mostrarElemento,rax

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
    mov     al,[simboloInaccesible]
    ret
esEspacio:
    mov     al,[simboloEspacio]
    ret
esOca:
    mov     al,[simboloOcas]
    ret
esZorro:
    mov     al,[simboloZorro]
    ret

VerificarMovimientoOcas:
; Falta implementar
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

    mov     rdi,mostrarInt
    mov     rsi,0
    mov     sil,bl
    sub     rsp,8
    call    printf
    add     rsp,8

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

    add     rdi,62              
    mov     [dirVectMovimientos],rdi

    mov     qword[iterador],0

buscarMovEnMovPosibles:
    cmp     qword[iterador],7
    je      movNoPosible    ; (No debería pasar nunca)

    mov     rax,[iterador]
    imul    rax,4           ; long. de elemento de vectorMovimientos
    add     rax,[dirVectMovimientos]
    mov     bl,byte[rax]    ; bl = nro de mov posible
    cmp     bl,-1
    je      movNoPosible    ; (No debería pasar nunca)
    cmp     bl,sil
    je      movEncontrado

    inc     qword[iterador]
    jmp     buscarMovEnMovPosibles

movNoPosible:
    ret

movEncontrado:
    ; guardo la posición del movimiento actual
    mov     [dirVectMovimientos],rax

    ; saco el zorro de su posición anterior.
    mov     r8,[filaZorro] ;fila guardada como qword
    imul    r8,[longitudFila]
    mov     r9,[colZorro] ;columna guardada como qword
    imul    r9,[longitudElemento]
    add     r8,r9
    add     r8,tablero

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
    add     r8,tablero

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
    add     r8,tablero

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

