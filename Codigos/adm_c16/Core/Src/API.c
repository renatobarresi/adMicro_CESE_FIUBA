/*
 * API.c
 *
 *  Created on: May 23, 2022
 *      Author: renato
 */


#include <stdio.h>
#include <sys/_stdint.h>
#include "API.h"

void zeros(uint32_t * vector, uint32_t longitud){
	for(uint32_t i = 0; i < longitud; i++){
		*(vector + i) = 0;
	}
}
void productoEscalar32(uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar){
	for(uint32_t i = 0; i < longitud; i++){
		*(vectorOut + i) = (*(vectorIn + i))*escalar;
	}
}
void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar){
	uint64_t producto;
	for(uint32_t i = 0; i < longitud; i++){
		producto = (*(vectorIn + i))*escalar;

		if(producto < *(vectorIn + i)) *(vectorOut + i) = 65535;
		else *(vectorOut + i) = producto;
	}
}
void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar){
	uint64_t producto;
	for(uint32_t i = 0; i < longitud; i++){
		producto = (*(vectorIn + i))*escalar;

		if(producto > 4095) *(vectorOut + i) = 4095;
		else *(vectorOut + i) = producto;
	}
}

void filtroVentana10(uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitudVectorIn){
	uint16_t ventana = 10;

	for(uint32_t i = 0; i < longitudVectorIn; i++){
		uint16_t promedio = 0;
		/*Verificar que existan los elementos minimos para el promedio*/
		if(longitudVectorIn - i >  ventana){
			for(uint8_t a = 0; a < ventana ; a++){
				promedio += *(vectorIn + (i + a));
			}
			*(vectorOut+i) = promedio/ventana;
		}else{
			/*Obtener posicion auxiliar maxima*/
			uint8_t posAux = ventana - (longitudVectorIn - i);
			for(uint8_t a = i; a < longitudVectorIn ; a++){
				promedio += *(vectorIn + (a));
			}
			for(uint8_t a = 0; a < posAux ; a++){
				promedio += *(vectorIn + (a));
			}
			*(vectorOut+i) = promedio/ventana;
		}
	}
}
/*Divide a 32bit number into two 16bit parts, discard the LS half word and store the MS half word in the 16bit vectorOut*/
void pack32to16(int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud){
	/*Check if number is greater than 16 bits*/
	for(uint32_t i = 0; i < longitud; i++){
		*(vectorOut + i) = (int16_t) (*(vectorIn + i) >> 16);
	}
}

int32_t max(int32_t * vectorIn, uint32_t longitud){
	int32_t maxNum;
	int32_t pos;
	maxNum = *(vectorIn);
	for(uint32_t i = 0; i<longitud; i++){
		if(*(vectorIn + i) > maxNum){
			maxNum = *(vectorIn + i);
			pos = i;
		}
	}
	return pos;
}

void downsampleM(int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N){
	uint32_t a = 0; //indice de vectorOut
	for(uint32_t i = 0; i<longitud; i++){
		if(i%N != 0){
			*(vectorOut+a) = *(vectorIn+i);
			a++;
		}
	}
}

void invertir(uint16_t * vector, uint32_t longitud){
    uint16_t auxVar;
    uint32_t auxLen = longitud >> 1;

	for(uint32_t i = 0; i < auxLen; i++){
		auxVar = *(vector + (longitud - 1 -i));
		*(vector + (longitud-1-i) ) = *(vector+i);
		*(vector + i) = auxVar;
	}
}

void corr(int16_t *vectorX, int16_t *vectorY, int32_t *vectorCorr, uint32_t longitud){

	uint32_t longVecCorr = longitud*2 - 1;
    uint32_t indexCorrelation; //index of items of vectors to multiply
    uint32_t auxLong;

    for(uint32_t i = 0; i<longVecCorr; i++){

		int32_t sum = 0; //stores the sum of the products of the values of the vectors to multiply

        if(i<longitud){
            indexCorrelation = 0;
            auxLong = (longitud - 1) - i;
            while(indexCorrelation <= i){
                sum += vectorX[indexCorrelation]*vectorY[auxLong];
                indexCorrelation++;
                auxLong++;
            }
        }else{
            indexCorrelation = longitud-1;
            auxLong = 2*(longitud - 1) - i;
            while(auxLong >= 0){
                sum += vectorX[indexCorrelation]*vectorY[auxLong];
                if(auxLong == 0) break;
                auxLong--;
                indexCorrelation--;
            }
        }

        /*Store the sum in vectorCorr*/
        *(vectorCorr+i) = sum;
	}
}

