import time
import pandas as pd
from selenium import webdriver
from bs4 import BeautifulSoup
from datetime import date

# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

today = date.today()
d1 = today.strftime("%d%m%Y")

# si es prueba colocar "_prueba", de lo contrario dejar en blanco
sufijo = '_prueba'
# sufijo = ''

# ----------------- MODIFICABLE
#
# ruta de entrada
PATH_INPUT = 'C:/Users/servpres_16/Documents/aron/Data/'
# ruta de salida
PATH_OUTPUT = 'C:/Users/servpres_16/Documents/aron/Data/'
# nombre del archivo output
FILE_OUTPUT1 = 'info_f8_{}{}.xlsx'.format(d1,sufijo)
# FILE_OUTPUT2 = 'infoF12BSSIPMICAT_{}{}.xlsx'.format(d1,sufijo)
# nombre del archivo con CUIs
FILE_CUI = 'cuis_f8{}.xlsx'.format(sufijo)
# tiempo que deja cargar cada página
timesleep=1.5
#
# ----------------- MODIFICABLE

options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(chrome_options=options)

BDbrecha = pd.DataFrame()

# Ncui = "2313872"

## INICIA BUCLE

file_xlsx = PATH_INPUT + FILE_CUI # ruta y nombre de listado id_entidad
df_xlsx = pd.read_excel(file_xlsx) # lee el excel con el listado id_entidad

cuis = df_xlsx['CUIS'].tolist() # convierte la columna 'id_entidad' en una lista

for Ncui in cuis:

    web1 = "https://ofi5.mef.gob.pe/invierte/ejecucion/verFichaEjecucion/"
    web = web1+str(Ncui)
    print(Ncui)
    
    driver.get(web)
    time.sleep(timesleep)
    pageHTML = driver.page_source
    soup = BeautifulSoup(pageHTML, 'lxml')
    
    try:
        table = soup.findAll('table', attrs={"class" : "table table-bordered table-hover table-striped"})[0]
        df = pd.read_html(str(table))[0]
        
        df['cui'] = Ncui
        
        first_column = df.pop('cui')
        
        df.insert(0, 'cui', first_column)
    except:
        data_blanco = [[Ncui,'','','','','']]
        df = pd.DataFrame(data_blanco)
        
    df.columns = [''] * len(df.columns)
    BDbrecha = pd.concat([BDbrecha, df], axis=0, sort=False)
    del df

del cuis
driver.close()

BDbrecha.columns = ['cui','servicio','indicador','unidad','espacio','cierre_brecha']

BDbrecha.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT1),sheet_name='BD',index=False)

# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
print('Segundos transcurridos:',nseconds) # imprime segundos de demora