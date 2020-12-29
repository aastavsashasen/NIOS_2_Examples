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

.global	_start # ============= 
_start:
movui r3, 0xFA00  	 # start address to read from
movui r4, 0xEA00 	 # start address to write to
# assigning values to FE00 and EA00 addresses
movi r20, 2d
movi r21, 3d
stw r20, (r3)
stw r21, (r4)
# ================== constants
movi r5, 10d   		 # number of memory locations
movi r6, 1d    		 # constant = 1
main_loop:
ldwio r7, (r3)		#load the value of the address in r3 into r7 
beq r7, r6, Mul_By_2     	# branch to Mul_By_2 if r7 is 1
muli r7, r7, 5d           	# multiply by 5 
store:	
stwio r7, (r4) 		#store value of register in address r4
addi r3, r3, 0x01   		# increment r3
addi r4, r4, 0x01  		# increment r4
subi r5, r5, 0x01    		# decrement r5
beq r5,r0, end_program	#check counter == zero, to end_program if it is
br main_loop		#otherwise loop 
Mul_By_2:
muli r7, r7, 0x2		#multiply by 2
br store		#branch to store 
end_program:
.end

	
	
	