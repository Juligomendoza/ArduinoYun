#!//usr/bin/python
import subprocess
## Jaime Rodrigo
## Panama Hitek www.panamahitek.com
## checkConnectionV1
## Revisa el estado actual de la conexión a Internet. Si luego de la cantidad de reintentos sigue fallando, 
##entonces deshabilita la primera red (que se asume es el modo de estacion) y deja habilitado la segunda (modo AP).
###################################################################################################################

# Variables globales
filename = "/usr/python-scripts/data.txt" #No modificar. Archivo a guardar los estados
site = "www.google.com" #Sitio utilizado para revisar la conexion a Internet
reset_network = 2   #Cantidad de veces que va a intentar reconectarse.

##Funciones
def readFile(filename):
    fo = open(filename, "a+")
    str = fo.read(2);
    fo.close()
    if str == "" :
        returnStr = -2
    else :
        returnStr = int(str)
    return returnStr
def writeFile(filename,string):
    fo = open(filename, "w+")
    fo.write(str(string));
    fo.close()
def ping(website):
    #Intenta hacer ping al sitio en el argumento.
    try:
        output = subprocess.check_output("ping -c 1 "+website, shell=True)
    except Exception, e:
        return False
    return True
def runBashcmd(comando):
    try:
        output = subprocess.call(comando, shell=True)
    except Exception, e:
        return False
    return True

##Programa
currentStatus = readFile(filename)
if currentStatus == -2 :
    runBashcmd('uci set wireless.@wifi-iface[0].disabled=0') #Deshabilitar la primera interfaz creada
    runBashcmd('uci set wireless.@wifi-device[0].disabled=0') #
    runBashcmd('uci commit wireless;wifi')
    writeFile(filename,0)
elif ping(site) :
    print "Conexion realizada correctamente."
    writeFile(filename,0)
else :
    if currentStatus != -1 :
        if currentStatus+1 == reset_network :
            #resetear red
            runBashcmd('wifi down; sleep 5; wifi')
            writeFile(filename,currentStatus+1)
        elif currentStatus+1 > reset_network :
            runBashcmd('uci set wireless.@wifi-iface[0].disabled=1') #Deshabilitar la primera interfaz creada
            runBashcmd('uci set wireless.@wifi-device[0].disabled=0') #
            runBashcmd('uci commit wireless;wifi')
            writeFile(filename,-1)
        else :
            writeFile(filename,currentStatus+1)
