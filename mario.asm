;Harvard University CS50, Problem Set 1, Mario
;program draws a half-pyramid with user-defined height 
;compile program with 'nasm mario.asm -f elf64 -o mario.o && ld mario.o -o mario'

STD_IN equ 0
STD_OUT equ 1
STD_ERR equ 2
SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60
BYTES_TO_READ equ 3

section .data
        str1 db "height: ", 0
        hash db "#", 0
        space db " ", 0
        newline db 10

section .bss
        number resb BYTES_TO_READ

section .text
        global _start
        
%macro print 1
        mov rax, %1
        call _printStr
%endmacro        

%macro newline 0
        call _newLine
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
        print str1
        call _getString
        newline
        
        stringToInt number
        call _drawPyramid

        exit
 
_getString:
        mov rax, SYS_READ
        mov rdi, STD_IN
        mov rsi, number
        mov rdx, BYTES_TO_READ
        syscall
        ret
                
_stringToInt:
        ;input: rcx as pointer to string
        ;output: lower 8 bytes of rax as integer 
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
        mov sil, al
        mov rax, 0
        mov al, sil
          
        ret        
        
_newLine:
        mov rax, SYS_WRITE
        mov rdi, STD_OUT
        mov rsi, newline
        mov rdx, 1
        syscall
        ret        
        
_printStr:
        push rax
        mov rbx, 0
_printStrLoop:
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
        
_drawPyramid:
        ;input: rax containg an integer specifying the pyramid's height
        ;output: draws a half-pyramid with user-defined height
        mov r10, rax
        mov r9, rax
        mov r8, rax    
        mov r12, 0 
        mov r15, 1
        ;loop printing lines
_loop1:
        dec r10
        
        dec r9
        cmp r9, 0
        je _hop1

        ;loop printing spaces        
        mov r8, r9
_loop2:
        dec r8
        print space
        cmp r8, 0   
        jne _loop2
_hop1:   
        inc r15 
        cmp r15, rax
        je _hop2
        
        ;loop printing hashes        
        mov r12, r15
_loop3:
        dec r12
        print hash
        cmp r12, 0   
        jne _loop3
_hop2:        
        newline
        cmp r10, 0
        jne _loop1   
        ret                                                     
