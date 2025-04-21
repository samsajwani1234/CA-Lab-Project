main:
    li s0, 0x100 #base address of array

    li t1, 9
    sw t1, 0(s0)

    li t1, 5
    sw t1, 4(s0)

    li t1, 1
    sw t1, 8(s0)

    li t1, 4
    sw t1, 12(s0)

    li t1, 3
    sw t1, 16(s0)
    
    li t1 2
    sw t1 20(s0)
    
    li t1 10
    sw t1 24(s0)

    li t0, 7         # t0 = array size (n)
    li t1, 1         # i = 1

outer_loop:
    bge t1, t0, end     # if i >= n, end
    slli t4, t1, 2      # t4 = i * 4
    add t4, s0, t4      # address of array[i]
    lw t2, 0(t4)        # t2 = key = array[i]
    addi t3, t1, -1     # j = i - 1

inner_loop:
    blt t3, zero, insert_key     # if j < 0, insert
    slli t4, t3, 2
    add t4, s0, t4
    lw t5, 0(t4)                 # t5 = array[j]
    ble t5, t2, insert_key
    sw t5, 4(t4)                 # array[j+1] = array[j]
    addi t3, t3, -1
    j inner_loop

insert_key:
    slli t4, t3, 2
    add t4, s0, t4
    sw t2, 4(t4)                # array[j+1] = key
    addi t1, t1, 1
    j outer_loop

end:
    li a0, 10
    ecall