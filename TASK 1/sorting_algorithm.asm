    addi  x18, x0, 0         # to track a[i] offset
    add   x8,  x0, x0        # i iterator (starts at 0)
    addi  x11, x0, 10        # loop bound n = 10

outerloop:
    beq   x8,  x11, outerexit  # if i == n, exit
    add   x29, x0, x8          # j iterator = i

    add   x19, x8, x0          
    add   x19, x19, x19        
    add   x19, x19, x19        # x19 = 4*x8 (byte offset)

innerloop:
    beq   x29, x11, innerexit  # if j == n, inner loop done
    addi  x29, x29, 1          # j++
    addi  x19, x19, 8          # offset += 8

    lw    x26, 0(x18)          # load a[i]
    lw    x27, 0(x19)          # load a[j]

    blt   x26, x27, bubblesort # if a[i] < a[j], swap
    beq   x0,  x0, innerloop   # else continue

bubblesort:
    add   x5,  x0, x26         # temp = a[i]
    sw    x27, 0(x18)          # a[i] = a[j]
    sw    x5,  0(x19)          # a[j] = temp
    beq   x0,  x0, innerloop   # restart inner

innerexit:
    addi  x8,  x8, 1           # i++
    addi  x18, x18, 8          # offset += 8
    beq   x0,  x0, outerloop   # back to outer

outerexit:
    # done
