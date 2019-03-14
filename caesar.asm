;Harvard University CS50, Problem Set 2, Caesar
;program encrypts a plaintext with the ceasar cipher
;compile program with 'nasm caesar.asm -f elf64 -o caesar.o && ld caesar.o -o caesar'

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
        newline db 10

section .bss
        number resb BYTES_TO_READ1
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
        getStr number, BYTES_TO_READ1
        stringToInt number
        mov rbx, 0
        mov bl, al
        push rbx
        print str2
        getStr plaintext, BYTES_TO_READ2
        newline
        pop rbx
        call _encrypt
        print ciphertext
        newline
        
        exit
 
_getString:
        mov rax, SYS_READ
        mov rdi, STD_IN
        mov rsi, rcx
        mov rdx, rbx
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
        mov rcx, plaintext
        mov rsi, ciphertext
        mov rax, 0  
        mov r10, 0  
        mov r9, 0    
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
        mov r9, 65
        jmp _continue          
_uppercase:
        mov r9, 97                  
_continue: 
        sub al, r9b
        add rax, rbx
                       
        mov rdx, 0
        mov r10, 26
        div r10
        add rdx, r9
        
        mov [rsi], rdx
        jmp _next
_noLetter:        
        mov [rsi], al
_next: 
        inc rsi
        inc rcx       
        cmp BYTE [rcx], 10
        jne _loop
        ret        
