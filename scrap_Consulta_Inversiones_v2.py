import time
import pandas as pd
import numpy as np
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
from datetime import date
    
# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

today = date.today()
d1 = today.strftime("%d_%m_%Y")

# si es prueba colocar "_prueba", de lo contrario dejar en blanco
sufijo = '_prueba_ci'
# sufijo = ''

# ----------------- MODIFICABLE
#
# ruta de entrada
PATH_INPUT = 'C:/Users/a/Documents/aron/Data/'
# ruta de salida
PATH_OUTPUT = 'C:/Users/a/Documents/aron/Reportes/'
# nombre del archivo output
FILE_OUTPUT1 = 'info_consulta_inversiones_v2_{}.xlsx'.format(d1)
# nombre del archivo con CUIs
FILE_CUI = 'cuis_2023{}.xlsx'.format(sufijo)
# tiempo que deja cargar cada página
timesleep=0.5
#
# ----------------- MODIFICABLE

driver = webdriver.Chrome()
BBDDca = pd.DataFrame()
web = "https://apps5.mineco.gob.pe/bingos/seguimiento_pi/Navegador/default.aspx?y=2023&ap=ActProy"
driver.get(web)
driver.switch_to.frame('frame0')
driver.find_element("id", "ctl00_CPH1_BtnProdProy").click()
time.sleep(timesleep)

file_xlsx = PATH_INPUT + FILE_CUI # ruta y nombre de listado id_entidad
df_xlsx = pd.read_excel(file_xlsx) # lee el excel con el listado id_entidad
cuis = df_xlsx['CUIS'].tolist() # convierte la columna 'id_entidad' en una lista

for Ncui in cuis:
    
    print(Ncui)
    driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Ncui)
    time.sleep(timesleep)
    driver.find_element("id", "ctl00_CPH1_BtnSearchByCode").click() # <------------------- CLICK
    time.sleep(timesleep)
    time.sleep(timesleep)
    
    _infopptotot = np.array([[0]])
    __infopptotot = pd.DataFrame(_infopptotot)
    del _infopptotot
    
    try:
        pptotot = driver.find_element("name", "grp1").get_attribute("value")
    except:
        pptotot = '{}/ / / / / / / / / '.format(Ncui)
        #driver.find_element("id", "ctl00_CPH1_Image1").click() # <------------------- CLICK
        #time.sleep(timesleep)
        #driver.switch_to.frame('frame0')
        #driver.find_element("id", "ctl00_CPH1_BtnProdProy").click() # <------------------- CLICK
        pass
    
    __infopptotot['pptotot'] = pptotot
    del pptotot
    tabpptotot = __infopptotot['pptotot'].str.split("/", expand = True)
    del __infopptotot
    BBDDca = pd.concat([BBDDca, tabpptotot], axis=0, sort=False)
    
    time.sleep(timesleep)
    try:
        driver.find_element("id", "ctl00_CPH1_TxtSearch").click() # <------------------- CLICK
        driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Keys.END)
        driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Keys.BACKSPACE)
        driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Keys.BACKSPACE)
        driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Keys.BACKSPACE)
        driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Keys.BACKSPACE)
        driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Keys.BACKSPACE)
        driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Keys.BACKSPACE)
        driver.find_element("id", "ctl00_CPH1_TxtSearch").send_keys(Keys.BACKSPACE)
    except:
        driver.find_element("id", "ctl00_CPH1_Image1").click() # <------------------- CLICK
        time.sleep(timesleep)
        driver.switch_to.frame('frame0')
        driver.find_element("id", "ctl00_CPH1_BtnProdProy").click() # <------------------- CLICK
        pass

BBDDca.columns = ['cui','ca_costo','ca_devacum21','ca_dev22','ca_pia23','ca_pim23','ca_dev23','ca_avance23','ca_devacumtot','ca_avancetot']
BBDDca = BBDDca.drop(['ca_avance23','ca_avancetot'], axis=1)

BBDDca.loc[BBDDca['ca_costo']==' ','ca_costo'] = ''
BBDDca['ca_costo'] = pd.to_numeric(BBDDca['ca_costo'])

BBDDca.loc[BBDDca['ca_devacum21']==' ','ca_devacum21'] = ''
BBDDca['ca_devacum21'] = pd.to_numeric(BBDDca['ca_devacum21'])

BBDDca.loc[BBDDca['ca_dev22']==' ','ca_dev22'] = ''
BBDDca['ca_dev22'] = pd.to_numeric(BBDDca['ca_dev22'])

BBDDca.loc[BBDDca['ca_pia23']==' ','ca_pia23'] = ''
BBDDca['ca_pia23'] = pd.to_numeric(BBDDca['ca_pia23'])

BBDDca.loc[BBDDca['ca_pim23']==' ','ca_pim23'] = ''
BBDDca['ca_pim23'] = pd.to_numeric(BBDDca['ca_pim23'])

BBDDca.loc[BBDDca['ca_dev23']==' ','ca_dev23'] = ''
BBDDca['ca_dev23'] = pd.to_numeric(BBDDca['ca_dev23'])

BBDDca.loc[BBDDca['ca_devacumtot']==' ','ca_devacumtot'] = ''
BBDDca['ca_devacumtot'] = pd.to_numeric(BBDDca['ca_devacumtot'])

BBDDca = BBDDca.fillna(0)

BBDDca['ca_devacum22'] = BBDDca['ca_devacum21'] + BBDDca['ca_dev22']

BBDDca = BBDDca[['cui','ca_costo','ca_devacum21','ca_dev22','ca_devacum22','ca_pia23','ca_pim23','ca_dev23','ca_devacumtot']]

BBDDca['cui'] = pd.to_numeric(BBDDca['cui'])

BBDDca = BBDDca[BBDDca.ca_costo != ' ']
BBDDca = BBDDca[BBDDca.ca_costo != '']
BBDDca = BBDDca[BBDDca.cui != 2000028]

driver.close()
# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
BBDDca.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT1),sheet_name='BD',index=False)