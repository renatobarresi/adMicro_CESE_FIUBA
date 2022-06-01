/*
 * API.h
 *
 *  Created on: May 23, 2022
 *      Author: renato
 */

#ifndef INC_API_H_
#define INC_API_H_

#include "main.h"

void zeros(uint32_t * vector, uint32_t longitud);
void productoEscalar32(uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);
void productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);

#endif /* INC_API_H_ */
