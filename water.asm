;Harvard University CS50 Problem Set 1, Smart Water
;program calculates water usage of shower per minute in bottles
;compile program with 'nasm water.asm -f elf64 -o water.o && ld water.o -o water'

STD_IN equ 0
STD_OUT equ 1
STD_ERR equ 2
SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60
BYTES_TO_READ equ 4

section .data
        msg1 db "How many minutes does it take for you to shower? ", 10, 0
        str1 db "minutes: ", 0
        str2 db "bottles: ", 0

section .bss
        string resb BYTES_TO_READ
        digitSpace resb 100
        digitSpacePos resb 8

section .text
        global _start

%macro print 1
        mov rax, %1
        call _printStr
%endmacro

%macro stringToInt 1
        mov rcx, %1
        call _stringToInt
%endmacro

%macro exit 0
        mov rax, SYS_EXIT
        mov rdi, STD_ERR        
        syscall
%endmacro
        
_start:
        print msg1
        print str1
        call _getString
        stringToInt string
        call _calcBottles
        push rax
        print str2
        pop rax
        call _printRAX

        exit

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
        
_getString:
        mov rax, SYS_READ
        mov rdi, STD_IN
        mov rsi, string
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
        
_calcBottles:
        ;input: rax containing duration of showering in minutes
        ;output: rax containing number of used bottles
        mov rdx, 0
        mov rcx, 12
        mul rcx
        ret
        
_printRAX:
        ;input: rax containing an integer value
        ;output: prints a string representing a number
        mov rcx, digitSpace
        mov rbx, 10
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
