#Para las listas se utilizó IA, para poder borrar la pantalla en la terminal y para pausar el programa por cierta cantidad de tiempo
import os
import time 

# Función auxiliar para limpiar la pantalla (compatible con Windows y Linux/Mac). 
def limpiar_pantalla():
    os.system('cls' if os.name == 'nt' else 'clear')

# =========================================================
# FUNCIONES DE VERIFICACIÓN Y SELECCIÓN
# =========================================================

def FibalABM(I, V, Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM):
    tiene_cap = False
    tiene_dio = False
    tiene_lm = False
    retornoABM = False
    
    print("=========================================================")
    print("    Verificación de componentes en inventario            ")
    print("=========================================================")
    
    # 1. VERIFICAR CAPACITOR (mínimo 1 unidad que soporte la tensión V)
    for k in range(len(Cant_cap)):
        if Cant_cap[k] >= 1 and Volt_Cap[k] >= V and tiene_cap == False:
            tiene_cap = True
            print(f"[Ok] Capacitor disponible: {Cap_Cap[k]} uF / {Volt_Cap[k]} V")
            
    if tiene_cap == False:
        print(f"[x] Sin capacitor adecuado (requiere soporte de al menos {V} V)")
    
    # 2. VERIFICAR DIODOS (mínimo 4 unidades que soporten la corriente I)
    for k in range(len(Cant_dod)):
        if Cant_dod[k] >= 4 and Corr_dod[k] >= I and tiene_dio == False:
            tiene_dio = True
            print(f"[Ok] Diodos disponibles: {Cant_dod[k]} unidades de {Corr_dod[k]} A")
            
    if tiene_dio == False:
        print(f"[x] Sin diodos suficientes (requiere al menos 4 diodos de >= {I} A)")
    
    # 3. VERIFICAR REGULADOR LM (mínimo 1 unidad de cualquier tipo registrado)
    for k in range(len(Cant_Lm)):
        if Cant_Lm[k] >= 1 and Tipo_LM[k] != "" and tiene_lm == False:
            tipo_lower = Tipo_LM[k].lower()
            if tipo_lower == "lm317" or tipo_lower == "lm317t":
                tiene_lm = True
                print(f"[Ok] Regulador disponible: {Tipo_LM[k].upper()}")
                print("El regulador ingresado es variable con potenciómetro (sirve de 0 a 30 V)")
            else:
                try:
                    # En Python el slicing [4:6] extrae los caracteres 5 y 6 (ej: de "lm7812" saca "12")
                    texto_xx = Tipo_LM[k][4:6]
                    Modelo_LM = int(texto_xx)
                    if Modelo_LM == V:
                        tiene_lm = True
                        print(f"[Ok] Regulador disponible: {Tipo_LM[k].upper()}")
                except ValueError:
                    tiene_lm = False
                    
    if tiene_lm == False:
        print("[x] Sin regulador LMxx disponible en inventario")
    
    # 4. EVALUACIÓN FINAL
    print("---------------------------------------------------------")
    if tiene_cap == True and tiene_dio == True and tiene_lm == True:
        print("Resultado: Es posible armar la fuente con su inventario.")
        retornoABM = True
    else:
        print("Resultado: No es posible armar la fuente con lo disponible.")
        retornoABM = False
        
    print("=========================================================")
    return retornoABM

def ElegirLMxx(V):
    retLMxx = 0.0
    print("=========================================================")
    print("         Selección de regulador de voltaje (LMxx)        ")
    print("=========================================================")
    print(" Reguladores lineales de tensión (I_diseño <= 0.8 A):    ") 
    
    if V == 5:
        print(" --- Salida fija positiva --- ")
        print("LM7805 (+5 V DC - Lógica digital / ATmega / Displays) (2000 ARS c/u)")
        retLMxx = 2000
        
    if V == 9:
        print(" --- Salida fija positiva --- ")
        print("LM7809 (+9 V DC - Baterías virtuales / Instrumental) (3300 ARS c/u) ")
        retLMxx = 3300
        
    if V == 12:
        print(" --- Salida fija positiva --- ")
        print("LM7812 (+12 V DC - Relés / Cooler DC / Solenoides) (3500 ARS c/u)")
        retLMxx = 3500
        
    if V != 12 and V != 9 and V != 5:
        print(f" --- Salida variable (0 a 30 V, depende la tensión de entrada) --- En este caso la tensión de entrada es: {V}")     
        print("LM317T (Ajustable 1.25 V a 12 V / Margen seg. 0.8 A) (10000 ARS c/u)")
        print("Para variar esto se necesita un potenciómetro lineal de 5 kOhm (5500 ARS c/u)")
        print("Se necesita una resistencia de 220 Ohm (3300 ARS 10 u o 330 c/u)")
        retLMxx = 15830
        
    return retLMxx

def ElegirCE(I, V):
    retPCE = 0.0
    print("=========================================================")
    print("          Selección de capacitor electrolítico           ")
    print("=========================================================")
    print(" Filtro de rizado para cargas de microelectrónica:       ")
    
    if I < 0.2 and V <= 25:
        print("470 uF / 25 V (Cargas muy bajas, I < 0.2 A / Sensores) (400 ARS c/u)")
        retPCE = 400
        
    if I >= 0.2 and I <= 0.5 and V <= 25:
        print(" [2] 1000 uF / 25 V (Cargas medias, I ~ 0.5 A / Arduino) (700 ARS c/u)")
        retPCE = 700
        
    if I > 0.5 or V > 25:
        print(" [3] 2200 uF / 35 V (Carga máxima, I ~ 0.8 A / ESP32 + Módulos) (1200 ARS c/u)")
        retPCE = 1200
        
    return retPCE

def ElegirPD(I):
    retPPD = 0.0
    print("=========================================================")
    print("            Selección de puente rectificador             ")
    print("=========================================================")
    
    if I < 0.4:
        print("Baja potencia (hasta 0.4 A - Ej: Diodos 1N4001..7) (3500 ARS los 4) ")
        retPPD = 3500
        
    if I >= 0.4 and I < 0.8:
        print("Media potencia (0.4 A a 0.8 A - Ej: W02M, W04M) (4500 ARS los 4)")
        retPPD = 4500
        
    if I == 0.8:
        print(" [3] Integrado encapsulado (hasta 0.8 A - Ej: DB104/DB107) (6500 ARS los 4) ")
        retPPD = 6500
        
    return retPPD


# =========================================================
# SUBPROCESOS (PROCEDIMIENTOS) DE INVENTARIO
# =========================================================

def Cargar_Todo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM):
    eleccion = "si"
    cantidad = 0
    max_comp = len(Cant_cap)
    
    print("Empecemos cargando tu inventario")
    print("Vamos a arrancar con los capacitores")
    while eleccion == "si" and cantidad < max_comp:
        if cantidad != 0:
            print("Su inventario actual es: \n")
            for k in range(max_comp):
                if Cant_cap[k] != 0:
                    print(f"{k+1}- Tiene {Cant_cap[k]} capacitores de {Cap_Cap[k]} microfaradios (uF) y {Volt_Cap[k]} V")
        print("\nIngrese el valor en microfaradios (uF) de su capacitor")
        micro_far_ingre = float(input())
        if micro_far_ingre > 0:
            print("Ingrese el voltaje que soporta el mismo")
            volt_ingre = float(input())
            if volt_ingre > 0:
                print("Ingrese la cantidad que tiene del mismo")
                cant_ingre = int(input())
                if cant_ingre > 0:
                    Cap_Cap[cantidad] = micro_far_ingre
                    Volt_Cap[cantidad] = volt_ingre
                    Cant_cap[cantidad] = cant_ingre
                    cantidad += 1
                    print("Desea agregar otro capacitor (si), sino presione cualquier tecla")
                    eleccion = input().lower()
                else:
                    print("Ingresó mal la cantidad del mismo")
            else:
                print("Ingresó mal el voltaje que soporta")
        else:
            print("Ingresó mal la capacidad del capacitor")
            
    limpiar_pantalla()
    eleccion = "si"
    cantidad = 0
    print("Ahora vamos a cargar tus diodos")
    while eleccion == "si" and cantidad < max_comp:
        if cantidad != 0:
            print("Su inventario actual es: \n")
            for k in range(max_comp):
                if Cant_dod[k] != 0:
                    print(f"{k+1}- Tiene {Cant_dod[k]} diodos de {Corr_dod[k]} A")
        print("\nIngrese la corriente en A que soporta su diodo")
        corriente_ingre = float(input())
        if corriente_ingre > 0:
            print("Ingrese la cantidad que tiene del mismo")
            cant_ingre = int(input())
            if cant_ingre > 0:
                Cant_dod[cantidad] = cant_ingre
                Corr_dod[cantidad] = corriente_ingre
                cantidad += 1
                print("Desea agregar otro diodo (si), sino presione cualquier tecla")
                eleccion = input().lower()
            else:
                print("Ingresó mal la cantidad que tiene del mismo")
        else:
            print("Ingresó mal la corriente que soporta el diodo")
            
    limpiar_pantalla()
    eleccion = "si"
    cantidad = 0
    print("Ahora vamos a cargar sus LM78XX")
    while eleccion == "si" and cantidad < max_comp:
        if cantidad != 0:
            print("Su inventario actual es: \n")
            for k in range(max_comp):
                if Cant_Lm[k] != 0:
                    print(f"{k+1}- Tiene {Cant_Lm[k]} del tipo {Tipo_LM[k]}")
        print("\nIngrese el tipo de LM78XX que tiene")
        txt_lm_ingre = input().lower()
        
        validos = ["lm7805", "lm7806", "lm7808", "lm7809", "lm7812", "lm7815", "lm7818", "lm7824", "lm317", "lm317t"]
        if txt_lm_ingre in validos:
            print("Ingrese la cantidad que tiene del mismo")
            cant_ingre = int(input())
            if cant_ingre > 0:
                Cant_Lm[cantidad] = cant_ingre
                Tipo_LM[cantidad] = txt_lm_ingre
                cantidad += 1
                print("Desea agregar otro LM78XX (si), sino presione cualquier tecla")
                eleccion = input().lower()
            else:
                print("Ingresó mal la cantidad que tiene del mismo")
        else:
            print("Ingresó mal el tipo de LM78XX, debe ingresar el modelo completo, ej: LM7812")
            
    limpiar_pantalla()
    Mostrar_inventario_completo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
    
    print("Desea hacer una modificación a su inventario (si), sino presione cualquier otra tecla")
    mod_inventario = input().lower()
    if mod_inventario == "si":
        Modificar_inventario(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)

def Modificar_inventario(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM):
    seguir_modificando = "si"
    
    while seguir_modificando == "si":
        print("Qué apartado desea modificar, ingrese su índice")
        print("1- Capacitores")
        print("2- Diodos")
        print("3- LM78XX")
        indice = int(input())
        limpiar_pantalla()
        
        if indice == 1:
            Modificar_stock_capacitores(Cant_cap, Volt_Cap, Cap_Cap)
        elif indice == 2:
            Modificar_stock_LM78xx(Cant_Lm, Tipo_LM)
        elif indice == 3:
            Modificar_stock_diodos(Cant_dod, Corr_dod)
        else:
            print("Ingresó mal el índice")
            
        limpiar_pantalla()
        Mostrar_inventario_completo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
        time.sleep(3)
        
        print("Desea modificar algún otro componente (si), sino presione cualquier otra tecla")
        seguir_modificando = input().lower()

def Mostrar_inventario_completo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM):
    print("Su inventario completo es el siguiente\n")
    print("Su inventario de capacitores es: \n")
    for k in range(len(Cant_cap)):
        if Cant_cap[k] != 0:
            print(f"{k+1}- Tiene {Cant_cap[k]} capacitores de {Cap_Cap[k]} microfaradios (uF) y {Volt_Cap[k]} V")
            
    print("\nSu inventario de LM78XX es: \n")
    for k in range(len(Cant_Lm)):
        if Cant_Lm[k] != 0:
            print(f"{k+1}- Tiene {Cant_Lm[k]} del tipo {Tipo_LM[k]}")
            
    print("\nSu inventario actual de diodos es: \n")
    for k in range(len(Cant_dod)):
        if Cant_dod[k] != 0:
            print(f"{k+1}- Tiene {Cant_dod[k]} diodos de {Corr_dod[k]} A")
    print("")

def Modificar_stock_capacitores(Cant_cap, Volt_Cap, Cap_Cap):
    mayor = 0
    print("Su inventario actual es: \n")
    for k in range(len(Cant_cap)):
        if Cant_cap[k] != 0:
            print(f"{k+1}- Tiene {Cant_cap[k]} capacitores de {Cap_Cap[k]} microfaradios (uF) y {Volt_Cap[k]} V")
            mayor = k + 1
    print("\nEscriba el índice de lo que desea realizar")
    print("1- Agregar nuevo ítem")
    print("2- Modificar ítem")
    print("3- Eliminar ítem")
    opcion = int(input())
    
    if opcion == 1:
        limpiar_pantalla()
        print("Ingrese el valor en microfaradios (uF) de su capacitor")
        micro_far_ingre = float(input())
        while micro_far_ingre <= 0:
            print("La capacidad debe ser mayor que 0")
            print("Ingrese nuevamente la capacidad. ")
            micro_far_ingre = float(input())
            
        print("Ingrese el volatje que soporta el mismo")
        volt_ingre = float(input())
        while volt_ingre <= 0:
            print("El voltaje debe ser mayor que 0")
            print("Ingrese nuevamente el voltaje: ")
            volt_ingre = float(input())
            
        print("Ingrese la cantidad que tiene del mismo")
        cant_ingre = int(input())
        while cant_ingre <= 0:
            print("La cantidad debe ser mayor que 0")
            cant_ingre = int(input())
            
        if mayor < len(Cant_cap):
            Cap_Cap[mayor] = micro_far_ingre
            Volt_Cap[mayor] = volt_ingre
            Cant_cap[mayor] = cant_ingre
            print("Se agregó el nuevo capacitor con éxito\n")
        else:
            print("Inventario lleno. No se puede agregar más.\n")
            
    elif opcion == 2:
        print("Ingrese el índice del apartado que desea modificar")
        indice = int(input())
        if 0 < indice <= mayor:
            print("Ingrese el valor en microfaradios (uF) de su capacitor")
            micro_far_ingre = float(input())
            if micro_far_ingre > 0:
                print("Ingrese el voltaje que soporta el mismo")
                volt_ingre = float(input())
                if volt_ingre > 0:
                    print("Ingrese la cantidad que tiene del mismo")
                    cant_ingre = int(input())
                    if cant_ingre > 0:
                        Cap_Cap[indice-1] = micro_far_ingre
                        Volt_Cap[indice-1] = volt_ingre
                        Cant_cap[indice-1] = cant_ingre
                        print("Se modificaron los datos de manera exitosa")
                        time.sleep(2)
                        limpiar_pantalla()
                        print("Su inventario actual es: ")
                        for k in range(len(Cant_cap)):
                            if Cant_cap[k] != 0:
                                print(f"{k+1}- Tiene {Cant_cap[k]} capacitores de {Cap_Cap[k]} microfaradios (uF) y {Volt_Cap[k]} V\n")
                        time.sleep(5)
                    else:
                        print("Ingresó mal la cantidad del mismo")
                else:
                    print("Ingresó mal el voltaje que soporta")
            else:
                print("Ingresó mal la capacidad del capacitor")
                
    elif opcion == 3:
        print("Ingrese el índice del apartado que desea eliminar")
        indice = int(input())
        if 1 <= indice <= mayor:
            for k in range(indice - 1, mayor - 1):
                Cap_Cap[k] = Cap_Cap[k + 1]
                Volt_Cap[k] = Volt_Cap[k + 1]
                Cant_cap[k] = Cant_cap[k + 1]
            Cap_Cap[mayor - 1] = 0
            Volt_Cap[mayor - 1] = 0
            Cant_cap[mayor - 1] = 0
            print("El capacitor fue eliminado correctamente")
        else:
            print("El índice ingresado no es válido")

def Modificar_stock_LM78xx(Cant_Lm, Tipo_LM):
    mayor = 0
    print("Su inventario actual es: \n")
    for k in range(len(Cant_Lm)):
        if Cant_Lm[k] != 0:
            print(f"{k+1}- Tiene {Cant_Lm[k]} del tipo {Tipo_LM[k]}")
            mayor = k + 1
    print("\nEscriba el índice de lo que desea realizar")
    print("1- Agregar nuevo ítem")
    print("2- Modificar ítem")
    print("3- Eliminar ítem")
    opcion = int(input())
    
    validos = ["lm7805", "lm7806", "lm7808", "lm7809", "lm7812", "lm7815", "lm7818", "lm7824"]
    
    if opcion == 1:
        limpiar_pantalla()
        print("Ingrese el tipo de LM78XX que tiene")
        txt_lm_ingre = input().lower()
        if txt_lm_ingre in validos:
            print("Ingrese la cantidad que tiene del mismo")
            cant_ingre = int(input())
            if cant_ingre > 0:
                if mayor < len(Cant_Lm):
                    Cant_Lm[mayor] = cant_ingre
                    Tipo_LM[mayor] = txt_lm_ingre
                    print("El LM78XX se agregó de manera exitosa\n")
                else:
                    print("Inventario lleno.")
            else:
                print("Ingresó mal la cantidad que tiene del mismo")
        else:
            print("Ingresó mal el tipo de LM78XX, debe ingresar el modelo completo, ej: LM7812")
            
    elif opcion == 2:
        print("Ingrese el índice del apartado que desea modificar")
        indice = int(input())
        if 0 < indice <= mayor:
            print("Ingrese el tipo de LM78XX que tiene")
            txt_lm_ingre = input().lower()
            if txt_lm_ingre in validos:
                print("Ingrese la cantidad que tiene del mismo")
                cant_ingre = int(input())
                if cant_ingre > 0:
                    Cant_Lm[indice - 1] = cant_ingre
                    Tipo_LM[indice - 1] = txt_lm_ingre
                    print("Su inventario fue modificado de manera exitosa")
                    time.sleep(2)
                    limpiar_pantalla()
                    print("Su inventario actual es: \n")
                    for k in range(len(Cant_Lm)):
                        if Cant_Lm[k] != 0:
                            print(f"{k+1}- Tiene {Cant_Lm[k]} del tipo {Tipo_LM[k]}\n")
                else:
                    print("Ingresó mal la cantidad que tiene del mismo")
            else:
                print("Ingresó mal el tipo de LM78XX")
        else:
            print("Ingresó mal el índice")
            
    elif opcion == 3:
        print("Ingrese el índice del apartado que desea eliminar")
        indice = int(input())
        if 1 <= indice <= mayor:
            for k in range(indice - 1, mayor - 1):
                Cant_Lm[k] = Cant_Lm[k + 1]
                Tipo_LM[k] = Tipo_LM[k + 1]
            Cant_Lm[mayor - 1] = 0
            Tipo_LM[mayor - 1] = ""
            print("El LM78XX fue eliminado correctamente")
        else:
            print("El indice ingresado no es válido")

def Modificar_stock_diodos(Cant_dod, Corr_dod):
    mayor = 0
    print("Su inventario actual es: \n")
    for k in range(len(Cant_dod)):
        if Cant_dod[k] != 0:
            print(f"{k+1}- Tiene {Cant_dod[k]} diodos de {Corr_dod[k]} A")
            mayor = k + 1
    print("\nEscriba el índice de lo que desea realizar")
    print("1- Agregar nuevo ítem")
    print("2- Modificar ítem")
    print("3- Eliminar ítem")
    opcion = int(input())
    
    if opcion == 1:
        limpiar_pantalla()
        print("Ingrese la corriente en A que soporta su diodo")
        corriente_ingre = float(input())
        if corriente_ingre > 0:
            print("Ingrese la cantidad que tiene del mismo")
            cant_ingre = int(input())
            if cant_ingre > 0:
                if mayor < len(Cant_dod):
                    Cant_dod[mayor] = cant_ingre
                    Corr_dod[mayor] = corriente_ingre
                    print("Se agregó el diodo de manera exitosa\n")
                else:
                    print("Inventario lleno.")
            else:
                print("Ingresó mal la cantidad que tiene del mismo")
        else:
            print("Ingresó mal la corriente que soporta el diodo")
            
    elif opcion == 2:
        print("Ingrese el índice del apartado que desea modificar")
        indice = int(input())
        if 0 < indice <= mayor:
            print("Ingrese la corriente en A que soporta su diodo")
            corriente_ingre = float(input())
            if corriente_ingre > 0:
                print("Ingrese la cantidad que tiene del mismo")
                cant_ingre = int(input())
                if cant_ingre > 0:
                    Cant_dod[indice - 1] = cant_ingre
                    Corr_dod[indice - 1] = corriente_ingre
                    print("Se modificaron los datos de manera exitosa")
                    time.sleep(2)
                    limpiar_pantalla()
                    print("Su inventario actual es: \n")
                    for k in range(len(Cant_dod)):
                        if Cant_dod[k] != 0:
                            print(f"{k+1}- Tiene {Cant_dod[k]} diodos de {Corr_dod[k]} A")
                else:
                    print("Ingresó mal la cantidad que tiene del mismo")
            else:
                print("Ingresó mal la corriente que soporta el diodo")
                
    elif opcion == 3:
        print("Ingrese el índice del apartado que desea eliminar")
        indice = int(input())
        if 1 <= indice <= mayor:
            for k in range(indice - 1, mayor - 1):
                Cant_dod[k] = Cant_dod[k + 1]
                Corr_dod[k] = Corr_dod[k + 1]
            Cant_dod[mayor - 1] = 0
            Corr_dod[mayor - 1] = 0
            print("El diodo fue eliminado correctamente")
        else:
            print("El indice ingresado no es válido")


# =========================================================
# PROCESO PRINCIPAL
# =========================================================

if __name__ == '__main__':
    op = "si"
    
    # ----------------------------------------------------------------------
    # ACÁ ESTÁ EL CAMBIO SOLICITADO: Se pide la cantidad de componentes
    # ----------------------------------------------------------------------
    print("=========================================================")
    print("  Configuración inicial del sistema                      ")
    print("=========================================================")
    print("¿Cuántos tipos distintos de componentes desea alojar como MÁXIMO por categoría?")
    max_elementos = int(input("Ingrese la cantidad (ej. 15, 50, 100): "))
    limpiar_pantalla()
    
    # PRECARGAR LISTAS PARA ABM DE FORMA DINÁMICA SEGÚN LO QUE PIDIÓ EL USUARIO
    Cant_cap = [0.0] * max_elementos
    Cant_Lm  = [0.0] * max_elementos
    Cant_dod = [0.0] * max_elementos
    Corr_dod = [0.0] * max_elementos
    Volt_Cap = [0.0] * max_elementos
    Cap_Cap  = [0.0] * max_elementos
    Tipo_LM  = [""] * max_elementos

    print("=========================================================")
    print("   Sistema de diseño y presupuesto de fuentes lineales   ")
    print("=========================================================")
    print("   Gestión de inventario y cálculo de componentes v1.0   ")
    print("---------------------------------------------------------")
    
    while op == "si":
        print("Ingrese la corriente máxima deseada en amperes (A) (máximo 0.8 A): ")
        I = float(input())
        while I <= 0 or I > 0.8:
            print("La corriente ingresada no es valida.")
            print("Debe ser mayor que 0 A y menor o igual a 0.8 A.")
            print("Ingrese nuevamente la corriente: ")
            I = float(input())
            
        print("Ingrese el voltaje deseado en volts (V) (máximo 30 V): ")
        V = float(input())
        while V <= 0 or V > 30:
            print("El voltaje ingresado no es valido")
            print("Debe ser mayor que 0 V y menor o igual a 30 V.")
            print("Ingrese nuevamente el voltaje: ")
            V = float(input())
            
        print("Seleccione de qué manera va a armar su presupuesto: ")
        print("[1] Selección automática")
        print("[2] Alta/baja/modificación de componente: ")
        elec = int(input())
        
        while elec == 1 or elec == 2:
            if elec == 1:
                limpiar_pantalla()
                pD = ElegirPD(I)
                print("Presione Enter para continuar...")
                input()
                
                limpiar_pantalla()
                pC = ElegirCE(I, V)
                print("Presione Enter para continuar...")
                input()
                
                limpiar_pantalla()
                pLMxx = ElegirLMxx(V)
                print("Presione Enter para continuar...")
                input()
                
                limpiar_pantalla()
                pf = pD + pC + pLMxx
                print("\nSu precio final de la fuente que desea armar por selección automática es:", pf, "ARS\n")
                time.sleep(3)
                elec = 0
                
            elif elec == 2:
                if Cant_cap[0] == 0 and Cant_Lm[0] == 0 and Cant_dod[0] == 0:
                    Cargar_Todo(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
                else:
                    print("Desea modificar su inventario (si), sino presione cualquier tecla")
                    mod_inventario = input().lower()
                    if mod_inventario == "si":
                        limpiar_pantalla()
                        Modificar_inventario(Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
                        
                retABM = FibalABM(I, V, Cant_cap, Cant_Lm, Cant_dod, Volt_Cap, Cap_Cap, Corr_dod, Tipo_LM)
                if retABM == True:
                    print("Sí vas a poder armar la fuente con lo que tenés")
                else:
                    print("No vas a poder armar una fuente con lo que tenés, te faltan componentes")
                elec = 0
                
            else:
                print("La opción ingresada es inválida")
                
        print("Desea volver a ejecutar el programa (si), si no presione cualquier otra tecla")
        op = input().lower()
        limpiar_pantalla()