//TI PYTHON-PSEINT
//INTEGRANTES: DISPENZA LEONEL, ARANCIBIA MARCOS, GUERRERO VALENTINA, MATHON MADELEM

//ENTRADA: VOLTAJE DESEADO EN VOLTS (V), CORRIENTE MAXIMA EN AMPERES (A), CANTIDAD DE COMPENENTES, VOLTAJE CAPACITORES, CAPACIDAD CAPACITORES Y DIODOS, TIPO DE LM (REDUCTOR DE VOLTAJE) 

//PROCESO: ABM COMPONENTES, SELECCION DE COMPONENTES QUE CUMPLAN CON LO REQUERIDO, IDENTIFICACION DE COMPONENTES FALTANTES Y SUMA DE PRECIO

//SALIDA: LISTA DE COMPONENTES A USAR, PRECIO TOTAL ESTIMADO 

//IA UTILIZADA GEMINI EN MODO FLASH EXTENDIDO
//COSAS QUE SE LE PIDIO: TEXTOS
//PROMTS:

Funcion retLMxx <- ElegirLMxx( V )
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

SubProceso Cargar_Todo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
	Definir eleccion, txt_lm_ingre Como Caracter;
	Definir cantidad, k, volt_ingre, micro_far_ingre, cant_ingre, corriente_ingre Como Entero;
	
	eleccion <- "si";
	cantidad <- 0;
	Escribir "EMPECEMOS CARGANDO TU INVENTARIO";
	Escribir "VAMOS A ARRANCAR CON LOS CAPACITORES";
	Mientras eleccion == "si" y cantidad <= 14 Hacer
		si cantidad <> 0 Entonces
			Escribir "SU INVENTARIO ACTUAL ES: ";
			Escribir "";
			Para k <- 0 Hasta 14 Hacer
				si Cant_cap[k] <> 0 Entonces
					Escribir k+1, "- Tiene ", Cant_cap[k], " capacitores de ", Cap_Cap[k], " microfaradios (uF) y ", Volt_Cap[k], "V" ;
				FinSi
			FinPara
		FinSi
		Escribir "";
		Escribir "INGRESE EL VALOR EN MICROFARADIOS (uF) DE SU CAPACITOR";
		Leer micro_far_ingre;
		si micro_far_ingre > 0 Entonces
			Escribir "INGRESE EL VOLTAJE QUE SORPORTA EL MISMO";
			Leer volt_ingre;
			si volt_ingre > 0 Entonces
				Escribir "Ingrese la cantidad que tiene del mismo";
				Leer cant_ingre;
				si cant_ingre > 0 Entonces
					Cap_Cap[cantidad] <- micro_far_ingre;
					Volt_Cap[cantidad] <- volt_ingre;
					Cant_cap[cantidad] <- cant_ingre;
					cantidad <- cantidad + 1;
					Escribir "Desea agregar otro capacitor (si), sino precione cualquier tecla";
					Leer eleccion;
					eleccion <- Minusculas(eleccion);
				SiNo
					Escribir "Ingreso mal la cantidad del mismo";
				FinSi
			SiNo
				Escribir "Ingresó mal el voltaje que soporta";
			FinSi
		SiNo
			Escribir "Ingresó mal la capacidad del capacitor";
		FinSi
	FinMientras
	
	Limpiar Pantalla;
	eleccion <- "si";
	cantidad <- 0;
	Escribir "Ahora vamos a cargar tus diodos";
	Mientras eleccion == "si" y cantidad <= 14  Hacer
		si cantidad <> 0 Entonces
			Escribir "SU INVENTARIO ACTUAL ES: ";
			Escribir "";
			Para k <- 0 Hasta 14 Hacer
				si Cant_dod[k] <> 0 Entonces
					Escribir k+1, "- Tiene ", Cant_dod[k], " diodos de ", Corr_dod[k], " A" ;
				FinSi
			FinPara
		FinSi
		Escribir "";
		Escribir "Ingrese la corriente en A que soporta su diodo";
		Leer corriente_ingre;
		si corriente_ingre > 0 Entonces
			Escribir "INGRESE LA CANTIDAD QUE TIENE DEL MISMO";
			Leer cant_ingre;
			si cant_ingre > 0 Entonces
				Cant_dod[cantidad] <- cant_ingre;
				Corr_dod[cantidad] <- corriente_ingre;
				cantidad <- cantidad + 1;
				Escribir "Desea agregar otro diodo (si), sino precione cualquier tecla";
				Leer eleccion;
				eleccion <- Minusculas(eleccion);
			SiNo
				Escribir "Ingreso mal la cantidad que tiene del mismo";
			FinSi
		SiNo
			Escribir "Ingresó mal la corriente que soporta el diodo";
		FinSi
	FinMientras
	
	Limpiar Pantalla;
	eleccion <- "si";
	cantidad <- 0;
	Escribir "Ahora vamos a cargar sus LM78XX";
	Mientras eleccion == "si" y cantidad <= 14 Hacer
		si cantidad <> 0 Entonces
			Escribir "SU INVENTARIO ACTUAL ES: ";
			Escribir "";
			Para k <- 0 Hasta 14 Hacer
				si Cant_Lm[k] <> 0 Entonces
					Escribir k+1, "- Tiene ", Cant_Lm[k], " del tipo ", Tipo_LM[k];
				FinSi
			FinPara
		FinSi
		Escribir "";
		Escribir "Ingrese el tipo de LM78XX que tiene";
		Leer txt_lm_ingre;
		txt_lm_ingre <- Minusculas(txt_lm_ingre);
		si txt_lm_ingre == "lm7805" o txt_lm_ingre == "lm7806" o txt_lm_ingre == "lm7808" o txt_lm_ingre == "lm7809" o txt_lm_ingre == "lm7812" o txt_lm_ingre == "lm7815" o txt_lm_ingre == "lm7818" o txt_lm_ingre == "lm7824" Entonces
			Escribir "INGRESE LA CANTIDAD QUE TIENE DEL MISMO";
			Leer cant_ingre;
			si cant_ingre > 0 Entonces
				Cant_Lm[cantidad] <- cant_ingre;
				Tipo_LM[cantidad] <- txt_lm_ingre;
				cantidad <- cantidad + 1;
				Escribir "Desea agregar otro LM78XX (si), sino precione cualquier tecla";
				Leer eleccion;
				eleccion <- Minusculas(eleccion);
			SiNo
				Escribir "Ingreso mal la cantidad que tiene del mismo";
			FinSi
		SiNo
			Escribir "Ingresó mal el tipo de LM78XX, debe ingresar el modelo completo, ej: LM7812";
		FinSi
	FinMientras
	Limpiar Pantalla;
FinSubProceso

SubProceso Modificar_inventario(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
	Definir seguir_modificando Como Caracter;
	Definir indice Como Entero;
	
	seguir_modificanto <- "si";
	
	Mientras seguir_modificando == "si" Hacer
		Escribir "Que apartado desea modificar, ingre su índice";
		Escribir "1- Capacitores";
		Escribir "2- Diodos";
		Escribir "3- LM78XX";
		Leer indice;
		Limpiar Pantalla;
		Segun indice Hacer
			1:
				Modificar_stock_capacitores(Cant_cap, Volt_Cap, Cap_Cap);
			2:
				Modificar_stock_LM78xx(Cant_Lm, Tipo_LM);
			3:
				Modificar_stock_diodos(Cant_dod, Corr_dod);
			De Otro Modo:
				Escribir "Ingresó mal el índice";
		FinSegun
		Limpiar Pantalla;
		Mostrar_inventario_completo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
		Esperar 3 Segundos;
		
		Escribir "Desea modificar algún otro componete (si), sino presione cualquier otra tecla";
		Leer seguir_modificando;
		seguir_modificando <- Minusculas(seguir_modificando);
	FinMientras
FinSubProceso

SubProceso Mostrar_inventario_completo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
	Definir k Como Entero;
	Escribir "Su inventario de capacitores es: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_cap[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_cap[k], " capacitores de ", Cap_Cap[k], " microfaradios (uF) y ", Volt_Cap[k], "V" ;
		FinSi
	FinPara
	
	Escribir "";
	
	Escribir "Su inventario de LM78XX es: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_Lm[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_Lm[k], " del tipo ", Tipo_LM[k];
		FinSi
	FinPara
	
	Escribir "";
	
	Escribir "Su inventario actual de diodos es: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_dod[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_dod[k], " diodos de ", Corr_dod[k], " A" ;
		FinSi
	FinPara
	
	Escribir "";
FinSubProceso

SubProceso Modificar_stock_capacitores(Cant_cap, Volt_Cap, Cap_Cap)
	Definir k, indice, mayor Como Entero;
	Definir micro_far_ingre, volt_ingre, cant_ingre Como Entero;
	
	Escribir "SU INVENTARIO ACTUAL ES: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_cap[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_cap[k], " capacitores de ", Cap_Cap[k], " microfaradios (uF) y ", Volt_Cap[k], "V" ;
			mayor <- k+1;
		FinSi
	FinPara
	Escribir "";
	
	Escribir "Ingrese el indice del apartado que desea modificar";
	Leer indice;
	
	si indice <= mayor y indice > 0 Entonces
		Escribir "INGRESE EL VALOR EN MICROFARADIOS (uF) DE SU CAPACITOR";
		Leer micro_far_ingre;
		si micro_far_ingre > 0 Entonces
			Escribir "INGRESE EL VOLTAJE QUE SORPORTA EL MISMO";
			Leer volt_ingre;
			si volt_ingre > 0 Entonces
				Escribir "Ingrese la cantidad que tiene del mismo";
				Leer cant_ingre;
				si cant_ingre > 0 Entonces
					Cap_Cap[indice-1] <- micro_far_ingre;
					Volt_Cap[indice-1] <- volt_ingre;
					Cant_cap[indice-1] <- cant_ingre;
					Escribir "Se modificaron los datos de manera exitosa";
					Esperar 2 Segundos;
					Limpiar Pantalla;
					Escribir "SU INVENTARIO ACTUAL ES: ";
					Para k <- 0 Hasta 14 Hacer
						si Cant_cap[k] <> 0 Entonces
							Escribir k+1, "- Tiene ", Cant_cap[k], " capacitores de ", Cap_Cap[k], " microfaradios (uF) y ", Volt_Cap[k], "V" ;
							Escribir "";
						FinSi
					FinPara
					Esperar 5 Segundos;
				SiNo
					Escribir "Ingreso mal la cantidad del mismo";
				FinSi
			SiNo
				Escribir "Ingresó mal el voltaje que soporta";
			FinSi
		SiNo
			Escribir "Ingresó mal la capacidad del capacitor";
		FinSi
	FinSi
FinSubProceso

SubProceso Modificar_stock_LM78xx(Cant_Lm, Tipo_LM)
	Definir k, indice, mayor Como Entero;
	Definir txt_lm_ingre Como Caracter;
	Definir cant_ingre Como Entero;
	
	Escribir "SU INVENTARIO ACTUAL ES: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_Lm[k] <> 0 Entonces
		Escribir k+1, "- Tiene ", Cant_Lm[k], " del tipo ", Tipo_LM[k];
		mayor <- k + 1;
		FinSi
	FinPara
	Escribir "";
	Escribir "Ingrese el indice del apartado que desea modificar";
	Leer indice;
	si indice <= mayor y indice > 0 Entonces
		Escribir "Ingrese el tipo de LM78XX que tiene";
		Leer txt_lm_ingre;
		txt_lm_ingre <- Minusculas(txt_lm_ingre);
		si txt_lm_ingre == "lm7805" o txt_lm_ingre == "lm7806" o txt_lm_ingre == "lm7808" o txt_lm_ingre == "lm7809" o txt_lm_ingre == "lm7812" o txt_lm_ingre == "lm7815" o txt_lm_ingre == "lm7818" o txt_lm_ingre == "lm7824" Entonces
			Escribir "INGRESE LA CANTIDAD QUE TIENE DEL MISMO";
			Leer cant_ingre;
			si cant_ingre > 0 Entonces
				Cant_Lm[indice - 1] <- cant_ingre;
				Tipo_LM[indice - 1] <- txt_lm_ingre;
				Escribir "Su inventario fue modificador de manera exitosa";
				Esperar 2 Segundos;
				Limpiar Pantalla;
				Escribir "SU INVENTARIO ACTUAL ES: ";
				Escribir "";
				Para k <- 0 Hasta 14 Hacer
					si Cant_Lm[k] <> 0 Entonces
						Escribir k+1, "- Tiene ", Cant_Lm[k], " del tipo ", Tipo_LM[k];
						Escribir "";
					FinSi
				FinPara
			SiNo
				Escribir "Ingreso mal la cantidad que tiene del mismo";
			FinSi
		SiNo
			Escribir "Ingresó mal el tipo de LM78XX";
		FinSi
	SiNo
		Escribir "Ingresó mal el índice";
	FinSi
FinSubProceso

SubProceso Modificar_stock_diodos(Cant_dod, Corr_dod)
	Definir k, indice, mayor Como Entero;
	Definir cant_ingre, corriente_ingre Como Entero;
	
	Escribir "SU INVENTARIO ACTUAL ES: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_dod[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_dod[k], " diodos de ", Corr_dod[k], " A" ;
			mayor <- k + 1;
		FinSi
	FinPara
	Escribir "";
	Escribir "Ingrese el indice del apartado que desea modificar";
	Leer indice;
	si indice <= mayor y indice > 0 Entonces
		Escribir "Ingrese la corriente en A que soporta su diodo";
		Leer corriente_ingre;
		si corriente_ingre > 0 Entonces
			Escribir "INGRESE LA CANTIDAD QUE TIENE DEL MISMO";
			Leer cant_ingre;
			si cant_ingre > 0 Entonces
				Cant_dod[indice - 1] <- cant_ingre;
				Corr_dod[indice - 1] <- corriente_ingre;
				Escribir "Se modificaron los datos de manera exitosa";
				Esperar 2 Segundos;
				Limpiar Pantalla;
				Escribir "SU INVENTARIO ACTUAL ES: ";
				Escribir "";
				Para k <- 0 Hasta 14 Hacer
					si Cant_dod[k] <> 0 Entonces
						Escribir k+1, "- Tiene ", Cant_dod[k], " diodos de ", Corr_dod[k], " A" ;
					FinSi
				FinPara
			SiNo
				Escribir "Ingreso mal la cantidad que tiene del mismo";
			FinSi
		SiNo
			Escribir "Ingresó mal la corriente que soporta el diodo";
		FinSi
	FinSi
FinSubProceso


Proceso TI
	Definir op Como Caracter;
	Definir V, I, pf, pD, pC, pLMxx Como Real;
	Definir Cant_cap, Cant_Lm, Cant_dod Como Real;
	Definir Corr_dod, Volt_Cap, Tipo_LM, Cap_Cap Como Real;
	Definir j, elec Como Entero;
	Definir mod_inventario Como Caracter;
	Dimensionar Cant_cap[15], Cant_Lm[15], Cant_dod[15];
	Dimensionar Corr_dod[15], Volt_Cap[15], Cap_Cap[15], Tipo_LM[15];
	
	op<-"si";
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
	Mientras op=="si" Hacer
		Escribir "INGRESE LA CORRIENTE MÁXIMA DESEADA EN AMPERES (A) (MÁXIMO 0.8 A): ";
		Leer I;
		Escribir "INGRESE EL VOLTEJE DESEADO EN VOLTS (V) (MAXIMO 30 V): ";
		Leer V;
		Si I<=0.8 y V<=30 Entonces				//HACER PROGRAMA DE ESTE SI (ES UN VALIDADOR DE ENTRADA)
			Escribir "SELECCIONE DE QUE MANERA VA A ARMAR SU PRESUPUESTO: ";
			Escribir "[1] SELECCION AUTOMATICA";
			Escribir "[2] ALTA/BAJA/MODIFICACION DE COMPONENTE: ";
			Leer elec;
			Segun elec Hacer
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
						Cargar_Todo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM);
					SiNo
						Escribir "Desea modificar su inventario (si), sino presione cualquier tecla";
						Leer mod_inventario;
						mod_inventario <- Minusculas(mod_inventario);
						si mod_inventario == "si" Entonces
							Limpiar Pantalla;
							Modificar_inventario(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM);
						FinSi
					FinSi
					
					// falta funcion para calcular en base al inventario
					
				De Otro Modo:
					Escribir "Ingresó mal la opción";
			FinSegun
		SiNo
			Escribir "LA CORRIENTE INGRESADA ES SUPERIOR A 0.8 A O LA TENSION INGRESADA ES SUPERIOR A 30 V";
		FinSi
		Escribir "DESEA VOLVER A EJECUTAR EL PROGRAMA (Si), SI NO PRESIONE CUALQUIER OTRA TECLA";
		Leer op;
		op <- Minusculas(op);
		Borrar Pantalla;
	FinMientras
FinProceso
