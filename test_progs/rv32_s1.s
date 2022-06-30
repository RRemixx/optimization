/*
    passed
*/

/*
    only D1 and D2 hazards
*/

   
    li  x1, 0x1
    nop
    nop
    nop
    nop
    li  x2, 0x2
    nop
    nop
    nop
    nop
    add x3, x2, x1             /* 3*/
    add x4, x3, x2		 /* 5*/
    add x5, x4, x3			 /* 8*/
    add x6, x5, x4		 /* 13*/
    add x7, x6, x5			 /* 21*/
    wfi