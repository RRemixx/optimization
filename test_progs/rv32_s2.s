        
        li x8, 0x1
        li x1, 0x2
        sw x1, 0(x8)      /*  mem[1] = 2   */
        sw x1, 3(x8)      /*  mem[4] = 2   */
        li x8, 0x1
        li x1, 0x2
        lw	x1,0(x8)      /*  x1 = 2       */
        addi x2,x1,8      /*  x2 = 10      */
        lw	x1,3(x8)      /*  x1 = 2       */
       	sw	x2,0(x1)      /*  mem[4] = 2   */
