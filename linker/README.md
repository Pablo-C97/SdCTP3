# Desafío: Linker

## Guía de Implementación y Análisis del MBR (Master Boot Record)

Este documento contiene las instrucciones paso a paso para compilar y ejecutar un código "Hello World" en hardware real (bare-metal) utilizando una BIOS en modo CSM, junto con el análisis de los binarios generados para verificar el correcto funcionamiento del Linker.


## 1. El Problema y la Solución (Escudo BPB)
Al intentar ejecutar un código ensamblador simple desde un pendrive en una placa base moderna (en nuestro caso ASUS Prime A320M), nos encontramos con que la BIOS sobrescribía parte de la memoria RAM (el "BIOS Parameter Block" o BPB) asumiendo que el pendrive tenía formato FAT. Esto causaba que nuestro código se corrompiera y crasheara.

**Solución implementada:** Agregamos un "Escudo BPB" en el código ensamblador (`main.S`). Esto consiste en un salto inicial (`jmp`) seguido de un bloque de 87 bytes vacíos (`.space 87`). De esta manera, la BIOS sobrescribe ese espacio vacío reservado, dejando el código ejecutable y los datos intactos.

---

## 2. Herramientas Utilizadas
* **`as`**: Ensamblador GNU para generar el código objeto.
* **`ld`**: Linker GNU para generar la imagen binaria plana.
* **`objdump`**: Para desensamblar e inspeccionar el código objeto.
* **`hexdump`** (o `hd`): Para inspeccionar los bytes crudos del binario final.

---

## 3. Instrucciones de Compilación y Grabado

Para replicar este entorno y compilar el binario desde cero, ejecutar los siguientes comandos en la terminal:

1. **Ensamblado:** Generamos el archivo objeto (`main.o`) a partir del código fuente.
   ```bash
   as -g -o main.o main.S
   ```

2. **Enlazado (Linking):** Generamos la imagen plana booteable (`main.img`) usando el script del linker (`link.ld`), asegurando que todo se ubique en la dirección de memoria `0x7c00`.
   ```bash
   ld --oformat binary -o main.img -T link.ld main.o
   ```
3. **Prueba en Emulador:** Para probar la imagen sin necesidad de hardware real, se puede usar QEMU(aunque no garantiza el funcionamiento en hardware real).
   ```bash
   qemu-system-x86_64 -drive format=raw,file=main.img
   ```

4. **Grabado en Hardware Real:** Para volcar la imagen en un pendrive (reemplazar `sdX` por el identificador del USB, usar `lsblk` para verificar).
   ```bash
   sudo dd if=main.img of=/dev/sdX bs=512 count=1
   ```
   *Nota: Tras grabar la imagen, configurar la BIOS para iniciar en modo Legacy/CSM y bootear desde la unidad USB.*

---

## 4. Verificación de Binarios y Ubicación en Memoria

Para comprobar que el linker acomodó el código correctamente y que el "Escudo BPB" está presente, analizamos las salidas de los comandos de volcado.

### 4.1 Inspección del Código Objeto (`objdump`)
Este comando nos permite ver las instrucciones ensambladas antes de que el linker las empaquete en su dirección final.

```bash
objdump -d main.o
```

**Salida obtenida:**
```text
main.o:     formato del fichero elf64-x86-64

Desensamblado de la sección .text:

0000000000000000 <__start>:
   0:   eb 58                   jmp    5a <real_start>
   2:   90                      nop
        ...

000000000000005a <real_start>:
  5a:   31 c0                   xor    %eax,%eax
  5c:   8e d8                   mov    %eax,%ds
  5e:   8e c0                   mov    %eax,%es
  60:   30 ff                   xor    %bh,%bh
  62:   be 00 00 b4 0e          mov    $0xeb40000,%esi

0000000000000067 <loop>:
  67:   ac                      lods   (%rsi),%al
  68:   08 c0                   or     %al,%al
  6a:   74 04                   je     70 <halt>
  6c:   cd 10                   int    $0x10
  6e:   eb f7                   jmp    67 <loop>

0000000000000070 <halt>:
  70:   f4                      hlt
  71:   eb fd                   jmp    70 <halt>

0000000000000073 <msg>:
  73:   68 65 6c 6c 6f          push   $0x6f6c6c65
  78:   20 77 6f                and    %dh,0x6f(%rdi)
  7b:   72 6c                   jb     e9 <msg+0x76>
  7d:   64                      fs
```

**Análisis:**
* El código comienza en el offset `0x00` con la instrucción de salto `jmp` (opcodes `eb 58`), que salta 88 bytes hacia adelante.
* Los puntos suspensivos (`...`) representan el `.space 87` que dejamos intencionalmente relleno de ceros.
* La ejecución real del programa comienza en el offset `0x5a` (90 en decimal) con la limpieza del registro `%eax` (`31 c0`).
* En el offset `0x73` se observa nuestro mensaje "hello world", el cual `objdump` intenta interpretar erróneamente como código de máquina.

### 4.2 Volcado Hexadecimal de la Imagen Final (`hexdump`)
Este comando muestra el contenido crudo (byte por byte) del sector de arranque de 512 bytes generado por el linker.

```bash
hexdump -C main.img
```

**Salida obtenida:**
```text
00000000  eb 58 90 00 00 00 00 00  00 00 00 00 00 00 00 00  |.X..............|
00000010  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00000050  00 00 00 00 00 00 00 00  00 00 31 c0 8e d8 8e c0  |..........1.....|
00000060  30 ff be 73 7c b4 0e ac  08 c0 74 04 cd 10 eb f7  |0..s|.....t.....|
00000070  f4 eb fd 68 65 6c 6c 6f  20 77 6f 72 6c 64 00 66  |...hello world.f|
00000080  2e 0f 1f 84 00 00 00 00  00 66 2e 0f 1f 84 00 00  |.........f......|
00000090  00 00 00 66 2e 0f 1f 84  00 00 00 00 00 66 2e 0f  |...f.........f..|
000000a0  1f 84 00 00 00 00 00 66  2e 0f 1f 84 00 00 00 00  |.......f........|
000000b0  00 66 2e 0f 1f 84 00 00  00 00 00 66 2e 0f 1f 84  |.f.........f....|
000000c0  00 00 00 00 00 66 2e 0f  1f 84 00 00 00 00 00 66  |.....f.........f|
000000d0  2e 0f 1f 84 00 00 00 00  00 66 2e 0f 1f 84 00 00  |.........f......|
000000e0  00 00 00 66 2e 0f 1f 84  00 00 00 00 00 66 2e 0f  |...f.........f..|
000000f0  1f 84 00 00 00 00 00 66  2e 0f 1f 84 00 00 00 00  |.......f........|
00000100  00 66 2e 0f 1f 84 00 00  00 00 00 66 2e 0f 1f 84  |.f.........f....|
00000110  00 00 00 00 00 66 2e 0f  1f 84 00 00 00 00 00 66  |.....f.........f|
00000120  2e 0f 1f 84 00 00 00 00  00 66 2e 0f 1f 84 00 00  |.........f......|
00000130  00 00 00 66 2e 0f 1f 84  00 00 00 00 00 66 2e 0f  |...f.........f..|
00000140  1f 84 00 00 00 00 00 66  2e 0f 1f 84 00 00 00 00  |.......f........|
00000150  00 66 2e 0f 1f 84 00 00  00 00 00 66 2e 0f 1f 84  |.f.........f....|
00000160  00 00 00 00 00 66 2e 0f  1f 84 00 00 00 00 00 66  |.....f.........f|
00000170  2e 0f 1f 84 00 00 00 00  00 66 2e 0f 1f 84 00 00  |.........f......|
00000180  00 00 00 66 2e 0f 1f 84  00 00 00 00 00 66 2e 0f  |...f.........f..|
00000190  1f 84 00 00 00 00 00 66  2e 0f 1f 84 00 00 00 00  |.......f........|
000001a0  00 66 2e 0f 1f 84 00 00  00 00 00 66 2e 0f 1f 84  |.f.........f....|
000001b0  00 00 00 00 00 66 2e 0f  1f 84 00 00 00 00 00 66  |.....f.........f|
000001c0  2e 0f 1f 84 00 00 00 00  00 66 2e 0f 1f 84 00 00  |.........f......|
000001d0  00 00 00 66 2e 0f 1f 84  00 00 00 00 00 66 2e 0f  |...f.........f..|
000001e0  1f 84 00 00 00 00 00 66  2e 0f 1f 84 00 00 00 00  |.......f........|
000001f0  00 66 2e 0f 1f 84 00 00  00 00 00 0f 1f 00 55 aa  |.f............U.|
00000200  04 00 00 00 20 00 00 00  05 00 00 00 47 4e 55 00  |.... .......GNU.|
00000210  02 00 01 c0 04 00 00 00  01 00 00 00 00 00 00 00  |................|
00000220  01 00 01 c0 04 00 00 00  01 00 00 00 00 00 00 00  |................|
00000230
```

**Conclusiones de la Imagen Binaria:**
1. **Ubicación de la Sección `.text`:** Vemos que los bytes iniciales (`eb 58 90`) se encuentran en el offset `0x00000000`, confirmando que el linker ubicó el programa al comienzo del sector físico.
2. **Confirmación del Padding:** El asterisco (`*`) indica que las líneas repetidas llenas de ceros fueron colapsadas visualmente, indicando que nuestro espacio reservado está intacto, desplazando el código principal hasta el offset `0x5a` (`31 c0`).
3. **Ubicación de los Datos:** En la columna derecha de caracteres ASCII se puede visualizar el string "hello world" partiendo del offset `0x73`.
4. **Firma Mágica:** Finalmente, los dos últimos bytes del sector de 512 bytes (offsets `0x1FE` y `0x1FF`) contienen los valores `55 aa`, cumpliendo con el requisito fundamental de la arquitectura x86 para que la BIOS reconozca la imagen como un MBR válido.

## 5. Prueba de Éxito en Hardware Real
Como demostración final de la correcta implementación del "Escudo BPB" y el linkeo exacto del programa, se muestra la ejecución exitosa del sector de arranque directamente desde un pendrive en hardware real: 