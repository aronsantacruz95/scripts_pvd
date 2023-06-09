import time
import pandas as pd
import numpy as np
from selenium import webdriver
from bs4 import BeautifulSoup as bs
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
FILE_OUTPUT1 = 'info_ssi_cui_contrato_{}{}.xlsx'.format(d1,sufijo)
# FILE_OUTPUT2 = 'infoF12BSSIPMICAT_{}{}.xlsx'.format(d1,sufijo)
# nombre del archivo con CUIs
FILE_CUI = 'cuis_contrato{}.xlsx'.format(sufijo)
# tiempo que deja cargar cada página
timesleep=1.5
#
# ----------------- MODIFICABLE

options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(chrome_options=options)
BBDD = pd.DataFrame()

Ncui = "2001621"

## INICIA BUCLE

file_xlsx = PATH_INPUT + FILE_CUI # ruta y nombre de listado id_entidad
df_xlsx = pd.read_excel(file_xlsx) # lee el excel con el listado id_entidad
cuis = df_xlsx['CUIS'].tolist() # convierte la columna 'id_entidad' en una lista

for Ncui in cuis:

    # SSI
    # ====
    
    _infoSSI = np.array([[0]])
    infoSSI = pd.DataFrame(_infoSSI)
    
    web1 = "https://ofi5.mef.gob.pe/ssi/Ssi/Index?codigo="
    web2 = "&tipo=2"
    web = web1+str(Ncui)+web2
    
    driver.get(web)
    time.sleep(timesleep)
    
    driver.find_element("id", "btn_seace").click()
    time.sleep(timesleep)
    
    df1 = pd.DataFrame()
    try:
        table = driver.find_element("id", "tb_seaceobra")
        table_html = table.get_attribute('innerHTML')
        soup = bs(table_html, 'lxml')
        row_soup = soup.findAll('tr', attrs={"class": "fil_hisfinan"})
        rows = []
        for row in row_soup:
          row_data = []
          for cell in row.findAll('td'):
              row_data.append(cell.text)
          rows.append(row_data)
        df1 = pd.DataFrame(rows)
        df1.columns = ['n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total', 'link_contrato']
        df1 = df1[['n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total']]
    except:
        pass
    if len(df1)==0:
        df1 = pd.DataFrame([['OBRA']], columns=['seace'])
    else:
        df1["seace"] = "OBRA"
    
    df2 = pd.DataFrame()
    try:
        table = driver.find_element("id", "tb_seaceserv")
        table_html = table.get_attribute('innerHTML')
        soup = bs(table_html, 'lxml')
        row_soup = soup.findAll('tr', attrs={"class": "fil_hisfinan"})
        rows = []
        for row in row_soup:
          row_data = []
          for cell in row.findAll('td'):
              row_data.append(cell.text)
          rows.append(row_data)
        df2 = pd.DataFrame(rows)
        df2.columns = ['n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total', 'link_contrato']
        df2 = df2[['n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total']]
    except:
        pass
    if len(df2)==0:
        df2 = pd.DataFrame([['SERVICIO']], columns=['seace'])
    else:
        df2["seace"] = "SERVICIO"
    
    df3 = pd.DataFrame()
    try:
        table = driver.find_element("id", "tb_seacebien")
        table_html = table.get_attribute('innerHTML')
        soup = bs(table_html, 'lxml')
        row_soup = soup.findAll('tr', attrs={"class": "fil_hisfinan"})
        rows = []
        for row in row_soup:
          row_data = []
          for cell in row.findAll('td'):
              row_data.append(cell.text)
          rows.append(row_data)
        df3 = pd.DataFrame(rows)
        df3.columns = ['n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total', 'link_contrato']
        df3 = df3[['n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total']]
    except:
        pass
    if len(df3)==0:
        df3 = pd.DataFrame([['BIEN']], columns=['seace'])
    else:
        df3["seace"] = "BIEN"
    
    df4 = pd.DataFrame()
    try:
        table = driver.find_element("id", "tb_seaceconsul")
        table_html = table.get_attribute('innerHTML')
        soup = bs(table_html, 'lxml')
        row_soup = soup.findAll('tr', attrs={"class": "fil_hisfinan"})
        rows = []
        for row in row_soup:
          row_data = []
          for cell in row.findAll('td'):
              row_data.append(cell.text)
          rows.append(row_data)
        df4 = pd.DataFrame(rows)
        df4.columns = ['n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total', 'link_contrato']
        df4 = df4[['n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total']]
    except:
        pass
    if len(df4)==0:
        df4 = pd.DataFrame([['CONSULTORÍA']], columns=['seace'])
    else:
        df4["seace"] = "CONSULTORÍA"
    
    dfT = pd.concat([df1, df2, df3, df4], axis=0, sort=False)
    dfT["cui"] = Ncui
    del df1
    del df2
    del df3
    del df4
    
    BBDD = pd.concat([BBDD, dfT], axis=0, sort=False)
    del dfT


BBDD = BBDD[['cui', 'seace', 'n_item', 'desc_item', 'contratista', 'n_contrato', 'fecha_susc', 'monto_contrato', 'monto_contrato_item_total']]

BBDD.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT1),sheet_name='BD',index=False)
driver.close()

# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
print('Segundos transcurridos:',nseconds) # imprime segundos de demora