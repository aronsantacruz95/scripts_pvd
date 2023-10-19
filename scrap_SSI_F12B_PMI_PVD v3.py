import time
import pandas as pd
import numpy as np
from selenium import webdriver
from bs4 import BeautifulSoup
from datetime import datetime

# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# OJO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# CAMBIA DEVENGADO DEL MES <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

current_datetime = datetime.now().strftime("%d%m%Y_%H%M")
print("Current date & time : ", current_datetime)

# ----------------- MODIFICABLE
#
# sufijo
sufijo = '_modiDANI1210rooc'
# ruta de entrada
PATH_INPUT = 'C:/Users/servpres_16/Documents/aron/Data/'
# ruta de salida
PATH_OUTPUT = 'C:/Users/servpres_16/Documents/aron/Data/'
# nombre del archivo output
FILE_OUTPUT = 'infoF12BSSIPMI_{}{}.xlsx'.format(current_datetime,sufijo)
# nombre del archivo con CUIs
FILE_CUI = 'cuis_2023{}.xlsx'.format(sufijo)
# tiempo que deja cargar cada página
timesleep=3
#
# ----------------- MODIFICABLE

options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(chrome_options=options)
BBDD = pd.DataFrame()
BBDDca = pd.DataFrame()

#Ncui = "2154492"

## INICIA BUCLE

file_xlsx = PATH_INPUT + FILE_CUI # ruta y nombre de listado id_entidad
df_xlsx = pd.read_excel(file_xlsx) # lee el excel con el listado id_entidad
cuis = df_xlsx['CUIS'].tolist() # convierte la columna 'id_entidad' en una lista

for Ncui in cuis:

    # F12B
    # ====
    
    web1 = "https://ofi5.mef.gob.pe/inviertews/Repseguim/ResumF12B?codigo="
    web = web1+str(Ncui)
    print(Ncui)
    
    driver.get(web)
    time.sleep(timesleep)
    pageHTML = driver.page_source
    soup = BeautifulSoup(pageHTML, 'lxml')
    
    fum = ''
    fum = soup.find(id="td_cab08").get_text()
    fum = fum[25:35:1]
    i = 0
    if (fum=='a Últ. Mod'):
        while (fum=='a Últ. Mod') and (i < 9):
            time.sleep(timesleep)
            pageHTML = driver.page_source
            soup = BeautifulSoup(pageHTML, 'lxml')
            fum = ''
            fum = soup.find(id="td_cab08").get_text()
            fum = fum[25:35:1]
            i += 1
    if i==9:
        _infoF12B = np.array([[0]])
        infoF12B = pd.DataFrame(_infoF12B)
        infoF12B['fum'] = ''
        infoF12B = infoF12B.iloc[: , 1:]
        infoF12B.index = [Ncui]
        infoF12B['opmi'] = ''
        infoF12B['uei'] = ''
        infoF12B['tipoinv'] = ''
        infoF12B['modalidadejec'] = ''
        infoF12B['registrocierre'] = ''
        infoF12B['pmi01'] = ''
        infoF12B['pmi02'] = ''
        infoF12B['pmi03'] = ''
        infoF12B['situacion'] = ''
        infoF12B['DEV_ACUM'] = ''
        infoF12B['PRIMER_DEV'] = ''
        infoF12B['ULT_DEV'] = ''
        infoF12B['PIM_ACT'] = ''
        infoF12B['DEV_ACT'] = ''
        infoF12B['PF_ACT'] = ''
        infoF12B['SALDO'] = ''
        infoF12B['PROG_ACT_ENE'] = ''
        infoF12B['PROG_ACT_FEB'] = ''
        infoF12B['PROG_ACT_MAR'] = ''
        infoF12B['PROG_ACT_ABR'] = ''
        infoF12B['PROG_ACT_MAY'] = ''
        infoF12B['PROG_ACT_JUN'] = ''
        infoF12B['PROG_ACT_JUL'] = ''
        infoF12B['PROG_ACT_AGO'] = ''
        infoF12B['PROG_ACT_SET'] = ''
        infoF12B['PROG_ACT_OCT'] = ''
        infoF12B['PROG_ACT_NOV'] = ''
        infoF12B['PROG_ACT_DIC'] = ''
        infoF12B['PROG_ACT_TOT'] = ''
        infoF12B['DEV_ENE'] = ''
        infoF12B['DEV_FEB'] = ''
        infoF12B['DEV_MAR'] = ''
        infoF12B['DEV_ABR'] = ''
        infoF12B['DEV_MAY'] = ''
        infoF12B['DEV_JUN'] = ''
        infoF12B['DEV_JUL'] = ''
        infoF12B['DEV_AGO'] = ''
        infoF12B['DEV_SET'] = ''
        infoF12B['DEV_OCT'] = ''
        infoF12B['DEV_NOV'] = ''
        infoF12B['DEV_DIC'] = ''
        infoF12B['DEV_TOT'] = ''
    else:
        opmi = ''
        opmi = soup.find(id="td_opmi").get_text()
        
        uei = ''
        uei = soup.find(id="td_cab03").get_text()
        
        tipoinv = ''
        tipoinv = soup.find(id="td_cab04").get_text()
        
        modalidadejec = ''
        modalidadejec = soup.find(id="td_cab05").get_text()
        
        registrocierre = ''
        registrocierre = soup.find(id="td_f9").get_text()
        
        pmi01 = ''
        pmi01 = soup.find(id="pmi01").get_text()
        pmi01 = pmi01.replace(',','')
        pmi02 = ''
        pmi02 = soup.find(id="pmi02").get_text()
        pmi02 = pmi02.replace(',','')
        pmi03 = ''
        pmi03 = soup.find(id="pmi03").get_text()
        pmi03 = pmi03.replace(',','')
        
        situacion = ''
        situacion = soup.find(id="situ_nvo").get_text()
        
        tablaCostoDev = pd.DataFrame()
        tablaCostoDev = pd.read_html(pageHTML, attrs={"id": "tacum03"})
        dfDevAcum = tablaCostoDev[0]
        dfDevAcum = dfDevAcum.tail(3)
        #dfDevAcum = dfDevAcum.drop([0])
        dfDevAcum = dfDevAcum.T
        dfDevAcum.iloc[0] = dfDevAcum.iloc[0].str.replace(':','')
        dfDevAcum.iloc[0] = dfDevAcum.iloc[0].str.replace(' ','_')
        dfDevAcum.iloc[1] = dfDevAcum.iloc[1].str.replace('S/ ','')
        dfDevAcum.iloc[1] = dfDevAcum.iloc[1].str.replace(',','')
        dfDevAcum.columns = dfDevAcum.iloc[0]
        dfDevAcum = dfDevAcum.drop([0]) # borra nombres
        #dfDevAcum = dfDevAcum.drop(['PRIMER_DEVENGADO', 'ULTIMO_DEVENGADO'], axis=1)
        dfDevAcum.columns= ['DEV_ACUM', 'PRIMER_DEV', 'ULT_DEV']
        dfDevAcum.index = [Ncui]
        
        tablaAvance = pd.DataFrame()
        tablaAvance = pd.read_html(pageHTML, attrs={"id": "t_avance"})
        dfAvance = tablaAvance[0]
        dfAvance = dfAvance.T
        dfAvance.iloc[1] = dfAvance.iloc[1].str.replace('S/ ','')
        dfAvance.iloc[1] = dfAvance.iloc[1].str.replace(',','')
        #dfAvance = dfAvance.drop([2, 3], axis=1)
        dfAvance = dfAvance.drop([0])
        dfAvance.columns= ['PIM_ACT', 'DEV_ACT', 'PF_ACT', 'SALDO']
        dfAvance.index = [Ncui]
        
        tablaProgFinanc = pd.DataFrame()
        tablaProgFinanc = pd.read_html(pageHTML, attrs={"id": "tprogfinanc"})
        dfProgFinanc = tablaProgFinanc[0]
        dfProgFinanc = dfProgFinanc.drop([0,2])
        dfProgFinanc.columns = ['vuela1', 'PROG_ACT_ENE', 'PROG_ACT_FEB', 'PROG_ACT_MAR', 'PROG_ACT_ABR', 'PROG_ACT_MAY', 'PROG_ACT_JUN', 'PROG_ACT_JUL', 'PROG_ACT_AGO', 'PROG_ACT_SET', 'PROG_ACT_OCT', 'PROG_ACT_NOV', 'PROG_ACT_DIC', 'PROG_ACT_TOT']
        dfProgFinanc = dfProgFinanc.drop(['vuela1'], axis=1)
        dfProgFinanc.index = [Ncui]
        
        dfDevengado = pd.DataFrame()
        dfDevengado = tablaProgFinanc[0]
        dfDevengado = dfDevengado.drop([0,1])
        dfDevengado.columns = ['vuela1', 'DEV_ENE', 'DEV_FEB', 'DEV_MAR', 'DEV_ABR', 'DEV_MAY', 'DEV_JUN', 'DEV_JUL', 'DEV_AGO', 'DEV_SET', 'DEV_OCT', 'DEV_NOV', 'DEV_DIC', 'DEV_TOT']
        dfDevengado = dfDevengado.drop(['vuela1'], axis=1)
        #dfDevengado.iloc[0] = dfDevengado.iloc[0].str.replace('-','0')
        dfDevengado.index = [Ncui]
        
        infoF12B = pd.DataFrame()
        infoF12B = pd.concat([dfProgFinanc, dfDevAcum, dfAvance, dfDevengado], axis=1)
        infoF12B['fum'] = fum
        infoF12B['opmi'] = opmi
        infoF12B['uei'] = uei
        infoF12B['tipoinv'] = tipoinv
        infoF12B['modalidadejec'] = modalidadejec
        infoF12B['registrocierre'] = registrocierre
        infoF12B['pmi01'] = pmi01
        infoF12B['pmi02'] = pmi02
        infoF12B['pmi03'] = pmi03
        infoF12B['situacion'] = situacion

    # SSI
    # ====
    
    _infoSSI = np.array([[0]])
    infoSSI = pd.DataFrame(_infoSSI)
    
    web1 = "https://ofi5.mef.gob.pe/ssi/Ssi/Index?codigo="
    web2 = "&tipo=2"
    web = web1+str(Ncui)+web2
    
    driver.get(web)
    time.sleep(timesleep)
    
    pageHTML = driver.page_source
    soup = BeautifulSoup(pageHTML, 'lxml')
    
    codsnip = ''
    codsnip = soup.find(id="td_snip").get_text()
    i = 0
    if (codsnip==''):
        while (fum=='') and (i < 9):
            time.sleep(timesleep)
            pageHTML = driver.page_source
            soup = BeautifulSoup(pageHTML, 'lxml')
            codsnip = ''
            codsnip = soup.find(id="td_snip").get_text()
            i += 1
    
    # codsnip = ''
    # codsnip = soup.find(id="td_snip").get_text()
    infoSSI['codsnip'] = codsnip
    
    fecharegistro = ''
    fecharegistro = soup.find(id="td_fecreg").get_text()
    infoSSI['fecharegistro'] = fecharegistro
    
    estadoinv = ''
    estadoinv = soup.find(id="td_estcu").get_text()
    infoSSI['estadoinv'] = estadoinv
    
    uf = ''
    uf = soup.find(id="td_uf").get_text()
    infoSSI['uf'] = uf
    
    situacionviab = ''
    situacionviab = soup.find(id="td_situinv").get_text()
    infoSSI['situacionviab'] = situacionviab
    
    fechaviab = ''
    fechaviab = soup.find(id="td_fecviab").get_text()
    infoSSI['fechaviab'] = fechaviab
    
    decretoemerg = ''
    decretoemerg = soup.find(id="td_emergds").get_text()
    infoSSI['decretoemerg'] = decretoemerg
    
    montoviable = ''
    montoviable = soup.find(id="td_mtoviab").get_text()
    montoviable = montoviable.replace(',','')
    infoSSI['montoviable'] = montoviable
    
    cadfun = ''
    cadfun = soup.find(id="td_cadfun").get_text()
    infoSSI['cadfun'] = cadfun
    
    beneficiarios = ''
    beneficiarios = soup.find(id="td_benif").get_text()
    beneficiarios = beneficiarios.replace(',','')
    infoSSI['beneficiarios'] = beneficiarios
    
    et = ''
    et = soup.find(id="td_indet").get_text()
    infoSSI['et'] = et
    
    registroseg = ''
    registroseg = soup.find(id="td_indseg").get_text()
    infoSSI['registroseg'] = registroseg
    
    feciniejec = ''
    feciniejec = soup.find(id="fec_iniejec").get_text()
    infoSSI['feciniejec'] = feciniejec
    
    fecfinejec = ''
    fecfinejec = soup.find(id="fec_finejec").get_text()
    infoSSI['fecfinejec'] = fecfinejec
    
    cia = ''
    cia = soup.find(id="val_cta").get_text()
    cia = cia.replace(',','')
    infoSSI['cia'] = cia
    
    laudo = ''
    laudo = soup.find(id="td_laudo").get_text()
    laudo = laudo.replace(',','')
    infoSSI['laudo'] = laudo
    
    cfianza = ''
    cfianza = soup.find(id="td_carfza").get_text()
    cfianza = cfianza.replace(',','')
    infoSSI['cfianza'] = cfianza
    
    montototal = ''
    montototal = soup.find(id="td_mtototal").get_text()
    montototal = montototal.replace(',','')
    infoSSI['montototal'] = montototal
    
    infoSSI['cui'] = Ncui
    
    PMI = ''
    PMI = soup.find(id="td_indpmi").get_text()
    infoSSI['PMI'] = PMI
    
    nominv = ''
    nominv = soup.find(id="td_nominv").get_text()
    infoSSI['nominv'] = nominv
    
    infoSSI.index = [Ncui]
    
    # PMI
    # ====
    
    web = "https://ofi5.mef.gob.pe/invierte/pmi/consultapmi?cui="+str(Ncui)
    driver.get(web)
    time.sleep(timesleep)
    pageHTML = driver.page_source
    #soup = BeautifulSoup(pageHTML, 'lxml')

    tablaPMI = pd.read_html(pageHTML, attrs={"id": "tblResultado"})
    dfPMI = tablaPMI[0]
    del tablaPMI
    dfPMI.columns = ['prioridad', 'prelacion', 'sector', '_opmi', 'nivgob', 'cui', 'codidea', 'tipoinv', 'nombreinv', 'costoactpmi', 'devacum2022pmi', 'pim2023', 'pmi2023', 'pmi2024', 'pmi2025', 'pmi2026']
    
    if (dfPMI['prioridad'].iat[0]=='Cargando...'):
        driver.get(web)
        time.sleep(timesleep)
        time.sleep(timesleep)
        pageHTML = driver.page_source
        tablaPMI = pd.read_html(pageHTML, attrs={"id": "tblResultado"})
        dfPMI = tablaPMI[0]
        del tablaPMI
        dfPMI.columns = ['prioridad', 'prelacion', 'sector', '_opmi', 'nivgob', 'cui', 'codidea', 'tipoinv', 'nombreinv', 'costoactpmi', 'devacum2022pmi', 'pim2023', 'pmi2023', 'pmi2024', 'pmi2025', 'pmi2026']

    if (dfPMI['prioridad'].iat[0]=='Cargando...'):
        driver.get(web)
        time.sleep(timesleep)
        time.sleep(timesleep)
        time.sleep(timesleep)
        pageHTML = driver.page_source
        tablaPMI = pd.read_html(pageHTML, attrs={"id": "tblResultado"})
        dfPMI = tablaPMI[0]
        del tablaPMI
        dfPMI.columns = ['prioridad', 'prelacion', 'sector', '_opmi', 'nivgob', 'cui', 'codidea', 'tipoinv', 'nombreinv', 'costoactpmi', 'devacum2022pmi', 'pim2023', 'pmi2023', 'pmi2024', 'pmi2025', 'pmi2026']
    
    dfPMI = dfPMI[['prioridad','prelacion','_opmi','costoactpmi','devacum2022pmi','pim2023','pmi2023','pmi2024','pmi2025','pmi2026']]
    dfPMI.index = [Ncui]
    
    infoF12BSSI = pd.concat([infoF12B, infoSSI, dfPMI], axis=1)
    del infoF12B
    del infoSSI
    del dfPMI
    
    BBDD = pd.concat([BBDD, infoF12BSSI], axis=0, sort=False)
    #BBDD = BBDD.append(infoF12BSSI)
    del infoF12BSSI
    
    ## TERMINA BUCLE

# BBDD = BBDD[['cui','codsnip','nominv','opmi','uf','uei','fecharegistro','feciniejec','fecfinejec','fum','fechaviab','montoviable','et','tipoinv','modalidadejec','estadoinv','situacion','decretoemerg','registrocierre','cadfun','beneficiarios','registroseg','PMI','pmi01','pmi02','pmi03','cia','concurr','laudo','cfianza','montototal','PIM_ACT','PROG_ACT_ENE','DEV_ENE','PROG_ACT_FEB','DEV_FEB','PROG_ACT_MAR','DEV_MAR','PROG_ACT_ABR','DEV_ABR','PROG_ACT_MAY','DEV_MAY','PROG_ACT_JUN','DEV_JUN','PROG_ACT_JUL','DEV_JUL','PROG_ACT_AGO','DEV_AGO','PROG_ACT_SET','DEV_SET','PROG_ACT_OCT','DEV_OCT','PROG_ACT_NOV','DEV_NOV','PROG_ACT_DIC','DEV_DIC','PROG_ACT_TOT','DEV_TOT','SALDO','DEV_ACUM','PRIMER_DEV','ULT_DEV','prioridad', 'prelacion', 'costoact', 'devacum2022', 'pim2023', 'pmi2023', 'pmi2024', 'pmi2025', 'pmi2026']]
BBDD = BBDD[['cui','nominv','opmi','uf','uei','fum','et','tipoinv','modalidadejec','estadoinv','situacion','decretoemerg','registrocierre','cadfun','beneficiarios','registroseg','montototal','PMI','pmi01','pmi02','pmi03','PIM_ACT','DEV_ENE','DEV_FEB','DEV_MAR','DEV_ABR','DEV_MAY','DEV_JUN','DEV_JUL','DEV_AGO','DEV_SET','PROG_ACT_OCT','PROG_ACT_NOV','PROG_ACT_DIC','PROG_ACT_TOT','SALDO','DEV_TOT','DEV_ACUM','_opmi','costoactpmi','devacum2022pmi','pim2023','pmi2023','pmi2024','pmi2025','pmi2026']]

BBDD.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT),sheet_name='BD',index=False)

driver.close()

# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
print('Segundos transcurridos:',nseconds) # imprime segundos de demora