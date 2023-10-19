* Previsiones y PL 2024

glo previ "C:\Users\servpres_16\Documents\aron\Documentos\03 Para revisión\prevision_2023\III Trimestre\"
glo data  "C:\Users\servpres_16\Documents\aron\Data\"

glo fecha "181023"

import excel using "${previ}\FORMATO_5_Previsiones (18.10.2023).xlsx", sheet(BASE) first clear
drop if Númeroúnicodeprevisión==""
gen clas="2."+substr(GenéricadeGasto,1,2)+"."+substr(SubGenéricadeGasto,1,2)+"."+substr(SubGenéricaDetalledeGasto,1,2)+"."+substr(EspecíficadeGasto,1,2)+"."+substr(EspecíficaDetalledeGasto,1,2)
replace clas=subinstr(clas,"..",".",.)
ren CodigoProductoProyecto cui
ren Montoprevisión2024 PREVISION_2024
replace clas=substr(clas,1,length(clas)-1) if substr(clas,length(clas),1)=="."
ren Fuente ff
keep ff cui PREVISION_2024 clas
collapse (sum) PREVISION_2024, by(ff cui clas)
save "${previ}\tmp_previs", replace

import excel using "${data}\CUI_CC_PL_ET.xlsx", clear first
save "${data}\tmp_cc", replace

import excel using "${data}\UE 010 - PL 2024.xlsx", clear sheet(BD) first
ren fuente_financ ff
ren dnpp cui
destring cui, replace
gen gg=substr(Especificadet,2,1)
gen sg=substr(Especificadet,4,1)
gen sgd=substr(Especificadet,5,2)
gen eg=substr(Especificadet,7,2)
gen edg=substr(Especificadet,9,2)
gen clas="2."+gg+"."+sg+"."+sgd+"."+eg+"."+edg
replace clas=subinstr(clas," ","",.)
keep ff cui producto_proyecto clas mto_pia
collapse (sum) mto_pia, by(ff cui producto_proyecto clas)

fre ff

merge 1:1 ff cui clas using "${previ}\tmp_previs", nogen
bys cui (producto_proyecto): replace producto_proyecto=producto_proyecto[_N] if producto_proyecto==""
replace producto_proyecto="2389468. MEJORAMIENTO DEL CAMINO VECINAL EMP. PE-5N (BAMBAMARCA) - SANTA ROSA DE TANANTA Y BALSA PROBANA DEL DISTRITO DE TOCACHE - PROVINCIA DE TOCACHE - DEPARTAMENTO DE SAN MARTIN" if cui==2389468
replace producto_proyecto="2464727. MEJORAMIENTO DEL CAMINO VECINAL EMP. AP-109 (SILCO) - AP-856 (CALCAUSO) DEL DISTRITO DE JUAN ESPINOZA MEDRANO - PROVINCIA DE ANTABAMBA - DEPARTAMENTO DE APURIMAC" if cui==2464727
replace producto_proyecto="2470713. MEJORAMIENTO DEL SERVICIO DE TRANSITABILIDAD VIAL INTERURBANA EN CAMINOS VECINALES AP-665; AP-669: EMP. PE-3S - POLTOCSA - EMP. AP-670 (OVALO DEL NIÑO) Y AP-659; AP-657: EMP. PE-3S - OLLABAMBA - LLIUPAPUQUIO - YUNCAYA - CUPISA - ANCATIRA - EMP. PE-3S (CHAMPACCOCHA) DISTRITO DE SAN JERONIMO DE LA PROVINCIA DE ANDAHUAYLAS DEL DEPARTAMENTO DE APURIMAC" if cui==2470713
replace producto_proyecto="2474480. MEJORAMIENTO DEL SERVICIO DE TRANSITABILIDAD VIAL EMP. PE-3 S (TALAVERA) - OMACA - OCOBAMBA - ROCCHAC - ONGOY - HUACCANA - MARAMORA - PULCAY L.D. AYACUCHO (CCANCHY, AY-102 A CHUNGUI) EN LAS PROVINCIAS DE ANDAHUAYLAS Y CHINCHEROS DEL DEPARTAMENTO DE APURIMAC" if cui==2474480
replace producto_proyecto="2595752. REPARACIÓN DE PUENTE; EN EL(LA) CAMINO VECINAL EL MILAGRO (INTERVENCIÓN EN EL PUENTE EL MILAGRO ROCU) DISTRITO DE COLCABAMBA, PROVINCIA HUARAZ, DEPARTAMENTO ANCASH" if cui==2595752
replace producto_proyecto="2595895. REPARACIÓN DE PUENTE; EN EL(LA) CAMINO VECINAL PI-836 (PUENTE HUARGUAR - SHIMBE), EN LA LOCALIDAD HUARGUAR, DISTRITO DE EL CARMEN DE LA FRONTERA, PROVINCIA HUANCABAMBA, DEPARTAMENTO PIURA" if cui==2595895
replace producto_proyecto="2596226. REPARACIÓN DE PUENTE; EN EL(LA) CAMINO VECINAL EN LA RUTA PI-845 (PUENTE COMENDEROS) EMP. PE -3N (DV. HUANCABAMBA) - CATALUCO - EMP. PI-849, EN LA LOCALIDAD CATALUCO, DISTRITO DE HUANCABAMBA, PROVINCIA HUANCABAMBA, DEPARTAMENTO PIURA" if cui==2596226

gen tipo_pro="2. PROYECTO" if substr(producto_proyecto,1,1)=="2"
replace tipo_pro="3. PRODUCTO" if substr(producto_proyecto,1,1)=="3"

recode mto_pia PREVISION_2024 (.=0)

gen pia_menos_previ=mto_pia-PREVISION_2024
order pia_menos_previ, after(PREVISION_2024)

merge m:1 cui using "${data}\tmp_cc", nogen keep(1 3)

replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 03"+" - "+substr(producto_proyecto,10,10000) if cui==2443427
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 02"+" - "+substr(producto_proyecto,10,10000) if cui==2444433
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 12"+" - "+substr(producto_proyecto,10,10000) if cui==2446445
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 04"+" - "+substr(producto_proyecto,10,10000) if cui==2446449
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 01"+" - "+substr(producto_proyecto,10,10000) if cui==2447282
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 05"+" - "+substr(producto_proyecto,10,10000) if cui==2458796
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 11"+" - "+substr(producto_proyecto,10,10000) if cui==2459159
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 07"+" - "+substr(producto_proyecto,10,10000) if cui==2464852
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 09"+" - "+substr(producto_proyecto,10,10000) if cui==2466445
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 08"+" - "+substr(producto_proyecto,10,10000) if cui==2468445
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 10"+" - "+substr(producto_proyecto,10,10000) if cui==2468720
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 06"+" - "+substr(producto_proyecto,10,10000) if cui==2471070
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 41"+" - "+substr(producto_proyecto,10,10000) if cui==2505082
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 24"+" - "+substr(producto_proyecto,10,10000) if cui==2506659
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 17"+" - "+substr(producto_proyecto,10,10000) if cui==2507211
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 35"+" - "+substr(producto_proyecto,10,10000) if cui==2507956
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 36"+" - "+substr(producto_proyecto,10,10000) if cui==2508333
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 25"+" - "+substr(producto_proyecto,10,10000) if cui==2508558
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 15"+" - "+substr(producto_proyecto,10,10000) if cui==2510877
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 31"+" - "+substr(producto_proyecto,10,10000) if cui==2512805
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 39 y 40"+" - "+substr(producto_proyecto,10,10000) if cui==2514132
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 28"+" - "+substr(producto_proyecto,10,10000) if cui==2515255
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 20"+" - "+substr(producto_proyecto,10,10000) if cui==2515902
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 42"+" - "+substr(producto_proyecto,10,10000) if cui==2527998
replace producto_proyecto=substr(producto_proyecto,1,9)+"CV 19"+" - "+substr(producto_proyecto,10,10000) if cui==2543359

export excel using "${data}\prevision_pl_2024_v${fecha}.xlsx", replace first(var) sheet(BD)
cap erase "${previ}\tmp_previs.dta"
cap erase "${data}\tmp_cc.dta"
