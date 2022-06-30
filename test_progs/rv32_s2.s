/*
    S1 and S2 hazard passed
*/

/*
    D3 hazard
*/  
   
    li  x1, 0x1       /*x1=1*/
    li  x2, 0x2        /*x2=2*/
    add x3, x2, x1      /*x3=3*/
    add x4, x3, x2    /*x4=5*/
    sw  x4, 0(x2)       /*(*x2)=5*/
    lw  x5, 0(x2)       /*x5=5*/
    add x6, x5, x0      /*x6=5*/
    wfi