/*
    Structural hazard
*/

    li  x1, 0x1       /*x1=1*/
    li  x2, 0x2        /*x2=2*/
    add x3, x2, x1      /*x3=3*/
    sw  x3, 0(x2)       
    add x1, x2, x2      /*x1=4*/
    add x2, x1, x1      /*x2=8*/
    add x4, x1, x2      /*x4=12*/
    add x5, x4, x1      /*x5=16*/
    add x1, x2, x2      /*x1=16*/
