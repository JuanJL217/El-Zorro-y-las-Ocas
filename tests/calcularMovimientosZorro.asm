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

global main
extern printf

section .data
    ; -1 espacios inaccesibles | 0 espacio | 1 oca | 2 zorro 
    tableroNorte                db -1,-1, 1, 1, 1,-1,-1
    tableroNorte1               db -1,-1, 1, 1, 1,-1,-1
    tableroNorte2               db  1, 1, 0, 1, 1, 1, 1
    tableroNorte3               db  1, 0, 1, 0, 0, 0, 1
    tableroNorte4               db  1, 1, 2, 0, 0, 0, 1
    tableroNorte5               db -1,-1, 0, 1, 0,-1,-1
    tableroNorte6               db -1,-1, 1, 1, 0,-1,-1


    repZorro                    db 2

    longitudFila                dq 7
    longitudElemento            dq 1
    newLine                     db 10,0
    mostrarInt                  db "%hhi ",0
    simboloEspacio              db ' '
    simboloZorro                db 'X'
    simboloOcas                 db 'O'
    simboloInaccesible          db '#'
    nuevaLinea              db 10,0
    mostrarLineaColumnas    db "[ ] 1  2  3  4  5  6  7 [ ]",10,0
    mostrarElemento         db " %c ",0
    mostrarFila             db " %li ",0
    mostrarMovimientoPosible db "nro: %hhi , fil: %hhi , col: %hhi , come oca?: %hhi",10,0
    mostrarBL               db "BL: %hhi - -",0
    mostrarPosZorro         db "filaZorro: %li colZorro: %li",10,0                
    ; ANSI
    ANSIBoldOn              db 27,"[1m",0
    ANSIBoldOff             db 27,"[22m",0
    ANSIResetColor          db 27,"[0m",0
    ANSIColorMarco          db 27,"[38;5;88m",0


section .bss
    tablero                 times 7 resb 7
    orientacion             resb 1 ; es un char ascii
    simboloOcasC            resb 1 ; es un char ascii
    simboloZorroC           resb 1 ; es un char ascii
    turnoActual             resb 1 ; es un número (0 Ocas ; 1 Zorro)
    ocasComidas             resb 1 ; es un número (0, 1, 2, ...)
    estadisticasZorro       times 8 resb 1 ; vector de 8 posiciones - una por cada dirección del zorro
    movimientosPosibles     times 8 resb 4 ; vector de 8 elementos, cada uno con 4 valores - una por cada dirección posible
    ; (nroMov, filMov, colMov, comeOca?)
    ; (nroMov, filMov, colMov, comeOca?)
    ; (nroMov, filMov, colMov, comeOca?)
    ; (nroMov, filMov, colMov, comeOca?)
    ; (nroMov, filMov, colMov, comeOca?)

    movActual               resb 1
    iterador                resq 1
    fila                    resq 1
    iteradorFila            resq 1
    iteradorCol             resq 1
    dirTablero              resq 1
    dirVectMovimientos      resq 1
    filaZorro               resq 1
    colZorro                resq 1
    acumuladorBL            resb 10

section .text

main:
    mov     rsi,tableroNorte
    mov     rdi,tablero
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
    
mostrarResultadoAntes:
    cmp     qword[iterador],8
    jge     finMostrar
    
    mov     rax,[iterador]
    imul    rax,4
    add     rax,movimientosPosibles

    mov     rdi,mostrarMovimientoPosible
    mov     rsi,[rax]
    mov     rdx,[rax+1]
    mov     rcx,[rax+2]
    mov     r8,[rax+3]
    sub     rsp,8
    call    printf
    add     rsp,8

    inc     qword[iterador]
    jmp     mostrarResultadoAntes
finMostrar:

    mov     rdi,tablero
    sub     rsp,8
    call    CalcularMovimientosZorro
    add     rsp,8

    mov     rdi,newLine
    sub     rsp,8
    call    printf
    add     rsp,8
    mov     qword[iterador],0
mostrarResultado:
    cmp     qword[iterador],8
    jge     finPrograma
    
    mov     rax,[iterador]
    imul    rax,4
    add     rax,movimientosPosibles

    mov     rdi,mostrarMovimientoPosible
    mov     rsi,[rax]
    mov     rdx,[rax+1]
    mov     rcx,[rax+2]
    mov     r8,[rax+3]
    sub     rsp,8
    call    printf
    add     rsp,8

    inc     qword[iterador]
    jmp     mostrarResultado
finPrograma:

    ret

; rdi = tablero
CalcularMovimientosZorro:
    mov     [dirTablero],rdi
    sub     rsp,8
    call    buscarZorro
    add     rsp,8
    mov     [filaZorro],rax
    mov     [colZorro],rbx

    mov     rdi,[dirTablero]
    add     rdi,62              
    ; rdi = movimientosPosibles
    mov     [dirVectMovimientos],rdi

    mov     rdi,mostrarPosZorro
    mov     rsi,[filaZorro]
    mov     rdx,[colZorro]
    sub     rsp,8
    call    printf
    add     rsp,8

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
    ; rbx = (f + i)
    mov     rax,qword[filaZorro]
    add     rax,qword[iteradorFila]
    mov     byte[rbx+1],al
    ; rax = (c + j)
    mov     rax,qword[colZorro]
    add     rax,qword[iteradorCol]  
    mov     byte[rbx+2],al

    mov     byte[rbx+3],0

    mov     rax,[rbx]
    add     rax,4
    mov     [rbx],rax
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
    inc     byte[movActual]
    jmp     movimientoFilaBucle

finCalcMovimientos:
    ret



acumularBL:
    mov     r9,0
    mov     r9b,byte[movActual]
    dec     r9b
    add     r9,acumuladorBL
    mov     [r9],bl
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