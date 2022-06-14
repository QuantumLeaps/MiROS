/* Board Support Package (BSP) for the NUCLEO-L152RE board */
#include <stdint.h>  /* Standard integers. WG14/N843 C99 Standard */

#include "bsp.h"
#include "miros.h"
#include "stm32l1xx.h"  /* CMSIS-compliant header file for the MCU used */
/* add other drivers if necessary... */

/* LED pins available on the board (just one user LED LD2--Green on PA.5) */
#define LED_LD2  (1U << 5)

/* Button pins available on the board (just one user Button B1 on PC.13) */
#define BTN_B1   (1U << 13)

void SysTick_Handler(void) {
    OS_tick();

    __disable_irq();
    OS_sched();
    __enable_irq();
}

void BSP_init(void) {
    /* enable GPIOA clock port for the LED LD2 */
    RCC->AHBENR |= (1U << 0);

    /* configure LED (PA.5) pin as push-pull output, no pull-up, pull-down */
    GPIOA->MODER   &= ~((3U << 2*5));
    GPIOA->MODER   |=  ((1U << 2*5));
    GPIOA->OTYPER  &= ~((1U <<   5));
    GPIOA->OSPEEDR &= ~((3U << 2*5));
    GPIOA->OSPEEDR |=  ((1U << 2*5));
    GPIOA->PUPDR   &= ~((3U << 2*5));

    /* enable GPIOC clock port for the Button B1 */
    RCC->AHBENR |=  (1U << 2);

    /* configure Button (PC.13) pins as input, no pull-up, pull-down */
    GPIOC->MODER   &= ~(3U << 2*13);
    GPIOC->OSPEEDR &= ~(3U << 2*13);
    GPIOC->OSPEEDR |=  (1U << 2*13);
    GPIOC->PUPDR   &= ~(3U << 2*13);
}

void BSP_ledRedOn(void) {
    /* no red LED on board */
}

void BSP_ledRedOff(void) {
    /* no red LED on board */
}

void BSP_ledBlueOn(void) {
    /* no blue LED on board */
}

void BSP_ledBlueOff(void) {
    /* no blue LED on board */
}

void BSP_ledGreenOn(void) {
    GPIOA->BSRRL |= LED_LD2;  /* turn LED on  */
}

void BSP_ledGreenOff(void) {
    GPIOA->BSRRH |= LED_LD2;  /* turn LED off */
}

void OS_onStartup(void) {
    SystemCoreClockUpdate();
    SysTick_Config(SystemCoreClock / BSP_TICKS_PER_SEC);

    /* set the SysTick interrupt priority (highest) */
    NVIC_SetPriority(SysTick_IRQn, 0U);
}

void OS_onIdle(void) {
#ifdef NDBEBUG
    __WFI(); /* stop the CPU and Wait for Interrupt */
#endif
}

void Q_onAssert(char const *module, int loc) {
    /* TBD: damage control */
    (void)module; /* avoid the "unused parameter" compiler warning */
    (void)loc;    /* avoid the "unused parameter" compiler warning */
    NVIC_SystemReset();
}
