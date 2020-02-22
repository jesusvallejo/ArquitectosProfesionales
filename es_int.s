
*********************************
* Inicializa el SP y el PC
*********************************
        ORG     $0
        DC.L    $8000           * Pila
        DC.L    INICIO          * PC
        ORG		$400

*********************************
* Definicion de equivalencias
*********************************

MR1A    EQU     $effc01       * de modo A (escritura/lectura) 		*Configura el numero de bits por caracter de una linea en A
MR1B    EQU     $effc11       * de modo B (escritura/lectura) 		*Configura el numero de bits por caracter de una linea en B

MR2A    EQU     $effc01       * de modo A (escritura/lectura) 		*Configura el modo de operacion de la Duart(modo normal/ECO)
MR2B    EQU     $effc11       * de modo B (escritura/lectura) 		*Configura el modo de operacion de la Duart(modo normal/ECO)

SRA     EQU     $effc03       * de estado A (lectura)		  		*Se consulta el estado de la linea A
SRB		EQU	    $effc13       * de estado A (lectura)         		*Se consulta el estado de la linea B

CSRA    EQU     $effc03       * de seleccion de reloj A (escritura) *Configura junto con el ACR la velocidad de transmision de la Duart en A(38400)(pag. 39)
CSRB	EQU     $effc03       * de seleccion de reloj B (escritura) *Configura junto con el ACR la velocidad de transmision de la Duart en B(38400)(pag. 39)
ACR		EQU		$effc09	      * de control auxiliar					*Auxiliar de la configuracion del CSRA y CSRB (pag. 39)

CRA     EQU     $effc05       * de control A (escritura)			*habilita o inhibe la transmision y/o recepcion en A
CRB     EQU     $effc15       * de control B (escritura)			*habilita o inhibe la transmision y/o recepcion en A

TBA     EQU     $effc07       * buffer transmision A (escritura)    *Buffer de la Duart al la que enviamos caracter
TBB     EQU     $effc17       * buffer transmision B (escritura)	*Buffer de la Duart al la que enviamos caracter

RBA     EQU     $effc07       * buffer recepcion A  (lectura)		*Buffer de la Duart de la que recivimos caracter
RBB		EQU		$effc17		  * buffer recepcion B	(lectura)		*Buffer de la Duart de la que recivimos caracter

IMR     EQU     $effc0B       * de mascara de interrupcion (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion   (lectura)
IVR		EQU		$effc19		  * declara el vector de interrupcion (lectura/escritura)

*********************************
* Reserva de Memoria
*********************************
		
BPA:	DS.B 	2001     *Reservamos 2001 bytes para el buffer interno de Print linea A
BPB:	DS.B 	2001	 *Reservamos 2001 bytes para el buffer interno de Print linea B
BSA:	DS.B 	2001	 *Reservamos 2001 bytes para el buffer interno de Scan linea A
BSB:	DS.B 	2001	 *Reservamos 2001 bytes para el buffer interno de Scan linea B

 *Punteros BUFFER
PPAL:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 puntero print a lectura
PPAE:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 puntero print a escritura
PPBE:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 puntero print b escritura
PPBL:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 
PSAE:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 
PSAL:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 
PSBE:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 puntero scan b escritura
PSBL:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 

IMRC: 	DS.B	2 *Necesitamos una copiade IMR ya que no es de lectura

*********************************	
* Init
*********************************
INIT:

	    *Configuramos la Duart
	    MOVE.B          #%00000011,MR1A     * 8 bits por caracter.
	    MOVE.B          #%00000000,MR2A     * Eco desactivado.
		
		MOVE.B          #%00000011,MR1B     * 8 bits por caracter.
	    MOVE.B          #%00000000,MR2B     * Eco desactivado.
		
	    MOVE.B          #%11001100,CSRA     * Velocidad = 38400 bps.
		MOVE.B          #%11001100,CSRB     * Velocidad = 38400 bps.
	    MOVE.B          #%00000000,ACR      * Velocidad = 38400 bps.
		
		MOVE.B          #%00010000,CRA      * Reinicia el puntero MR1
	    MOVE.B          #%00000101,CRA      * Transmision y recepcion activados.
		MOVE.B 			#%00010000,CRB		* Reinicia el puntero MR1
		MOVE.B          #%00000101,CRB      * Transmision y recepcion activados.

		
		
		MOVE.B			#$00000040,IVR		* Inicializa el vector  * ESTABA MAL CORREGIDO 20/20/2020
		MOVE.B			#%00100010,IMR		* Inicializa interrupciones escritura
		MOVE.B			#%00100010,IMRC		* Inicializa interrupciones escritura

		
		
		*Apuntamos los punteros de escritura/lectura a la direccion de su buffer	
		MOVE.L			#BPA,A0
		MOVE.L			A0,PPAE
		MOVE.L 			A0,PPAL
		
		MOVE.L			#BPB,A0
		MOVE.L			A0,PPBE
		MOVE.L 			A0,PPBL
		
		MOVE.L			#BSA,A0
		MOVE.L			A0,PSAE
		MOVE.L 			A0,PSAL
		
		MOVE.L			#BSB,A0
		MOVE.L			A0,PSBE
		MOVE.L 			A0,PSBL

		*ACTUALIZAMOS LA DIRECCION DE LA TABLA DE VECTORES DE INTERRUPCION CON LA DIR DE LA RTI, cuando haya una interrupcion saltara a esa direccion
		MOVE.L 			#RTI,A0
		MOVE.L			#$100,A1
		MOVE.L			A0,(A1)
		
        RTS

*********************************
* Leecar(BUFFER(D0))
*********************************
LEECAR:
		LINK A6,#-56  *Guardamos todos los registros para asegurar que no hay problemas de concurrencia
		*MOVE.L 		D0,-56(A6) *NO SE GUARDA EN PILA YA QUE LO USAMOS
		MOVE.L 		D1,-52(A6)
		MOVE.L 		D2,-48(A6)
		MOVE.L 		D3,-44(A6)
		MOVE.L 		D4,-40(A6)
		MOVE.L 		D5,-36(A6)
		MOVE.L 		D6,-32(A6)
		MOVE.L 		D7,-28(A6)
		MOVE.L 		A0,-24(A6)
		MOVE.L 		A1,-20(A6)
		MOVE.L 		A2,-16(A6)
		MOVE.L 		A3,-12(A6)
		MOVE.L 		A4,-8(A6)
		MOVE.L 		A5,-4(A6)


		AND.L			#3,D0		*guardo los 2 bits mas significativos
		CMP.L			#0,D0 		*comparo d0 con 00
		BEQ				LESA		*LEECAR SCAN A
		CMP.L			#1,D0  		*comparo d0 con 01
		BEQ				LESB		*LEECAR SCAN B
		CMP.L			#2,D0  		*comparo d0 con 10
		BEQ				LEPA		*LEECAR PRINT A
		CMP.L			#3,D0  		*comparo d0 con 11
		BEQ				LEPB		*LEECAR PRINT B
		
		
LESA: 		*LEECAR SCAN A
		MOVE.L 			PSAE,A2		*guardo puntero de escritura de A(scan)
		MOVE.L 			PSAL,A3		*guardo puntero de lectura de A(scan)
		CMP.L			A2,A3		*comparo los punteros
		BEQ				FINLEC		*si son iguales devuelve en D0=0xFFFFFFFF
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BSA,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3
		BEQ				FLESA		
		MOVE.L			A3,PSAL		*guardo en la direccion el avance del puntero
		BRA FINLE		
FLESA:	*FIN LEECAR SCAN A
		MOVE.L			#BSA,A3		*muevo el puntero a la direccion inicial
		MOVE.L			A3,PSAL	    *guardo en la direccion el avance del puntero
		BRA FINLE
		
LESB: 	*LEECAR SCAN B
		MOVE.L 			PSBE,A2		*guardo puntero de escritura de A(scan)
		MOVE.L 			PSBL,A3		*guardo puntero de lectura de A(scan)
		CMP.L			A2,A3		*comparo los punteros
		BEQ				FINLEC		*si son iguales devuelve en D0=0xFFFFFFFF
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BSB,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3
		BEQ				FLESB		
		MOVE.L			A3,PSBL		*guardo en la direccion el avance del puntero
		BRA FINLE		
FLESB:	*FIN LEECAR SCAN B
		MOVE.L			#BSB,A3		*muevo el puntero a la direccion inicial
		MOVE.L			A3,PSBL		*guardo en la direccion el avance del puntero
		BRA FINLE
		
LEPA: 	*LEECAR PRINT A
		MOVE.L 			PPAE,A2		*guardo puntero de escritura de A(scan)
		MOVE.L 			PPAL,A3		*guardo puntero de lectura de A(scan)
		CMP.L			A2,A3		*comparo los punteros
		BEQ				FINLEC		*si son iguales devuelve en D0=0xFFFFFFFF
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BPA,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3								 
		BEQ				FLEPA												    
		MOVE.L			A3,PPAL		*guardo en la direccion el avance del puntero
		BRA FINLE
FLEPA:	*FIN LEECAR PRINT A
		MOVE.L			#BPA,A3		*muevo el puntero a la direccion Inicia 	MAL TIENE QUE METER #BPA
		MOVE.L			A3,PPAL	*guardo en la direccion el avance del puntero
		BRA FINLE
		
LEPB: 	*LEECAR PRINT B	
		MOVE.L 			PPBE,A2		*guardo puntero de escritura de B(scan)
		MOVE.L 			PPBL,A3		*guardo puntero de lectura de B(scan)
		CMP.L			A2,A3		*comparo los punteros
		BEQ				FINLEC		*si son iguales devuelve en D0=0xFFFFFFFF
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BPB,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3
		BEQ				FLEPB		
		MOVE.L			A3,PPBL		*guardo en la direccion el avance del puntero
		BRA FINLE
FLEPB:	*FIN LEECAR PRINT B
		MOVE.L			#BPB,A3		*muevo el puntero a la direccion inicial
		MOVE.L			A3,PPBL	*guardo en la direccion el avance del puntero
		BRA FINLE

FINLEC:	*FIN LEECAR CERO(NO HAY CARACTERES EN EL BUFFER)
		MOVE.L 			#$FFFFFFFF,D0	*devuelve 0xFFFFFFFF
		
FINLE:   *FIN LEECAR
		*MOVE.L 		-56(A6),D0 *NO SE GUARDA EN PILA YA QUE LO USAMOS
		MOVE.L 		-52(A6),D1
		MOVE.L 		-48(A6),D2
		MOVE.L 		-44(A6),D3
		MOVE.L 		-40(A6),D4
		MOVE.L 		-36(A6),D5
		MOVE.L 		-32(A6),D6
		MOVE.L 		-28(A6),D7
		MOVE.L 		-24(A6),A0
		MOVE.L 		-20(A6),A1
		MOVE.L 		-16(A6),A2
		MOVE.L 		-12(A6),A3
		MOVE.L 		-8(A6),A4
		MOVE.L 		-4(A6),A5
		UNLK 		A6
		RTS	
				
*********************************
* Esccar(BUFFER(D0),CARACTER(D1))
*********************************
ESCCAR:
		LINK A6,#-56  *Guardamos todos los registros para asegurar que no hay problemas de concurrencia
		*MOVE.L 		D0,-56(A6) *NO SE SACA DE PILA YA QUE LO USAMOS
		*MOVE.L 		D1,-52(A6) *NO SE SACA DE PILA YA QUE LO USAMOS
		MOVE.L 		D2,-48(A6)
		MOVE.L 		D3,-44(A6)
		MOVE.L 		D4,-40(A6)
		MOVE.L 		D5,-36(A6)
		MOVE.L 		D6,-32(A6)
		MOVE.L 		D7,-28(A6)
		MOVE.L 		A0,-24(A6)
		MOVE.L 		A1,-20(A6)
		MOVE.L 		A2,-16(A6)
		MOVE.L 		A3,-12(A6)
		MOVE.L 		A4,-8(A6)
		MOVE.L 		A5,-4(A6)


		AND.W	#3,D0  *me quedo con los dos bits significativos
		CMP.W 	#0,D0
		BEQ		ESA *ESCCAR SCAN A
		CMP.W 	#1,D0 
		BEQ 	ESB *ESCCAR SCAN B
		CMP.W 	#2,D0
		BEQ 	EPA *ESCCAR PRINT A
		CMP.W 	#3,D0
		BEQ 	EPB *ESCCAR PRINT B
		
		
ESA:		*ESCCAR SCAN A
			MOVE.L 			PSAE,A0			*CARGAMOS PUNTERO ESCRITURA
			MOVE.L 			PSAL,A2			*CARGAMOS PUNTERO LECTURA
			MOVE.B			D1,(A0)+		*ESCRIBIMO EN BUFFER
			MOVE.L			#0,D0 			*TODO BIEN
			MOVE.L 			#BSA,A1			
			ADDA.L 			#2001,A1		*CARGO DIRECCION FINAL DEL BUFFER		
			CMP.L 			A0,A1			*A0=A1??
			BEQ				ESAFB 			*FINAL DE BUFFER 
			CMP.L			A0,A2
			BNE				FESA	
			MOVE.L 			#-1,D0
			BRA FINE			
ESAFB:      *ESCCAR SCAN A FIN DE BUFFER
			MOVE.L			#BSA,A0			*muevo el puntero a la direccion inicial
			CMP.L			A0,A2
			BNE				FESA	
			MOVE.L 			#-1,D0
			BRA FINE
FESA:		*FIN ESCCAR SCAN A
			MOVE.L			A0,PSAE
			BRA FINE	

EPA:		*ESCCAR PRINT A
			MOVE.L 			PPAE,A0			*CARGAMOS PUNTERO ESCRITURA
			MOVE.L 			PPAL,A2			*CARGAMOS PUNTERO LECTURA
			MOVE.B			D1,(A0)+		*ESCRIBIMO EN BUFFER
			MOVE.L			#0,D0 			*TODO BIEN
			MOVE.L 			#BPA,A1			
			ADDA.L 			#2001,A1		*CARGO DIRECCION FINAL DEL BUFFER
			CMP.L 			A0,A1			*A0=A1??
			BEQ				EPAFB 			*FINAL DE BUFFER 
			CMP.L			A0,A2
			BNE				FEPA	
			MOVE.L 			#-1,D0
			BRA FINE			
EPAFB:		*ESCCAR PRINT A FIN DE BUFFER
			MOVE.L			#BPA,A0			*muevo el puntero a la direccion inicial
			CMP.L			A0,A2
			BNE				FEPA	
			MOVE.L 			#-1,D0
			BRA FINE
FEPA:		*FIN ESCCAR PRINT A
			MOVE.L			A0,PPAE
			BRA FINE		

ESB:		*ESCCAR SCAN B
			MOVE.L 			PSBE,A0			*CARGAMOS PUNTERO ESCRITURA
			MOVE.L 			PSBL,A2			*CARGAMOS PUNTERO LECTURA
			MOVE.B			D1,(A0)+		*ESCRIBIMO EN BUFFER
			MOVE.L			#0,D0 			*TODO BIEN
			MOVE.L 			#BSB,A1			
			ADDA.L 			#2001,A1		*CARGO DIRECCION FINAL DEL BUFFER			
			CMP.L 			A0,A1			*A0=A1??
			BEQ				ESBFB 			*FINAL DE BUFFER 
			CMP.L			A0,A2
			BNE				FESB	
			MOVE.L 			#-1,D0
			BRA FINE			
ESBFB:		*ESCCAR SCAN B FIN DE BUFFER
			MOVE.L			#BSB,A0			*muevo el puntero a la direccion inicial
			CMP.L			A0,A2
			BNE				FESB	
			MOVE.L 			#-1,D0
			BRA FINE
FESB:		*FIN ESCCAR SCAN B
			MOVE.L			A0,PSBE
			BRA FINE		

EPB:		*ESCCAR PRINT B
			MOVE.L 			PPBE,A0			*CARGAMOS PUNTERO ESCRITURA
			MOVE.L 			PPBL,A2			*CARGAMOS PUNTERO LECTURA
			MOVE.B			D1,(A0)+		*ESCRIBIMO EN BUFFER
			MOVE.L			#0,D0 			*TODO BIEN
			MOVE.L 			#BPB,A1			
			ADDA.L 			#2001,A1		*CARGO DIRECCION FINAL DEL BUFFER
			CMP.L 			A0,A1			*A0=A1??
			BEQ				EPBFB 			*FINAL DE BUFFER 
			CMP.L			A0,A2
			BNE				FEPB	
			MOVE.L 			#-1,D0
			BRA FINE			
EPBFB:		*ESCCAR PRINT B FIN DE BUFFER
			MOVE.L			#BPB,A0			*muevo el puntero a la direccion inicial
			CMP.L			A0,A2
			BNE				FEPB	
			MOVE.L 			#-1,D0
			BRA FINE
FEPB:		*FIN ESCCAR PRINT B
			MOVE.L			A0,PPBE
			BRA FINE

FINE:
		*MOVE.L 		-56(A6),D0 *NO SE SACA DE PILA YA QUE LO USAMOS
		*MOVE.L 		-52(A6),D1 *NO SE SACA DE PILA YA QUE LO USAMOS
		MOVE.L 		-48(A6),D2
		MOVE.L 		-44(A6),D3
		MOVE.L 		-40(A6),D4
		MOVE.L 		-36(A6),D5
		MOVE.L 		-32(A6),D6
		MOVE.L 		-28(A6),D7
		MOVE.L 		-24(A6),A0
		MOVE.L 		-20(A6),A1
		MOVE.L 		-16(A6),A2
		MOVE.L 		-12(A6),A3
		MOVE.L 		-8(A6),A4
		MOVE.L 		-4(A6),A5
		UNLK 		A6
		RTS	

*********************************
* Linea(BUFFER(D0))
*********************************
LINEA:
		LINK A6,#-56  *Guardamos todos los registros para asegurar que no hay problemas de concurrencia
		*MOVE.L 		D0,-56(A6) *NO SE GUARDA EN PILA YA QUE LO USAMOS
		MOVE.L 		D1,-52(A6)
		MOVE.L 		D2,-48(A6)
		MOVE.L 		D3,-44(A6)
		MOVE.L 		D4,-40(A6)
		MOVE.L 		D5,-36(A6)
		MOVE.L 		D6,-32(A6)
		MOVE.L 		D7,-28(A6)
		MOVE.L 		A0,-24(A6)
		MOVE.L 		A1,-20(A6)
		MOVE.L 		A2,-16(A6)
		MOVE.L 		A3,-12(A6)
		MOVE.L 		A4,-8(A6)
		MOVE.L 		A5,-4(A6)

		AND.W	#3,D0  *me quedo con los dos bits significativos
		CMP.L 	#0,D0
		BEQ		LSA *LINEA SCAN A
		CMP.W 	#2,D0
		BEQ 	LPA *LINEA PRINT A
		CMP.W 	#1,D0 
		BEQ 	LSB *LINEA SCAN B
		CMP.W 	#3,D0
		BEQ 	LPB *LINEA PRINT B
		
LSA: 	*LINEA SCAN A
		MOVE.L		#0,D3 *CONTADOR DE LINEA
		MOVE.L		#BSA,A4
		ADDA.L		#2001,A4
		MOVE.L		PSAL,A0 		*A0 PUNTERO 
		MOVE.L 		PSAE,A1 		*CARGO PUNTERO DE ESCRITURA
BLSA:								* BUCLE LSA
		CMP.L 		A1,A0			*MIRO A VER SI ESTA FLV
		BEQ 		FLV
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   * USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FINLA
		ADD.L 		#1,D3
		CMP.L 		A4,A0
		BEQ 		FLSA
		ADDA.L 		#1,A0 	  *MUEVO EL PUNTERO
		BRA 		BLSA
FLSA:   *FIN LINEA SCAN A
		MOVE.L		#BSA,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BLSA

		
LPA: 	*LINEA PRINT A
		MOVE.L		#0,D3 *CONTADOR DE LINEA
		MOVE.L		#BPA,A4
		ADDA.L		#2001,A4
		MOVE.L		PPAL,A0 		*A0 PUNTERO 
		MOVE.L 		PPAE,A1 		*CARGO PUNTERO DE ESCRITURA
BLPA:	* BUCLE LINEA PRINT A
		CMP.L 		A1,A0			*MIRO A VER SI ESTA FLV
		BEQ 		FLV
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   * USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FINLA
		ADD.L 		#1,D3
		CMP.L 		A4,A0
		BEQ 		FLPA
		ADDA.L 		#1,A0 	  *MUEVO EL PUNTERO
		BRA 		BLPA
FLPA:   *FIN LINEA PRINT A
		MOVE.L		#BPA,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BLPA
		
LSB: 	*LINEA SCAN B
		MOVE.L		#0,D3 *CONTADOR DE LINEA
		MOVE.L		#BSB,A4
		ADDA.L		#2001,A4
		MOVE.L		PSBL,A0 		*A0 PUNTERO 
		MOVE.L 		PSBE,A1 		*CARGO PUNTERO DE ESCRITURA
BLSB:	* BUCLE LINEA SCAN B
		CMP.L 		A1,A0			*MIRO A VER SI ESTA FLV
		BEQ 		FLV
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   * USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FINLA
		ADD.L 		#1,D3
		CMP.L 		A4,A0
		BEQ 		FLSB
		ADDA.L 		#1,A0 	  *MUEVO EL PUNTERO
		BRA 		BLSB
FLSB:   *FIN LINEA SCAN B
		MOVE.L		#BSB,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BLSB
		
LPB: 	*LINEA PRINT B
		MOVE.L		#0,D3 *CONTADOR DE LINEA
		MOVE.L		#BPB,A4
		ADDA.L		#2001,A4
		MOVE.L		PPBL,A0 		*A0 PUNTERO LECTURA 
		MOVE.L 		PPBE,A1 		*CARGO PUNTERO DE ESCRITURA
BLPB:	* BUCLE LINEA PRINT B
		CMP.L 		A1,A0			*MIRO A VER SI ESTA FLV
		BEQ 		FLV
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   * USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FINLA
		ADD.L 		#1,D3
		CMP.L 		A4,A0
		BEQ 		FLPB
		ADDA.L 		#1,A0 	  *MUEVO EL PUNTERO
		BRA 		BLPB
FLPB:	*FIN LINEA PRINT B
		MOVE.L		#BPB,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BLPB


FLV: 	*FIN LINEA VACIA 
		MOVE.L 		#0,D0 			*D0=0
		*MOVE.L 	-56(A6),D0 *NO SE GUARDA EN PILA YA QUE LO USAMOS
		MOVE.L 		-52(A6),D1
		MOVE.L 		-48(A6),D2
		MOVE.L 		-44(A6),D3
		MOVE.L 		-40(A6),D4
		MOVE.L 		-36(A6),D5
		MOVE.L 		-32(A6),D6
		MOVE.L 		-28(A6),D7
		MOVE.L 		-24(A6),A0
		MOVE.L 		-20(A6),A1
		MOVE.L 		-16(A6),A2
		MOVE.L 		-12(A6),A3
		MOVE.L 		-8(A6),A4
		MOVE.L 		-4(A6),A5
		UNLK 		A6
		RTS	
		
FINLA:  *FIN LINEA
		ADD.L		#1,D3
		MOVE.L 		D3,D0
		*MOVE.L 	-56(A6),D0 *NO SE GUARDA EN PILA YA QUE LO USAMOS
		MOVE.L 		-52(A6),D1
		MOVE.L 		-48(A6),D2
		MOVE.L 		-44(A6),D3
		MOVE.L 		-40(A6),D4
		MOVE.L 		-36(A6),D5
		MOVE.L 		-32(A6),D6
		MOVE.L 		-28(A6),D7
		MOVE.L 		-24(A6),A0
		MOVE.L 		-20(A6),A1
		MOVE.L 		-16(A6),A2
		MOVE.L 		-12(A6),A3
		MOVE.L 		-8(A6),A4
		MOVE.L 		-4(A6),A5
		UNLK 		A6
		RTS	

*********************************
* PRINT (BUFFER,DESCRIPTOR,TAMAÑO(POR PILA))
*********************************
PRINT:
		 
		LINK A6,#-56  *Guardamos todos los registros para asegurar que no hay problemas de concurrencia
		*MOVE.L 		D0,-56(A6) *DEVUELVE PARAMETRO
		MOVE.L 		D1,-52(A6)
		MOVE.L 		D2,-48(A6)
		MOVE.L 		D3,-44(A6)
		MOVE.L 		D4,-40(A6)
		MOVE.L 		D5,-36(A6)
		MOVE.L 		D6,-32(A6)
		MOVE.L 		D7,-28(A6)
		MOVE.L 		A0,-24(A6)
		MOVE.L 		A1,-20(A6)
		MOVE.L 		A2,-16(A6)
		MOVE.L 		A3,-12(A6)
		MOVE.L 		A4,-8(A6)
		MOVE.L 		A5,-4(A6)
		
		*CARGAMOS DATOS
		MOVE.L		8(A6),A0			*A0=buffer
		MOVE.W		12(A6),D0      		*D0=descriptor
	    MOVE.W 		14(A6),D3			*D1=TAMA?

		
PRINTTL:
		MOVE.L		D0,D4		 								
		CMP.W		#0,D0 				*miro a ver en que puerto va a leer
		BEQ		PRINTA				*escribe en puerto A
		CMP.W		#1,D0				
		BEQ 		PRINTB 				*escribe en puerto B 
		MOVE.L 	#-1,D0 				*D0=-1 SI NO ES NI 0 NI 1
		BRA 		DMPILAP

		 
		 
PRINTA:
		
		MOVE.L 		#0,D2 			*D2=CONTADOR
		

BUCPA:
		ADD.L 		#2,D0 			*PREPARO D0 PARA ESCCAR
		MOVE.B		(A0)+,D1		*OBTENGO EL CARACTER DEL buffer
		ADD.L 		#1,D2			*CONTADOR++
		MOVE.L 		A0,-24(A6)
		CMP.L 		#13,D1			*MIRO A VER SI ES RETORNO DE CARRO
		BEQ			ACTTA
		BSR			ESCCAR			*LLAMO A ESCCAR
		MOVE.L 		-24(A6),A0
		CMP.L		#-1,D0 			*COMPRUEBO VALOR DEVUELTO POR ESCCAR
		BEQ			DMPILAP
		CMP.L 		D2,D3			*MIRO A VER SI HEMOS LLEGADO HASTA TAMAÑO
		BEQ			DMPILAP
		BRA 		BUCPA


ACTTA:	 
		 BSR 		ESCCAR
		 MOVE.L 		-24(A6),A0
		 MOVE.L 	D2,D0 			*METO EL NUMERO DE CARACTERES ESCRITOS
		 BSET		#0,IMRC
		 MOVE.B		IMRC,IMR
		 BRA 		DMPILAP		 
		 
		 
		 
PRINTB:
		
		MOVE.L 		#0,D2 			*D2=CONTADOR
BUCPB:	
		ADD.L 		#3,D0 			*PREPARO D0 PARA ESCCAR    a lo mejr es better usar move
		MOVE.B		(A0)+,D1		*OBTENGO EL CARACTER DEL buffer
		ADD.L 		#1,D2			*CONTADOR++
		CMP.L 		#13,D1			*MIRO A VER SI ES RETORNO DE CARRO
		BEQ			ACTTB
		BSR			ESCCAR			*LLAMO A ESCCAR
		CMP.L		#-1,D0 			*COMPRUEBO VALOR DEVUELTO POR ESCCAR
		BEQ			DMPILAP
		CMP.L 		D2,D3			*MIRO A VER SI HEMOS LLEGADO HASTA TAMAÑO
		BEQ			DMPILAP
		BRA 		BUCPB

ACTTB:	 
		
		 MOVE.L		#13,D1
		 BSR 		ESCCAR
		 MOVE.L 	D2,D0 			*METO EL NUMERO DE CARACTERES ESCRITOS
		 BSET		#4,IMRC
		 MOVE.B		IMRC,IMR
		 BRA 		DMPILAP	
				
		 
DMPILAP:  
		*MOVE.L 		-56(A6),D0 *DEVUELVE PARAMETRO
		MOVE.L 		-52(A6),D1
		MOVE.L 		-48(A6),D2
		MOVE.L 		-44(A6),D3
		MOVE.L 		-40(A6),D4
		MOVE.L 		-36(A6),D5
		MOVE.L 		-32(A6),D6
		MOVE.L 		-28(A6),D7
		MOVE.L 		-24(A6),A0
		MOVE.L 		-20(A6),A1
		MOVE.L 		-16(A6),A2
		MOVE.L 		-12(A6),A3
		MOVE.L 		-8(A6),A4
		MOVE.L 		-4(A6),A5
		UNLK 		A6
		RTS	
		 								
*********************************
* SCAN (BUFFER,DESCRIPTOR,TAMAÑO(POR PILA))
*********************************
SCAN:  
		LINK A6,#-56  *Guardamos todos los registros para asegurar que no hay problemas de concurrencia
		*MOVE.L 		D0,-56(A6) *DEVUELVE PARAMETRO
		MOVE.L 		D1,-52(A6)
		MOVE.L 		D2,-48(A6)
		MOVE.L 		D3,-44(A6)
		MOVE.L 		D4,-40(A6)
		MOVE.L 		D5,-36(A6)
		MOVE.L 		D6,-32(A6)
		MOVE.L 		D7,-28(A6)
		MOVE.L 		A0,-24(A6)
		MOVE.L 		A1,-20(A6)
		MOVE.L 		A2,-16(A6)
		MOVE.L 		A3,-12(A6)
		MOVE.L 		A4,-8(A6)
		MOVE.L 		A5,-4(A6)
		
		
		 MOVE.W		14(A6),D1			*D1=tama?
		 MOVE.W		12(A6),D0      		*D0=descriptor
		 MOVE.L		8(A6),A0			*A0=buffer CARGO EL Buffer
		 CMP.W		#0,D0 				*miro a ver en que puerto va a leer
		 BEQ		SCANA				*escribe en puerto A
		 CMP.W		#1,D0
		 BEQ 		SCANB 				*escribe en puerto B 
		 MOVE.L 	#-1,D0 				*D0=-1 SI NO ES NI 0 NI 1
		 BRA 		DMPILAS
SCANA: 	 

		 MOVE.L 	#0,D0 				*D0=0   BUSCAMOS CUANTOS CARACTERES HAY EN EL BUFFER DE SCAN A
		 BSR 		LINEA
		 MOVE.L 	D0,D2				*D2=LINEA
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINCEROA	 
		 CMP.W 		D1,D2 				*COMPARO TAMA? Y LINEA
		 BGT 		FINCEROA
BUCSA:	 	 
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINSCANA
		 MOVE.B 	#0,D0 				*PARAMETRO PARA LEECAR
		 BSR 		LEECAR		 
		 MOVE.B 	D0,(A0)+			*COPIO EL CARACTER EN BUFFER
		 MOVE.L		#BSA,A4
		 ADDA.L		#2001,A4
		 CMP.L		A4,A0				*MIRO A VER SI HA LLEGADO AL FINAL DEL buffer
		 BEQ 		PUNTSA
		 SUB.L		#1,D2				*N--		
		 BRA BUCSA
PUNTSA:	 MOVE.L 	#BSA,A0				*SI HA LLEGADO AL FINAL EL PUNTERO SE VA AL PRINCIPIO DEL BUFFER
		 SUB.L		#1,D2				*N--
		 BRA 		BUCSA
FINCEROA: MOVE.L 	#0,D0 				*DEVUELVE 0 EN D0
		  BRA DMPILAS
FINSCANA: 
		 MOVE.L 	D3,D0 				*D0=N	
		 BRA DMPILAS


SCANB: 	 
		 
		 MOVE.L 	#1,D0 				*D0=0
		 BSR 		LINEA 				*llamo a linea para saber cual es el tama? DE linea
		 MOVE.L 	D0,D2				*D2=LINEA
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINCEROB
		 MOVE.L 	D2,D3				*D3 REGISTRO TAMAÑO ESCRITO
		 CMP.W 		D1,D2 				*COMPARO TAMA? Y LINEA
		 BGT 		FINCEROB
BUCSB:	 	
		 CMP.W		#0,D2 				*LINEA=1? Error 1 editado 18/02/2020
		 BEQ 		FINSCANB
		 MOVE.B 	#1,D0 				*PARAMETRO PARA LEECAR
		 BSR 		LEECAR
		 MOVE.B 	D0,(A0)+			*COPIO EL CARACTER EN BUFFER
		 MOVE.L		#BSB,A4
		 ADDA.L		#2001,A4
		 CMP.L		A4,A0				*MIRO A VER SI HA LLEGADO AL FINAL DEL buffer
		 BEQ 		PUNTSB
		 SUB.L		#1,D2				*N--		
		 BRA BUCSB
PUNTSB:	 MOVE.L 	#BSB,A0				*SI HA LLEGADO AL FINAL EL PUNTERO SE VA AL PRINCIPIO DEL BUFFER
		 SUB.L		#1,D2				*N--
		 BRA 		BUCSB
FINCEROB: MOVE.L 	#0,D0 				*DEVUELVE 0 EN D0
		  BRA DMPILAS
FINSCANB: MOVE.L 	D3,D0 				*D0=N
		  BRA DMPILAS
DMPILAS:  
		*MOVE.L 		-56(A6),D0 *DEVUELVE PARAMETRO
		MOVE.L 		-52(A6),D1
		MOVE.L 		-48(A6),D2
		MOVE.L 		-44(A6),D3
		MOVE.L 		-40(A6),D4
		MOVE.L 		-36(A6),D5
		MOVE.L 		-32(A6),D6
		MOVE.L 		-28(A6),D7
		MOVE.L 		-24(A6),A0
		MOVE.L 		-20(A6),A1
		MOVE.L 		-16(A6),A2
		MOVE.L 		-12(A6),A3
		MOVE.L 		-8(A6),A4
		MOVE.L 		-4(A6),A5
		UNLK 		A6
		RTS	


*********************************
* RTI
*********************************

RTI:
* GUARDAR EN PILA D0-D5 A0-A4 , 6X2 + 5X4 = 32 BYTES A RESERVAR PARA GUARDAR 
	
		LINK A6,#-56  *Guardamos todos los registros para asegurar que no hay problemas de concurrencia
		MOVE.L 		D0,-56(A6) 
		MOVE.L 		D1,-52(A6)
		MOVE.L 		D2,-48(A6)
		MOVE.L 		D3,-44(A6)
		MOVE.L 		D4,-40(A6)
		MOVE.L 		D5,-36(A6)
		MOVE.L 		D6,-32(A6)
		MOVE.L 		D7,-28(A6)
		MOVE.L 		A0,-24(A6)
		MOVE.L 		A1,-20(A6)
		MOVE.L 		A2,-16(A6)
		MOVE.L 		A3,-12(A6)
		MOVE.L 		A4,-8(A6)
		MOVE.L 		A5,-4(A6)


***********************************************************************************************		
		MOVE.L		#0,D1
		MOVE.B		IMRC,D1				*COPIO EN UN REGISTRO LA COPIA DEL IMR 		
		AND.B		ISR,D1	 			*FUNCION AND entre iSR y imrc editado 21/02/2020
		BTST		#0,D1				*MIRO EL BIT 0 DE D1
		BNE			TA
		BTST		#1,D1				*MIRO EL BIT 1 DE D1
		BNE			RA
		BTST		#4,D1				*MIRO EL BIT 4 DE D1
		BNE			TB
		BTST		#5,D1				*MIRO EL BIT 5 DE D1
		BNE			RB
		BRA         FINRTI


**********************************************************************************************
TA:	
			MOVE.L		#0,D6			*RETORNO DE CARRO A 0
			MOVE.L		#2,D0
			BSR 		LINEA
		  	CMP.L 		#0,D0 			*LINEA =0?
		  	BEQ 		FINTA
		  	CMP.L 		#-1,D0 			*BUFFER ERRONEO?
			BEQ 		FINTA

BUCLETA:	
			CMP.L		#1,D6			*COMPRUEBO SI HA HABIDO
			BEQ 		FINTA		  	
			MOVE.L		#2,D0 			*METO EN D0 EL BIT 2 (TBA)		
			BSR 		LEECAR
			CMP.L 		#13,D0 			*RETORNO DE CARRO?
			BEQ 		RETCATA
			
VUELTATA:
			MOVE.B		D0,TBA 			*METO EL CARACTER EN EL BUFFER DE Transmision
			BRA 		BUCLETA

RETCATA:  
		  MOVE.L 		#1,D6 			*RETORNO DE CARRO=1
		  MOVE.B 		#10,TBA 		*METO SALTO DE LINEA
		  BRA BUCLETA
FINTA: 	  
		  BCLR			#0,IMRC 			*INHIBO INTERRUPCIONES EN TA
		  MOVE.B 		IMRC,IMR
FINTAF:   
		  BRA 			FINRTI

****************************************************************************************
TB:
	
			MOVE.L		#0,D6			*RETORNO DE CARRO A 0
BUCLETB:	
			CMP.L		#1,D6			*COMPRUEBO SI HA HABIDO
			BEQ 		SALTATB
			MOVE.L		#3,D0 			*METO EN D0 EL 2 PARA LLAMAR A LINEA
		    BSR 			LINEA
		    CMP.L 		#0,D0 			*LINEA =0?
		    BEQ 			FINTB
			MOVE.L		#3,D0 			*METO EN D0 EL BIT 2 (TBB)		
			BSR 		LEECAR
			CMP.L 		#13,D0 			*RETORNO DE CARRO?
			BEQ 		RETCATB
			CMP.L 		#-1,D0 			*BUFFER VACIO?
			BEQ 		FINTB
VUELTATB:
			MOVE.B		D0,TBB 			*METO EL CARACTER EN EL BUFFER DE Transmision
			BRA 		BUCLETA

SALTATB: 	
		  MOVE.B 		#10,TBB 		*METO SALTO DE LINEA
		  MOVE.L		#3,D0 			*METO EN D0 EL 2 PARA LLAMAR A LINEA
		  BSR 			LINEA
		  CMP.L 		#0,D0 			*LINEA =0?
		  BEQ 			FINTB
		  BRA 			FINTBF
RETCATB:  
		  MOVE.L 		#1,D6 			*RETORNO DE CARRO=1
		  BRA VUELTATB
FINTB: 	  
		  BCLR			#4,IMRC 			*INHIBO INTERRUPCIONES EN TB
		  MOVE.B 		IMRC,IMR
FINTBF:   
		  BRA 			FINRTI

***********************************************************************************************
RA:
		  MOVE.L 		#0,D1
		  MOVE.B 		RBA,D1			*CARACTER PARA ESCCAR
		  MOVE.L 		#0,D0 			*BUFFER PARA ESCCAR(RBA)
		  BSR 			ESCCAR 			
		  CMP.L 		#-1,D0 			*SALIDA=-1?
		  BRA 			FINRTI 		

************************************************************************************************


RB:		  
		  MOVE.L 		#0,D1
		  MOVE.B 		RBB,D1			*CARACTER PARA ESCCAR
		  MOVE.L 		#1,D0 			*BUFFER PARA ESCCAR(RBB)
		  BSR 			ESCCAR 			
		  CMP.L 		#-1,D0 			*SALIDA=-1?

		  BRA 			FINRTI 		

***************************************************************************************************		 
		 
FINRTI:
		MOVE.L 		-56(A6),D0
		MOVE.L 		-52(A6),D1
		MOVE.L 		-48(A6),D2
		MOVE.L 		-44(A6),D3
		MOVE.L 		-40(A6),D4
		MOVE.L 		-36(A6),D5
		MOVE.L 		-32(A6),D6
		MOVE.L 		-28(A6),D7
		MOVE.L 		-24(A6),A0
		MOVE.L 		-20(A6),A1
		MOVE.L 		-16(A6),A2
		MOVE.L 		-12(A6),A3
		MOVE.L 		-8(A6),A4
		MOVE.L 		-4(A6),A5
		UNLK 		A6	
		RTE


**********************************FIN RTI*****************************************************
BUFP:       DS.B        2100           *Buffer para lectura y escritura de caracteres  
CONTLP:     DC.W        0           *Contador de lineas
CONTCP:     DC.W        0          *Contador de caracteres
DIRLECP:    DC.L        0           *Direccion de lectura para SCAN
DIRESCP:    DC.L        0           *Direccion de escritura para PRINT
TAMEP:      DC.W        0           *TamaÃ±o de escritura para PRINT
DESAP:      EQU         0          *Descriptor de linea A
DESBP:      EQU         1          *Descriptor de linea B 
NLINP:      EQU         1           *Numero de lineas a leer
TAMLP:      EQU         30           *TamaÃ±o de linea para SCAN
TAMBP:      EQU         30           *TamaÃ±o de bloque para PRINT

INICIO:
            MOVE.L      #BUS_ERROR,8      * Bus error handler
            MOVE.L      #ADDRESS_ER,12     * Address error handler
            MOVE.L      #ILLEGAL_IN,16     * Illegal instruction handler
            MOVE.L      #PRIV_VIOLT,32     * Privilege violation handler  

            BSR         INIT
            MOVE.W      #$2000,SR       *Permite interrupciones

BUCPR:      MOVE.W      #0,CONTCP       *Inicializa contador de caracteres
            MOVE.W      #NLINP,CONTLP     *Inicializa contador de lineas
            MOVE.L      #BUFP,DIRLECP     *Direccion de lectura (comienzo del buffer)
OTRAL:      MOVE.W      #TAMLP,-(A7)     *TamaÃ±o maximo de la linea
            MOVE.W      #DESBP,-(A7)     *Puerto B
            MOVE.L      DIRLECP,-(A7)     *Direccion de lectura
ESPL:       BSR         SCAN
            CMP.L       #0,D0
            BEQ         ESPL         *Si no se ha leido una linea de intenta de nuevo
            ADDA.L      #8,A7         *Restablece la pila
            ADD.L       D0,DIRLECP       *Calcula la nueva direccion de lectura
            ADD.W       D0,CONTCP       *Actualiza el numero de caracteres leidos
            SUB.W       #1,CONTLP       *Actualiza el numero de lineas leidas. Si no
            BNE         OTRAL         *se han leido todas las lineas se vuelve a leer

            MOVE.L      #BUFP,DIRLECP     *Direccion de lectura (comienzo del buffer)
OTRAE:      MOVE.W      #TAMBP,TAMEP     *TamaÃ±o de escritura = TamaÃ±o de bloque
ESPE:       MOVE.W      TAMEP,-(A7)     *TamaÃ±o de escritura
            MOVE.W      #DESAP,-(A7)     *Puerto A
            MOVE.L      DIRLECP,-(A7)     * Direccion de lectura
            BSR         PRINT 
            ADD.L       #8,A7         *Restablece la pila
            ADD.L       D0,DIRLECP       *Calcula la nueva direccion del buffer 
            SUB.W       D0,CONTCP       *Actualiza el contador de caracteres
            BEQ         SALIR         *Si no quedas caracteres se acaba
            SUB.W       D0,TAMEP       *Actualiza el tamaÃ±o de escritura
            BNE         ESPE         *Si no se ha escrito todo el bloque se insiste
            CMP.W       #TAMBP,CONTCP     *Si el nÂº de caracteres que quedan es menor que el 
                            *tamaÃ±o establecido se transimite ese numero
            BHI         OTRAE        *Sigueinte bloque
            MOVE.W      CONTCP,TAMEP
            BRA         ESPE        *Siguiente bloque

SALIR:      BRA         BUCPR

FINP:        
            BREAK

BUS_ERROR:
            BREAK
            NOP
ADDRESS_ER: BREAK
            NOP

ILLEGAL_IN:
            BREAK
            NOP
PRIV_VIOLT:
            BREAK
            NOP
	




		
		BREAK