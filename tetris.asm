.globl main board

.data

screen: .space 4096

tetrominos: .byte 
	0 0 0 0 # I
	1 1 1 1
	0 0 0 0
	0 0 0 0
	
	1 0 0 0 # J
	1 1 1 0
	0 0 0 0
	0 0 0 0
	
	0 0 1 0 # L
	1 1 1 0
	0 0 0 0
	0 0 0 0
	
	0 1 1 0 # O
	0 1 1 0
	0 0 0 0
	0 0 0 0
	
	0 1 1 0 # S
	1 1 0 0
	0 0 0 0
	0 0 0 0
	
	0 1 0 0 # T
	1 1 1 0
	0 0 0 0
	0 0 0 0
	
	1 1 0 0 # Z
	0 1 1 0
	0 0 0 0
	0 0 0 0

tetromino_colors: .word
    	0x01eff2 # I
	0x0001ec # J
	0xf29f03 # L
	0xf1f000 # O
	0x01f000 # S
	0x9e01ee # T
	0xf20000 # Z

board: .space 240


.text
main:
	call clear_board
	

	li t5, 0
loop:
	call draw
	not t5, t5
	j loop

	jal zero, end
	



## begin clear_board
# Zeroes the board
clear_board:
	la t0, board
	addi t1, t0, 240
	
	li t3, 0xFFFFFFFF
clear_board_loop:
	sw t3, 0(t0)
	addi t0, t0, 4
	bne t0, t1, clear_board_loop
	jalr zero, ra, 0
## end clear_board


## begin draw
draw:
	# Screen config: 32x32, base address: 0x10010000, 
	# Play area 20x10 (board+39 -> board+239)
	
	la t0, board
	addi t0, t0, 39 # t0 = board start address
	addi t1, t0, 200 # t1 = board end address
	la t2, screen # t2 = screen address
	
	addi t2, t2, 4 # offset right
	
	li t3, 10 # t3 = i = 0
	
draw_loop:
	bgt t0, t1, draw_end
	
	bgt t3, zero, draw_body
	#not t5, t5
	addi t2, t2, 88
	li t3, 10
draw_body:
	lb t4, 0(t0)
	beq t4, zero, draw_nodraw
	
	## Draw code begin
	sw t5, 0(t2)
	#not t5, t5
	## Draw code end
	
draw_nodraw:
	addi t2, t2, 4
	addi t3, t3, -1

	addi t0, t0, 1
	j draw_loop
	
draw_end:
	ret

	
	
	
	

## end draw
	
end:
