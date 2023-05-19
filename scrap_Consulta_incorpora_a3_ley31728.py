import time
import pandas as pd
from selenium import webdriver
from datetime import date

# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

today = date.today()
d1 = today.strftime("%d_%m_%Y")
sufijo = ''
# sufijo = '_parte08'

# ----------------- MODIFICABLE
#
# ruta de entrada
PATH_INPUT = 'C:/Users/servpres_16/Documents/aron/Data/'
# ruta de salida
PATH_OUTPUT = 'C:/Users/servpres_16/Documents/aron/Data/'
# archivo input (proyectos incorporados)
FILE_INPUT = 'id_cui{}.xlsx'.format(sufijo)
# nombre del archivo output
FILE_OUTPUT = 'amigable_incorpora_RO_a3_ley31728_{}{}.xlsx'.format(d1,sufijo)
# tiempo que deja cargar cada página
timesleep=0.1
#
# ----------------- MODIFICABLE

driver = webdriver.Chrome()

file_xlsx = PATH_INPUT + FILE_INPUT
df_xlsx = pd.read_excel(file_xlsx)

def scrap_ro_proy793():
    
    lista_proyectos = []
    BBDDcam = pd.DataFrame()
    
    web = "https://apps5.mineco.gob.pe/transparencia/Navegador/default.aspx?y=2023&ap=Proyecto"
    driver.get(web)
    
    driver.switch_to.frame('frame0')
    driver.find_element("id", "ctl00_CPH1_BtnFuenteAgregada").click()
    time.sleep(timesleep)
    driver.find_element("xpath", "//*[contains(text(),'1: RECURSOS ORDINARIOS')]").click()
    time.sleep(timesleep)
    driver.find_element("id", "ctl00_CPH1_BtnGenerica").click()
    time.sleep(timesleep)
    driver.find_element("xpath", "//*[contains(text(),'6-26: ADQUISICION DE ACTIVOS NO FINANCIEROS')]").click()
    time.sleep(timesleep)
    driver.find_element("id", "ctl00_CPH1_BtnTipoGobierno").click()
    time.sleep(timesleep)
    driver.find_element("xpath", "//*[contains(text(),'M: GOBIERNOS LOCALES')]").click()
    time.sleep(timesleep)
    driver.find_element("id", "ctl00_CPH1_BtnSubTipoGobierno").click()
    time.sleep(timesleep)
    driver.find_element("xpath", "//*[contains(text(),'M: MUNICIPALIDADES')]").click()
    # boton departamento
    time.sleep(timesleep)
    driver.find_element("id", "ctl00_CPH1_BtnDepartamento").click()
    
    # Obtener la lista de departamentos únicos del DataFrame
    departamentos = df_xlsx['dep'].unique()
    
    # Recorrer cada departamento
    for depto in departamentos:
        
        # Filtrar las filas correspondientes a este departamento
        depto_rows = df_xlsx.loc[df_xlsx['dep'] == depto]
        
        # Escribir el departamento y hacer clic en el botón de búsqueda
        dpto_s = "//*[contains(text(),'{:02}: ')]".format(depto)
        driver.find_element("xpath",dpto_s).click()
        
        # boton provincia
        time.sleep(timesleep)
        driver.find_element("id", "ctl00_CPH1_BtnProvincia").click()
        
        # Obtener la lista de provincias únicas del DataFrame
        provincias = depto_rows['prov'].unique()
        
        # Recorrer cada provincia
        for provi in provincias:
            
            # Filtrar las filas correspondientes a esta provincia
            provi_rows = depto_rows.loc[depto_rows['prov'] == provi]
            
            # Escribir la provincia y hacer clic en el botón de búsqueda
            # seleccionamos provincia
            prov_s = "//*[contains(text(),'{:04}: ')]".format(provi)
            driver.find_element("xpath",prov_s).click()
            
            # boton municipalidad
            time.sleep(timesleep)
            driver.find_element("id", "ctl00_CPH1_BtnMunicipalidad").click()
            
            # Obtener la lista de munis únicas del DataFrame
            munis = provi_rows['dist'].unique()
            
            # Recorrer cada distrito
            for muni in munis:
                
                # Filtrar las filas correspondientes a esta muni
                muni_rows = provi_rows.loc[provi_rows['dist'] == muni]
                
                # seleccionamos municipalidad
                dist_s = "//*[contains(text(),'{:06}-3')]".format(muni)
                driver.find_element("xpath",dist_s).click()
                
                # boton proyecto
                time.sleep(timesleep)
                driver.find_element("id", "ctl00_CPH1_BtnProdProy").click()
                
                for index, row in muni_rows.iterrows():
                
                    # seleccionamos proyecto
                    print(row['cui'])
                    cui_s = "//*[contains(text(),'{}:')]".format(row['cui'])
                    driver.find_element("xpath",cui_s).click()
                    
                    # boton aao
                    time.sleep(timesleep)
                    driver.find_element("id", "ctl00_CPH1_BtnAAO").click()
                    
                    # contamos cuantas aao hay
                    tmp=1
                    boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(tmp)
                    driver.find_element("id", boton).click()
                    while True:
                        tmp += 1
                        boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(tmp)
                        try:
                            time.sleep(timesleep)
                            driver.find_element("id", boton).click()
                        except:
                            total_aao = tmp-1 # < -------------------------------------------------------------  cambia total_*
                            # del tmp
                            break
                    
                    # seleccionamos aao i
                    count_aao=1
                    while (count_aao<=total_aao):
                        boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(count_aao)
                        time.sleep(timesleep)
                        driver.find_element("id", boton).click()
                        aao = driver.find_element("id",boton).find_element("name", "grp1").get_attribute("value").split('/', 1)[0]
                        
                        # boton funcion
                        time.sleep(timesleep)
                        driver.find_element("id", "ctl00_CPH1_BtnFuncion").click()
                        fc = driver.find_element("name", "grp1").get_attribute("value").split('/', 1)[0]
                
                        # boton division funcional
                        time.sleep(timesleep)
                        driver.find_element("id", "ctl00_CPH1_BtnDivFuncional").click()
                        dfc = driver.find_element("name", "grp1").get_attribute("value").split('/', 1)[0]
                
                        # boton grupo funcional
                        time.sleep(timesleep)
                        driver.find_element("id", "ctl00_CPH1_BtnGrupoFuncional").click()
                        
                        # contamos cuantas gfc hay
                        tmp=1
                        boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(tmp)
                        driver.find_element("id", boton).click()
                        while True:
                            tmp += 1
                            boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(tmp)
                            try:
                                time.sleep(timesleep)
                                driver.find_element("id", boton).click()
                            except:
                                total_gfcs = tmp-1 # < -------------------------------------------------------------  cambia total_*
                                # del tmp
                                break
                        
                        # seleccionamos gfc i
                        count_gfc=1
                        while (count_gfc<=total_gfcs):
                            boton = 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(count_gfc)
                            time.sleep(timesleep)
                            driver.find_element("id", boton).click()
                            gfc = driver.find_element("id",boton).find_element("name", "grp1").get_attribute("value").split('/', 1)[0]
                            
                            # boton pp
                            time.sleep(timesleep)
                            driver.find_element("id", "ctl00_CPH1_BtnProgramaPpto").click()
                            
                            e=0
                            while True:
                                e += 1
                                try:
                                    los_grp1 = driver.find_element("id", 'ctl00_CPH1_RptData_ctl{:02}_TD0'.format(e))  # cada fila
                                    ppto = los_grp1.find_element("name", "grp1").get_attribute("value")
                                    ppto = '{}/{}/{}/{}/{}/'.format(row['cui'],aao,fc,dfc,gfc)+ppto
                                    lista_proyectos.append(ppto)
                                except:
                                    break
                            
                            count_gfc+=1
                            driver.find_element("id", "ctl00_CPH1_RptHistory_ctl13_TD0").click()
                        count_aao+=1
                        driver.find_element("id", "ctl00_CPH1_RptHistory_ctl10_TD0").click()
                    driver.find_element("id", "ctl00_CPH1_RptHistory_ctl09_TD0").click()
                driver.find_element("id", "ctl00_CPH1_RptHistory_ctl08_TD0").click()
            driver.find_element("id", "ctl00_CPH1_RptHistory_ctl07_TD0").click()
        driver.find_element("id", "ctl00_CPH1_RptHistory_ctl06_TD0").click()
    
    serie_proyectos = pd.Series(lista_proyectos)
    del lista_proyectos
    
    BBDDcam['tmp'] = serie_proyectos
    del serie_proyectos
    
    BBDDcam = BBDDcam['tmp'].str.split("/", expand = True)
    
    BBDDcam.columns = ['cui','aao','funcion','divfuncional','gpofuncional','pp','pia','pim','comp_a','comp_m','dev','gir','cert']
    
    BBDDcam = BBDDcam[['cui','funcion','divfuncional','gpofuncional','pp','aao','pia','pim','cert','comp_a','comp_m','dev','gir']]
    
    BBDDcam['pia'] = pd.to_numeric(BBDDcam['pia'])
    BBDDcam['pim'] = pd.to_numeric(BBDDcam['pim'])
    BBDDcam['cert'] = pd.to_numeric(BBDDcam['cert'])
    BBDDcam['comp_a'] = pd.to_numeric(BBDDcam['comp_a'])
    BBDDcam['comp_m'] = pd.to_numeric(BBDDcam['comp_m'])
    BBDDcam['dev'] = pd.to_numeric(BBDDcam['dev'])
    BBDDcam['gir'] = pd.to_numeric(BBDDcam['gir'])
    
    BBDDcam.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT),sheet_name='BD',index=False)
    
    driver.close()
    
    # para contabilizar tiempo de demora
    end = time.time() # fin de toma de tiempo
    nseconds = end-start # calcula tiempo (segundos)
    nseconds=int(nseconds) # se pasa a enteros
    print('Segundos transcurridos:',nseconds) # imprime segundos de demora

try:
    scrap_ro_proy793()
except:
    try:
        print('-')
        print('ERROR # 1')
        print('-')
        time.sleep(5)
        scrap_ro_proy793()
    except:
        try:
            print('-')
            print('ERROR # 2')
            print('-')
            time.sleep(5)
            scrap_ro_proy793()
        except:
            print('-')
            print('ERROR # 3')
            print('-')
            time.sleep(5)
            scrap_ro_proy793()
