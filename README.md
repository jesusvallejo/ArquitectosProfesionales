# ArquitectosProfesionales
Proyecto arquitectura de computadores

- Romano Rodriguez, Sara https://github.com/SaraRomano
- Vallejo Collados, Jesus


Fallos(en principio resueltos, pero no testeado en corrector del DATSI)
```
Fecha: 06/05/2020     22:27
		Correccion del usuario z170311 x150319


	Le queda 1 correccion seleccionable por el usuario

Identificador de la prueba: pr51es_int
	Entrada/Salida por interrupciones.
	La subrutina PRINT falla cuando se escriben dos lineas de 500
bytes por las lineas A y B (en sendas llamadas a PRINT). Cada
linea esta compuesta de la secuencia 1234567890 (repetida 50 veces) mas el
retorno de carro.
La salida del periferico A no es correcta.

	A continuación se muestra un volcado hexadecimal de los 10
primeros caracteres escritos sobre el puerto A que son diferentes al
resultado previsto.
El resultado obtenido es:
        0789: ----
        0790: ----
        0791: ----
        0792: ----
        0793: ----
        0794: ----
        0795: ----
        0796: ----
        0797: ----
        0798: ----

El resultado correcto deberia ser:
	0789: 0x37
	0790: 0x38
	0791: 0x39
	0792: 0x30
	0793: 0x31
	0794: 0x32
	0795: 0x33
	0796: 0x34
	0797: 0x35
	0798: 0x36


La salida del periferico B no es correcta.

	A continuación se muestra un volcado hexadecimal de los 10
primeros caracteres escritos sobre el puerto B que son diferentes al
resultado previsto.
El resultado obtenido es:
        0008: ----
        0009: ----
        0010: ----
        0011: ----
        0012: ----
        0013: ----
        0014: ----
        0015: ----
        0016: ----
        0017: ----

El resultado correcto deberia ser:
	0008: 0x38
	0009: 0x39
	0010: 0x30
	0011: 0x31
	0012: 0x32
	0013: 0x33
	0014: 0x34
	0015: 0x35
	0016: 0x36
	0017: 0x37


Identificador de la prueba: pr54es_int
	Entrada/Salida por interrupciones.
	La subrutina PRINT falla cuando se escriben dos lineas de 1500
bytes por las lineas A y B. Cada linea esta compuesta de la secuencia
1234567890 (repetida 150 veces) mas el retorno de carro.
La salida del periferico A no es correcta.

	A continuación se muestra un volcado hexadecimal de los 10
primeros caracteres escritos sobre el puerto A que son diferentes al
resultado previsto.
El resultado obtenido es:
        1503: ----
        1504: ----
        1505: ----
        1506: ----
        1507: ----
        1508: ----
        1509: ----
        1510: ----
        1511: ----
        1512: ----

El resultado correcto deberia ser:
	1503: 0x31
	1504: 0x32
	1505: 0x33
	1506: 0x34
	1507: 0x35
	1508: 0x36
	1509: 0x37
	1510: 0x38
	1511: 0x39
	1512: 0x30


Identificador de la prueba: pr55es_int
	Entrada/Salida por interrupciones.
	Se realiza la lectura de 3000 bytes de la linea A en lineas de
10 bytes (nueve caracteres mas el retorno de carro). Estas lineas se
imprimen por la linea B. Se asegura que los bufferes internos de las
lineas A y B nunca se llenan. Las lineas que se leen se componen por
la secuencia 123456789 mas el retorno de carro.
La salida del periferico B no es correcta.

	A continuación se muestra un volcado hexadecimal de los 10
primeros caracteres escritos sobre el puerto B que son diferentes al
resultado previsto.
El resultado obtenido es:
        1321: ----
        1322: ----
        1323: ----
        1324: ----
        1325: ----
        1326: ----
        1327: ----
        1328: ----
        1329: ----
        1330: ----

El resultado correcto deberia ser:
	1321: 0x31
	1322: 0x32
	1323: 0x33
	1324: 0x34
	1325: 0x35
	1326: 0x36
	1327: 0x37
	1328: 0x38
	1329: 0x39
	1330: 0x0d


Identificador de la prueba: pr59es_int
	Entrada/Salida por interrupciones.
	Se realiza la lectura de 3000 bytes de la linea A en lineas de
1001 bytes (1000 bytes mas el retorno de carro). Estas lineas se transmiten
por las lineas A y B. Se asegura que los bufferes internos de las lineas
A y B nunca se llenan. Las lineas que se leen se componen por la secuencia
0123456789 repetida 100 veces (mas el retorno de carro).
La salida del periferico B no es correcta.

	A continuación se muestra un volcado hexadecimal de los 10
primeros caracteres escritos sobre el puerto B que son diferentes al
resultado previsto.
El resultado obtenido es:
        0613: ----
        0614: ----
        0615: ----
        0616: ----
        0617: ----
        0618: ----
        0619: ----
        0620: ----
        0621: ----
        0622: ----

El resultado correcto deberia ser:
	0613: 0x32
	0614: 0x33
	0615: 0x34
	0616: 0x35
	0617: 0x36
	0618: 0x37
	0619: 0x38
	0620: 0x39
	0621: 0x30
	0622: 0x31
```
