# La librería 'os' se utiliza para borrar la pantalla, equivale al "Borrar pantalla; de pseint"
#  La librería 'time' se utiliza para manejar funciones relacionadas con el tiempo, en este caso seria el esperartelca; de pseint.
import os
import time 

def limpiar_pantalla():
    os.system('cls' if os.name == 'nt' else 'clear')

def FibalABM(I, V, dic_capacitores, dic_lms, dic_diodos):
    tiene_cap = False
    tiene_dio = False
    tiene_lm = False
    retornoABM = False
    
    print("=========================================================")
    print("    Verificación de componentes en inventario            ")
    print("=========================================================")
    
    for volt, caps in dic_capacitores.items():
        if volt >= V and not tiene_cap:
            for cap, cant in caps.items():
                if cant >= 1:
                    tiene_cap = True
                    print("[Ok] Capacitor disponible:", cap, "uF /", volt, "V")
                    break
            
    if not tiene_cap:
        print("[x] Sin capacitor adecuado (requiere soporte de al menos", V, "V)")
    
    for amp, cant in dic_diodos.items():
        if cant >= 4 and amp >= I and not tiene_dio:
            tiene_dio = True
            print("[Ok] Diodos disponibles:", cant, "unidades de", amp, "A")
            
    if not tiene_dio:
        print("[x] Sin diodos suficientes (requiere al menos 4 diodos de >=", I, "A)")
    
    for tipo, cant in dic_lms.items():
        if cant >= 1 and not tiene_lm:
            tipo_lower = tipo.lower()
            if tipo_lower in ["lm317", "lm317t"]:
                tiene_lm = True
                print("[Ok] Regulador disponible:", tipo.upper())
                print("El regulador ingresado es variable con potenciómetro (sirve de 0 a 30 V)")
            else:
                try:
                    texto_xx = tipo[4:6]
                    Modelo_LM = int(texto_xx)
                    if Modelo_LM == V:
                        tiene_lm = True
                        print("[Ok] Regulador disponible:", tipo.upper())
                except ValueError:
                    pass
                    
    if not tiene_lm:
        print("[x] Sin regulador LMxx disponible en inventario")
    
    print("---------------------------------------------------------")
    if tiene_cap and tiene_dio and tiene_lm:
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
        print(" --- Salida variable (0 a 30 V, depende la tensión de entrada) --- En este caso la tensión de entrada es:", V)     
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

def Cargar_Todo(dic_capacitores, dic_lms, dic_diodos):
    eleccion = "si"
    
    print("Empecemos cargando tu inventario")
    print("Vamos a arrancar con los capacitores")
    while eleccion == "si":
        if dic_capacitores:
            print("Su inventario actual es: \n")
            i = 1
            for volt, caps in dic_capacitores.items():
                for cap, cant in caps.items():
                    print(str(i) + "-", "Tiene", cant, "capacitores de", cap, "microfaradios (uF) y", volt, "V")
                    i += 1
        print("\nIngrese el valor en microfaradios (uF) de su capacitor")
        micro_far_ingre = float(input())
        if micro_far_ingre > 0:
            print("Ingrese el voltaje que soporta el mismo")
            volt_ingre = float(input())
            if volt_ingre > 0:
                print("Ingrese la cantidad que tiene del mismo")
                cant_ingre = int(input())
                if cant_ingre > 0:
                    if volt_ingre not in dic_capacitores:
                        dic_capacitores[volt_ingre] = {}
                    dic_capacitores[volt_ingre][micro_far_ingre] = dic_capacitores[volt_ingre].get(micro_far_ingre, 0) + cant_ingre
                    
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
    print("Ahora vamos a cargar tus diodos")
    while eleccion == "si":
        if dic_diodos:
            print("Su inventario actual es: \n")
            i = 1
            for amp, cant in dic_diodos.items():
                print(str(i) + "-", "Tiene", cant, "diodos de", amp, "A")
                i += 1
        print("\nIngrese la corriente en A que soporta su diodo")
        corriente_ingre = float(input())
        if corriente_ingre > 0:
            print("Ingrese la cantidad que tiene del mismo")
            cant_ingre = int(input())
            if cant_ingre > 0:
                dic_diodos[corriente_ingre] = dic_diodos.get(corriente_ingre, 0) + cant_ingre
                print("Desea agregar otro diodo (si), sino presione cualquier tecla")
                eleccion = input().lower()
            else:
                print("Ingresó mal la cantidad que tiene del mismo")
        else:
            print("Ingresó mal la corriente que soporta el diodo")
            
    limpiar_pantalla()
    eleccion = "si"
    print("Ahora vamos a cargar sus LM78XX")
    while eleccion == "si":
        if dic_lms:
            print("Su inventario actual es: \n")
            i = 1
            for tipo, cant in dic_lms.items():
                print(str(i) + "-", "Tiene", cant, "del tipo", tipo.upper())
                i += 1
        print("\nIngrese el tipo de LM78XX que tiene")
        txt_lm_ingre = input().lower()
        
        validos = ["lm7805", "lm7806", "lm7808", "lm7809", "lm7812", "lm7815", "lm7818", "lm7824", "lm317", "lm317t"]
        if txt_lm_ingre in validos:
            print("Ingrese la cantidad que tiene del mismo")
            cant_ingre = int(input())
            if cant_ingre > 0:
                dic_lms[txt_lm_ingre] = dic_lms.get(txt_lm_ingre, 0) + cant_ingre
                print("Desea agregar otro LM78XX (si), sino presione cualquier tecla")
                eleccion = input().lower()
            else:
                print("Ingresó mal la cantidad que tiene del mismo")
        else:
            print("Ingresó mal el tipo de LM78XX, debe ingresar el modelo completo, ej: LM7812")
            
    limpiar_pantalla()
    Mostrar_inventario_completo(dic_capacitores, dic_lms, dic_diodos)
    
    print("Desea hacer una modificación a su inventario (si), sino presione cualquier otra tecla")
    mod_inventario = input().lower()
    if mod_inventario == "si":
        Modificar_inventario(dic_capacitores, dic_lms, dic_diodos)

def Modificar_inventario(dic_capacitores, dic_lms, dic_diodos):
    seguir_modificando = "si"
    
    while seguir_modificando == "si":
        print("Qué apartado desea modificar, ingrese su índice")
        print("1- Capacitores")
        print("2- Diodos")
        print("3- LM78XX")
        indice = int(input())
        limpiar_pantalla()
        
        if indice == 1:
            Modificar_stock_capacitores(dic_capacitores)
        elif indice == 2:
            Modificar_stock_LM78xx(dic_lms)
        elif indice == 3:
            Modificar_stock_diodos(dic_diodos)
        else:
            print("Ingresó mal el índice")
            
        limpiar_pantalla()
        Mostrar_inventario_completo(dic_capacitores, dic_lms, dic_diodos)
        time.sleep(3)
        
        print("Desea modificar algún otro componente (si), sino presione cualquier otra tecla")
        seguir_modificando = input().lower()

def Mostrar_inventario_completo(dic_capacitores, dic_lms, dic_diodos):
    print("Su inventario completo es el siguiente\n")
    print("Su inventario de capacitores es: \n")
    i = 1
    for volt, caps in dic_capacitores.items():
        for cap, cant in caps.items():
            print(str(i) + "-", "Tiene", cant, "capacitores de", cap, "microfaradios (uF) y", volt, "V")
            i += 1
            
    print("\nSu inventario de LM78XX es: \n")
    i = 1
    for tipo, cant in dic_lms.items():
        print(str(i) + "-", "Tiene", cant, "del tipo", tipo.upper())
        i += 1
            
    print("\nSu inventario actual de diodos es: \n")
    i = 1
    for amp, cant in dic_diodos.items():
        print(str(i) + "-", "Tiene", cant, "diodos de", amp, "A")
        i += 1
    print("")

def Modificar_stock_capacitores(dic_capacitores):
    items = []
    print("Su inventario actual es: \n")
    i = 1
    for volt, caps in dic_capacitores.items():
        for cap, cant in caps.items():
            items.append((volt, cap))
            print(str(i) + "-", "Tiene", cant, "capacitores de", cap, "microfaradios (uF) y", volt, "V")
            i += 1
    mayor = len(items)
    
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
            
        if volt_ingre not in dic_capacitores:
            dic_capacitores[volt_ingre] = {}
        dic_capacitores[volt_ingre][micro_far_ingre] = dic_capacitores[volt_ingre].get(micro_far_ingre, 0) + cant_ingre
        print("Se agregó el nuevo capacitor con éxito\n")
            
    elif opcion == 2:
        print("Ingrese el índice del apartado que desea modificar")
        indice = int(input())
        if 0 < indice <= mayor:
            old_volt, old_cap = items[indice - 1]
            
            print("Ingrese el nuevo valor en microfaradios (uF) de su capacitor")
            micro_far_ingre = float(input())
            if micro_far_ingre > 0:
                print("Ingrese el nuevo voltaje que soporta el mismo")
                volt_ingre = float(input())
                if volt_ingre > 0:
                    print("Ingrese la nueva cantidad que tiene del mismo")
                    cant_ingre = int(input())
                    if cant_ingre > 0:
                        del dic_capacitores[old_volt][old_cap]
                        if not dic_capacitores[old_volt]: 
                            del dic_capacitores[old_volt]
                            
                        if volt_ingre not in dic_capacitores:
                            dic_capacitores[volt_ingre] = {}
                        dic_capacitores[volt_ingre][micro_far_ingre] = cant_ingre
                        
                        print("Se modificaron los datos de manera exitosa")
                        time.sleep(2)
                        limpiar_pantalla()
                    else:
                        print("Ingresó mal la cantidad del mismo")
                else:
                    print("Ingresó mal el voltaje que soporta")
            else:
                print("Ingresó mal la capacidad del capacitor")
        else:
            print("El índice ingresado no es válido")
                
    elif opcion == 3:
        print("Ingrese el índice del apartado que desea eliminar")
        indice = int(input())
        if 0 < indice <= mayor:
            old_volt, old_cap = items[indice - 1]
            del dic_capacitores[old_volt][old_cap]
            if not dic_capacitores[old_volt]: 
                del dic_capacitores[old_volt]
            print("El capacitor fue eliminado correctamente")
        else:
            print("El índice ingresado no es válido")

def Modificar_stock_LM78xx(dic_lms):
    items = []
    print("Su inventario actual es: \n")
    i = 1
    for tipo, cant in dic_lms.items():
        items.append(tipo)
        print(str(i) + "-", "Tiene", cant, "del tipo", tipo.upper())
        i += 1
    mayor = len(items)
    
    print("\nEscriba el índice de lo que desea realizar")
    print("1- Agregar nuevo ítem")
    print("2- Modificar ítem")
    print("3- Eliminar ítem")
    opcion = int(input())
    
    validos = ["lm7805", "lm7806", "lm7808", "lm7809", "lm7812", "lm7815", "lm7818", "lm7824", "lm317", "lm317t"]
    
    if opcion == 1:
        limpiar_pantalla()
        print("Ingrese el tipo de LM78XX que tiene")
        txt_lm_ingre = input().lower()
        if txt_lm_ingre in validos:
            print("Ingrese la cantidad que tiene del mismo")
            cant_ingre = int(input())
            if cant_ingre > 0:
                dic_lms[txt_lm_ingre] = dic_lms.get(txt_lm_ingre, 0) + cant_ingre
                print("El LM78XX se agregó de manera exitosa\n")
            else:
                print("Ingresó mal la cantidad que tiene del mismo")
        else:
            print("Ingresó mal el tipo de LM78XX, debe ingresar el modelo completo, ej: LM7812")
            
    elif opcion == 2:
        print("Ingrese el índice del apartado que desea modificar")
        indice = int(input())
        if 0 < indice <= mayor:
            old_tipo = items[indice - 1]
            print("Ingrese el nuevo tipo de LM78XX que tiene")
            txt_lm_ingre = input().lower()
            if txt_lm_ingre in validos:
                print("Ingrese la nueva cantidad que tiene del mismo")
                cant_ingre = int(input())
                if cant_ingre > 0:
                    del dic_lms[old_tipo]
                    dic_lms[txt_lm_ingre] = cant_ingre
                    print("Su inventario fue modificado de manera exitosa")
                    time.sleep(2)
                    limpiar_pantalla()
                else:
                    print("Ingresó mal la cantidad que tiene del mismo")
            else:
                print("Ingresó mal el tipo de LM78XX")
        else:
            print("Ingresó mal el índice")
            
    elif opcion == 3:
        print("Ingrese el índice del apartado que desea eliminar")
        indice = int(input())
        if 0 < indice <= mayor:
            old_tipo = items[indice - 1]
            del dic_lms[old_tipo]
            print("El LM78XX fue eliminado correctamente")
        else:
            print("El índice ingresado no es válido")

def Modificar_stock_diodos(dic_diodos):
    items = []
    print("Su inventario actual es: \n")
    i = 1
    for amp, cant in dic_diodos.items():
        items.append(amp)
        print(str(i) + "-", "Tiene", cant, "diodos de", amp, "A")
        i += 1
    mayor = len(items)
    
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
                dic_diodos[corriente_ingre] = dic_diodos.get(corriente_ingre, 0) + cant_ingre
                print("Se agregó el diodo de manera exitosa\n")
            else:
                print("Ingresó mal la cantidad que tiene del mismo")
        else:
            print("Ingresó mal la corriente que soporta el diodo")
            
    elif opcion == 2:
        print("Ingrese el índice del apartado que desea modificar")
        indice = int(input())
        if 0 < indice <= mayor:
            old_amp = items[indice - 1]
            print("Ingrese la nueva corriente en A que soporta su diodo")
            corriente_ingre = float(input())
            if corriente_ingre > 0:
                print("Ingrese la nueva cantidad que tiene del mismo")
                cant_ingre = int(input())
                if cant_ingre > 0:
                    del dic_diodos[old_amp]
                    dic_diodos[corriente_ingre] = cant_ingre
                    print("Se modificaron los datos de manera exitosa")
                    time.sleep(2)
                    limpiar_pantalla()
                else:
                    print("Ingresó mal la cantidad que tiene del mismo")
            else:
                print("Ingresó mal la corriente que soporta el diodo")
        else:
            print("El índice ingresado no es válido")
            
    elif opcion == 3:
        print("Ingrese el índice del apartado que desea eliminar")
        indice = int(input())
        if 0 < indice <= mayor:
            old_amp = items[indice - 1]
            del dic_diodos[old_amp]
            print("El diodo fue eliminado correctamente")
        else:
            print("El índice ingresado no es válido")

if __name__ == '__main__':
    op = "si"
    
    dic_capacitores = {}
    dic_lms = {}
    dic_diodos = {}

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
                if not dic_capacitores and not dic_lms and not dic_diodos:
                    Cargar_Todo(dic_capacitores, dic_lms, dic_diodos)
                else:
                    print("Desea modificar su inventario (si), sino presione cualquier tecla")
                    mod_inventario = input().lower()
                    if mod_inventario == "si":
                        limpiar_pantalla()
                        Modificar_inventario(dic_capacitores, dic_lms, dic_diodos)
                        
                retABM = FibalABM(I, V, dic_capacitores, dic_lms, dic_diodos)
                if retABM:
                    print("Sí vas a poder armar la fuente con lo que tenés")
                else:
                    print("No vas a poder armar una fuente con lo que tenés, te faltan componentes")
                elec = 0
                
            else:
                print("La opción ingresada es inválida")
                
        print("Desea volver a ejecutar el programa (si), si no presione cualquier otra tecla")
        op = input().lower()
        limpiar_pantalla()