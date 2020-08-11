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

.global _start
_start:

# say the value of b is 0x02
# say the value of c is 0x03
movi r2, 0x00 # a value
movi r3, 0x02 # b value
movi r4, 0x03 # c value
movi r5, 0x04 # d value
#movi sp, 0xfffffff0

#MULT: # using loop rather than 'mul'
subi sp, sp, 8  # grow the stack by four bytes (a long word)
stw r3, 0(sp) # save the value of b onto the top of the stack
stw r4, 4(sp) # save the value of c in the 2nd position of the stack
mult_LOOP:
add r2, r2, r3 # add a value of b to a
subi r4, r4, 0x01 # decrement c as once instance of b collected
# now need to add b to a another c times!
# will result in a being the final solution being stored in a 
bne r4, r0, mult_LOOP # loop until c=0
# now c=0! so a=b+b+.... (done c times) = bxc
# but we need to restore b and c (from stack pointer)
ldw r3, 0(sp) # restore b value from top of stack
ldw r4, 4(sp) # similarly restore a value
addi sp, sp, 8 # remove a stored element
# assign our result to d
mov r5, r2

.end 
	
	
	