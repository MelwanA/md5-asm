section .data
    chp db 'hello', 0

section .bss
    buffer resb 64
    A resd 1
    B resd 1
    C resd 1
    D resd 1
    count resd 1
    len resd 1

section .text
    global _start

_start:
    mov dword [A], 0x67452301
    mov dword [B], 0xEFCDAB89
    mov dword [C], 0x98BADCFE
    mov dword [D], 0x10325476

    mov ecx, 64
    mov esi, buffer
    mov byte [esi], 0x80 
    inc esi
    dec ecx
    xor eax, eax
    rep stosb  

    mov eax, [count] 
    mov dword [len], eax
    shl eax, 3  
    mov dword [esi], eax  
    add esi, 4
    mov eax, [count+4]
    mov dword [len+4], eax
    shl eax, 3
    mov dword [esi], eax


    mov ebx, 0
    mov ecx, 4
    mov esi, buffer
init_md_buffer_loop:
    mov eax, [ebx]
    mov [esi], eax
    add ebx, 4
    add esi, 4
    loop init_md_buffer_loop


    mov esi, buffer
; Process message loop
process_message_loop:
    ; Initialize variables
    mov edx, esi
    mov eax, [message_hash]
    mov ebx, [message_hash + 4]
    mov ecx, [message_hash + 8]
    mov edi, [message_hash + 12]

    ; Round 1
    ; Hash message block
    mov eax, ebx
    add eax, [esi]
    add eax, 0xd76aa478
    shl eax, 7
    add eax, [message_hash]
    mov [message_hash], edi
    mov edi, ecx
    mov ecx, ebx
    mov ebx, eax

    ; Round 2
    ; Hash message block
    mov eax, ebx
    add eax, [esi + 4]
    add eax, 0xe8c7b756
    shl eax, 12
    add eax, [message_hash + 4]
    mov [message_hash + 4], edi
    mov edi, ecx
    mov ecx, ebx
    mov ebx, eax

    ; Round 3
    ; Hash message block
    mov eax, ebx
    add eax, [esi + 8]
    add eax, 0x242070db
    shl eax, 17
    add eax, [message_hash + 8]
    mov [message_hash + 8], edi
    mov edi, ecx
    mov ecx, ebx
    mov ebx, eax

    ; Round 4
    ; Hash message block
    mov eax, ebx
    add eax, [esi + 12]
    add eax, 0xc1bdceee
    shl eax, 22
    add eax, [message_hash + 12]
    mov [message_hash + 12], edi
    mov edi, ecx
    mov ecx, ebx
    mov ebx, eax

    ; Update hash
    add [message_hash], eax
    add [message_hash + 4], ebx
    add [message_hash + 8], ecx
    add [message_hash + 12], edi

    ; Check if message is complete
    add dword [message_length], 64
    chp dword [message_length], 64
    jb process_message_loop

    ; Output hash
    mov eax, [message_hash]
    mov ebx, [message_hash + 4]
    mov ecx, [message_hash + 8]
    mov edx, [message_hash + 12]
    ; Output hash
    mov esi, message_hash
    mov edi, 32  ; Buffer for hex representation of hash
    call hex_str
    ; Output newline
    mov esi, newline
    mov edi, 64
    call print_string

    ; Terminate the program
    mov eax, 60  ; syscall number for exit
    xor edi, edi  ; exit code 0
    syscall

; Function to convert hexadecimal to string
hex_str:
    ; Load byte from string
    movzx ecx, byte [esi]
    ; Copy byte
    mov dl, cl
    ; Isolate low nibble
    and dl, 0xF
    ; Check if less than 10
    chp dl, 10
    ; If less than 10, print directly
    jl print_char
    ; Otherwise, add offset for letters
    add dl, 'A' - 10
print_char:
    ; Store character in buffer
    mov [edi], dl
    ; Move buffer pointer
    inc edi
    ; Move high nibble to low
    shr ecx, 4
    ; Copy high nibble
    mov dl, cl
    ; Isolate low nibble
    and dl, 0xF
    ; Check if less than 10
    chp dl, 10
    ; If less than 10, print directly
    jl print_char
    ; Otherwise, add offset for letters
    add dl, 'A' - 10
    ; Print character
    jmp print_char

; Function to print string
print_string:
    ; Set loop counter
    mov ecx, 8
next_char:
    ; Load character from string
    movzx eax, byte [esi]
    ; Store character in buffer
    mov [edi], eax
    ; Move to next character
    inc esi
    ; Move buffer pointer
    inc edi
    ; Repeat for all characters
    loop next_char
    ; Return
    ret

section .data
    ; Newline character and null terminator
    newline db 10, 0