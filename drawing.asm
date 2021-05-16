
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
	li a2, 5 # log2(32)
	
	addi sp, sp, -4
	sw ra, 0(sp)
	call square_matrix_index_at
	lw ra, 0(sp)
	addi sp, sp, 4
	
	slli a0, a0, 2 # index * 4
	la t0, screen
	add a0, a0, t0 # address
	ret
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
# Draws a portion of a matrix at a certain position.
# Colors are picked from colors table, using the values in the matrix cells as indexes, or transparent if the value is 0.
# (in) a0: row
# (in) a1: column
# (in) a2: draw box width
# (in) a3: draw box height
# (in) a4: draw box row
# (in) a5: draw box column
# (in) a6: matrix address
# (in) a7: matrix width
blit:
	addi sp, sp, -36
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	sw s5, 24(sp)
	sw s6, 32(sp)
	
	mv s0, a2 # s0 = dbx width
	mv s1, a3 # s1 = dbx height
	mv s2, a4 # s2 = dbx row
	mv s3, a5 # s3 = dbx column
	mv s4, a6 # s4 = mtx add
	mv s5, a7 # s5 = mtx width
	
	call screen_address_at
	mv s6, a0 # s6 = screen address
	
	mv a0, s0
	call screen_newline_offset # a0 = screen newline offset
	
	# t0 = matrix address
	mul t0, a7, a4 # mat addr = mat width * dbx row
	add t0, t0, a5 # mat addr += dbx column
	add t0, t0, s4
	
	# t1 = matrix newline offset
	sub t1, s5, s0
	
	la t6, screen # t6 = screen min address

	li t2, 0 # row = 0
blit_row_loop:
	bge t2, s1, blit_row_loop_end # if row > dbx height then goto row loop end
	
	li t3, 0 # column = 0
blit_col_loop:
	bge t3, s0, blit_col_loop_end # if column > dbx width then goto col loop end
	
	# Load the color
	la t4, colors # t4 = colors
	lb t5, 0(t0) # color index = matrix[t2, t3]
	
	# Skip if zero
	beq t5, zero, blit_col_loop_continue
	
	slli t5, t5, 2 # color offset = color index * 4
	add t4, t4, t5 # t4 = colors + color_index
	
	# Write the color
	lw t4, 0(t4) # t4 = *t4
	sw t4, 0(s6) # *s6 = t4
	
blit_col_loop_continue:
	
	addi t0, t0, 1 # matrix add++
	addi s6, s6, 4 # screen add += 4
	addi t3, t3, 1 # column++
	j blit_col_loop
blit_col_loop_end:
	add t0, t0, t1 # matrix add += matrix newline offset
	add s6, s6, a0 # screen add += screen newline offset
	addi t2, t2, 1 # row ++
	j blit_row_loop
blit_row_loop_end:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	lw s5, 24(sp)
	lw s6, 32(sp)
	addi sp, sp, 36
	
	ret
	
## end blit
