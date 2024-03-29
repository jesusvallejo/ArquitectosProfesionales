
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
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura) *Configura junto con el ACR la velocidad de transmision de la Duart en A(38400)(pag. 39)
SRB		EQU	    $effc13       * de estado A (lectura)         		*Se consulta el estado de la linea B
CSRB	EQU     $effc13       * de seleccion de reloj B (escritura) *Configura junto con el ACR la velocidad de transmision de la Duart en B(38400)(pag. 39)
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
PPAL:	DC.L	0 * Puntero PRINT A lectura
PPAE:	DC.L	0 * Puntero PRINT A escritura
PPBE:	DC.L	0 * Puntero PRINT B escritura
PPBL:	DC.L	0 * Puntero PRINT B lectura
PSAE:	DC.L	0 * Puntero SCAN A escritura
PSAL:	DC.L	0 * Puntero SCAN A lectura
PSBE:	DC.L	0 * Puntero SCAN B escritura
PSBL:	DC.L	0 * Puntero SCAN B lectura

IMRC: 	DC.B	0 * Necesitamos una copia de IMR ya que no es un registro de lectura

RDCTA: 	DC.L	0 * Retorno de carro para RTI, en transmision A
RDCTB: 	DC.L	0 * Retorno de carro para RTI, en transmision B
RDCPA: 	DC.L	0 * Retorno de carro para PRINT en A
RDCPB: 	DC.L	0 * Retorno de carro para PRINT en B
CCB:    DC.W	0 * Contador de caracteres del buffer (SCAN/PRINT)
HLTA:    DC.L	0 * 
HLTB:    DC.L	0 * 
*********************************	
* Init
*********************************
INIT:

	    *Configuramos la Duart

	    MOVE.B          #%00010000,CRA      * Reinicia el puntero MR1
	    MOVE.B          #%00000011,MR1A     * 8 bits por caracter.
	    MOVE.B 			#%00010000,CRB		* Reinicia el puntero MR1
	    MOVE.B          #%00000000,MR2A     * Eco desactivado.
		
		MOVE.B          #%00000011,MR1B     * 8 bits por caracter.
	    MOVE.B          #%00000000,MR2B     * Eco desactivado.
		
	    MOVE.B          #%11001100,CSRA     * Velocidad = 38400 bps.
		MOVE.B          #%11001100,CSRB     * Velocidad = 38400 bps.
	    MOVE.B          #%00000000,ACR      * Velocidad = 38400 bps.
		

	    MOVE.B          #%00000101,CRA      * Transmision y recepcion activados.

		MOVE.B          #%00000101,CRB      * Transmision y recepcion activados.

		MOVE.B			#$00000040,IVR		* Inicializa el vector a hex 40
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
* Algoritmo LEECAR
* switch(d0)
*  case 0:
*    Lesa();  -----------------> if (buffer.punteroEscritura != buffer.punteroLectura){
*  case 1:                               solucion= buffer.punteroLectura.lee();
*    Lesb();                             if(buffer.punterolectura != buffer.finalBuffer){
*  case 2:								    buffer.punteroLectura++;}
*	 Lepa();                             else {   
*  case 3:                                  buffer.punteroLectura = buffer.iniciobuffer;}}
*    Lepb();                      else{
*                                         return -1;}
*                                 return solucion
LEECAR:


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
		MOVE.L			#0,D0
		MOVE.L 			PSAE,A2		*guardo puntero de escritura de A(scan)
		MOVE.L 			PSAL,A3		*guardo puntero de lectura de A(scan)
		CMP.L			A2,A3		*comparo los punteros -----------------------> Miro que los puntero de escritura u lectura no esten a la misma altura
		BEQ				FINLEC		*si son iguales devuelve en D0=0xFFFFFFFF----> si estan se devuelve -1(buffer vacio)
		MOVE.B			(A3)+,D0	*devuelve en D0 el dato----------------------> sino se devuelve el dato y se aumenta el puntero
		MOVE.L			#2001,A4	*guardo 2001 en A4
		ADDA.L			#BSA,A4		*guardo la direccion final del buffer
		CMP.L			A4,A3		*comparo A4,A3-------------------------------> si no se ha llegado al final del buffer se guarda el puntero 
		BEQ				FLESA		
		MOVE.L			A3,PSAL		*guardo en la direccion el avance del puntero
		BRA FINLE		
FLESA:	*FIN LEECAR SCAN A
		MOVE.L			#BSA,A3		*muevo el puntero a la direccion inicial-----> Si estamos al final del buffer se pone el puntero al inicio y se guarda
		MOVE.L			A3,PSAL	    *guardo en la direccion el avance del puntero
		BRA FINLE
		
LESB: 	*LEECAR SCAN B
		MOVE.L			#0,D0
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
		MOVE.L			#0,D0
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
		MOVE.L			#0,D0
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

		RTS	
				
*********************************
* Esccar(BUFFER(D0),CARACTER(D1))
*********************************
* Algoritmo ESCCAR
* switch(d0)
*  case 0:
*    esa();  ----------------->     buffer.punteroEscritura.Escribe(caracter);
*  case 1:                          if(buffer.punteroEscritura == buffer.finalBuffer){
*    esb();                            buffer.punteroEscritura = buffer.inicioBuffer}
*  case 2:							if(buffer.punteroEscritura + 1 != buffer.punteroLectura){   
*	 epa();                            buffer.punteroEscritura++;} 
*  case 3:                          else{	    
*    epb();                            return -1;}
*                                   buffer.punteroEscritura++;
*                                   return 0;
ESCCAR:


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
			MOVE.B			D1,(A0)+		*ESCRIBIMOS EN BUFFER
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
			MOVE.B			D1,(A0)+		*ESCRIBIMOS EN BUFFER
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
			MOVE.B			D1,(A0)+		*ESCRIBIMOS EN BUFFER
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
			MOVE.B			D1,(A0)+		*ESCRIBIMOS EN BUFFER
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

		RTS	

*********************************
* Linea(BUFFER(D0))
*********************************
* Algoritmo LINEA
* switch(d0)
*  case 0:                          contador=0;
*    Lsa();  ----------------->     A0 = buffer.punteroLectura; A1 = buffer.punteroEscritura;
*  case 1:                          WHILE(A0!=A1){
*    Lsb();                           if(A0==A1){return 0;};contador++; 
*  case 2:							  if(A0.leer() == 13){return contador;}
*	 Lpa();                           A0++;
*  case 3:                            if(A0 == buffer.finalBuffer){A0=buffer.inicioBuffer;}   
*    Lpb();                         }
*                                   return 0;
*                                     
LINEA:


		AND.W	#3,D0  				*Dos bits significativos
		CMP.L 	#0,D0
		BEQ		LSA 				*LINEA SCAN A
		CMP.W 	#2,D0
		BEQ 	LPA 				*LINEA PRINT A
		CMP.W 	#1,D0 
		BEQ 	LSB 				*LINEA SCAN B
		CMP.W 	#3,D0
		BEQ 	LPB 				*LINEA PRINT B
		
LSA: 	*LINEA SCAN A
		MOVE.L		#0,D3 			*CONTADOR DE LINEA
		MOVE.L		#BSA,A4
		ADDA.L		#2001,A4
		MOVE.L		PSAL,A0 		*A0 PUNTERO CARGO PUNTERO DE lECTURA
		MOVE.L 		PSAE,A1 		*CARGO PUNTERO DE ESCRITURA
BLSA:								* BUCLE LSA
		CMP.L 		A1,A0			*MIRO A VER SI ESTA FLV
		BEQ 		FLV
		CMP.L 		A4,A0
		BEQ 		FLSA
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   		* USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FINLA
		ADD.L 		#1,D3
		ADDA.L 		#1,A0 	  		*MUEVO EL PUNTERO
		BRA 		BLSA
FLSA:   *FIN LINEA SCAN A
		MOVE.L		#BSA,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BLSA

		
LPA: 	*LINEA PRINT A
		MOVE.L		#0,D3 			*CONTADOR DE LINEA
		MOVE.L		#BPA,A4
		ADDA.L		#2001,A4
		MOVE.L		PPAL,A0 		*A0 PUNTERO 
		MOVE.L 		PPAE,A1 		*CARGO PUNTERO DE ESCRITURA
BLPA:	* BUCLE LINEA PRINT A
		CMP.L 		A1,A0			*MIRO A VER SI ESTA FLV
		BEQ 		FLV
		CMP.L 		A4,A0
		BEQ 		FLPA
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   		*USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FINLA
		ADD.L 		#1,D3

		ADDA.L 		#1,A0 	  		*MUEVO EL PUNTERO
		BRA 		BLPA
FLPA:   *FIN LINEA PRINT A
		MOVE.L		#BPA,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BLPA
		
LSB: 	*LINEA SCAN B
		MOVE.L		#0,D3 			*CONTADOR DE LINEA
		MOVE.L		#BSB,A4
		ADDA.L		#2001,A4
		MOVE.L		PSBL,A0 		*A0 PUNTERO 
		MOVE.L 		PSBE,A1 		*CARGO PUNTERO DE ESCRITURA
BLSB:	* BUCLE LINEA SCAN B
		CMP.L 		A1,A0			*MIRO A VER SI ESTA FLV
		BEQ 		FLV
		CMP.L 		A4,A0
		BEQ 		FLSB
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   		*USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FINLA
		ADD.L 		#1,D3

		ADDA.L 		#1,A0 	  		*MUEVO EL PUNTERO
		BRA 		BLSB
FLSB:   *FIN LINEA SCAN B
		MOVE.L		#BSB,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BLSB
		
LPB: 	*LINEA PRINT B
		MOVE.L		#0,D3 			*CONTADOR DE LINEA
		MOVE.L		#BPB,A4
		ADDA.L		#2001,A4
		MOVE.L		PPBL,A0 		*A0 PUNTERO LECTURA 
		MOVE.L 		PPBE,A1 		*CARGO PUNTERO DE ESCRITURA
BLPB:	* BUCLE LINEA PRINT B
		CMP.L 		A1,A0			*MIRO A VER SI ESTA FLV
		BEQ 		FLV
		CMP.L 		A4,A0
		BEQ 		FLPB
		MOVE.B		(A0),D5
		CMP.L 		#13,D5   		*USAMOS PUNTERO SCAN DE A LECTURA
		BEQ 		FINLA
		ADD.L 		#1,D3

		ADDA.L 		#1,A0 	  		*MUEVO EL PUNTERO
		BRA 		BLPB
FLPB:	*FIN LINEA PRINT B
		MOVE.L		#BPB,A0			*PONGO DIRECCION INICIAL EN EL PUNTERO
		BRA 		BLPB


FLV: 	*FIN LINEA VACIA 
		MOVE.L 		#0,D0 			*D0=0
		RTS	
		
FINLA:  *FIN LINEA
		ADD.L		#1,D3
		MOVE.L 		D3,D0
		RTS	

                        


***********
* PRINT (BUFFER,DESCRIPTOR,TAMAÑO(POR PILA))
***********
* switch(descriptor)          contador =0;
*  case 0:                    while(contador!= tamaño && contadorCaracteres !=0){
*     printa();----------->    caracter = Esscar(buffer.getCaracter());
*  case 1:                     CONTADOR++;contadorCaracteres--;
*     printb();                if(caracter==13)
*  default:                      retornoDeCarro = true;
*   return -1;					}
*                              if(retornoDeCarro)
*                                 habilitaInterrupcionTransmision();
*                                 retornoDeCarro = false;
*                              dmpila();

PRINT:
		LINK A6,#0    *SARA

		*CARGAMOS DATOS
		MOVE.L		#0,A5
		MOVE.L		#0,D0
		MOVE.L		#0,D3
		MOVE.L		8(A6),A5			*A5=buffer
		MOVE.W		12(A6),D0      		*D0=descriptor
	    MOVE.W 		14(A6),D3			*D1=TAMA?
	    CMP.L       #0,D3
	    BEQ         DMPILAT        

		
PRINTTL:

		MOVE.L		D0,D4		 								
		CMP.W		#0,D0 				*miro a ver en que puerto va a leer
		BEQ		    PRINTA					*escribe en puerto A
		CMP.W		#1,D0				
		BEQ 		PRINTB 				*escribe en puerto B 
		MOVE.L 		#-1,D0 				*D0=-1 SI NO ES NI 0 NI 1
		BRA 		DMPILAPM

		 
		 
PRINTA:

		MOVE.L 		#0,D2 			*D2=CONTADOR
BUCPA:	
		
		MOVE.L 		#2,D0 			*PREPARO D0 PARA ESCCAR    a lo mejr es better usar move
		MOVE.L		#0,D1			*LIMPIO D1
		MOVE.B		(A5)+,D1		*OBTENGO EL CARACTER DEL buffer, cambiar en el resto
		CMP.L 		#13,D1			*MIRO A VER SI ES RETORNO DE CARRO
		BEQ			ACTTA
BUCPA1:
		BSR			ESCCAR			*LLAMO A ESCCAR, escribo el caracter
		CMP.L		#-1,D0 			*COMPRUEBO VALOR DEVUELTO POR ESCCAR
		BEQ			DMPILAP
		ADD.L 		#1,D2			*CONTADOR++	
		CMP.L 		D2,D3			*MIRO A VER SI HEMOS LLEGADO HASTA TAMAÑO de bloque 
		BEQ			DMPILAP         
		BRA 		BUCPA           *siguiente caracter
ACTTA:	 
        
        BSR			ESCCAR			*LLAMO A ESCCAR
        CMP.L		#-1,D0 			*COMPRUEBO VALOR DEVUELTO POR ESCCAR
		BEQ			DMPILAP
        ADD.L 		#1,D2			*CONTADOR++

DMPILAPA:

		 MOVE.W     #$2700,SR
		 BSET		#0,IMRC
		 MOVE.B		IMRC,IMR
		 MOVE.W     #$2000,SR
		 BRA        DMPILAP
		 
PRINTB:
		MOVE.L 		#0,D2 			*D2=CONTADOR
BUCPB:	
		 
		MOVE.L 		#3,D0 			*PREPARO D0 PARA ESCCAR    a lo mejr es better usar move
		MOVE.L		#0,D1			*LIMPIO D1
		MOVE.B		(A5)+,D1		*OBTENGO EL CARACTER DEL buffer
		CMP.L 		#13,D1			*MIRO A VER SI ES RETORNO DE CARRO
		BEQ			ACTTB
BUCPB1:	
        BSR			ESCCAR			*LLAMO A ESCCAR
		CMP.L		#-1,D0 			*COMPRUEBO VALOR DEVUELTO POR ESCCAR
		BEQ			DMPILAP
		ADD.L 		#1,D2			*CONTADOR++
		CMP.L 		D2,D3			*MIRO A VER SI HEMOS LLEGADO HASTA TAMAÑO
		BEQ			DMPILAP
		BRA 		BUCPB
ACTTB:	 
		
      
        BSR			ESCCAR			*LLAMO A ESCCAR
        CMP.L		#-1,D0 			*COMPRUEBO VALOR DEVUELTO POR ESCCAR
		BEQ			DMPILAP
        ADD.L 		#1,D2			*CONTADOR++
      
DMPILAPB:
		 
		 MOVE.W     #$2700,SR
		 BSET		#4,IMRC
		 MOVE.B		IMRC,IMR
		 MOVE.W     #$2000,SR
		 BRA        DMPILAP		         	
				
DMPILAT:  MOVE.L #0,D2		 
DMPILAP:  MOVE.L 	D2,D0 			*METO EL NUMERO DE CARACTERES ESCRITOS
DMPILAPM:		 

		UNLK 		A6
		RTS
*********************************************
* SCAN (BUFFER,DESCRIPTOR,TAMAÑO(POR PILA))
*********************************
* switch(descriptor)          linea = linea();solucion = linea;if(linea==0){return 0;}
*  case 0:                    while(linea!=0){
*     scana();----------->      buffer.punteroEscritura.escribir(leecar());contadorCaracteres++;
*  case 1:                      if(buffer.punteroEscritura.getPos() == buffer.finalBuffer()){
*     scanb();                     buffer.punteroEscritura= buffer.inicioBuffer;}
*  default:                     linea--;
*   return -1;					}
*                              return solucion;
*                                
*                                 
*                              
*
SCAN:   
		LINK A6,#0    *SARA

***********************************************************************************
		 MOVE.L      #0,D0
		 MOVE.L      #0,D1
		 MOVE.W		14(A6),D1			*D1=tama?
		 MOVE.W		12(A6),D0      		*D0=descriptor
		 MOVE.L		8(A6),A0			*A0=buffer CARGO EL Buffer
		 CMP.W		#0,D0 				*miro a ver en que puerto va a leer
		 BEQ		SCANA				*escribe en puerto A
		 CMP.W		#1,D0
		 BEQ 		SCANB 				*escribe en puerto B 
		 MOVE.L 	#-1,D0 				*D0=-1 SI NO ES NI 0 NI 1
		 BRA 		DMPILAS
**************************************************************************		 
		 		 
SCANA: 	 
		 MOVE.B 	#0,D0 				*D0=0   BUSCAMOS CUANTOS CARACTERES HAY EN EL BUFFER DE SCAN A
		 BSR 		LINEA
		 MOVE.L		8(A6),A0			*A0=buffer CARGO EL Buffer
		 MOVE.L 	D0,D2				*D2=LINEA
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINCEROA	 
		 MOVE.L 	D2,D3				*D3 REGISTRO TAMAÑO ESCRITO
		 CMP.W 		D1,D2 				*COMPARO TAMA? Y LINEA
		 BGT 		FINCEROA
BUCSA:	 	 
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINSCANA
		 MOVE.B 	#0,D0 				*PARAMETRO PARA LEECAR
		 BSR 		LEECAR		 
		 MOVE.B 	D0,(A0)+			*COPIO EL CARACTER EN BUFFER
		 SUB.L		#1,D2				*N--		
		 BRA BUCSA

FINCEROA: MOVE.L 	#0,D0 				*DEVUELVE 0 EN D0
		  BRA DMPILAS
FINSCANA: 
		 MOVE.L 	D3,D0 				*D0=N	
		 BRA DMPILAS

***************************************************************************************
SCANB: 	 
		 MOVE.L		#0,D0
		 MOVE.L 	#1,D0 				*D0=0
		 BSR 		LINEA 				*llamo a linea para saber cual es el tama? DE linea
		 MOVE.L		8(A6),A0			*A0=buffer CARGO EL Buffer
		 MOVE.L 	D0,D2				*D2=LINEA
		 CMP.W		#0,D2 				*LINEA=0?
		 BEQ 		FINCEROB
		 MOVE.L 	D2,D3				*D3 REGISTRO TAMAÑO ESCRITO
		 CMP.W 		D1,D2 				*COMPARO TAMA? Y LINEA
		 BGT 		FINCEROB
BUCSB:	 	
		 CMP.W		#0,D2 				*LINEA=1? Error 1 editado 18/02/2020
		 BEQ 		FINSCANB
		 MOVE.L 	#1,D0 				*PARAMETRO PARA LEECAR
		 BSR 		LEECAR
		 MOVE.B 	D0,(A0)+			*COPIO EL CARACTER EN BUFFER
		 SUB.L		#1,D2				*N--		
		 BRA BUCSB


FINCEROB: MOVE.L 	#0,D0 				*DEVUELVE 0 EN D0
		  BRA DMPILAS
FINSCANB: MOVE.L 	D3,D0 				*D0=N
		  BRA DMPILAS
DMPILAS:  

		UNLK 		A6
		RTS	


*********************************
* RTI
*********************************
* Algoritmo rti
* switch(and(imrc,isr))        linea=linea();if(retornoDeCarro==true){buffer.escribirCaracter.transmision(10);retornoDeCarro=false;if(linea()==0){inhibirInterrupcionTransmision();}}
*  case 0:        ta/b ------->   if(linea!=0 && linea!=-1)                
*    ta();                         caracter = leecar();
*  case 1:                           if(caracter == 13){retornoDeCarroTA=true;}
*    ra();                             buffer.escribirCaracter.transmision(caracter);
*  case 2:		  				  
*	 tb();                           
*  case 3:                 ra/b--------> esccar(buffer.getCaracter();)              
*    rb();                            
*                                   
*        

RTI:
* GUARDAR EN PILA D0-D5 A0-A4 , 6X2 + 5X4 = 32 BYTES A RESERVAR PARA GUARDAR 
	
		LINK A6,#-36  *Guardamos todos los registros para asegurar que no hay problemas de concurrencia
		MOVE.L 		D0,-4(A6)         
		MOVE.L 		D1,-8(A6)
		MOVE.L 		D3,-12(A6)
		MOVE.L 		D5,-16(A6)
		MOVE.L 		A0,-20(A6)
		MOVE.L 		A1,-24(A6)
		MOVE.L 		A2,-28(A6)
		MOVE.L 		A3,-32(A6)
		MOVE.L 		A4,-36(A6)
***********************************************************************************************		
AMBOS:
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
		BRA         FINREAL
**********************************************************************************************	
TA:			
			CMP.L		#1,RDCTA
			BEQ 		FINTA	
			MOVE.L		#2,D0 			*METO EN D0 3 		
			BSR 		LEECAR
			CMP.L 		#13,D0 			*RETORNO DE CARRO? 
			BNE 		VUELTATA			
RETCATA:  
			MOVE.L 		#1,RDCTA
VUELTATA:			  	
		  MOVE.B		D0,TBA			
		  BRA 			FINRTI		
FINTA: 	  
		  MOVE.L		#0,RDCTA
		  MOVE.B 		#10,TBA 			*NO MAS LINEA, SI RET DE CARRO, METO SALTO DE LINEA	  	  
     	  BCLR			#0,IMRC 			*INHIBO INTERRUPCIONES EN TA
		  MOVE.B 		IMRC,IMR 
		  BRA 			FINRTI

***********************************************************************************************

TB:			
			CMP.L		#1,RDCTB
			BEQ 		FINTB	  	
			MOVE.L		#3,D0 			*METO EN D0 3 		
			BSR 		LEECAR
			CMP.L 		#13,D0 			*RETORNO DE CARRO? 
			BNE 		VUELTATB			
RETCATB:  
			MOVE.L 		#1,RDCTB

VUELTATB:			  	
		  MOVE.B		D0,TBB			*NO REtORNO DE CARRO, SI LINEA, METO CARACTER
		  BRA         	FINRTI 			
FINTB: 	  
		  MOVE.L		#0,RDCTB
		  MOVE.B 		#10,TBB 			*NO MAS LINEAS, SI RET DE CARRO, METO SALTO DE LINEA  	
		  BCLR			#4,IMRC 			*INHIBO INTERRUPCIONES EN TA
		  MOVE.B 		IMRC,IMR 
		  BRA 			FINRTI

***********************************************************************************************
RA:
		  MOVE.L 		#0,D1
		  MOVE.B 		RBA,D1			*CARACTER PARA ESCCAR
		  MOVE.L 		#0,D0 			*BUFFER PARA ESCCAR(RBA)
		  BSR 			ESCCAR 			
		  BRA 			FINRTI 		

**********************************************************************************************
RB:		  
		  MOVE.L 		#0,D1
		  MOVE.B 		RBB,D1			*CARACTER PARA ESCCAR
		  MOVE.L 		#1,D0 			*BUFFER PARA ESCCAR(RBB)
		  BSR 			ESCCAR 			
		  BRA 			FINRTI 		
**********************************************************************************************	 
		 
FINRTI: 
        BRA AMBOS
FINREAL:		
		MOVE.L 		-36(A6),A4
		MOVE.L 		-32(A6),A3
		MOVE.L 		-28(A6),A2
		MOVE.L 		-24(A6),A1
		MOVE.L 		-20(A6),A0
		MOVE.L 		-16(A6),D5
		MOVE.L 		-12(A6),D3
		MOVE.L 		-8(A6),D1
		MOVE.L 		-4(A6),D0
		UNLK 		A6
		RTE

**********************************FIN RTI*****************************************************

********************************* PRUEBA PROPUESTA********************************************

BUFFER:       DS.B        2100   				*Buffer para lectura y escritura de caracteres  
CONTL:   	  DC.W        0 					*Contador de lineas
CONTC:    	  DC.W        0					*Contador de caracteres
DIRLEC:   	  DC.L        0 					*Direccion de lectura para SCAN
DIRESC:       DC.L        0 					*Direccion de escritura para PRINT
TAME:      	  DC.W        0 					*Tamaño de escritura para PRINT
DESA:         EQU         0					*Descriptor de linea A
DESB:         EQU         1					*Descriptor de linea B 
NLIN:         EQU         1 					*Numero de lineas a leer
TAML:         EQU         3000 					*Tamaño de linea para SCAN
TAMB:         EQU         5 					*Tamaño de bloque para PRINT

INICIO:
            MOVE.L      #BUS_ERROR,8    	* Bus error handler
            MOVE.L      #ADDRESS_ER,12 		* Address error handler
            MOVE.L      #ILLEGAL_IN,16 		* Illegal instruction handler
            MOVE.L      #PRIV_VIOLT,32 		* Privilege violation handler  
            BSR         INIT
            MOVE.W      #$2000,SR 			*Permite interrupciones

BUCPR:      MOVE.W      #0,CONTC   		*Inicializa contador de caracteres
            MOVE.W      #NLIN,CONTL 		*Inicializa contador de lineas
            MOVE.L      #BUFFER,DIRLEC 		*Direccion de lectura (comienzo del buffer)
OTRAL:      MOVE.W      #TAML,-(A7) 		*Tamaño maximo de la linea
            MOVE.W      #DESB,-(A7) 		*Puerto A
            MOVE.L      DIRLEC,-(A7) 		*Direccion de lectura
ESPL:       BSR         SCAN
            CMP.L       #0,D0
            BEQ         ESPL 				*Si no se ha leido una linea de intenta de nuevo
            ADDA.L      #8,A7 				*Restablece la pila
            ADD.L       D0,DIRLEC 			*Calcula la nueva direccion de lectura
            ADD.W       D0,CONTC 			*Actualiza el numero de caracteres leidos
            SUB.W       #1,CONTL 			*Actualiza el numero de lineas leidas. Si no
            BNE         OTRAL 				*se han leido todas las lineas se vuelve a leer

            MOVE.L      #BUFFER,DIRLEC 		*Direccion de lectura (comienzo del buffer)
OTRAE:      MOVE.W      #TAMB,TAME 		*Tamaño de escritura = Tamaño de bloque
ESPE:       MOVE.W      TAME,-(A7) 		*Tamaño de escritura
            MOVE.W      #DESA,-(A7) 		*Puerto A
            MOVE.L      DIRLEC,-(A7) 		* Direccion de lectura
            BSR         PRINT 
            ADD.L       #8,A7 				*Restablece la pila
            ADD.L       D0,DIRLEC 			*Calcula la nueva direccion del buffer 
            SUB.W       D0,CONTC 			*Actualiza el contador de caracteres
            BEQ         SALIR 				*Si no quedas caracteres se acaba
            SUB.W       D0,TAME 			*Actualiza el tamaño de escritura
            BNE         ESPE 				*Si no se ha escrito todo el bloque se insiste
            CMP.W       #TAMB,CONTC 		*Si el nº de caracteres que quedan es menor que el 
            								*tamaño establecido se transimite ese numero
            BHI         OTRAE				*Sigueinte bloque
            MOVE.W      CONTC,TAME
            BRA         ESPE				*Siguiente bloque

SALIR:      BRA         BUCPR

FIN:        
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