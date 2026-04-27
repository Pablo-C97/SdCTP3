# Desafío: UEFI y coreboot

## ¿Qué es UEFI? ¿Cómo puedo usarlo? y Funciones de ejemplo
**UEFI (Unified Extensible Firmware Interface)** es el estándar moderno que reemplaza a la tradicional BIOS. Actúa como una interfaz de software entre el sistema operativo y el firmware del hardware. A diferencia de la BIOS, que funciona en modo real a 16 bits y depende de interrupciones, UEFI puede ejecutarse en 32 o 64 bits, admite interfaces gráficas, soporta discos mucho más grandes (gracias a GPT) y permite programar directamente en lenguajes de alto nivel como C.

Para usarlo en el desarrollo de bajo nivel o durante el proceso de arranque, se interactúa con sus servicios predefinidos (*Boot Services* y *Runtime Services*) en lugar de llamar a interrupciones manuales. 
* **Función de ejemplo:** Una función típica a la que se puede llamar usando esta dinámica es `GetTime()`, que devuelve la hora actual del reloj de hardware, o `GetVariable()`, utilizada para leer variables de configuración del entorno NVRAM.

## Casos de bugs de UEFI que puedan ser explotados
Al ser un sistema mucho más complejo que la BIOS, UEFI tiene una superficie de ataque mayor. Los atacantes buscan explotar estas vulnerabilidades para instalar *bootkits* o *rootkits* que se cargan antes que el sistema operativo y los antivirus, logrando persistencia total. Algunos ejemplos incluyen:
* **Vulnerabilidades de Secure Boot (ej. BlackLotus o LogoFAIL):** Permiten a un atacante saltarse la verificación de firmas de Secure Boot modificando variables en la NVRAM o aprovechando fallos en los drivers de las imágenes de inicio. Esto permite cargar *bootloaders* no firmados y maliciosos.
* **Bugs en binarios confiables (ej. CVE-2024-7344):** Fallos descubiertos recientemente donde aplicaciones de recuperación de sistema confiables permiten cargar archivos binarios no firmados durante el arranque de UEFI, actuando como una puerta trasera para el malware.

## ¿Qué es Converged Security and Management Engine (CSME) e Intel MEBx?
* **Intel CSME (anteriormente Intel Management Engine):** Es un subsistema autónomo integrado en la mayoría de los chipsets de Intel desde 2008. Funciona como una "computadora dentro de la computadora" (generalmente corriendo un SO basado en MINIX) que opera de manera independiente al procesador principal. Se ejecuta siempre que la placa base reciba energía, incluso si la PC está apagada. Es responsable de verificar criptográficamente el firmware y es la base de tecnologías de seguridad y administración remota.
* **Intel MEBx (Management Engine BIOS Extension):** Es la extensión a nivel de firmware (accesible durante el arranque de la PC) que permite a los administradores configurar los parámetros de red y las credenciales del CSME para habilitar la gestión fuera de banda (*out-of-band*).

## ¿Qué es coreboot? Productos y ventajas
**coreboot** es un proyecto de firmware de código abierto diseñado para reemplazar el firmware propietario de la BIOS/UEFI distribuido por los fabricantes. Su filosofía es realizar la inicialización mínima necesaria del hardware y luego cederle el control a un programa secundario (*payload*), como SeaBIOS o EDK2 (para soporte UEFI).
* **Productos que lo incorporan:** Se utiliza principalmente en computadoras enfocadas en la seguridad y el código abierto, como las laptops de System76, los equipos de Purism, los dispositivos de red Protectli, y de forma masiva en todas las Chromebooks de Google.
* **Ventajas de su utilización:**
    * **Velocidad:** Al eliminar rutinas innecesarias, el tiempo de arranque es extremadamente rápido.
    * **Seguridad y Transparencia:** Al ser de código abierto, la comunidad puede auditar el código en busca de vulnerabilidades y puertas traseras, reduciendo drásticamente la superficie de ataque.
    * **Flexibilidad:** Permite a los desarrolladores elegir y compilar exactamente qué *payloads* quieren usar sin depender de las restricciones del fabricante de la placa madre.
