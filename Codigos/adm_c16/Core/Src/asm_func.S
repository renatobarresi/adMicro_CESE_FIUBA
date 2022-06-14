.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12

.global asm_filtroVentana10
.global asm_pack32to16
.global asm_max
.global asm_downsampleM
.global asm_invertir

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_zeros (uint32_t *vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud
@
.thumb_func
    asm_zeros:
        @ Registros usados
        @   r2: valor cero
        mov r2, 0           @ constante cero
    .asm_zeros_loop:
        str r2, [r0], 4     @ sizeof(uint32_t) == 4, *vector++ = r2
        subs r1, 1          @ --longitud
        bne .asm_zeros_loop
        bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar32(uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
.thumb_func
	asm_productoEscalar32:

	.asm_productoEscalar32_loop:
		//Guardar valor en direccion R0 en R5 e incrementar en 4
		ldr r5, [r0], 4
		//Multiplicar R0 por R5 y guardar en R4
		mul r4, r5, r3
		//Guardar valor de R4 en R1 e incrementar en 4 direccion en R1
		str r4, [r1], 4
		//Restar longitud hasta que sea negativo
		subs r2, 1
		bne .asm_productoEscalar32_loop
		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
.thumb_func
	asm_productoEscalar16:
		mov r6, 65535
	.asm_productoEscalar16_loop:
		//Guardar valor en direccion R0 en R5 e incrementar en 4
		ldrh r5, [r0], 2
		//Multiplicar R0 por R5 y guardar en R4
		mul r4, r5, r3
		//Si el valor en R4 es mayor a 65535 cargar a registro
		cmp r4, r6 			 //r4 > r6?
		bgt greater_than
		//Guardar valor de R4 en R1 e incrementar en 4 direccion en R1
		strh r4, [r1], 2
		b cont
		greater_than:
			mov r4, 65535
			str r4, [r1], 2
		//Restar longitud hasta que sea negativo
		cont:
			subs r2, 1
			bne .asm_productoEscalar16_loop
			bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
@	r3: escalar
.thumb_func
	asm_productoEscalar12:
		mov r6, 4095
	.asm_productoEscalar12_loop:
		//Guardar valor en direccion R0 en R5 e incrementar en 4
		ldrh r5, [r0], 2
		//Multiplicar R0 por R5 y guardar en R4
		mul r4, r5, r3
		//Si el valor en R4 es mayor a 65535 cargar a registro
		cmp r4, r6 			 //r4 > r6?
		bgt greater_than12
		//Guardar valor de R4 en R1 e incrementar en 4 direccion en R1
		strh r4, [r1], 2
		b cont12
		greater_than12:
			mov r4, 4095
			str r4, [r1], 2
		//Restar longitud hasta que sea negativo
		cont12:
			subs r2, 1
			bne .asm_productoEscalar16_loop
			bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitudVectorIn
.thumb_func
	asm_filtroVentana10:

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_pack32to16(int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@	r2: longitud
.thumb_func
	asm_pack32to16:
	mov r3, 0
	.asm_pack32to16_loop:
		ldr r3, [r0], 4
		lsr r3, 16
		strh r3, [r1], 2
		subs r1, 1
		bne .asm_pack32to16_loop
	bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@int32_t asm_max(int32_t * vectorIn, uint32_t longitud);
@
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: longitud
.thumb_func
	asm_max:
		ldr r2, [r0]
		mov r4, 1
		.asm_max_loop:
			ldr r3, [r0], 4
			cmp r3, r2
			bgt greather_than
			b contMax
			greather_than:
				mov r5, r4
			contMax:
				add r4, r4, 1
				subs r1, 1
				bne .asm_max_loop
		bx lr
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@void asm_downsampleM(int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N);
@
@ Parametros recibidos:
@   r0: *vectorIn
@   r1: *vectorOut
@ 	r2: longitud
@	r3: N
.thumb_func
	asm_downsampleM:

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_invertir(uint16_t * vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *vector
@   r1: longitud
.thumb_func
	asm_invertir:
		lsr r2, r1, 1	//longitud >> 1
		mov r3, 0		//i = 0
		.asm_invertir_loop:
			//vector + (longitud - i)
			sub r4, r1, 1   //r4 = longitud - 1
			sub r4, r4, r3  //r4 = longitud - 1 - i
			add r4, r0, r4  //r4 (apunta a fin del vector) = vector + a
			//r5 -> auxVar = *(vector + (longitud - 1 -i));
			ldrh r5, [r4]
			//(vector + (longitud-1-i) ) = *(vector+i);
			ldrh r6, [r0], 2
			strh r6, [r4]
			//*(vector + i) = auxVar;
			strh r5, [r0]

			add r3, r3, 1 //i++
			subs r2, 1
			bne .asm_invertir_loop
		bx lr

