# =============================================================================
# Makefile для збирання прошивки STM32F4-Discovery
# Лабораторна робота №2: основні інструкції 32-бітного ARM
# Виконав: Миркін Р.І., група ІО-31
#
# Залежності:
#   start.S     - таблиця векторів, Reset Handler з викликом lab1
#   lab1.S      - реалізація функції за варіантом 4 (3114 % 5 = 4)
#   lscript.ld  - скрипт лінкера з картою пам'яті STM32F4
#
# Цілі:
#   make        - зібрати firmware.elf та firmware.bin
#   make qemu   - запустити в емуляторі qemu з gdb-сервером на tcp::1234
#   make clean  - видалити проміжні файли збирання
# =============================================================================

# --- Префікс крос-компіляторного тулчейну ---
SDK_PREFIX ?= arm-none-eabi-

# Інструменти збирання
CC      = $(SDK_PREFIX)gcc
LD      = $(SDK_PREFIX)ld
SIZE    = $(SDK_PREFIX)size
OBJCOPY = $(SDK_PREFIX)objcopy
QEMU    = qemu-system-gnuarmeclipse

# --- Параметри цільової платформи ---
BOARD    ?= STM32F4-Discovery
MCU       = STM32F407VG
TARGET    = firmware
CPU_CC    = cortex-m4
TCP_ADDR  = 1234

# Перелік об'єктних файлів, що увійдуть у фінальний ELF
OBJS = start.o lab1.o

# --- Ціль за замовчуванням ---
all: target

# --- Збирання прошивки ---
# Крок 1: компілюємо КОЖЕН .S окремо у .o (start.S → start.o, lab1.S → lab1.o)
# Крок 2: лінкуємо обидва .o у firmware.elf за скриптом lscript.ld
# Крок 3: objcopy конвертує ELF у "сирий" бінарний образ для qemu/Flash
target:
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -mthumb -Wall start.S -o start.o
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -mthumb -Wall lab1.S  -o lab1.o
	$(CC) $(OBJS) -mcpu=$(CPU_CC) -mthumb -Wall --specs=nosys.specs -nostdlib -lgcc -T./lscript.ld -o $(TARGET).elf
	$(OBJCOPY) -O binary -F elf32-littlearm $(TARGET).elf $(TARGET).bin

# --- Запуск у qemu з gdb-сервером (CPU паузнуто, чекає підключення) ---
qemu:
	$(QEMU) --verbose --verbose --board $(BOARD) --mcu $(MCU) -d unimp,guest_errors --image $(TARGET).bin --semihosting-config enable=on,target=native -gdb tcp::$(TCP_ADDR) -S

# --- Очищення робочої директорії від артефактів збирання ---
clean:
	-rm -f *.o
	-rm -f *.elf
	-rm -f *.bin

.PHONY: all target qemu clean
