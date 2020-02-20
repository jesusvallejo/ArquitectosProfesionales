* Inicializa el SP y el PC
**************************
        ORG     $0
        DC.L    $8000           * Pila
        DC.L    INICIO          * PC
        ORG		$400

* Definici? de equivalencias
*********************************

MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2? escritura)
MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2? escritura)
SRA     EQU     $effc03       * de estado A (lectura)
SRB		EQU	    $effc13
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CSRB	EQU     $effc03       * de seleccion de reloj B (escritura)
CRA     EQU     $effc05       * de control A (escritura)
CRB     EQU     $effc15       * de control B (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
RBB		EQU		$effc17		  * buffer recepcion B	(lectura)
ACR		EQU		$effc09	      * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion A (lectura)
IVR		EQU		$effc19		  * declara el vector de interrupcion

**************************** Memory *************************************************************
		

BPA:	DS.B 	2001
BPB:	DS.B 	2001
BSA:	DS.B 	2001
BSB:	DS.B 	2001

 *punteros BUFFER
PPAL:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 puntero print a lectura
PPAE:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 puntero print a escritura
PPBE:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 puntero print b escritura
PPBL:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 
PSAE:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 
PSAL:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 
PSBE:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 puntero scan b escritura
PSBL:	DC.L	0 *EDITADO 20/02/2020 , ANTES UN DC.l 0 

IMRC: 	DS.B	2
	
**************************** INIT *************************************************************
INIT:

	    MOVE.B          #%00010000,CRA      * Reinicia el puntero MR1
	    MOVE.B          #%00000011,MR1A     * 8 bits por caracter.
	    MOVE.B          #%00000000,MR2A     * Eco desactivado.
	    MOVE.B          #%11001100,CSRA     * Velocidad = 38400 bps.
	    MOVE.B          #%00000000,ACR      * Velocidad = 38400 bps.
	    MOVE.B          #%00000101,CRA      * Transmision y recepcion activados.
		MOVE.B 			#%00010000,CRB		* Reinicia el puntero MR1
		MOVE.B          #%00000011,MR1B     * 8 bits por caracter.
	    MOVE.B          #%00000000,MR2B     * Eco desactivado.
		MOVE.B          #%11001100,CSRB     * Velocidad = 38400 bps.
		MOVE.B          #%00000101,CRB      * Transmision y recepcion activados.
		MOVE.B			#$00000040,IVR		* Inicializa el vector  * ESTABA MAL CORREGIDO 20/20/2020
		MOVE.B			#%00010001,IMR		* Inicializa interrupciones escritura
		MOVE.B			#%00010001,IMRC		* Inicializa interrupciones escritura 			
		MOVE.B			#%00100010,ISR		* Inicializa interrupciones lectura
			
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

		*ACTUALIZAMOS LA DIRECCION DE LA TABLA DE VECTORES DE INTERRUPCION CON LA DIR DE LA RTI
	MOVE.L 			#RTI,A0
	MOVE.L			#$100,A1
	MOVE.L			A0,(A1)
		
        RTS


		
LEECAR: 

		AND.L			#3,D0		*guardo los 2 bits mas significativos
		CMP.L			#0,D0 		*comparo d0 con 00
		BEQ				LEPSA		*guardo puntero psa
		CMP.L			#1,D0  		*comparo d0 con 01
		BEQ				LEPSB		*guardo puntero psb
		CMP.L			#2,D0  		*comparo d0 con 10
		BEQ				LEPPA		*guardo puntero ppa
		CMP.L			#3,D0  		*comparo d0 con 11
		BEQ				LEPPB		*guardo puntero ppb
		
		
LEPSA: 		
		MOVE.L 			PSAE,A2		*guardo puntero de escritura de A(scan)
		MOVE.L 			PSAL,A3		*guardo puntero de lectura de A(scan)
		CMP.L			A2,A3		*comparo los punteros
		BEQ				FINLC		*si son iguales devuelve en D0=0xFFFFFFFF
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BSA,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3
		BEQ				LFBSA		
		MOVE.L			A3,PSAL		*guardo en la direccion el avance del puntero
		RTS
LFBSA:	
		MOVE.L			#BSA,A3		*muevo el puntero a la direccion inicial
		MOVE.L			A3,PSAL	    *guardo en la direccion el avance del puntero
		RTS
LEPSB: 	
		MOVE.L 			PSBE,A2		*guardo puntero de escritura de A(scan)
		MOVE.L 			PSBL,A3		*guardo puntero de lectura de A(scan)
		CMP.L			A2,A3		*comparo los punteros
		BEQ				FINLC		*si son iguales devuelve en D0=0xFFFFFFFF
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BSB,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3
		BEQ				LFBSB		
		MOVE.L			A3,PSBL		*guardo en la direccion el avance del puntero
		RTS
LFBSB:	
		MOVE.L			#BSB,A3		*muevo el puntero a la direccion inicial
		MOVE.L			A3,PSBL	*guardo en la direccion el avance del puntero
		RTS
LEPPA: 		
		MOVE.L 			PPAE,A2		*guardo puntero de escritura de A(scan)
		MOVE.L 			PPAL,A3		*guardo puntero de lectura de A(scan)
		CMP.L			A2,A3		*comparo los punteros
		BEQ				FINLC		*si son iguales devuelve en D0=0xFFFFFFFF
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BPA,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3								 
		BEQ				LFBPA												    
		MOVE.L			A3,PPAL		*guardo en la direccion el avance del puntero
		RTS
LFBPA:	
		MOVE.L			#BPA,A3		*muevo el puntero a la direccion Inicia 	MAL TIENE QUE METER #BPA
		MOVE.L			A3,PPAL	*guardo en la direccion el avance del puntero
		RTS
LEPPB: 		
		MOVE.L 			PPBE,A2		*guardo puntero de escritura de B(scan)
		MOVE.L 			PPBL,A3		*guardo puntero de lectura de B(scan)
		CMP.L			A2,A3		*comparo los punteros
		BEQ				FINLC		*si son iguales devuelve en D0=0xFFFFFFFF
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BPB,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3
		BEQ				LFBPB		
		MOVE.L			A3,PPBL		*guardo en la direccion el avance del puntero
		RTS
LFBPB:	
		MOVE.L			#BPB,A3		*muevo el puntero a la direccion inicial
		MOVE.L			A3,PPBL	*guardo en la direccion el avance del puntero
		RTS

FINLC: 	
		MOVE.L 			#$FFFFFFFF,D0	*devuelve 0xFFFFFFFF
		RTS
		
		

**** ESCCAR ********
ESCCAR:   
		AND.W	#3,D0  *me quedo con los dos bits significativos
		CMP.W 	#0,D0
		BEQ		CBSA *CASO BUFER SCAN A
		CMP.W 	#2,D0
		BEQ 	CBPA *CASO BUFFER PRINT A
		CMP.W 	#1,D0 
		BEQ 	CBSB *CASO BUFFER SCAN B
		CMP.W 	#3,D0
		BEQ 	CBPB *CASO BUFFER PRINT B
		
		
CBSA:		
			MOVE.L 			PSAE,A0			*CARGAMOS PUNTERO ESCRITURA
			MOVE.L 			PSAL,A2			*CARGAMOS PUNTERO LECTURA
			MOVE.B			D1,(A0)+		*ESCRIBIMO EN BUFFER
			MOVE.L			#0,D0 			*TODO BIEN
			MOVE.L 			#BSA,A1			
			ADDA.L 			#2001,A1		*CARGO DIRECCION FINAL DEL BUFFER
			
			CMP.L 			A0,A1			*A0=A1??
			BEQ				SANC 			*FINAL DE BUFFER 

			CMP.L			A0,A2
			BNE				FINESCSA	
			MOVE.L 			#-1,D0
			RTS			
SANC:
			MOVE.L			#BSA,A0			*muevo el puntero a la direccion inicial
			CMP.L			A0,A2
			BNE				FINESCSA	
			MOVE.L 			#-1,D0
			RTS
FINESCSA:	
			MOVE.L			A0,PSAE
			RTS	

CBPA:		
			MOVE.L 			PPAE,A0			*CARGAMOS PUNTERO ESCRITURA
			MOVE.L 			PPAL,A2			*CARGAMOS PUNTERO LECTURA
			MOVE.B			D1,(A0)+		*ESCRIBIMO EN BUFFER
			MOVE.L			#0,D0 			*TODO BIEN
			MOVE.L 			#BPA,A1			
			ADDA.L 			#2001,A1		*CARGO DIRECCION FINAL DEL BUFFER
			
			CMP.L 			A0,A1			*A0=A1??
			BEQ				PANC 			*FINAL DE BUFFER 

			CMP.L			A0,A2
			BNE				FINESCPA	
			MOVE.L 			#-1,D0
			RTS			
PANC:
			MOVE.L			#BPA,A0			*muevo el puntero a la direccion inicial
			CMP.L			A0,A2
			BNE				FINESCPA	
			MOVE.L 			#-1,D0
			RTS
FINESCPA:	
			MOVE.L			A0,PPAE
			RTS		

CBSB:		
			MOVE.L 			PSBE,A0			*CARGAMOS PUNTERO ESCRITURA
			MOVE.L 			PSBL,A2			*CARGAMOS PUNTERO LECTURA
			MOVE.B			D1,(A0)+		*ESCRIBIMO EN BUFFER
			MOVE.L			#0,D0 			*TODO BIEN
			MOVE.L 			#BSB,A1			
			ADDA.L 			#2001,A1		*CARGO DIRECCION FINAL DEL BUFFER
			
			CMP.L 			A0,A1			*A0=A1??
			BEQ				SBNC 			*FINAL DE BUFFER 

			CMP.L			A0,A2
			BNE				FINESCSB	
			MOVE.L 			#-1,D0
			RTS			
SBNC:
			MOVE.L			#BSB,A0			*muevo el puntero a la direccion inicial
			CMP.L			A0,A2
			BNE				FINESCSB	
			MOVE.L 			#-1,D0
			RTS
FINESCSB:	
			MOVE.L			A0,PSBE
			RTS		

CBPB:		
			MOVE.L 			PPBE,A0			*CARGAMOS PUNTERO ESCRITURA
			MOVE.L 			PPBL,A2			*CARGAMOS PUNTERO LECTURA
			MOVE.B			D1,(A0)+		*ESCRIBIMO EN BUFFER
			MOVE.L			#0,D0 			*TODO BIEN
			MOVE.L 			#BPB,A1			
			ADDA.L 			#2001,A1		*CARGO DIRECCION FINAL DEL BUFFER
			
			CMP.L 			A0,A1			*A0=A1??
			BEQ				PBNC 			*FINAL DE BUFFER 

			CMP.L			A0,A2
			BNE				FINESCPB	
			MOVE.L 			#-1,D0
			RTS			
PBNC:
			MOVE.L			#BPB,A0			*muevo el puntero a la direccion inicial
			CMP.L			A0,A2
			BNE				FINESCPB	
			MOVE.L 			#-1,D0
			RTS
FINESCPB:	
			MOVE.L			A0,PPBE
			RTS		



**** FIN ESCCAR ********
**** LINEA ********
LINEA:
		AND.W	#3,D0  *me quedo con los dos bits significativos
		CMP.L 	#0,D0
		BEQ		CBSAL *CASO BUFER SCAN A
		CMP.W 	#2,D0
		BEQ 	CBPAL *CASO BUFFER PRINT A
		CMP.W 	#1,D0 
		BEQ 	CBSBL *CASO BUFFER SCAN B
		CMP.W 	#3,D0
		BEQ 	CBPBL *CASO BUFFER PRINT B
		
CBSAL: 				* Caso Buffer Scan "A" LINEA
		MOVE.L		#0,D3 *CONTADOR DE LINEA
		MOVE.L		#BSA,A4
		ADDA.L		#2001,A4
		MOVE.L		PSAL,A0 		*A0 PUNTERO 
		MOVE.L 		PSAE,A1 		*CARGO PUNTERO DE ESCRITURA
BCBSAL:								* BUCLE CBSAL
		CMP.L 		A0,A1			*MIRO A VER SI ESTA VACIO
		BEQ 		VACIO
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   * USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FLINEA
		ADD.L 		#1,D3
		CMP.L 		A4,A0
		BEQ 		FLINSA
		ADDA.L 		#1,A0 	  *MUEVO EL PUNTERO
		BRA 		BCBSAL
FLINSA:
		MOVE.L		#BSA,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BCBSAL

		
CBPAL: 				* Caso Buffer PRINT "A" LINEA
		MOVE.L		#0,D3 *CONTADOR DE LINEA
		MOVE.L		#BPA,A4
		ADDA.L		#2001,A4
		MOVE.L		PPAL,A0 		*A0 PUNTERO 
		MOVE.L 		PPAE,A1 		*CARGO PUNTERO DE ESCRITURA
BCBPAL:								* BUCLE CBSAL
		CMP.L 		A0,A1			*MIRO A VER SI ESTA VACIO
		BEQ 		VACIO
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   * USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FLINEA
		ADD.L 		#1,D3
		CMP.L 		A4,A0
		BEQ 		FLINPA
		ADDA.L 		#1,A0 	  *MUEVO EL PUNTERO
		BRA 		BCBPAL
FLINPA:
		MOVE.L		#BPA,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BCBPAL
		
CBSBL: 				* Caso Buffer Scan "B" LINEA
		MOVE.L		#0,D3 *CONTADOR DE LINEA
		MOVE.L		#BSB,A4
		ADDA.L		#2001,A4
		MOVE.L		PSBL,A0 		*A0 PUNTERO 
		MOVE.L 		PSBE,A1 		*CARGO PUNTERO DE ESCRITURA
BCBSBL:								* BUCLE CBSAL
		CMP.L 		A0,A1			*MIRO A VER SI ESTA VACIO
		BEQ 		VACIO
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   * USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FLINEA
		ADD.L 		#1,D3
		CMP.L 		A4,A0
		BEQ 		FLINSB
		ADDA.L 		#1,A0 	  *MUEVO EL PUNTERO
		BRA 		BCBSBL
FLINSB:
		MOVE.L		#BSB,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BCBSBL
		
CBPBL: 				* Caso Buffer PRINT "B" LINEA
		MOVE.L		#0,D3 *CONTADOR DE LINEA
		MOVE.L		#BPB,A4
		ADDA.L		#2001,A4
		MOVE.L		PPBL,A0 		*A0 PUNTERO 
		MOVE.L 		PPBE,A1 		*CARGO PUNTERO DE ESCRITURA
BCBPBL:								* BUCLE CBSAL
		CMP.L 		A0,A1			*MIRO A VER SI ESTA VACIO
		BEQ 		VACIO
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   * USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FLINEA
		ADD.L 		#1,D3
		CMP.L 		A4,A0
		BEQ 		FLINPB
		ADDA.L 		#1,A0 	  *MUEVO EL PUNTERO
		BRA 		BCBPBL
FLINPB:
		MOVE.L		#BPB,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BCBPBL


VACIO: 	MOVE.L 		#0,D0 			*D0=0
		RTS	
		
FLINEA:
		ADD.L		#1,D3
		MOVE.L 		#0,D0
		ADD.L 		D3,D0
		RTS

**** FIN LINEA ********
		

********** PRINT ********************
PRINT:
		 
		 LINK 		A6,#0
		 MOVE.L		8(A6),A0			*A0=buffer
		 MOVE.W		12(A6),D0      		*D0=descriptor
		 MOVE.W 	14(A6),D3			*D1=TAMA?
		 MOVE.L		A6,A7
		 								*creo marco de pila
*		 CMP.W		#0,D1				*SI TAMA? = 0 --> DESTRUCCION DEL MARCO DE PILA
*		 BEQ		DMPILA
		 CMP.W		#0,D0 				*miro a ver en que puerto va a leer
		 BEQ		PRINTA				*escribe en puerto A
		 CMP.W		#1,D0				
		 BEQ 		PRINTB 				*escribe en puerto B 
		 MOVE.L 	#-1,D0 				*D0=-1 SI NO ES NI 0 NI 1
		 BRA 		DMPILA

		 
		 
PRINTA:
		ADD.L 		#2,D0 			*PREPARO D0 PARA ESCCAR
		MOVE.L 		#0,D2 			*D2=CONTADOR
BUCPA:
		MOVE.B		(A0)+,D1		*OBTENGO EL CARACTER DEL buffer
		ADD.L 		#1,D2			*CONTADOR++
		CMP.L 		#13,D1			*MIRO A VER SI ES RETORNO DE CARRO
		BEQ			ACTTA
		MOVE.L 		A0,-(A7)		*GUARDO EN PILA
		MOVE.W 		D0,-(A7)
		MOVE.W 		D3,-(A7)
		MOVE.L 		D2,-(A7)
		BSR			ESCCAR			*LLAMO A ESCCAR

		CMP.L		#-1,D0 			*COMPRUEBO VALOR DEVUELTO POR ESCCAR
		BEQ			DMPILA
		MOVE.L 		(A7)+,D2		*RECUPERO REGISTROS
		MOVE.W 		(A7)+,D3
		MOVE.W 		(A7)+,D0
		MOVE.L 		(A7)+,A0
		BRA 		BUCPA


ACTTA:	
		 MOVE.L 	D2,D0 			*METO EL NUMERO DE CARACTERES ESCRITOS
*		 MOVE.W 	#$2700,SR
		 MOVE.L		IMRC,D5
		 BSET		#0,D5
		 MOVE.B		D5,IMRC
		 MOVE.B		D5,IMR
*		 MOVE.W		#$2000,SR
		 BRA 		DMPILA		 
		 
		 
		 
PRINTB:
		ADD.L 		#2,D0 			*PREPARO D0 PARA ESCCAR    a lo mejr es better usar move
		MOVE.L 		#0,D2 			*D2=CONTADOR
BUCPB:
		MOVE.B		(A0)+,D1		*OBTENGO EL CARACTER DEL buffer
		ADD.L 		#1,D2			*CONTADOR++
		CMP.L 		#13,D1			*MIRO A VER SI ES RETORNO DE CARRO
		BEQ			ACTTB
		MOVE.L 		A0,-(A7)		*GUARDO EN PILA
		MOVE.W 		D0,-(A7)
		MOVE.W 		D3,-(A7)
		MOVE.L 		D2,-(A7)

		BSR			ESCCAR			*LLAMO A ESCCAR

		CMP.L		#-1,D0 			*COMPRUEBO VALOR DEVUELTO POR ESCCAR
		BEQ			DMPILA
		MOVE.L 		(A7)+,D2		*RECUPERO REGISTROS
		MOVE.W 		(A7)+,D3
		MOVE.W 		(A7)+,D0
		MOVE.L 		(A7)+,A0
		BRA 		BUCPB


ACTTB:	
		 MOVE.L 	D2,D0 			*METO EL NUMERO DE CARACTERES ESCRITOS
*		 MOVE.W 	#$2700,SR
		 MOVE.L		IMRC,D5
		 BSET		#4,D5
		 MOVE.B		D5,IMRC
		 MOVE.B		D5,IMR
*		 MOVE.W		#$2000,SR			
		 
DMPILA:  
		 UNLK 		A6
		 RTS
		 								
		 
********** FIN PRINT ********************

**************************** SCAN ************************************************************
SCAN:  
		 LINK 		A6,#0				*creo marco de pila
		 MOVE.W		12(A6),D0      		*D0=descriptor
		 CMP.W		#0,D0 				*miro a ver en que puerto va a leer
		 BEQ		SCANA				*escribe en puerto A
		 CMP.W		#1,D0
		 BEQ 		SCANB 				*escribe en puerto B 
		 MOVE.L 	#-1,D0 				*D0=-1 SI NO ES NI 0 NI 1
		 BRA 		DMPILAS
SCANA: 	 

		 MOVE.L 	#0,D0 				*D0=0
		 BSR 		LINEA
		 MOVE.W		#0,D2		  		*editado 18/02/2020
		 MOVE.W		#0,D3		  		*editado 18/02/2020
		 MOVE.L 	D0,D2				*D2=LINEA
		 MOVE.L 	D2,D3				*D3 REGISTRO POR SI ACASO CON N
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINCEROA
		 MOVE.W		14(A6),D1			*D1=tama?		 
		 CMP.W 		D1,D2 				*COMPARO TAMA? Y LINEA
		 BGT 		FINCEROA
BUCSA:	 	 
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINSCANA
		 MOVE.B 	#0,D0 				*PARAMETRO PARA LEECAR
		 BSR 		LEECAR
		 MOVE.L		8(A6),A0			*A0=buffer CARGO EL Buffer
		 MOVE.B 	D0,(A0)+			*COPIO EL CARACTER EN BUFFER
		 MOVE.L		A0,8(A6)            * PUSH A PILA PARA VNZAR 
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
FINSCANA: MOVE.L 	D3,D0 				*D0=N	
*		  MOVE.W 	#$2700,SR
		  MOVE.L		IMRC,D5
		  BSET			#1,D5
		  MOVE.B		D5,IMRC
		  MOVE.B		D5,IMR
*		  MOVE.W		#$2000,SR
		  BRA DMPILAS


SCANB: 	 
		 
		 MOVE.L 	#1,D0 				*D0=0
		 BSR 		LINEA 				*llamo a linea para saber cual es el tama? DE linea
		 MOVE.L 	D0,D2				*D2=LINEA
		 MOVE.L 	D2,D3				*D3 REGISTRO POR SI ACASO CON N
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINCEROB
		 MOVE.W		14(A6),D1			*D1=tama?
		 CMP.W 		D1,D2 				*COMPARO TAMA? Y LINEA
		 BGT 		FINCEROB
BUCSB:	 	
		 CMP.W		#0,D2 				*LINEA=1? Error 1 editado 18/02/2020
		 BEQ 		FINSCANB
		 MOVE.B 	#1,D0 				*PARAMETRO PARA LEECAR
		 BSR 		LEECAR
		 MOVE.L		8(A6),A0			*A0=buffer CARGO EL Buffer
		 MOVE.B 	D0,(A0)+			*COPIO EL CARACTER EN BUFFER
		 MOVE.L		A0,8(A6)            * actualizo PILA PARA VNZAR 
		 MOVE.L		#BSB,A4
		 ADDA.L		#2001,A4
		 CMP.L		A4,A0				*MIRO A VER SI HA LLEGADO AL FINAL DEL buffer
		 BEQ 		PUNTSB
		 SUB.L		#1,D2				*N--		
		 BRA BUCSA
PUNTSB:	 MOVE.L 	#BSB,A0				*SI HA LLEGADO AL FINAL EL PUNTERO SE VA AL PRINCIPIO DEL BUFFER
		 SUB.L		#1,D2				*N--
		 BRA 		BUCSB
FINCEROB: MOVE.L 	#0,D0 				*DEVUELVE 0 EN D0
		  BRA DMPILAS
FINSCANB: MOVE.L 	D3,D0 				*D0=N
*		  MOVE.W 	#$2700,SR
		  MOVE.L	IMRC,D5
		  BSET		#5,D5
		  MOVE.B	D5,IMRC
		  MOVE.B	D5,IMR
*		  MOVE.W	#$2000,SR
		  BRA DMPILAS
DMPILAS:  
		UNLK 	A6
		 RTS
,

**************************** FIN SCAN ********************************************************

*****************************RTI**************************************************************

RTI:
	
	MOVE.L		#0,D1
	MOVE.L		#-1,A5
	MOVE.B		IMRC,D1				*COPIO EN UN REGISTRO LA COPIA DEL IMR 		
	AND.B		ISR,D1	 			*FUNCION AND EN IMR Y ISR
	BTST		#0,D1				*MIRO EL BIT 0 DE D1
	BEQ			TA
	BTST		#1,D1				*MIRO EL BIT 1 DE D1
	BEQ			RA
	BTST		#4,D1				*MIRO EL BIT 4 DE D1
	BEQ			TB
	BTST		#5,D1				*MIRO EL BIT 5 DE D1
	BEQ			RB

TA:
	
			MOVE.L		#0,D6			*RETORNO DE CARRO A 0
BUCLETA:	
			CMP.L		#1,D6			*COMPRUEBO SI HA HABIDO
			BEQ 		SALTATA
			MOVE.L		#2,D0 			*METO EN D0 EL BIT 2 (TBA)		
			BSR 		LEECAR
			CMP.L 		#13,D0 			*RETORNO DE CARRO?
			BEQ 		RETCATA
VUELTATA:
			MOVE.L		D0,TBA 			*METO EL CARACTER EN EL BUFFER DE Transmision
			BRA 		BUCLETA

SALTATA: 	
		  MOVE.B 		#10,TBA 		*METO SALTO DE LINEA
		  MOVE.L		#2,D0 			*METO EN D0 EL 2 PARA LLAMAR A LINEA
		  BSR 			LINEA
		  CMP.L 		#0,D0 			*LINEA =0?
		  BEQ 			FINTA
		  BRA 			FINTAF
RETCATA:  
		  MOVE.L 		#1,D6 			*RETORNO DE CARRO=1
		  BRA VUELTATA
FINTA: 	  
		  BCLR			#0,IMR 			*INHIBO INTERRUPCIONES EN TA
		  BCLR 			#0,IMRC
FINTAF:   
		  RTS


TB:
	
			MOVE.L		#0,D6			*RETORNO DE CARRO A 0
BUCLETB:	
			CMP.L		#1,D6			*COMPRUEBO SI HA HABIDO
			BEQ 		SALTATB
			MOVE.L		#3,D0 			*METO EN D0 EL BIT 2 (TBB)		
			BSR 		LEECAR
			CMP.L 		#13,D0 			*RETORNO DE CARRO?
			BEQ 		RETCATB
VUELTATB:
			MOVE.L		D0,TBB 			*METO EL CARACTER EN EL BUFFER DE Transmision
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
		  BCLR			#4,IMR 			*INHIBO INTERRUPCIONES EN TB
		  BCLR 			#4,IMRC
FINTBF:   
		  RTS


RA:
		  MOVE.B 		RBA,D1			*CARACTER PARA ESCCAR
		  MOVE.L 		#0,D0 			*BUFFER PARA ESCCAR(RBA)
		  BSR 			ESCCAR 			
		  CMP.L 		#-1,D0 			*SALIDA=-1?
		  BEQ 			FINRAINI 
FINRAINI: 
		  BCLR			#1,IMR 			*INHIBO INTERRUPCIONES EN RA
		  BCLR 			#1,IMRC
		  BRA 			FINRA 		
FINRA:  
 		 RTS



RB:
		  MOVE.B 		RBB,D1			*CARACTER PARA ESCCAR
		  MOVE.L 		#1,D0 			*BUFFER PARA ESCCAR(RBB)
		  BSR 			ESCCAR 			
		  CMP.L 		#-1,D0 			*SALIDA=-1?
		  BEQ 			FINRBINI 
FINRBINI: 
		  BCLR			#5,IMR 			*INHIBO INTERRUPCIONES EN RB
		  BCLR 			#5,IMRC
		  BRA 			FINRB 		
FINRB:  
 		 RTS


**********************************FIN RTI*****************************************************


BUFP:       DS.B        2100           *Buffer para lectura y escritura de caracteres  
CONTLP:     DC.W        0           *Contador de lineas
CONTCP:     DC.W        0          *Contador de caracteres
DIRLECP:    DC.L        0           *Direccion de lectura para SCAN
DIRESCP:    DC.L        0           *Direccion de escritura para PRINT
TAMEP:      DC.W        0           *Tamaño de escritura para PRINT
DESAP:      EQU         0          *Descriptor de linea A
DESBP:      EQU         1          *Descriptor de linea B 
NLINP:      EQU         1           *Numero de lineas a leer
TAMLP:      EQU         30           *Tamaño de linea para SCAN
TAMBP:      EQU         30           *Tamaño de bloque para PRINT

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
OTRAL:      MOVE.W      #TAMLP,-(A7)     *Tamaño maximo de la linea
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
OTRAE:      MOVE.W      #TAMBP,TAMEP     *Tamaño de escritura = Tamaño de bloque
ESPE:       MOVE.W      TAMEP,-(A7)     *Tamaño de escritura
            MOVE.W      #DESAP,-(A7)     *Puerto A
            MOVE.L      DIRLECP,-(A7)     * Direccion de lectura
            BSR         PRINT 
            ADD.L       #8,A7         *Restablece la pila
            ADD.L       D0,DIRLECP       *Calcula la nueva direccion del buffer 
            SUB.W       D0,CONTCP       *Actualiza el contador de caracteres
            BEQ         SALIR         *Si no quedas caracteres se acaba
            SUB.W       D0,TAMEP       *Actualiza el tamaño de escritura
            BNE         ESPE         *Si no se ha escrito todo el bloque se insiste
            CMP.W       #TAMBP,CONTCP     *Si el nº de caracteres que quedan es menor que el 
                            *tamaño establecido se transimite ese numero
            BHI         OTRAE        *Sigueinte bloque
            MOVE.W      CONTCP,TAMEP
            BRA         ESPE        *Siguiente bloque

SALIR:      BRA         BUCPR

FINP:       MOVE.W #-1,D7 *DEVUELEVE FFFF EN D7
            BREAK

BUS_ERROR:
			MOVE.W #-2,D7 *DEVUELEVE FFFE EN D7
            BREAK
            NOP
ADDRESS_ER: 
			MOVE.W #-3,D7 *DEVUELEVE FFFD EN D7
			BREAK
            NOP

ILLEGAL_IN:
			MOVE.W #-4,D7 *DEVUELEVE FFFC EN D7
            BREAK
            NOP
PRIV_VIOLT:
			MOVE.W #-5,D7 *DEVUELEVE FFFB EN D7
            BREAK
            NOP

		BREAK