# Desafío 3: Modo Protegido
[Programa que se ejecuta en modo protegido](inicial/main.S)

[Separo los segmentos de datos y pila](segmento_stack/main.S)

[Marcar segmento de datos como solo lectura](data_solo_lectura/main.S)


### Contruir la imagen
en cada carpeta
```bash
make
```

### Ejecución de QEMU y GDB para Depuración

Para depurar utiliza dos terminales separados:

**Terminal 1: Lanzar el Emulador**
```bash
qemu-system-x86_64 -drive format=raw,file=main.img -s -S
```
* `-s`: Abre un servidor GDB en el puerto TCP 1234.
* `-S`: Congela la CPU al inicio (no empieza a ejecutar hasta que GDB lo ordene).

**Terminal 2: Lanzar el Depurador**
```bash
gdb main.elf \
    -ex "target remote localhost:1234" \
    -ex "set architecture i8086" \
    -ex "break *0x7C00" \
    -ex "continue"
```