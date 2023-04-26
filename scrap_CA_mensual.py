import time
import pandas as pd
import numpy as np
from selenium import webdriver
from bs4 import BeautifulSoup
from selenium.webdriver.common.keys import Keys
from datetime import date

# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

today = date.today()
d1 = today.strftime("%d_%m_%Y")

# ----------------- MODIFICABLE
#
# ruta de entrada
PATH_INPUT = 'C:/Users/a/Documents/aron/Data/'
# ruta de salida
PATH_OUTPUT = 'C:/Users/a/Documents/aron/Reportes/'
# nombre del archivo output
FILE_OUTPUT = 'amigable_x_mes_proyectos_PVD_{}.xlsx'.format(d1)
# tiempo que deja cargar cada página
timesleep=0.5
#
# ----------------- MODIFICABLE

driver = webdriver.Chrome()

lista_proyectos = []
BBDDcam = pd.DataFrame()

web = "https://apps5.mineco.gob.pe/transparencia/Navegador/default.aspx?y=2023&ap=Proyecto"
driver.get(web)
driver.switch_to.frame('frame0')
driver.find_element("id", "ctl00_CPH1_BtnTipoGobierno").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_RptData_ctl01_TD0").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_BtnSector").click()
time.sleep(timesleep)
driver.find_element("xpath", "//*[contains(text(),'36: TRANSPORTES Y COMUNICACIONES')]").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_BtnPliego").click()
time.sleep(timesleep)
driver.find_element("xpath", "//*[contains(text(),'036: MINISTERIO DE TRANSPORTES Y COMUNICACIONES')]").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_BtnEjecutora").click()
time.sleep(timesleep)
driver.find_element("xpath", "//*[contains(text(),'010-1250')]").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_BtnFuenteAgregada").click()
time.sleep(timesleep)

# llegamos a la lista de fuentes

a=1
boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(a)
driver.find_element("id", boton).click()
while True:
    a += 1
    boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(a)
    try:
        driver.find_element("id", boton).click()
    except:
        ffs = a-1 # ffs es la cantidad de fuentes
        break

# vamor a clickear cada fuente

b=1
while (b<=ffs):
    boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(b)
    driver.find_element("id", boton).click()
    time.sleep(timesleep)
    ff = driver.find_element("id",boton).find_element("name", "grp1").get_attribute("value").split('/', 1)[0]
    driver.find_element("id", "ctl00_CPH1_BtnMes").click() # entramos a mes
    
    c=1
    boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(c)
    driver.find_element("id", boton).click()
    while True:
        c += 1
        boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(c)
        try:
            driver.find_element("id", boton).click()
        except:
            meses = c-1
            break # meses es la cantidad de meses
    
    # vamor a clickear cada mes
    
    d=1
    while (d<=meses):
        boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(d)
        driver.find_element("id", boton).click()
        time.sleep(timesleep)
        mes = driver.find_element("id",boton).find_element("name", "grp1").get_attribute("value").split('/', 1)[0]
        driver.find_element("id", "ctl00_CPH1_BtnProdProy").click() # entramos a la lista proyecto
        
        e=0
        while True:
            e += 1
            try:
                los_grp1 = driver.find_element("id", 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(e))  # cada fila
                ppto = los_grp1.find_element("name", "grp1").get_attribute("value")
                ppto = '{}/{}/'.format(ff,mes)+ppto
                lista_proyectos.append(ppto)
            except:
                break
        driver.find_element("id", "ctl00_CPH1_RptHistory_ctl07_TD0").click()
        d += 1
    driver.find_element("id", "ctl00_CPH1_RptHistory_ctl06_TD0").click()
    b += 1

serie_proyectos = pd.Series(lista_proyectos)
del lista_proyectos

BBDDcam['tmp'] = serie_proyectos
del serie_proyectos

BBDDcam = BBDDcam['tmp'].str.split("/", expand = True)

BBDDcam.columns = ['ff','mes','cui','pia','pim','comp_a','comp_m','dev','gir','cert']
BBDDcam = BBDDcam.drop(['pia','pim'], axis=1)

BBDDcam = BBDDcam[['cui','ff','mes','cert','comp_a','comp_m','dev','gir']]

BBDDcam['cert'] = pd.to_numeric(BBDDcam['cert'])
BBDDcam['comp_a'] = pd.to_numeric(BBDDcam['comp_a'])
BBDDcam['comp_m'] = pd.to_numeric(BBDDcam['comp_m'])
BBDDcam['dev'] = pd.to_numeric(BBDDcam['dev'])
BBDDcam['gir'] = pd.to_numeric(BBDDcam['gir'])

BBDDcam = BBDDcam.pivot_table(index=['cui', 'ff'], columns='mes', values=['cert','comp_a','comp_m','dev','gir'])
BBDDcam.columns = [f'{col[0]}_{col[1]}' for col in BBDDcam.columns]

# pia y pim de proyectos

lista_proyectos = []
BBDDpim = pd.DataFrame()

web = "https://apps5.mineco.gob.pe/transparencia/Navegador/default.aspx?y=2023&ap=Proyecto"
driver.get(web)
driver.switch_to.frame('frame0')
driver.find_element("id", "ctl00_CPH1_BtnTipoGobierno").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_RptData_ctl01_TD0").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_BtnSector").click()
time.sleep(timesleep)
driver.find_element("xpath", "//*[contains(text(),'36: TRANSPORTES Y COMUNICACIONES')]").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_BtnPliego").click()
time.sleep(timesleep)
driver.find_element("xpath", "//*[contains(text(),'036: MINISTERIO DE TRANSPORTES Y COMUNICACIONES')]").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_BtnEjecutora").click()
time.sleep(timesleep)
driver.find_element("xpath", "//*[contains(text(),'010-1250')]").click()
time.sleep(timesleep)
driver.find_element("id", "ctl00_CPH1_BtnFuenteAgregada").click()
time.sleep(timesleep)

# llegamos a la lista de fuentes

a=1
boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(a)
driver.find_element("id", boton).click()
while True:
    a += 1
    boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(a)
    try:
        driver.find_element("id", boton).click()
    except:
        ffs = a-1 # ffs es la cantidad de fuentes
        break

b=1
while (b<=ffs):
    boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(b)
    driver.find_element("id", boton).click()
    time.sleep(timesleep)
    ff = driver.find_element("id",boton).find_element("name", "grp1").get_attribute("value").split('/', 1)[0]
    driver.find_element("id", "ctl00_CPH1_BtnProdProy").click() # entramos a la lista proyecto
    e=0
    while True:
        e += 1
        try:
            los_grp1 = driver.find_element("id", 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(e))  # cada fila
            ppto = los_grp1.find_element("name", "grp1").get_attribute("value")
            ppto = '{}/'.format(ff)+ppto
            lista_proyectos.append(ppto)
        except:
            break
    driver.find_element("id", "ctl00_CPH1_RptHistory_ctl06_TD0").click()
    b += 1

serie_proyectos = pd.Series(lista_proyectos)
del lista_proyectos

BBDDpim['tmp'] = serie_proyectos
del serie_proyectos

BBDDpim = BBDDpim['tmp'].str.split("/", expand = True)

BBDDpim.columns = ['ff','cui','pia','pim','comp_a','comp_m','dev','gir','cert']
BBDDpim = BBDDpim.drop(['comp_a','comp_m','dev','gir','cert'], axis=1)
BBDDpim['pia'] = pd.to_numeric(BBDDpim['pia'])
BBDDpim['pim'] = pd.to_numeric(BBDDpim['pim'])

BBDD = pd.merge(BBDDpim, BBDDcam, on=['cui', 'ff'], how='outer')

BBDD = BBDD.fillna(0)

del BBDDcam
del BBDDpim

BBDD.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT),sheet_name='BD',index=False)

driver.close()

# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
print('Segundos transcurridos:',nseconds) # imprime segundos de demora