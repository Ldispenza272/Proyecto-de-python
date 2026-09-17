//=========================================================
// AUTOR: DISPENZA LEONEL, ARANCIBIA MARCOS, GUERRERO VALENTINA, MATHON MADELEM
// USO DE IA: Nivel 2
// HERRAMIENTA: GEMINI EN MODO FLASH EXTENDIDO
// DETALLE: Ayudó en la redacción de algunos textos (prompts en el documento) y a pasar los mismos a minúsculas
// CRÍTICA: Ninguna
// =========================================================

//El análisis (EPS), se encuentra en el documento

Funcion retornoABM <- FibalABM ( I, V, Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM )
	Definir retornoABM Como Logico;
	Definir k, Modelo_LM Como Entero;
	Definir tiene_cap, tiene_dio, tiene_lm Como Logico;
	Definir texto_xx Como Caracter;
	
	tiene_cap <- Falso;
	tiene_dio <- Falso;
	tiene_lm <- Falso;
	
	//Uso de IA en textos
	Escribir "=========================================================";
	Escribir "    Verificación de componentes en inventario            ";
	Escribir "=========================================================";
	
	// 1. VERIFICAR CAPACITOR (mínimo 1 unidad que soporte la tensión V)
	Para k <- 0 Hasta 14 Hacer
		Si Cant_cap[k] >= 1 Y Volt_Cap[k] >= V Y tiene_cap == Falso Entonces
			tiene_cap <- Verdadero;
			Escribir "[Ok] Capacitor disponible: ", Cap_Cap[k], " uF / ", Volt_Cap[k], " V";
		FinSi
	FinPara
	Si tiene_cap == Falso Entonces
		Escribir "[x] Sin capacitor adecuado (requiere soporte de al menos ", V, " V)";
	FinSi
	
	// 2. VERIFICAR DIODOS (mínimo 4 unidades que soporten la corriente I)
	Para k <- 0 Hasta 14 Hacer
		Si Cant_dod[k] >= 4 Y Corr_dod[k] >= I Y tiene_dio == Falso Entonces
			tiene_dio <- Verdadero;
			Escribir "[Ok] Diodos disponibles: ", Cant_dod[k], " unidades de ", Corr_dod[k], " A";
		FinSi
	FinPara
	Si tiene_dio==Falso Entonces
		Escribir "[x] Sin diodos suficientes (requiere al menos 4 diodos de >= ", I, " A)";
	FinSi
	
	// 3. VERIFICAR REGULADOR LM (mínimo 1 unidad de cualquier tipo registrado)
	Para k <- 0 Hasta 14 Hacer
		Si Cant_Lm[k] >= 1 Y Tipo_LM[k] <> "" Y tiene_lm == Falso Entonces
			Si Minusculas(Tipo_LM[k]) == "lm317" o Minusculas(Tipo_LM[k]) == "lm317t" Entonces
				tiene_lm <- Verdadero;
				Escribir "[Ok] Regulador disponible: ", Mayusculas(Tipo_LM[k]);
				Escribir "El regulador ingresado es variable con potenciómetro (sirve de 0 a 30 V)";
			SiNo
				texto_xx<-Subcadena(Tipo_LM[k], 4, 6);
				Modelo_LM<-ConvertirANumero(texto_xx);
				Si Modelo_LM==V Entonces
					tiene_lm <- Verdadero;
					Escribir "[Ok] Regulador disponible: ", Mayusculas(Tipo_LM[k]);
				SiNo
					tiene_lm <- Falso;
				FinSi
			FinSi
		FinSi
	FinPara
	Si tiene_lm==Falso Entonces
		Escribir "[x] Sin regulador LMxx disponible en inventario";
	FinSi
	
	// 4. EVALUACIÓN FINAL
	Escribir "---------------------------------------------------------";
	Si tiene_cap == Verdadero Y tiene_dio == Verdadero Y tiene_lm == Verdadero Entonces
		Escribir "Resultado: Es posible armar la fuente con su inventario.";
		retornoABM <- Verdadero;
	SiNo
		Escribir "Resultado: No es posible armar la fuente con lo disponible.";
		retornoABM <- Falso;
	FinSi
	Escribir "=========================================================";
FinFuncion

Funcion retLMxx <- ElegirLMxx( V )
	Definir retLMxx Como Real;
	
	//Uso de IA en textos
	Escribir "=========================================================";
	Escribir "         Selección de regulador de voltaje (LMxx)        ";
	Escribir "=========================================================";
	Escribir " Reguladores lineales de tensión (I_diseño <= 0.8 A):    "; 
	
	Si V==5 Entonces
		Escribir " --- Salida fija positiva --- ";
		Escribir "LM7805 (+5 V DC - Lógica digital / ATmega / Displays) (2000 ARS c/u)";
		retLMxx<-2000;
	FinSi
	
	Si V==9 Entonces
		Escribir " --- Salida fija positiva --- ";
		Escribir "LM7809 (+9 V DC - Baterías virtuales / Instrumental) (3300 ARS c/u) ";
		retLMxx<-3300;
	FinSi
	
	Si V==12 Entonces
		Escribir " --- Salida fija positiva --- ";
		Escribir "LM7812 (+12 V DC - Relés / Cooler DC / Solenoides) (3500 ARS c/u)";
		retLMxx<-3500;
	FinSi
	
	Si V<>12 y V<>9 y V<>5 Entonces
		Escribir " --- Salida variable (0 a 30 V, depende la tensión de entrada) --- En este caso la tensión de entrada es: ", V;     
		Escribir "LM317T (Ajustable 1.25 V a 12 V / Margen seg. 0.8 A) (10000 ARS c/u)";
		Escribir "Para variar esto se necesita un potenciómetro lineal de 5 kOhm (5500 ARS c/u)";
		Escribir "Se necesita una resistencia de 220 Ohm (3300 ARS 10 u o 330 c/u)";
		retLMxx<-15830;
	FinSi
FinFuncion

Funcion retPCE <- ElegirCE (I, V)
	Definir retPCE Como Real;
	
	//Uso de IA en textos
	Escribir "=========================================================";
	Escribir "          Selección de capacitor electrolítico           ";
	Escribir "=========================================================";
	Escribir " Filtro de rizado para cargas de microelectrónica:       ";
	
	Si I<0.2 y V<=25 Entonces
		Escribir "470 uF / 25 V (Cargas muy bajas, I < 0.2 A / Sensores) (400 ARS c/u)";
		retPCE<-400;
	FinSi
	
	Si I>=0.2 y I<=0.5 y V<=25 Entonces
		Escribir " [2] 1000 uF / 25 V (Cargas medias, I ~ 0.5 A / Arduino) (700 ARS c/u)";
		retPCE<-700;
	FinSi
	
	Si I>0.5 o V>25 Entonces
		Escribir " [3] 2200 uF / 35 V (Carga máxima, I ~ 0.8 A / ESP32 + Módulos) (1200 ARS c/u)";
		retPCE<-1200;
	FinSi
FinFuncion

Funcion retPPD <- ElegirPD (I)
	Definir retPPD Como Real;
	
	//Uso de IA en textos
	Escribir "=========================================================";
	Escribir "            Selección de puente rectificador             ";
	Escribir "=========================================================";
	
	Si I<0.4 Entonces
		Escribir "Baja potencia (hasta 0.4 A - Ej: Diodos 1N4001..7) (3500 ARS los 4) ";
		retPPD<-3500;
	FinSi
	
	Si I>=0.4 y I<0.8 Entonces
		Escribir "Media potencia (0.4 A a 0.8 A - Ej: W02M, W04M) (4500 ARS los 4)";
		retPPD<-4500;
	FinSi
	
	Si I==0.8 Entonces
		Escribir " [3] Integrado encapsulado (hasta 0.8 A - Ej: DB104/DB107) (6500 ARS los 4) ";
		retPPD<-6500;
	FinSi
FinFuncion

SubProceso Cargar_Todo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
	Definir eleccion, txt_lm_ingre, mod_inventario Como Caracter;
	Definir cantidad, k, cant_ingre Como Entero;
	Definir corriente_ingre, volt_ingre, micro_far_ingre Como Real;
	
	eleccion <- "si";
	cantidad <- 0;
	Escribir "Empecemos cargando tu inventario";
	Escribir "Vamos a arrancar con los capacitores";
	Mientras eleccion == "si" y cantidad <= 14 Hacer
		si cantidad <> 0 Entonces
			Escribir "Su inventario actual es: ";
			Escribir "";
			Para k <- 0 Hasta 14 Hacer
				si Cant_cap[k] <> 0 Entonces
					Escribir k+1, "- Tiene ", Cant_cap[k], " capacitores de ", Cap_Cap[k], " microfaradios (uF) y ", Volt_Cap[k], " V" ;
				FinSi
			FinPara
		FinSi
		Escribir "";
		Escribir "Ingrese el valor en microfaradios (uF) de su capacitor";
		Leer micro_far_ingre;
		si micro_far_ingre > 0 Entonces
			Escribir "Ingrese el voltaje que soporta el mismo";
			Leer volt_ingre;
			si volt_ingre > 0 Entonces
				Escribir "Ingrese la cantidad que tiene del mismo";
				Leer cant_ingre;
				si cant_ingre > 0 Entonces
					Cap_Cap[cantidad] <- micro_far_ingre;
					Volt_Cap[cantidad] <- volt_ingre;
					Cant_cap[cantidad] <- cant_ingre;
					cantidad <- cantidad + 1;
					Escribir "Desea agregar otro capacitor (si), sino presione cualquier tecla";
					Leer eleccion;
					eleccion <- Minusculas(eleccion);
				SiNo
					Escribir "Ingresó mal la cantidad del mismo";
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
			Escribir "Su inventario actual es: ";
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
			Escribir "Ingrese la cantidad que tiene del mismo";
			Leer cant_ingre;
			si cant_ingre > 0 Entonces
				Cant_dod[cantidad] <- cant_ingre;
				Corr_dod[cantidad] <- corriente_ingre;
				cantidad <- cantidad + 1;
				Escribir "Desea agregar otro diodo (si), sino presione cualquier tecla";
				Leer eleccion;
				eleccion <- Minusculas(eleccion);
			SiNo
				Escribir "Ingresó mal la cantidad que tiene del mismo";
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
			Escribir "Su inventario actual es: ";
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
		si txt_lm_ingre == "lm7805" o txt_lm_ingre == "lm7806" o txt_lm_ingre == "lm7808" o txt_lm_ingre == "lm7809" o txt_lm_ingre == "lm7812" o txt_lm_ingre == "lm7815" o txt_lm_ingre == "lm7818" o txt_lm_ingre == "lm7824" o txt_lm_ingre == "lm317" o txt_lm_ingre == "lm317t" Entonces
			Escribir "Ingrese la cantidad que tiene del mismo";
			Leer cant_ingre;
			si cant_ingre > 0 Entonces
				Cant_Lm[cantidad] <- cant_ingre;
				Tipo_LM[cantidad] <- txt_lm_ingre;
				cantidad <- cantidad + 1;
				Escribir "Desea agregar otro LM78XX (si), sino presione cualquier tecla";
				Leer eleccion;
				eleccion <- Minusculas(eleccion);
			SiNo
				Escribir "Ingresó mal la cantidad que tiene del mismo";
			FinSi
		SiNo
			Escribir "Ingresó mal el tipo de LM78XX, debe ingresar el modelo completo, ej: LM7812";
		FinSi
	FinMientras
	Limpiar Pantalla;
	Mostrar_inventario_completo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM);
	
	Escribir "Desea hacer una modificación a su inventario (si), sino presione cualquier otra tecla";
	Leer mod_inventario;
	mod_inventario <- Minusculas(mod_inventario);
	si mod_inventario == "si" Entonces
		Modificar_inventario(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM);
	FinSi
FinSubProceso

SubProceso Modificar_inventario(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
	Definir seguir_modificando Como Caracter;
	Definir indice Como Entero;
	
	seguir_modificando <- "si";
	
	Mientras seguir_modificando == "si" Hacer
		Escribir "Qué apartado desea modificar, ingrese su índice";
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
		Mostrar_inventario_completo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM);
		Esperar 3 Segundos;
		
		Escribir "Desea modificar algún otro componente (si), sino presione cualquier otra tecla";
		Leer seguir_modificando;
		seguir_modificando <- Minusculas(seguir_modificando);
	FinMientras
FinSubProceso

SubProceso Mostrar_inventario_completo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
	Definir k Como Entero;
	Escribir "Su inventario completo es el siguiente";
	Escribir "";
	Escribir "Su inventario de capacitores es: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_cap[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_cap[k], " capacitores de ", Cap_Cap[k], " microfaradios (uF) y ", Volt_Cap[k], " V" ;
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
	Definir micro_far_ingre, volt_ingre, cant_ingre, opcion Como Entero;
	
	Escribir "Su inventario actual es: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_cap[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_cap[k], " capacitores de ", Cap_Cap[k], " microfaradios (uF) y ", Volt_Cap[k], " V" ;
			mayor <- k+1;
		FinSi
	FinPara
	Escribir "";
	
	Escribir "Escriba el índice de lo que desea realizar";
	Escribir "1- Agregar nuevo ítem";
	Escribir "2- Modificar ítem";
	Escribir "3- Eliminar ítem";
	Leer opcion;
	
	Segun opcion Hacer
		1:
			Limpiar Pantalla;
			Escribir "Ingrese el valor en microfaradios (uF) de su capacitor";
			Leer micro_far_ingre;
			si micro_far_ingre > 0 Entonces
				Escribir "Ingrese el voltaje que soporta el mismo";
				Leer volt_ingre;
				si volt_ingre > 0 Entonces
					Escribir "Ingrese la cantidad que tiene del mismo";
					Leer cant_ingre;
					si cant_ingre > 0 Entonces
						Cap_Cap[mayor] <- micro_far_ingre;
						Volt_Cap[mayor] <- volt_ingre;
						Cant_cap[mayor] <- cant_ingre;
						Escribir "Se agregó el nuevo capacitor con éxito";
						Escribir "";
					SiNo
						Escribir "Ingresó mal la cantidad del mismo";
					FinSi
				SiNo
					Escribir "Ingresó mal el voltaje que soporta";
				FinSi
			SiNo
				Escribir "Ingresó mal la capacidad del capacitor";
			FinSi
		2:
			Escribir "Ingrese el índice del apartado que desea modificar";
			Leer indice;
			
			si indice <= mayor y indice > 0 Entonces
				Escribir "Ingrese el valor en microfaradios (uF) de su capacitor";
				Leer micro_far_ingre;
				si micro_far_ingre > 0 Entonces
					Escribir "Ingrese el voltaje que soporta el mismo";
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
							Escribir "Su inventario actual es: ";
							Para k <- 0 Hasta 14 Hacer
								si Cant_cap[k] <> 0 Entonces
									Escribir k+1, "- Tiene ", Cant_cap[k], " capacitores de ", Cap_Cap[k], " microfaradios (uF) y ", Volt_Cap[k], " V" ;
									Escribir "";
								FinSi
							FinPara
							Esperar 5 Segundos;
						SiNo
							Escribir "Ingresó mal la cantidad del mismo";
						FinSi
					SiNo
						Escribir "Ingresó mal el voltaje que soporta";
					FinSi
				SiNo
					Escribir "Ingresó mal la capacidad del capacitor";
				FinSi
			FinSi
		3:
			Escribir "Ingrese el índice del apartado que desea eliminar";
			Leer indice;
			
			si indice <= mayor y indice > 0 Entonces
				Cap_Cap[indice-1] <- 0;
				Volt_Cap[indice-1] <- 0;
				Cant_cap[indice-1] <- 0;
			FinSi
		De Otro Modo:
			Escribir "Eligió un índice no válido";
	FinSegun
FinSubProceso

SubProceso Modificar_stock_LM78xx(Cant_Lm, Tipo_LM)
	Definir k, indice, mayor, opcion Como Entero;
	Definir txt_lm_ingre Como Caracter;
	Definir cant_ingre Como Entero;
	
	Escribir "Su inventario actual es: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_Lm[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_Lm[k], " del tipo ", Tipo_LM[k];
			mayor <- k + 1;
		FinSi
	FinPara
	Escribir "";
	
	Escribir "Escriba el índice de lo que desea realizar";
	Escribir "1- Agregar nuevo ítem";
	Escribir "2- Modificar ítem";
	Escribir "3- Eliminar ítem";
	Leer opcion;
	
	Segun opcion Hacer
		1:
			Limpiar Pantalla;
			Escribir "Ingrese el tipo de LM78XX que tiene";
			Leer txt_lm_ingre;
			txt_lm_ingre <- Minusculas(txt_lm_ingre);
			si txt_lm_ingre == "lm7805" o txt_lm_ingre == "lm7806" o txt_lm_ingre == "lm7808" o txt_lm_ingre == "lm7809" o txt_lm_ingre == "lm7812" o txt_lm_ingre == "lm7815" o txt_lm_ingre == "lm7818" o txt_lm_ingre == "lm7824" Entonces
				Escribir "Ingrese la cantidad que tiene del mismo";
				Leer cant_ingre;
				si cant_ingre > 0 Entonces
					Cant_Lm[mayor] <- cant_ingre;
					Tipo_LM[mayor] <- txt_lm_ingre;
					Escribir "El LM78XX se agregó de manera exitosa";
					Escribir "";
				SiNo
					Escribir "Ingresó mal la cantidad que tiene del mismo";
				FinSi
			SiNo
				Escribir "Ingresó mal el tipo de LM78XX, debe ingresar el modelo completo, ej: LM7812";
			FinSi
		2:
			Escribir "Ingrese el índice del apartado que desea modificar";
			Leer indice;
			
			si indice <= mayor y indice > 0 Entonces
				Escribir "Ingrese el tipo de LM78XX que tiene";
				Leer txt_lm_ingre;
				txt_lm_ingre <- Minusculas(txt_lm_ingre);
				si txt_lm_ingre == "lm7805" o txt_lm_ingre == "lm7806" o txt_lm_ingre == "lm7808" o txt_lm_ingre == "lm7809" o txt_lm_ingre == "lm7812" o txt_lm_ingre == "lm7815" o txt_lm_ingre == "lm7818" o txt_lm_ingre == "lm7824" Entonces
					Escribir "Ingrese la cantidad que tiene del mismo";
					Leer cant_ingre;
					si cant_ingre > 0 Entonces
						Cant_Lm[indice - 1] <- cant_ingre;
						Tipo_LM[indice - 1] <- txt_lm_ingre;
						Escribir "Su inventario fue modificado de manera exitosa";
						Esperar 2 Segundos;
						Limpiar Pantalla;
						Escribir "Su inventario actual es: ";
						Escribir "";
						Para k <- 0 Hasta 14 Hacer
							si Cant_Lm[k] <> 0 Entonces
								Escribir k+1, "- Tiene ", Cant_Lm[k], " del tipo ", Tipo_LM[k];
								Escribir "";
							FinSi
						FinPara
					SiNo
						Escribir "Ingresó mal la cantidad que tiene del mismo";
					FinSi
				SiNo
					Escribir "Ingresó mal el tipo de LM78XX";
				FinSi
			SiNo
				Escribir "Ingresó mal el índice";
			FinSi
		3:
			Escribir "Ingrese el índice del apartado que desea eliminar";
			Leer indice;
			
			si indice <= mayor y indice > 0 Entonces
				Cant_Lm[indice - 1] <- 0;
				Tipo_LM[indice - 1] <- "";
			FinSi
		De Otro Modo:
			Escribir "Eligió un índice no válido";	
	FinSegun
FinSubProceso

SubProceso Modificar_stock_diodos(Cant_dod, Corr_dod)
	Definir k, indice, mayor, opcion Como Entero;
	Definir cant_ingre, corriente_ingre Como Entero;
	
	Escribir "Su inventario actual es: ";
	Escribir "";
	Para k <- 0 Hasta 14 Hacer
		si Cant_dod[k] <> 0 Entonces
			Escribir k+1, "- Tiene ", Cant_dod[k], " diodos de ", Corr_dod[k], " A" ;
			mayor <- k + 1;
		FinSi
	FinPara
	Escribir "";
	
	Escribir "Escriba el índice de lo que desea realizar";
	Escribir "1- Agregar nuevo ítem";
	Escribir "2- Modificar ítem";
	Escribir "3- Eliminar ítem";
	Leer opcion;
	
	Segun opcion Hacer
		1:
			Limpiar Pantalla;
			Escribir "Ingrese la corriente en A que soporta su diodo";
			Leer corriente_ingre;
			si corriente_ingre > 0 Entonces
				Escribir "Ingrese la cantidad que tiene del mismo";
				Leer cant_ingre;
				si cant_ingre > 0 Entonces
					Cant_dod[mayor] <- cant_ingre;
					Corr_dod[mayor] <- corriente_ingre;
					Escribir "Se agregó el diodo de manera exitosa";
					Escribir "";
				SiNo
					Escribir "Ingresó mal la cantidad que tiene del mismo";
				FinSi
			SiNo
				Escribir "Ingresó mal la corriente que soporta el diodo";
			FinSi
		2:
			Escribir "Ingrese el índice del apartado que desea modificar";
			Leer indice;
			si indice <= mayor y indice > 0 Entonces
				Escribir "Ingrese la corriente en A que soporta su diodo";
				Leer corriente_ingre;
				si corriente_ingre > 0 Entonces
					Escribir "Ingrese la cantidad que tiene del mismo";
					Leer cant_ingre;
					si cant_ingre > 0 Entonces
						Cant_dod[indice - 1] <- cant_ingre;
						Corr_dod[indice - 1] <- corriente_ingre;
						Escribir "Se modificaron los datos de manera exitosa";
						Esperar 2 Segundos;
						Limpiar Pantalla;
						Escribir "Su inventario actual es: ";
						Escribir "";
						Para k <- 0 Hasta 14 Hacer
							si Cant_dod[k] <> 0 Entonces
								Escribir k+1, "- Tiene ", Cant_dod[k], " diodos de ", Corr_dod[k], " A" ;
							FinSi
						FinPara
					SiNo
						Escribir "Ingresó mal la cantidad que tiene del mismo";
					FinSi
				SiNo
					Escribir "Ingresó mal la corriente que soporta el diodo";
				FinSi
			FinSi
		3:
			Escribir "Ingrese el índice del apartado que desea eliminar";
			Leer indice;
			
			si indice <= mayor y indice > 0 Entonces
				Cant_dod[indice - 1] <- 0;
				Corr_dod[indice - 1] <- 0;
			FinSi
		De Otro Modo:
			Escribir "Eligió un índice no válido";
	FinSegun
FinSubProceso


Proceso Armador_de_fuentes_lineales
	Definir op Como Caracter;
	Definir V, I, pf, pD, pC, pLMxx Como Real;
	Definir Cant_cap, Cant_Lm, Cant_dod Como Real;
	Definir Corr_dod, Volt_Cap, Cap_Cap Como Real;
	Definir Tipo_LM Como Caracter;
	Definir j, elec Como Entero;
	Definir mod_inventario Como Caracter;
	Definir retABM Como Logico;
	Dimensionar Cant_cap[15], Cant_Lm[15], Cant_dod[15];
	Dimensionar Corr_dod[15], Volt_Cap[15], Cap_Cap[15], Tipo_LM[15];
	
	op <- "si";
	//PRECAGAR LISTAS PARA ABM
	Para j<-0 Hasta 14 Con Paso 1 Hacer
		Cant_cap[j]<-0;
		Cant_Lm[j]<-0;
		Cant_dod[j]<-0;
		Corr_dod[j]<-0;
		Volt_Cap[j]<-0;
		Cap_Cap[j]<-0;
		Tipo_LM[j]<-"";
	FinPara
	
	//Uso de IA en textos
	Escribir "=========================================================";
	Escribir "   Sistema de diseño y presupuesto de fuentes lineales   ";
	Escribir "=========================================================";
	Escribir "   Gestión de inventario y cálculo de componentes v1.0   ";
	Escribir "---------------------------------------------------------";
	Mientras op == "si" Hacer
		Escribir "Ingrese la corriente máxima deseada en amperes (A) (máximo 0.8 A): ";
		Leer I;
		Escribir "Ingrese el voltaje deseado en volts (V) (máximo 30 V): ";
		Leer V;
		
		Si I <= 0.8 y I > 0 y V > 0 y V <= 30 Entonces				//HACER PROGRAMA DE ESTE SI (ES UN VALIDADOR DE ENTRADA)
			Escribir "Seleccione de qué manera va a armar su presupuesto: ";
			Escribir "[1] Selección automática";
			Escribir "[2] Alta/baja/modificación de componente: ";
			Leer elec;
			Mientras elec==1 o elec==2 Hacer
				Segun elec Hacer
					1:
						Borrar Pantalla;
						pD <- ElegirPD(I);
						Escribir "Presione una tecla para continuar...";
						Esperar Tecla;
						
						Borrar Pantalla;
						pC <- ElegirCE(I, V);
						Escribir "Presione una tecla para continuar...";
						Esperar Tecla;
						
						Borrar Pantalla;
						pLMxx <- ElegirLMxx(V);
						Escribir "Presione una tecla para continuar...";
						Esperar Tecla;
						
						Borrar Pantalla;
						pf <- pD + pC + pLMxx;
						Escribir "";
						Escribir "Su precio final de la fuente que desea armar por selección automática es: ", pf, " ARS";
						Escribir "";
						Esperar 3 Segundos;
						elec <- 0;
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
						retABM<-FibalABM ( I, V, Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM );
						Si retABM==Verdadero Entonces
							Escribir "Sí vas a poder armar la fuente con lo que tenés";
							elec<-0;
						SiNo
							Escribir "No vas a poder armar una fuente con lo que tenés, te faltan componentes";
							elec<-0;
						FinSi
					De Otro Modo:
						Escribir "La opción ingresada es inválida";
				FinSegun
			FinMientras
		SiNo
			Escribir "La corriente ingresada es superior a 0.8 A o la tensión ingresada es superior a 30 V, o ingresó valores negativos";
		FinSi
		
		Escribir "Desea volver a ejecutar el programa (si), si no presione cualquier otra tecla";
		Leer op;
		op <- Minusculas(op);
		Borrar Pantalla;
	FinMientras
FinProceso