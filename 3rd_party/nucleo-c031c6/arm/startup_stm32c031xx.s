;*****************************************************************************
; @file     startup_stm32c031xx.s for ARM-KEIL ARM assembler
; @brief    CMSIS Cortex-M4F Core Device Startup File for stm32c031xx
; @version  CMSIS 5.9.0
; @date     1 Feb 2023
;
; Modified by Quantum Leaps:
; - Added relocating of the Vector Table to free up the 256B region at 0x0
;   for NULL-pointer protection by the MPU.
; - Modified all exception handlers to branch to assert_failed()
;   instead of locking up the CPU inside an endless loop.
;
; @description
; Created from the CMSIS template for the specified device
; Quantum Leaps, www.state-machine.com
;
; @note
; The symbols Stack_Size and Heap_Size should be provided on the command-
; line options to the assembler, for example as:
;     --pd "Stack_Size SETA 1024" --pd "Heap_Size SETA 0"


;******************************************************************************
; Allocate space for the stack.
;
        AREA    STACK, NOINIT, READWRITE, ALIGN=3
__stack_base
StackMem
        SPACE   Stack_Size    ; provided in command-line option, for example:
                              ; --pd "Stack_Size SETA 512"
__stack_limit
__initial_sp

;******************************************************************************
; Allocate space for the heap.
;
        AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
HeapMem
        SPACE   Heap_Size     ; provided in command-line option, for example:
                              ; --pd "Heap_Size SETA 0"
__heap_limit

; Indicate that the code in this file preserves 8-byte alignment of the stack.
        PRESERVE8

;******************************************************************************
; The vector table.
;
; Place code into the reset code section.
        AREA   RESET, DATA, READONLY, ALIGN=8
        EXPORT  __Vectors
        EXPORT  __Vectors_End
        EXPORT  __Vectors_Size

__Vectors
        DCD     __initial_sp                ; Top of Stack
        DCD     Reset_Handler               ; Reset Handler
        DCD     NMI_Handler                 ; NMI Handler
        DCD     HardFault_Handler           ; Hard Fault Handler
        DCD     Default_Handler             ; Reserved
        DCD     Default_Handler             ; Reserved
        DCD     Default_Handler             ; Reserved
        DCD     Default_Handler             ; Reserved
        DCD     Default_Handler             ; Reserved
        DCD     Default_Handler             ; Reserved
        DCD     Default_Handler             ; Reserved
        DCD     SVC_Handler                 ; SVCall handler
        DCD     DebugMon_Handler            ; Debug Monitor handler
        DCD     Default_Handler             ; Reserved
        DCD     PendSV_Handler              ; PendSV handler
        DCD     SysTick_Handler             ; SysTick handler

        ; IRQ handlers...
        DCD     WWDG_IRQHandler             ; [ 0] Window Watchdog
        DCD     Reserved1_IRQHandler        ; [ 1] Reserved
        DCD     RTC_IRQHandler              ; [ 2] RTC through EXTI Line
        DCD     FLASH_IRQHandler            ; [ 3] FLASH
        DCD     RCC_IRQHandler              ; [ 4] RCC
        DCD     EXTI0_1_IRQHandler          ; [ 5] EXTI Line 0 and 1
        DCD     EXTI2_3_IRQHandler          ; [ 6] EXTI Line 2 and 3
        DCD     EXTI4_15_IRQHandler         ; [ 7] EXTI Line 4 to 15
        DCD     Reserved8_IRQHandler        ; [ 8] Reserved
        DCD     DMA1_Channel1_IRQHandler    ; [ 9] DMA1 Channel 1
        DCD     DMA1_Channel2_3_IRQHandler  ; [10] DMA1 Channel 2 and Channel 3
        DCD     DMAMUX1_IRQHandler          ; [11] DMAMUX
        DCD     ADC1_IRQHandler             ; [12] ADC1
        DCD     TIM1_BRK_UP_TRG_COM_IRQHandler ; [13] TIM1 Break, Update, Trigger and Commutation
        DCD     TIM1_CC_IRQHandler          ; [14] TIM1 Capture Compare
        DCD     Reserved15_IRQHandler       ; [15] Reserved
        DCD     TIM3_IRQHandler             ; [16] TIM3
        DCD     Reserved17_IRQHandler       ; [17] Reserved
        DCD     Reserved18_IRQHandler       ; [18] Reserved
        DCD     TIM14_IRQHandler            ; [19] TIM14
        DCD     Reserved20_IRQHandler       ; [20] Reserved
        DCD     TIM16_IRQHandler            ; [21] TIM16
        DCD     TIM17_IRQHandler            ; [22] TIM17
        DCD     I2C1_IRQHandler             ; [23] I2C1
        DCD     Reserved24_IRQHandler       ; [24] Reserved
        DCD     SPI1_IRQHandler             ; [25] SPI1
        DCD     Reserved26_IRQHandler       ; [26] Reserved
        DCD     USART1_IRQHandler           ; [27] USART1
        DCD     USART2_IRQHandler           ; [28] USART2
        DCD     Reserved29_IRQHandler       ; [29] Reserved
        DCD     Reserved30_IRQHandler       ; [30] Reserved
        DCD     Reserved31_IRQHandler       ; [31] Reserved

__Vectors_End

__Vectors_Size  EQU   __Vectors_End - __Vectors


;******************************************************************************
; This is the code for exception handlers.
;
        AREA    |.text|, CODE, READONLY

;******************************************************************************
; This is the code that gets called when the processor first starts execution
; following a reset event.
;
Reset_Handler   PROC
        EXPORT  Reset_Handler   [WEAK]
        IMPORT  SystemInit
        IMPORT  __main
        IMPORT  assert_failed

        LDR     r0,=SystemInit  ; CMSIS system initialization
        BLX     r0

        ; Call the C library entry point that handles startup. This will copy
        ; the .data section initializers from flash to SRAM and zero fill the
        ; .bss section.
        ; NOTE: The __main function clears the C stack as well
        LDR     r0,=__main
        BX      r0

        ; __main calls the main() function, which should not return,
        ; but just in case jump to assert_failed() if main returns.
        CPSID   i                 ; disable all interrupts
        LDR     r0,=str_EXIT
        MOVS    r1,#1
        LDR     r2,=__initial_sp  ; re-set the SP in case of stack overflow
        MOV     sp,r2
        LDR     r2,=assert_failed
        BX      r2
str_EXIT
        DCB     "EXIT"
        ALIGN
        ENDP

;******************************************************************************
NMI_Handler     PROC
        EXPORT  NMI_Handler     [WEAK]
        CPSID   i                 ; disable all interrupts
        LDR     r0,=str_NMI
        MOVS    r1,#1
        LDR     r2,=__initial_sp  ; re-set the SP in case of stack overflow
        MOV     sp,r2
        LDR     r2,=assert_failed
        BX      r2
str_NMI
        DCB     "NMI"
        ALIGN
        ENDP

;******************************************************************************
HardFault_Handler PROC
        EXPORT  HardFault_Handler [WEAK]
        CPSID   i                 ; disable all interrupts
        LDR     r0,=str_HardFault
        MOVS    r1,#1
        LDR     r2,=__initial_sp  ; re-set the SP in case of stack overflow
        MOV     sp,r2
        LDR     r2,=assert_failed
        BX      r2
str_HardFault
        DCB     "HardFault"
        ALIGN
        ENDP



;******************************************************************************
;
; Weak non-fault handlers...
;

;******************************************************************************
SVC_Handler PROC
        EXPORT  SVC_Handler       [WEAK]
        CPSID   i                 ; disable all interrupts
        LDR     r0,=str_SVC
        MOVS    r1,#1
        LDR     r2,=__initial_sp  ; re-set the SP in case of stack overflow
        MOV     sp,r2
        LDR     r2,=assert_failed
        BX      r2
str_SVC
        DCB     "SVC"
        ALIGN
        ENDP

;******************************************************************************
DebugMon_Handler PROC
        EXPORT  DebugMon_Handler  [WEAK]
        CPSID   i                 ; disable all interrupts
        LDR     r0,=str_DebugMon
        MOVS    r1,#1
        LDR     r2,=__initial_sp  ; re-set the SP in case of stack overflow
        MOV     sp,r2
        LDR     r2,=assert_failed
        BX      r2
str_DebugMon
        DCB     "DebugMon"
        ALIGN
        ENDP

;******************************************************************************
PendSV_Handler PROC
        EXPORT  PendSV_Handler    [WEAK]
        CPSID   i                 ; disable all interrupts
        LDR     r0,=str_PendSV
        MOVS    r1,#1
        LDR     r2,=__initial_sp  ; re-set the SP in case of stack overflow
        MOV     sp,r2
        LDR     r2,=assert_failed
        BX      r2
str_PendSV
        DCB     "PendSV"
        ALIGN
        ENDP

;******************************************************************************
SysTick_Handler PROC
        EXPORT  SysTick_Handler   [WEAK]
        CPSID   i                 ; disable all interrupts
        LDR     r0,=str_SysTick
        MOVS    r1,#1
        LDR     r2,=__initial_sp  ; re-set the SP in case of stack overflow
        MOV     sp,r2
        LDR     r2,=assert_failed
        BX      r2
str_SysTick
        DCB     "SysTick"
        ALIGN
        ENDP

;******************************************************************************
Default_Handler PROC
        EXPORT  WWDG_IRQHandler                [WEAK]
        EXPORT  RTC_IRQHandler                 [WEAK]
        EXPORT  FLASH_IRQHandler               [WEAK]
        EXPORT  RCC_IRQHandler                 [WEAK]
        EXPORT  EXTI0_1_IRQHandler             [WEAK]
        EXPORT  EXTI2_3_IRQHandler             [WEAK]
        EXPORT  EXTI4_15_IRQHandler            [WEAK]
        EXPORT  DMA1_Channel1_IRQHandler       [WEAK]
        EXPORT  DMA1_Channel2_3_IRQHandler     [WEAK]
        EXPORT  DMAMUX1_IRQHandler             [WEAK]
        EXPORT  ADC1_IRQHandler                [WEAK]
        EXPORT  TIM1_BRK_UP_TRG_COM_IRQHandler [WEAK]
        EXPORT  TIM1_CC_IRQHandler             [WEAK]
        EXPORT  TIM3_IRQHandler                [WEAK]
        EXPORT  TIM14_IRQHandler               [WEAK]
        EXPORT  TIM16_IRQHandler               [WEAK]
        EXPORT  TIM17_IRQHandler               [WEAK]
        EXPORT  I2C1_IRQHandler                [WEAK]
        EXPORT  SPI1_IRQHandler                [WEAK]
        EXPORT  USART1_IRQHandler              [WEAK]
        EXPORT  USART2_IRQHandler              [WEAK]
        EXPORT  Reserved1_IRQHandler           [WEAK]
        EXPORT  Reserved8_IRQHandler           [WEAK]
        EXPORT  Reserved15_IRQHandler          [WEAK]
        EXPORT  Reserved17_IRQHandler          [WEAK]
        EXPORT  Reserved18_IRQHandler          [WEAK]
        EXPORT  Reserved20_IRQHandler          [WEAK]
        EXPORT  Reserved24_IRQHandler          [WEAK]
        EXPORT  Reserved26_IRQHandler          [WEAK]
        EXPORT  Reserved29_IRQHandler          [WEAK]
        EXPORT  Reserved30_IRQHandler          [WEAK]
        EXPORT  Reserved31_IRQHandler          [WEAK]

WWDG_IRQHandler
RTC_IRQHandler
FLASH_IRQHandler
RCC_IRQHandler
EXTI0_1_IRQHandler
EXTI2_3_IRQHandler
EXTI4_15_IRQHandler
DMA1_Channel1_IRQHandler
DMA1_Channel2_3_IRQHandler
DMAMUX1_IRQHandler
ADC1_IRQHandler
TIM1_BRK_UP_TRG_COM_IRQHandler
TIM1_CC_IRQHandler
TIM3_IRQHandler
TIM14_IRQHandler
TIM16_IRQHandler
TIM17_IRQHandler
I2C1_IRQHandler
SPI1_IRQHandler
USART1_IRQHandler
USART2_IRQHandler
Reserved1_IRQHandler
Reserved8_IRQHandler
Reserved15_IRQHandler
Reserved17_IRQHandler
Reserved18_IRQHandler
Reserved20_IRQHandler
Reserved24_IRQHandler
Reserved26_IRQHandler
Reserved29_IRQHandler
Reserved30_IRQHandler
Reserved31_IRQHandler
        CPSID   i                 ; disable all interrupts
        LDR     r0,=str_Undefined
        MOVS    r1,#1
        LDR     r2,=__initial_sp  ; re-set the SP in case of stack overflow
        MOV     sp,r2
        LDR     r2,=assert_failed
        BX      r2
str_Undefined
        DCB     "Undefined"
        ALIGN
        ENDP

        ALIGN               ; make sure the end of this section is aligned

;******************************************************************************
; The function expected of the C library startup code for defining the stack
; and heap memory locations.  For the C library version of the startup code,
; provide this function so that the C library initialization code can find out
; the location of the stack and heap.
;
    IF :DEF: __MICROLIB
        EXPORT  __initial_sp
        EXPORT  __stack_limit
        EXPORT  __heap_base
        EXPORT  __heap_limit
    ELSE
        IMPORT  __use_two_region_memory
        EXPORT  __user_initial_stackheap

__user_initial_stackheap PROC
        LDR     R0, =__heap_base
        LDR     R1, =__stack_limit
        LDR     R2, =__heap_limit
        LDR     R3, =__stack_base
        BX      LR
        ENDP
    ENDIF
        ALIGN               ; make sure the end of this section is aligned

    END                     ; end of module

