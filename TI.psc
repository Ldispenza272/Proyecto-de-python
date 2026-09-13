//TI PYTHON-PSEINT
//INTEGRANTES: DISPENZA LEONEL, ARANCIBIA MARCOS, GUERRERO VALENTINA, MATHON MADELEM
//ENTRADA: VOLTAJE DESEADO EN VOLTS (V), CORRIENTE MAXIMA EN AMPERES (A), COMPONENTE
//PROCESO: ABM COMPONENTES, SELECCION DE COMPONENTES QUE CUMPLAN CON LO REQUERIDO, IDENTIFICACION DE COMPONENTES FALTANTES Y SUMA DE PRECIO
//SALIDA: LISTA DE COMPONENTES A USAR, PRECIO TOTAL ESTIMADO 
//IA UTILIZADA GEMINI
//COSAS QUE SE LE PIDIO: TEXTOS
Funcion retLMxx <- ElegirLMxx ( V )
	Definir retLMxx Como Real;
	Escribir "=========================================================";
	Escribir "         SELECCIÓN DE REGULADOR DE VOLTAJE (LMxx)        ";
	Escribir "=========================================================";
	Escribir " Reguladores lineales de tensión (I_diseño <= 0.8 A):    ";                                       
	Si V==5 Entonces
		Escribir " --- SALIDA FIJA POSITIVA --- ";
		Escribir "LM7805 ( +5V DC - Lógica digital / ATmega / Displays) (2000 ARS C/U)";
		retLMxx<-2000;
	FinSi
	Si V==9 Entonces
		Escribir " --- SALIDA FIJA POSITIVA --- ";
		Escribir "LM7809 ( +9V DC - Baterías virtuales / Instrumental) (3300 ARS C/U) ";
		retLMxx<-3300;
	FinSi
	Si V==12 Entonces
		Escribir " --- SALIDA FIJA POSITIVA --- ";
		Escribir "LM7812 ( +12V DC - Relés / Cooler DC / Solenoides) (3500 ARS C/U)";
		retLMxx<-3500;
	FinSi
	Si V<>12 y V<>9 y V<>5 Entonces
		Escribir " --- SALIDA VARIABLE (0 A 30 V, DEPENDE LA TENSION DE ENTRADA) --- EN ESTE CASO LA TENSION DE ENTRADA ES:", V;     
		Escribir "LM317T ( Ajustable 1.25V a 12V / Margen seg. 0.8 A) (10000 ARS C/U)";
		Escribir "PARA VARIAR ESTO SE NECESITA UN POTENCIOMETRO LINEAL DE 5 KOHM (5500 ARS C/U)";
		Escribir "SE NECESITA UN RESISTENCIA DE 220 OHM (3300 ARS 10 U O 330 C/U)";
		retLMxx<-15830;
	FinSi
FinFuncion

Funcion retPCE <- ElegirCE (I, V)
	Definir retPCE Como Real;
	Escribir "=========================================================";
	Escribir "          SELECCIÓN DE CAPACITOR ELECTROLÍTICO           ";
	Escribir "=========================================================";
	Escribir " Filtro de rizado para cargas de microelectrónica:       ";
	Si I<0.2 y V<=25 Entonces
		Escribir "470 uF  / 25V (Cargas muy bajas, I < 0.2 A / Sensores) (400 ARS C/U)";
		retPCE<-400;
	FinSi
	Si I>=0.2 y I<=0.5 y V<=25 Entonces
		Escribir " [2] 1000 uF / 25V (Cargas medias,    I ~ 0.5 A / Arduino) (700 ARS C/U)";
		retPCE<-700;
	FinSi
	Si I>0.5 y I<=0.8 y V<=35 Entonces
		Escribir " [3] 2200 uF / 35V (Carga máxima,    I ~ 0.8 A / ESP32 + Módulos) (1200 ARS C/U)";
		retPCE<-1200;
	FinSi
FinFuncion

Funcion retPPD <- ElegirPD (I)
	Borrar Pantalla;
	Definir retPPD Como Real;
	Escribir "=========================================================";
	Escribir "            SELECCIÓN DE PUENTE RECTIFICADOR             ";
	Escribir "=========================================================";
	Si I<0.4 Entonces
		Escribir "Baja Potencia  (Hasta 0.4 A - Ej: Diodos 1N4001..7) (3500 ARS LOS 4) ";
		retPPD<-3500;
	FinSi
	Si I>=0.4 y I<0.8 Entonces
		Escribir "Media Potencia (0.4 A a 0.8 A - Ej: W02M, W04M)     (4500 ARS LOS 4)";
		retPPD<-4500;
	FinSi
	Si I==0.8 Entonces
		Escribir " [3] Integrado Encapsulado (Hasta 0.8 A - Ej: DB104/DB107) (6500 ARS LOS 4) ";
		retPPD<-6500;
	FinSi
FinFuncion

SubProceso Cargar_capacitores(Cant_cap)
	
FinSubProceso

SubProceso Cargar_LMxx(Cant_Lm)
	
FinSubProceso

SubProceso Cargar_diodos(Cant_dod)
	
FinSubProceso

SubProceso Cargar_Todo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, )
	Definir eleccion Como Caracter;
	Definir cantidad, k Como Entero;
	eleccion <- "si";
	cantidad <- 0;
	Escribir "EMPECEMOS CARGANDO TU INVENTARIO";
	Escribir "VAMOS A ARRANCAR CON LOS CAPACITORES";
	Mientras eleccion == "si" Hacer
		Escribir "SU INVENTARIO ACTUAL ES: ";
		Para k <- 0 Hasta 14 Hacer
			si List_cap[k] <> 0 Entonces
				Escribir List_cap[k];
				Escribir "";
			FinSi
			Escribir "INGRESE EL VALOR DE OHMS DE SU CAPACITOR";
			
		FinPara
	FinMientras
	
FinSubProceso

Proceso TI
	Definir op Como Caracter;
	Definir V, I, pf, e, pD, pC, pLMxx Como Real;
	Definir Cant_cap, Cant_Lm, Cant_dod Como Real;
	Definir Corr_dod, Volt_Cap, Tipo_LM, Cap_Cap Como Real;
	Definir j Como Entero;
	Definir mod_inventario Como Caracter;
	Dimensionar Cant_cap[15], Cant_Lm[15], Cant_dod[15];
	Dimensionar Corr_dod[15], Volt_Cap[15], Cap_Cap[15], Tipo_LM[15];
	op<-"S";
	//PRECAGAR LISTAS EN 0 PARA ABM
	Para j<-0 Hasta 14 Con Paso 1 Hacer
		Cant_cap[j]<-0;
		Cant_Lm[j]<-0;
		Cant_dod[j]<-0;
		Corr_dod[j]<-0;
		Volt_Cap[j]<-0;
		Cap_Cap[j]<-0;
		Tipo_LM[j]<-0;
	FinPara

	//
	Escribir "=========================================================";
	Escribir "   SISTEMA DE DISEÑO Y PRESUPUESTO DE FUENTES LINEALES   ";
	Escribir "=========================================================";
	Escribir "   Gestión de Inventario y Cálculo de Componentes v1.0   ";
	Escribir "---------------------------------------------------------";
	Mientras op=="S" o op=="s" Hacer
		Escribir "INGRESE LA CORRIENTE MÁXIMA DESEADA EN AMPERES (A) (MÁXIMO 0.8 A): ";
		Leer I;
		Escribir "INGRESE EL VOLTEJE DESEADO EN VOLTS (V) (MAXIMO 30 V): ";
		Leer V;
		Si I<=0.8 y V<=30 Entonces				//HACER PROGRAMA DE ESTE SI (ES UN VALIDADOR DE ENTRADA)
			Escribir "SELECCIONE DE QUE MANERA VA A ARMAR SU PRESUPUESTO: ";
			Escribir "[1] SELECCION AUTOMATICA";
			Escribir "[2] ALTA/BAJA/MODIFICACION DE COMPONENTE: ";
			Leer e;
			Segun e Hacer
				1:
					pD<-ElegirPD(I);
					Escribir "PRESIONE UNA TECLA PARA CONTINUAR...";
					Esperar Tecla;
					Borrar Pantalla;
					pC<-ElegirCE(I, V);
					Escribir "PRESIONE UNA TECLA PARA CONTINUAR...";
					Esperar Tecla;
					Borrar Pantalla;
					pLMxx<-ElegirLMxx(V);
					Escribir "PRESIONE UNA TECLA PARA CONTINUAR...";
					Esperar Tecla;
					Borrar Pantalla;
					pf<-pD+pC+pLMxx;
					Escribir "SU PRECIO FINAL DE LA FUENTE QUE DESEA ARMAR POR SELECCION AUTOMATICA ES: ", pf, " ARS";
				2:
					Si Cant_cap[0] == 0 Y Cant_Lm[0] == 0 Y Cant_dod[0] == 0 Entonces
						Cargar_Todo(Cant_cap, Cant_Lm, Cant_dod);
					FinSi
					Cargar_LMxx(Cant_Lm);
					Cargar_diodos(Cant_dod);
					Cargar_capacitores(Cant_cap);
				De Otro Modo:
					Escribir "OPCION INVALIDA";
			FinSegun
		SiNo
			Escribir "LA CORRIENTE INGRESADA ES SUPERIOR A 0.8 A O LA TENSION INGRESADA ES SUPERIOR A 30 V";
		FinSi
		Escribir "DESEA VOLVER A EJECUTAR EL PROGRAMA (S), SI NO PRESIONE CUALQUIER OTRA TECLA";
		Leer op;
		Borrar Pantalla;
	FinMientras
FinProceso
