/*
    
*/

/*
    D3 hazard
*/  
   
    li  x1, 0x1       /*A*/
    li  x6, 0x1
    li  x7, 0x1
    li  x8, 0x1
    li  x9, 0x1
    li  x2, 0x2        /*B*/
    li  x4, 0x1
    li  x5, 0x1
    li  x6, 0x1
    li  x7, 0x1
    add x3, x2, x1
    add x4, x3, x2    /*D1 hazard on X3*/
    sw  x4, 0(x2)
    lw  x5, 0(x2)
    add x6, x5, x0
    wfi