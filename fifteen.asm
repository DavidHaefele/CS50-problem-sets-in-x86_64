;Harvard University CS50, Problem Set 3, Game Of Fifteen
;compile program with 'nasm fifteen.asm -f elf64 -o fifteen.o && ld fifteen.o -o fifteen'

STD_IN equ 0
STD_OUT equ 1
STD_ERR equ 2
SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60
BYTES_TO_READ equ 32

section .data
        str1 db "Which tile should be moved next?  ", 0
        str2 db "You won!", 10, 0
        newline db 10
        tab db 9
        array db 15,14,13,12,11,10,9,8,7,6,5,4,3,1,2,95

section .bss
        number resb BYTES_TO_READ
        digitSpace resb 100
        digitSpacePos resb 8

section .text
        global _start
        
%macro print 1
        mov rax, %1
        call _printStr
%endmacro        

%macro newline 0
        call _newLine
%endmacro

%macro getStr 1
        mov rcx, %1
        call _getString
%endmacro

%macro stringToInt 1
        mov rcx, %1
        call _stringToInt
%endmacro
        
%macro exit 0
        mov rax, SYS_EXIT
        mov rdi, STD_ERR
        syscall
        ret
%endmacro


_start:
        call _draw
        call _move
_endGame:

        exit
 
_getString:
        mov rax, SYS_READ
        mov rdi, STD_IN
        mov rsi, rcx
        mov rdx, BYTES_TO_READ
        syscall
        ret 
        
_stringToInt:
        ;input: rcx as pointer to string
        ;output: rax as integer (eax)
        mov rax, 0
        mov rsi, [rcx]
        sub sil, 48
        add rax, rsi
        inc rcx
_repeat:      
        mov rsi, [rcx]
        cmp sil, 10
        je _exitLoop
                 
        sub sil, 48
        mov rdx, 0
        mov rbx, 10
        mul rbx  
        add rax, rsi
        
        inc rcx
        jmp _repeat
_exitLoop:  
        mov rsi, 0
        mov esi, eax
        mov rax, 0
        mov eax, esi
          
        ret                
        
_newLine:
        mov rax, SYS_WRITE
        mov rdi, STD_OUT
        mov rsi, newline
        mov rdx, 1
        syscall
        ret 
        
_printTab:
        mov rax, SYS_WRITE
        mov rdi, STD_OUT
        mov rsi, tab
        mov rdx, 1
        syscall
        ret                

        
_printStr:
        push rax
        mov rbx, 0
_printStrLoop:
        inc r9
        inc rax
        inc rbx
        mov cl, [rax]
        cmp cl, 0
        jne _printStrLoop
        
        mov rax, SYS_WRITE
        mov rdi, STD_OUT
        pop rsi
        mov rdx, rbx
        syscall
        ret        


_printRAX:
        ;input: rax containing an integer value
        ;output: prints a string representing the number in rax
        mov rcx, digitSpace
        mov rbx, 0
        mov [rcx], rbx
        inc rcx
        mov [digitSpacePos], rcx
_printRAXLoop1:
        mov rdx, 0
        mov rbx, 10
        div rbx
        push rax
        add rdx, 48
        
        mov rcx, [digitSpacePos]
        mov [rcx], dl
        inc rcx
        mov [digitSpacePos], rcx
        
        pop rax
        cmp rax, 0
        jne _printRAXLoop1
_printRAXLoop2:
        mov rcx, [digitSpacePos]
        
        mov rax, SYS_WRITE
        mov rdi, STD_OUT
        mov rsi, rcx
        mov rdx, 1
        syscall
        
        mov rcx, [digitSpacePos]
        dec rcx
        mov [digitSpacePos], rcx
        
        cmp rcx, digitSpace
        jge _printRAXLoop2
        
        ret        

        
_draw:
        mov r9, array
        mov r15, 0
        mov r10, 0
        newline
        newline
_drawLoop:
        mov al, [r9]
        cmp al, 95
        je _printNothing
        
        call _printRAX
        jmp _printSomething      
_printNothing:
_printSomething:                        
        call _printTab                
        inc r9
        
        inc r10
        cmp r10, 4
        je _endl
        jmp _noendl
_endl:
        mov r10, 0
        newline  
        newline   
        newline   
_noendl:        
        inc r15
        cmp r15, 16
        jne _drawLoop

        ret   

        
_move:
        print str1
        getStr number
        stringToInt number
        mov rbx, 0
        mov bl, al
        mov rax, 0
        mov al, bl

        mov r9, array
        mov r8, 0
        mov r15, 0
_moveLoop:
        mov bl, [r9]
        
        cmp bl, al
        je _numberFound      
          
        inc r8       
        inc r9        
        inc r15
        
        cmp r15, 16
        jne _moveLoop
_numberFound:
        cmp BYTE [array+r8+1], 95
        je _spaceR
        jmp _noSpaceR
_spaceR:
        mov BYTE [array+r8+1], al
        mov BYTE [array+r8], 95
_noSpaceR:

        cmp BYTE [array+r8-1], 95
        je _spaceL
        jmp _noSpaceL
_spaceL:
        mov BYTE [array+r8-1], al
        mov BYTE [array+r8], 95
_noSpaceL:

        cmp BYTE [array+r8-4], 95
        je _spaceU
        jmp _noSpaceU
_spaceU:
        mov BYTE [array+r8-4], al
        mov BYTE [array+r8], 95
_noSpaceU:

        cmp BYTE [array+r8+4], 95
        je _spaceD
        jmp _noSpaceD
_spaceD:
        mov BYTE [array+r8+4], al
        mov BYTE [array+r8], 95
_noSpaceD:                
        call _draw
        call _check
        ret

        
_check:
        mov r8, 0
        mov r14,0
        mov rsi, 0
_checkLoop:
        mov sil, BYTE [array+r8]
        cmp sil, BYTE [array+r8+1]
        jl _solved
        jmp _unsolved
_solved:
        inc r14
_unsolved:
        cmp r14, 15
        je _won

        inc r8
        cmp r8, 16
        je _checkEnd
        jmp _checkLoop
_won:
        print str2
        jmp _endGame
_checkEnd:
        call _move
        ret        
                                
