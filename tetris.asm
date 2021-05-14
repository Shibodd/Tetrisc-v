.globl main board

.data

screen: .space 4096

tetromino_matrices: .byte 
	0 0 0 0 # I
	1 1 1 1
	0 0 0 0
	0 0 0 0
	
	2 0 0 0 # J
	2 2 2 0
	0 0 0 0
	0 0 0 0
	
	0 0 3 0 # L
	3 3 3 0
	0 0 0 0
	0 0 0 0
	
	0 4 4 0 # O
	0 4 4 0
	0 0 0 0
	0 0 0 0
	
	0 5 5 0 # S
	5 5 0 0
	0 0 0 0
	0 0 0 0
	
	0 6 0 0 # T
	6 6 6 0
	0 0 0 0
	0 0 0 0
	
	7 7 0 0 # Z
	0 7 7 0
	0 0 0 0
	0 0 0 0

colors: .word
	0x0F0F2F # Nothing
    	0x01eff2 # I
	0x0001ec # J
	0xf29f03 # L
	0xf1f000 # O
	0x01f000 # S
	0x9e01ee # T
	0xf20000 # Z

board: .space 240

matrix_rotation_temp: .space 16
falling_tetromino_matrix: .space 16
falling_tetromino_type: .byte 4
falling_tetromino_r: .byte 2
falling_tetromino_c: .byte 5


.text
## begin main
main:
	# background color
	li a0, 0
	li a1, 0
	li a2, 32
	li a3, 32
	li a4, 0x0F0F2F
	call draw_box
	
	#border
	li a0, 5
	li a1, 10
	li a2, 12
	li a3, 22
	li a4, 0xAAAAAA
	call draw_box
	
	
	call test
	
	
	li a0, 0
	li a7, 93
	ecall 
## end main


## begin test
test:
	addi sp, sp, -8
	sw ra, 0(sp)
	sw s0, 4(sp)

	# set falling tetromino type
	la t0, falling_tetromino_type
	li t1, 2
	sb t1, 0(t0)
	mv s0, t1 # s0 = tetromino type
	
	la a0, falling_tetromino_matrix
	la a1, tetromino_matrices
	mv t1, s0
	addi t1, t1, -1
	slli t1, t1, 4
	add a1, a1, t1
	li a2, 16
	call memcpy

	li a0, -1
	call rotate_tetromino
	
	call get_tetromino_matrix_size
	mv a2, a0 # (in) a2: draw box width
	mv a3, a0 # (in) a3: draw box height
	
	li a0, 10 # (in) a0: row
	li a1, 16 # (in) a1: column
	li a4, 0 # (in) a4: draw box row
	li a5, 0 # (in) a5: draw box column
	la a6, falling_tetromino_matrix # (in) a6: matrix address
	li a7, 4 # (in) a7: matrix width
	call blit
	

	lw ra, 0(sp)
	lw s0, 4(sp)
	addi sp, sp, 8
	
	ret
## end test



## begin get_tetromino_matrix_size
# (out) a0: the size of the matrix of the current tetromino
get_tetromino_matrix_size:
	lb t0, falling_tetromino_type
	addi t0, t0, -1
	beq t0, zero, get_tetromino_matrix_size_typeI
	li a0, 3
	ret
get_tetromino_matrix_size_typeI:
	li a0, 4
	ret
	
## end get_tetromino_matrix_size



## begin rotate_tetromino
# (in) a0: direction (if a0 >= 0 then right, else left)
rotate_tetromino:
	lb t0, falling_tetromino_type
	addi t0, t0, -4
	bne t0, zero, rotate_tetromino_ok # Return if falling_tetromino_type = 4
	ret
rotate_tetromino_ok:
	addi sp, sp, -24
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s3, 16(sp)
	sw s4, 20(sp)
	
	mv s4, a0 # s4 = rotation direction
	
	call get_tetromino_matrix_size
	
	mv s2, a0 # t2 = tetromino matrix size
	
	li a2, 2 # width argument of square_matrix_index_at

	li s0, 0 # s0 = row
rotate_tetromino_row_loop:
	bge s0, s2, rotate_tetromino_row_loop_end
	li s1, 0 # s1 = column
rotate_tetromino_column_loop:
	bge s1, s2, rotate_tetromino_column_loop_end
	
	# new column = tetromino matrix size - 1 - row
	
	# square_matrix_index_at:
	# (out) a0: index
	# (in) a0: row
	# (in) a1: column
	# (in) a2: width in power of two form
	
	mv a0, s0
	mv a1, s1
	call square_matrix_index_at
	la s3, falling_tetromino_matrix
	add s3, s3, a0 
	# s3 = src address
	
	
	# a0 = new row
	# a1 = new column
	bge s4, zero, rotate_tetromino_right_calc
rotate_tetromino_left_calc:	
	# new row = tetromino matrix size - 1 - column
	# new column = row
	mv a1, s0 # new column = row
	addi a0, s2, -1 # new row = tetromino matrix size - 1
	sub a0, a0, s1 # new row -= column
	
	j rotate_tetromino_calc_end
rotate_tetromino_right_calc:	
	# new row = column
	# new column = tetromino matrix size - 1 - row
	mv a0, s1 # new row = column
	addi a1, s2, -1 # new column = tetromino matrix size - 1
	sub a1, a1, s0 # new column -= row
	
rotate_tetromino_calc_end:
	call square_matrix_index_at 
	la t4, matrix_rotation_temp
	add a0, a0, t4 
	# a0 = dst address

	lb s3, 0(s3)
	sb s3, 0(a0)

	addi s1, s1, 1 # column++
	j rotate_tetromino_column_loop
rotate_tetromino_column_loop_end:
	addi s0, s0, 1 # row++
	j rotate_tetromino_row_loop
rotate_tetromino_row_loop_end:
	
	la a0, falling_tetromino_matrix
	la a1, matrix_rotation_temp
	li a2, 16
	call memcpy

	
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s3, 16(sp)
	lw s4, 20(sp)
	addi sp, sp, 24
	ret
	
## end rotate_tetromino

.include "matrices.asm"
.include "drawing.asm"
	
end:
