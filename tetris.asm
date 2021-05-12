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
	
	jal zero, end

## begin clear_board
# Zeroes the board
clear_board:
	la t0, board
	addi t1, t0, 240
	
	li t2, 1
clear_board_loop:
	sb t2, 0(t0)
	addi t0, t0, 1
	blt t0, t1, clear_board_loop
	jr ra
## end clear_board



## begin screen_address_at
# Returns the address of the cell (a0, a1) of the screen.
# (out) a0: address
# (in) a0: row
# (in) a1: column
screen_address_at:
	slli a0, a0, 7	# row_offset = row * 32 * 4
	slli a1, a1, 2	# column_offset = column * 4

	la t0, screen
	add a0, a0, t0	# result = row_offset + screen base address
	add a0, a0, a1	# result = screen_addr + column_offset
	jr ra
## end screen_address_at


## begin screen_newline_offset
# Returns the number of bytes a loop has to skip to reach a screen newline.
# (out) a0: offset
# (in) a0: draw area width
screen_newline_offset:
	# result = (32 - draw area width) * 4
	li t0, 32
	sub a0, t0, a0 # result = 32 - draw area width
	slli a0, a0, 2 # result *= 4
	
	jr ra
## end screen_newline_offset



## begin draw_box
# Draws a a2 x a3 box at (a0, a1).
# (in) a0: row
# (in) a1: column
# (in) a2: width
# (in) a3: height
# (in) a4: color
draw_box:
	addi sp, sp, -20
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)

	mv s0, a2 # s0 = width
	mv s1, a3 # s1 = height
	mv s2, a4 # s2 = color
	
	call screen_address_at
	mv s3, a0 # s3 = draw address
	
	mv a0, s0
	call screen_newline_offset
	# a0 = screen newline offset
	
	li t0, 0 # row = 0
draw_box_row_loop:
	bge t0, s1, draw_box_row_loop_end
	li t1, 0 # col = 0
draw_box_column_loop:
	bge t1, s0, draw_box_column_loop_end
	
	sw s2, 0(s3)
	
	addi t1, t1, 1
	addi s3, s3, 4
	j draw_box_column_loop
draw_box_column_loop_end:
	add s3, s3, a0
	addi t0, t0, 1
	j draw_box_row_loop
draw_box_row_loop_end:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	addi sp, sp, -20
	jr ra
## end


## begin blit
# Blits a portion of a matrix at a position on the screen.
# Colors are picked from colors based on the value in the matrix cell.
# 
# row, column: position where to draw
# (in) a0: row
# (in) a1: column
# draw box: portion of matrix to draw
# (in) a2: draw box row
# (in) a3: draw box column
# (in) a4: draw box width
# (in) a5: draw box height
# source matrix info
# (in) a6: matrix base address
# (in) a7: matrix width

blit:
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
	lb t4, 0(a6)
	la t5, colors
	slli t4, t4, 2
	add t5, t5, t4
	lw t4, 0(t5)
	sw t4, 0(a0)

	
	addi a0, a0, 4 # screen draw address += 4
	addi a6, a6, 1 # matrix read address += 1
	addi t3, t3, 1 # ++col
	j blit_column_loop
	
blit_column_loop_end:
	addi t2, t2, 1 # ++row
	add a0, a0, t1 # screen address += screen newline offset
	add a6, a6, a7 # matrix address += matrix newline offset
	
	j blit_row_loop
blit_row_loop_end:

	lw ra, 0(sp)
	lw s0, 4(sp)
	addi sp, sp, 4

	ret
## end blit


	
end:
