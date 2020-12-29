/* Memory */
.equ SDRAM_BASE, 0x00000000
.equ SDRAM_END, 0x03FFFFFF
.equ FPGA_PIXEL_BUF_BASE, 0x08000000
.equ FPGA_PIXEL_BUF_END, 0x0800FFFF
.equ FPGA_CHAR_BASE, 0x09000000
.equ FPGA_CHAR_END, 0x09001FFF
/* Devices */
.equ LED_BASE, 0xFF200000
.equ LEDR_BASE, 0xFF200000
.equ HEX3_HEX0_BASE, 0xFF200020
.equ HEX5_HEX4_BASE, 0xFF200030
.equ SW_BASE, 0xFF200040
.equ KEY_BASE, 0xFF200050
.equ JP1_BASE, 0xFF200060
.equ ARDUINO_GPIO, 0xFF200100
.equ ARDUINO_RESET_N, 0xFF200110
.equ JTAG_UART_BASE, 0xFF201000
.equ TIMER_BASE, 0xFF202000
.equ TIMER_2_BASE, 0xFF202020
.equ PIXEL_BUF_CTRL_BASE, 0xFF203020
.equ CHAR_BUF_CTRL_BASE, 0xFF203030

.text /*places the seperation*/

.equ ADDR_PUSHBUTTONS, 0xFF200050 
.equ LED_BASE, 0xff200000 
.equ STACK_END, 0x007FFFFC 
.equ ADDR_SLIDESWITCHES, 0xFF200040 
.section .exceptions, "ax“ 

.global exception_handler 
exception_handler: # It is the exception handler that decides which hardware interrupt service routine to call  
subi sp, sp, 28 #save used regs on stack   
stw r7, 0(sp) # value repr. on LED lights  
stw r8, 4(sp) # store LED_BASE (address)  
stw ra, 8(sp)  
stw r5, 12(sp) # pushbuttons address  
stw r6, 16(sp) # edge capture 
stw r9, 20(sp) # switch address  
stw r10, 24(sp) # value on switches 

/* interrupts are enabled, check if any are pending */ 
# Check if external interrupt occurred  
rdctl  et, ipending  # If zero, check for other exceptions  
beq  et, r0, other_exceptions 
/* upon return, execute the interrupted instruction */ 
# Hardware interrupt, decrement ea by 4 (one instruction)  
# ie) to execute interrupted instruction upon   
# return to main program  
subi  ea, ea, 4   
andi et, et, 0x2    # Check if IRQ1 asserted 
# if not check other interrupts   
beq   et, r0, other_interrupts  
call  ext_irq1 # if yes => IRQ1 routine 

other_interrupts: 
/* Insert instructions to handle other interrupts here */  
br  end_handler    # Done handling HW interrupts 
other_exceptions: 
/* Insert instructions to handle other exceptions here */ 
# Not using any other exceptions end_handler: 
/* restore used regs from stack */  
ldw  r7, 0(sp) # value repr. on LED lights  
ldw  r8, 4(sp) # store LED_BASE (address)  
ldw  ra, 8(sp)  
ldw r5, 12(sp) # pushbuttons address  
ldw r6, 16(sp) # edge capture 
ldw r9, 20(sp) # switch address 
ldw r10, 24(sp) # value on switches  
addi  sp, sp, 28  
eret 

ext_irq1:  
movia  r9,ADDR_SLIDESWITCHES # base address for switches  
ldwio  r10, 0(r9)  # Read switches  
movia  r8, LED_BASE # base address for LEDR  
ldwio  r7, (r8) # load from LED base address  
# base address of pushbutton KEY (parallel port)  
movia r5, ADDR_PUSHBUTTONS 
                                                                                            
ldwio  r6, 12(r5) # load edge capture register (base+12) 
# mask for pushbutton 1 pressed   
andi r6, r6, 0x2  
beq r6, r0, slide_left  
srl r7, r7, r10 #slide LED’s right by r10  
br  next    

slide_left:     
sll r7, r7, r10 #slide LED’s left by r10  
next:    
stwio r7, (r8) # push new value to LED’s movia r7, 0x3  
# writing 1 to edge capture register clears it   
stwio r7, 12(r5)    
ret 
 
.global _start 
_start: 
movia sp, STACK_END  # initialize stack  
movia ra, _start 
movia r2, ADDR_PUSHBUTTONS 
movia r3,0x3 # mask for interrupts 
stwio r3,8(r2)  # Enable interrupts on pushbuttons 0 and 1, 
# ie) in the interrupt mask register  
# now Clear edge capture register to prevent unexpected interrupt 
stwio r3,12(r2) 
movia r8, LED_BASE # store LED address 
movi r7, 0x38 # turn on the LED's 4 to 6 = 111000 
stwio r7, (r8) # update LED values 
# To enable pushbutton interrupts… 
movia r2, 0x2 
# Enable bit 1 - Pushbuttons use IRQ 1 
wrctl ienable,r2 
movia r2,1 
# Enable global Interrupts on Processor  
wrctl status,r2 

Loop:  # infinite loop…          
nop          
br Loop