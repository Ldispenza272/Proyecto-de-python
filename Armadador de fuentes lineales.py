Cant_cap = []
Cant_Lm = []
Cant_dod = []
Corr_dod = []
Volt_Cap = []
Cap_Cap = []
Tipo_LM = []
op = "si"
print("=========================================================")
print("   Sistema de diseño y presupuesto de fuentes lineales   ")
print("=========================================================")
print("   Gestión de inventario y cálculo de componentes v1.0   ")
print("---------------------------------------------------------")
j = int(input("Ingresar la cantiadad de componentes a cargar (se recomienda dimensionar de mas): "))
for i in range(0, j, 1):
    Cant_cap.append(0)
    Cant_Lm.append(0)
    Cant_dod.append(0)
    Corr_dod.append(0)
    Volt_Cap.append(0)
    Cap_Cap.append(0)
    Tipo_LM.append(0)
while op == "si":
    
    op = input("¿Desea ingresar más componentes? (si/no): ")
