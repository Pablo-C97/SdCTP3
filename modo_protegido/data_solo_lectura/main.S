.code16          # El BIOS arranca en modo real de 16 bits

start:
    cli              # Paso 3: deshabilitar interrupciones
    # Limpiar registros de segmento
    xor  %ax, %ax    # AX = 0  (no se puede mover inmediato a segmento directamente)
    mov  %ax, %ds    # DS = 0
    mov  %ax, %es    # ES = 0
    mov  %ax, %ss    # SS = 0

    # Inicializar el stack justo debajo del MBR
    mov  $0x7C00, %sp   # El stack crece hacia abajo desde 0x7C00cd

    # Paso 5: cargar la GDT
    lgdt gdt_descriptor

    # Paso 6: activar bit PE en CR0
    mov  %cr0, %eax
    or   $0x1, %eax
    mov  %eax, %cr0

    # Paso 7: far jump → flush pipeline + CS = selector de código
    ljmp $0x08, $pm_entry

# ─── A partir de acá: 32 bits ───────────────────────────
.code32
pm_entry:
    # Paso 8: cargar registros de segmento con selector de datos
    mov  $0x10, %eax
    mov  %eax, %ds
    mov  %eax, %es
    mov  %eax, %fs
    mov  %eax, %gs

    # Paso 9: inicializar stack en modo protegido
    mov  $0x18, %eax        # selector de stack (lectura/escritura)
    mov  $0x90000, %esp
    mov  %eax, %ss         # SS con EAX completo

    movl %cr0, %eax
    orl  $0x10000, %eax    # Activa el bit 16 (WP)
    orl  $0x11, %eax       # Activa PE (bit 0) y ET (bit 4)
    movl %eax, %cr0

    # Paso 10: ejecutar código en modo protegido
    mov  $0x80000, %edi
    mov  $0xDEADBEEF, %eax
    mov %eax, (%edi)           # mov con DS explícito → debe disparar #GP

    hlt
# ── GDT ────────────────────────────────────────────
gdt_start:

# Descriptor 0: Nulo (obligatorio, la CPU lo exige)
gdt_null:
    .quad 0x0000000000000000

# Descriptor 1: Código (selector 0x08)
gdt_code:
    .word 0xFFFF        # Límite [15:0]
    .word 0x0000        # Base  [15:0]
    .byte 0x00          # Base  [23:16]
    .byte 0x9A          # Acceso: P=1, DPL=0, S=1, Type=1010
    .byte 0xCF          # Flags 0xC + Límite[19:16] 0xF
    .byte 0x00          # Base  [31:24]

# Descriptor 2: Datos (selector 0x10)
gdt_data:
    .word 0xFFFF        # Límite [15:0]
    .word 0x0000        # Base  [15:0]
    .byte 0x00          # Base  [23:16]
    .byte 0x90          # Acceso: P=1, DPL=0, S=1, Type=0010
    .byte 0xCF          # Flags 0xC + Límite[19:16] 0xF
    .byte 0x00          # Base  [31:24]

gdt_stack:                      # selector 0x18  (lectura/escritura)
    .word 0xFFFF
    .word 0x0000
    .byte 0x00
    .byte 0x92                  # datos lectura/escritura
    .byte 0xCF
    .byte 0x00

gdt_end:


# Estructura de 6 bytes que lee lgdt
gdt_descriptor:
    .word gdt_end - gdt_start - 1   # tamaño de la GDT - 1
    .long gdt_start                 # dirección física de la GDT



