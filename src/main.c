#include "stm32f10x.h"
#include "usart.h"
#include <stdio.h>

#ifdef __GNUC__
  /* With GCC/RAISONANCE, small printf (option LD Linker->Libraries->Small printf
     set to 'Yes') calls __io_putchar() */
  #define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
#else
  #define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)
#endif /* __GNUC__ */

/*
void STM_EVAL_LEDInit(Led_TypeDef Led)
{
  GPIO_InitTypeDef  GPIO_InitStructure;
  
  // Enable the GPIO_LED Clock 
  RCC_APB2PeriphClockCmd(GPIO_CLK[Led], ENABLE);

  // Configure the GPIO_LED pin 
  GPIO_InitStructure.GPIO_Pin = GPIO_PIN[Led];
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;

  GPIO_Init(GPIO_PORT[Led], &GPIO_InitStructure);
}

void STM_EVAL_LEDOn(Led_TypeDef Led)
{
  GPIO_PORT[Led]->BSRR = GPIO_PIN[Led];     
}

void STM_EVAL_LEDOff(Led_TypeDef Led)
{
  GPIO_PORT[Led]->BRR = GPIO_PIN[Led];  
}
*/


/**
  * @brief  Retargets the C library printf function to the USART.
  * @param  None
  * @retval None
  */
PUTCHAR_PROTOTYPE
{
  /* Place your implementation of fputc here */
  /* e.g. write a character to the USART */
  USART_SendData(USART1, (uint8_t) ch);
  /* Loop until the end of transmission */
  while (USART_GetFlagStatus(USART1, USART_FLAG_TC) == RESET)
  {}
  return ch;
}

void debug_log(char *str)
{
	int i,len;
	char c;
	len = strlen(str);
	for(i = 0; i< len; i++){
  		USART_SendData(USART1, (uint8_t) c);
  		while (USART_GetFlagStatus(USART1, USART_FLAG_TC) == RESET){;}
	}
}

#ifdef  USE_FULL_ASSERT

/**
  * @brief  Reports the name of the source file and the source line number
  *   where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t* file, uint32_t line)
{ 
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* Infinite loop */
  while (1)
  {
  }
}
#endif




int main(void)
{
    USART1_Config();//
    /*
    printf("*************************************************************\r\n");
    printf("*                                                           *\r\n");
    printf("* Thank you for using The Development Board Of YuanDi ! ^_^ *\r\n");
    printf("*                                                           *\r\n");
    printf("*************************************************************\r\n");
    */
    debug_log("start control led\n");
    while (1)
    {
      while (USART_GetFlagStatus(USART1,USART_FLAG_RXNE) == RESET);
      USART_SendData(USART1,USART_ReceiveData(USART1));
    }
}



/*********************************************************************************************************
      END FILE
*********************************************************************************************************/





