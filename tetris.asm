.globl main board

.data


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
	jal ra, clear_board
	jal ra, draw
	jal zero, end
	



## begin clear_board
# Zeroes the board
clear_board:
	la t0, board
	addi t1, t0, 240
	
	li t3, 0xFF
clear_board_loop:
	sb t3, 0(t0)
	addi t0, t0, 1
	bne t0, t1, clear_board_loop
	jalr zero, ra, 0
## end clear_board


## begin draw
draw:
	# Screen config: 32x32, base address: 0x10010000, 
	# Play area 20x10 (board+40 -> board+240)
	la t0, board
	addi t0, t0, 40
	addi t1, t0, 200
	li t2, 0x10010000
	li t3, -10
draw_loop:
	# do stuff
	
	addi t0, t0, 1
	blt t1, t0, draw_end
	addi t3, t3, 1
	addi t2, t2, 4
	bne t3, zero, draw_loop
	li t3, -10
	addi t2, t2, 12
	jal zero, draw_loop
	
draw_end:
	ret

	
	
	
	

## end draw
	
end:
