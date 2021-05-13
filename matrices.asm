## begin memcpy
# Copies a memory portion.
# (in) a0: source matrix address
# (in) a1: destination matrix address
# (in) a2: bytes to copy
memcpy:
	bge zero, a2, memcpy_end # a2 <= 0  <=>  0 >= a2
	
	lb t0, 0(a0) # tmp = *src_addr
	sb t0, 0(a1) # *dst_addr = tmp
	
	addi a0, a0, 1 # src_addr ++
	addi a1, a1, 1 # dst_addr ++
	addi a2, a2, -1
	j memcpy
memcpy_end:
	ret
## end memcpy


## begin square_matrix_index_at
# Returns the index of the cell (a0, a1) of a square matrix
# (out) a0: index
# (in) a0: row
# (in) a1: column
# (in) a2: width in power of two form
square_matrix_index_at:
	sll a0, a0, a2	# row_offset = row * 2^(width in power of two form)
	add a0, a0, a1 # index = row_offset + column
	jr ra
## end square_matrix_index_at
	
