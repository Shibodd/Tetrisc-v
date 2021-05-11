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
	
	la a0, board # matrix addr
	li a1, 10 # matrix width
	li a2, 0 # draw box row
	li a3, 0 # draw box column
	li a4, 10 # draw box width
	li a5, 20 # draw box height
	li a6, 0 # row
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
	blt t0, t1, clear_board_loop
	jr ra
## end clear_board


## begin blit
# Blits a portion of a matrix at a position on the screen.
# Colors are picked from colors based on the value in the matrix cell.
# 
# (in) a0: matrix base address
# (in) a1: matrix width (in power of 2 form)
# draw box: portion of matrix to draw
# (in) a2: draw box row
# (in) a3: draw box column
# (in) a4: draw box width
# (in) a5: draw box height
# row, column: position where to draw
# (in) a6: row
# (in) a7: column
blit:
	## t0 = screen address
	la t0, screen	# screen_addr = screen base address
	slli t1, a6, 7	# row_offset = row * 32 * 4
	add t0, t0, t1	# screen_addr += row_offset
	slli t1, a7, 2	# column_offset = column * 4
	add t0, t0, t1	# screen_addr += column_offset
	
	## a0 = matrix address
	sll t1, a2, a1	# row_offset = row * matrix width
	add a0, a0, t1	# mat_addr += row_offset
	add a0, a0, a3	# mat_addr += column
	
	## t1 = screen newline offset = (32 - a4) * 4
	li t1, 32
	sub t1, t1, a4
	slli t1, t1, 2
	
	## a1 = matrix newline offset = (mat_width - draw box width) * 4
	sub a1, a1, a4
	slli a1, a1, 2
	
	# t2 = row index
	# t3 = column index
	
	# for (t3 = 0; t3 < a5; ++t3)
	li t2, 0
blit_row_loop:
	bge t2, a5, blit_row_loop_end
	
	# for (t4 = 0; t4 < a4; ++t4)
	li t3, 0
blit_column_loop:
	bge t3, a4, blit_column_loop_end

	
	# Load the color
	lb t4, 0(a0)
	la t5, colors
	slli t4, t4, 2
	add t5, t5, t4
	lw t4, 0(t5)
	sw t4, 0(t0)

	
	addi t0, t0, 4 # screen draw address += 4
	addi a0, a0, 1 # matrix read address += 1
	addi t3, t3, 1 # ++col
	j blit_column_loop
	
blit_column_loop_end:
	addi t2, t2, 1 # ++row
	add t0, t0, t1 # screen address += screen newline offset
	add a0, a0, a1 # matrix address += matrix newline offset
	
	j blit_row_loop
blit_row_loop_end:
	ret
## end blit


	
end:
