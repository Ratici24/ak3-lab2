/*
 * lscript.ld - скрипт лінкера для STM32F407VG (Cortex-M4)
 * Лабораторна робота №2
 * Виконав: Миркін Р.І., група ІО-31
 *
 * Описує карту пам'яті цільового мікроконтролера STM32F4-Discovery
 * та обчислює адресу вершини стеку __stack_start для start.S.
 */

MEMORY
{
    /*
     * FLASH — постійна пам'ять програми. У STM32F407VG flash починається
     * з адреси 0x08000000, об'єм 1 МБ. Атрибути (rx) — read/execute.
     */
    FLASH ( rx )  : ORIGIN = 0x08000000, LENGTH = 1M

    /*
     * RAM — оперативна пам'ять. У STM32F407VG SRAM мапиться на 0x20000000,
     * об'єм 128 КБ. Атрибути (rxw) — read/execute/write.
     */
    RAM ( rxw )   : ORIGIN = 0x20000000, LENGTH = 128K
}

/*
 * Стек у Cortex-M зростає вниз (full descending). Початкова адреса —
 * остання адреса RAM, з якої він починає рости в бік нижчих адрес.
 */
__stack_start = ORIGIN(RAM) + LENGTH(RAM);
