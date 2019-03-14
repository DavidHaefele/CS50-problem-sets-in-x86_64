;Harvard University CS50, Problem Set 2, Vigenere
;program encrypts a plaintext with the vigenere cipher
;compile program with 'nasm vigenere.asm -f elf64 -o vigenere.o && ld vigenere.o -o vigenere'

STD_IN equ 0
STD_OUT equ 1
STD_ERR equ 2
SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60
BYTES_TO_READ1 equ 32
BYTES_TO_READ2 equ 128

section .data
        str1 db "Enter a secret key: ", 0
        str2 db "Enter a plaintext: ", 0
        errStr db "Please enter a key containing only alphabetical characters!", 0
        newline db 10

section .bss
        keyword resb BYTES_TO_READ1
        plaintext resb BYTES_TO_READ2
        ciphertext resb BYTES_TO_READ2

section .text
        global _start
        
%macro print 1
        mov rax, %1
        call _printStr
%endmacro        

%macro newline 0
        call _newLine
%endmacro

%macro getStr 2
        mov rcx, %1
        mov rbx, %2
        call _getString
%endmacro
        
%macro exit 0
        mov rax, SYS_EXIT
        mov rdi, STD_ERR
        syscall
        ret
%endmacro

_start:
        print str1
        getStr keyword, BYTES_TO_READ1
        
        print str2
        getStr plaintext, BYTES_TO_READ2
        newline
        
        call _encrypt
        print ciphertext
_catch:        
        newline
        
        exit
 
_getString:
        mov rax, SYS_READ
        mov rdi, STD_IN
        mov rsi, rcx
        mov rdx, rbx
        syscall
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
        
_encrypt:
        ;input: rcx as pointer to plaintext and rbx containing the encryption key
        ;output: rsi as pointer to ciphertext
        mov rbx, keyword
        mov rcx, plaintext
        mov rsi, ciphertext
        mov rax, 0  ;the i-th character of our plaintext
        mov r15, 0  ;the i-th character of our keyword
_loop:
        mov al, [rcx]
        cmp al, 65
        jl _noLetter
        cmp al, 122
        jg _noLetter
              
        cmp al, 90
        jle _lowercase
        cmp al, 97
        jge _uppercase
        
        jmp _noLetter
_lowercase:
        mov r9b, 65
        jmp _continue1        
_uppercase:
        mov r9b, 97                  
_continue1: 
        sub al, r9b

        mov r15b, [rbx]
        cmp r15b, 65
        jl _keyNoLetter
        cmp r15b, 122
        jg _keyNoLetter 
        
        cmp r15b, 90
        jle _keyLowercase
        cmp r15b, 97
        jge _keyUppercase
        
        jmp _keyNoLetter  
_keyLowercase:
        mov r8b, 65
        jmp _continue2         
_keyUppercase:
        mov r8b, 97 
        jmp _continue2            
_keyNoLetter:
        print errStr
        jmp _catch
_continue2:
        sub r15b, r8b

        add rax, r15
       
        mov rdx, 0
        mov r10, 26
        div r10
        add rdx, r9
        
        mov [rsi], rdx
        jmp _next1
_noLetter:        
        mov [rsi], al
_next1: 
        inc rsi
        inc rcx
        inc rbx
        
        cmp BYTE [rbx], 10
        je _resetRBX
        jmp _next2
_resetRBX:
        mov rbx, keyword
_next2:                       
        cmp BYTE [rcx], 10
        jne _loop
        ret
