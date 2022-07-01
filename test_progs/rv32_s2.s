/*
    
*/

/*
    Control hazard
*/

    li  x1, 0x1       /*x1=1*/
    li  x2, 0x2        /*x2=2*/
    bne x1, x2, loop #   /*branch taken*/
    add x3, x2, x1        
    add x1, x2, x2      
    add x4, x1, x2      
    nop
    nop
    wfi
loop: add x5, x2, x1      /*x5=3*/
    add x1, x2, x2      /*x1=4*/
    wfi
