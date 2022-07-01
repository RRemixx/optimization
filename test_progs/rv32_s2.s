    data = 0x1000
	li	x4, data
	li	x5, 0x1008
	li	x6, 0x1010
	li	x10, 2
	li	x2, 1
	sw	x2, 0(x4)
	sw	x2, 0(x5)
    nop
    nop
    nop
    nop
    nop
    lw	x2, 0(x4)
	lw	x3, 0(x5)
    add x3, x3, x10
    wfi
