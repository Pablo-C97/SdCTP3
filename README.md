# SdCTP3
**Trabajo Práctico N°3 - Sistemas de Computación** *Universidad Nacional de Córdoba (UNC) - FCEFyN*

Este repositorio contiene el desarrollo del tercer trabajo práctico de la materia, centrado en el estudio del proceso de arranque (booting), programación a bajo nivel (*bare-metal*) y la transición entre los distintos modos de ejecución de la arquitectura x86.

## Estructura del Proyecto

El trabajo está dividido en tres directorios, cada uno correspondiente a los desafíos planteados por la cátedra, con su respectiva documentación interna:

* **`/uefi_coreboot`**: Investigación teórica sobre el proceso de arranque moderno. Incluye documentación sobre el estándar UEFI, la plataforma Intel CSME y el proyecto de firmware de código abierto coreboot.
* **`/linker`**: Exploración del proceso de enlazado (*linking*) para entornos *bare-metal*. Incluye la creación de un sector de arranque (MBR) de 512 bytes desde cero, configuración del *Location Counter* en el script del linker, y pruebas de ejecución exitosas en hardware físico implementando un "Escudo BPB".
* **`/modo_protegido`**: Desarrollo en lenguaje ensamblador (sin uso de macros) para realizar la transición del procesador desde el Modo Real (16 bits) al Modo Protegido (32 bits). Abarca la configuración manual de la Global Descriptor Table (GDT), segmentación de memoria y pruebas de violación de acceso a segmentos de solo lectura.

---
