.globl main board

.data

screen: .space 4096

tetromino_matrices: .byte 
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

colors: .word
	0	 # Nothing
    	0x01eff2 # I
	0x0001ec # J
	0xf29f03 # L
	0xf1f000 # O
	0x01f000 # S
	0x9e01ee # T
	0xf20000 # Z

board: .space 240


falling_tetromino_matrix: .space 16
falling_tetromino_type: .word 0
falling_tetromino_r: .word 2
falling_tetromino_c: .word 5



.text
main:
	call clear_board

	## begin blit
	li a0, 0 # matrix addr
	li a1, 3 # matrix width
	li a2, 0 # draw box row
	li a3, 0 # draw box column
	li a4, 2 # draw box width
	li a5, 2 # draw box height
	li a6, 1 # row
	li a7, 1 # column
	call blit
	
	jal zero, end
	



## begin clear_board
# Zeroes the board
clear_board:
	la t0, board
	addi t1, t0, 240
	
	li t3, 0
clear_board_loop:
	sw t3, 0(t0)
	addi t0, t0, 4
	bne t0, t1, clear_board_loop
	jr ra
## end clear_board


## begin blit
# (in) a0: matrix base address
# (in) a1: matrix width (in power of 2 form)
# draw box: subset of matrix to draw
# (in) a2: draw box row
# (in) a3: draw box column
# (in) a4: draw box width
# (in) a5: draw box height
# row, column: position where to draw
# (in) a6: row
# (in) a7: column
blit:
	## t0 = screen row base address
	la t0, screen  # screen_addr = screen base address
	slli t1, a6, 7 # row_offset = row * 32 * 4
	add t0, t0, t1 # screen_addr += row_offset
	slli t1, a7, 2 # column_offset = column * 4
	add t0, t0, t1 # screen_addr += column_offset
	
	## a0 = matrix row base address
	sll t1, a2, a1 # row_offset = row * matrix width
	add a0, a0, t1 # mat_addr += row_offset
	add a0, a0, a3 # mat_addr += column
	
	# t5 = matrix row size
	li t5, 1 # matrix row size = 1
	sll t5, t5, a1 # matrix row size = 2 ^ matrix width (in power of 2 form)
	
	# t1 = screen draw address
	# t2 = matrix read address
	# t3 = row index
	# t4 = column index
	
	# for (t3 = 0; t3 < a5; ++t3)
	li t3, 0
blit_row_loop:
	bge t3, a5, blit_row_loop_end
	mv t1, t0 # screen draw address = screen row base address
	mv t2, a0 # matrix read address = matrix row base address
	
	# for (t4 = 0; t4 < a4; ++t4)
	li t4, 0
blit_column_loop:
	bge t4, a4, blit_column_loop_end
	
	li t5, 0xFFFFFF
	sw t5, 0(t1)
	
	addi t1, t1, 4 # screen draw address += 4
	addi t2, t2, 1 # matrix read address += 1
	addi t4, t4, 1
	j blit_column_loop
	
blit_column_loop_end:
	addi t3, t3, 1
	addi t0, t0, 128 # screen row base address += 32 * 4 (newline)
	add a0, a0, t5 # matrix row base address += matrix row size (newline)
	
	j blit_row_loop
blit_row_loop_end:
	ret
## end blit


	
end:
