import time
import pandas as pd
import numpy as np
from selenium import webdriver
from bs4 import BeautifulSoup
from datetime import date

# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

today = date.today()
d1 = today.strftime("%d%m%Y")

# si es prueba colocar "_prueba", de lo contrario dejar en blanco
sufijo = ''
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

BBDDP1 = pd.DataFrame()
BBDDP2 = pd.DataFrame()

Ncui = "2313872"

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
        div = soup.findAll('div', attrs={"class" : "table-responsive"})[0]
        table = div.find_all('table')[0]
        df = pd.read_html(str(table))[0]
        
        df['cui'] = Ncui
        
        # shift column 'C' to first position
        first_column = df.pop('cui')
          
        # insert column using insert(position,column_name,first_column) function
        df.insert(0, 'cui', first_column)
        df.columns = [''] * len(df.columns)
    except:
        df = pd.DataFrame()
    
    BBDDP1 = pd.concat([BBDDP1, df], axis=0, sort=False)
    del df

del cuis
driver.close()

BBDDP1.columns = ['cui','v1','v2','factor','v3','v4','v5','v6','fecini','fecfin','v7','v8','v9']
BBDDP1 = BBDDP1[['cui','factor','fecini','fecfin']]
BBDDP1 = BBDDP1[BBDDP1.factor == 'INFRAESTRUCTURA']
BBDDP1 = BBDDP1[BBDDP1.fecini.str[2]=='/']

cui_encontrados = BBDDP1[['cui']]
cui_encontrados = cui_encontrados.drop_duplicates()
cui_encontrados.columns = ['CUIS']

valida_cui = pd.merge(df_xlsx, cui_encontrados, on='CUIS', how='outer', indicator=True)
cui_faltantes = valida_cui[valida_cui._merge == 'left_only']
cui_faltantes = cui_faltantes[['CUIS']]

cuis = cui_faltantes['CUIS'].tolist() # convierte la columna 'id_entidad' en una lista

for Ncui in cuis:

    web1 = "https://ofi5.mef.gob.pe/invierte/ejecucion/verFichaEjecucion/"
    web = web1+str(Ncui)
    print(Ncui)
    
    driver.get(web)
    time.sleep(timesleep)
    pageHTML = driver.page_source
    soup = BeautifulSoup(pageHTML, 'lxml')
    
    try:
        table = soup.findAll('table', attrs={"class" : "table table-bordered table-hover table-striped"})[2]
        df = pd.read_html(str(table))[0]
        
        df['cui'] = Ncui
        
        # shift column 'C' to first position
        first_column = df.pop('cui')
          
        # insert column using insert(position,column_name,first_column) function
        df.insert(0, 'cui', first_column)
        df.columns = [''] * len(df.columns)
    except:
        df = pd.DataFrame()
    
    BBDDP2 = pd.concat([BBDDP2, df], axis=0, sort=False)
    del df

del cuis
driver.close()

BBDDP2.columns = ['cui','v1','v2','factor','v3','v4','fecini','fecfin','v5','v6']
BBDDP2 = BBDDP2[['cui','factor','fecini','fecfin']]
BBDDP2 = BBDDP2[BBDDP2.factor == 'INFRAESTRUCTURA']
BBDDP2 = BBDDP2[BBDDP2.fecini.str[2]=='/']

BBDD = pd.concat([BBDDP1,BBDDP2], axis=0, sort=False)

BBDD.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT1),sheet_name='BD',index=False)

# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
print('Segundos transcurridos:',nseconds) # imprime segundos de demora