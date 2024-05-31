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

;   recibe en rdi la posicion de inicio del tablero
;   actualiza el vector movimientosPosibles con los movimientos posibles para el zorro
;   movimientos posibles:
;   1: arriba izq, 2: arriba, 3: arriba der
;   4: izquierda ,          , 6: derecha
;   7: abajo  izq, 8: abajo , 9: abajo  der
;   si el número almacenado es positivo, es un movimiento común.
;   si es negativo, es un movimiento para comer una oca.
CalcularMovimientosZorro:
    mov     [dirTablero],rdi
    add     rdi,69 ; rdi ahora apunta al primer elemento del vector movimientosPosibles
    mov     [dirVectMovimientos],rdi

VerificarMovimientoOcas:
; Falta implementar
    ret

VerificarMovimientoZorro:
; Falta implementar
    ret

ContarOcas:
; Falta implementar
    ret