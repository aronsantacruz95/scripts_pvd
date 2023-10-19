/*
---
Descarga de SIAF OL:

archivo de ejecución presupuestal:
Reportes>Exportar Información Presupuestaria>UE

archivo de certificacion:
Reportes>Modificación Presupuestal>Ejecución Mensual Vs Marco Presupuestal>UE>Cadena Programática y Funcional>Clasificador de Gasto>Fase Certificado

archivo de compromiso anual:
Reportes>Modificación Presupuestal>Ejecución Mensual Vs Marco Presupuestal>UE>Cadena Programática y Funcional>Clasificador de Gasto>Fase Compromiso Anual

archivo de metas físicas:
Reportes>Avance Físico>Avance Físico de Metas Presupuestales>UE
---
*/

clear all
set more off
set rmsg on, permanently

glo fecha "19102023"
glo hora  "0900"

glo archivo_ppto        "gasto_siafol_${fecha}_${hora}.xls" // archivo de ejecución presupuestal
glo archivo_cert   "gasto_cert_siafol_${fecha}_${hora}.xls" // archivo de certificacion
glo archivo_compa "gasto_compa_siafol_${fecha}_${hora}.xls" // archivo de compromiso anual
glo archivo_metas 		"metas_siafol_${fecha}_${hora}.xls" // archivo de metas físicas
// glo archivo_cc 						"secfunc_cui_clas.xlsx" // archivo de cc

cd "C:\Users\servpres_16\Documents\aron\Data\"

// certificacion

import excel using "${archivo_cert}", clear
drop A C E R S T U

gen _fuente_financ=substr(B,1,2) if inlist(B,"00 RECURSOS ORDINARIOS","09 RECURSOS DIRECTAMENTE RECAUDADOS","13 DONACIONES Y TRANSFERENCIAS","19 RECURSOS POR OPERACIONES OFICIALES DE CREDITO")
gen _sec_func=substr(B,1,4) if substr(B,5,2)=="  " & substr(B,11,1)==" " & substr(B,19,1)==" " & substr(B,27,1)==" "
gen _categoria_gasto=B if B=="5" | B=="6"
gen tmp=strtrim(stritrim(subinstr(B,"."," ",.))) if length(B)<20 & substr(B,1,1)=="2"
split tmp, gen(tmp_) p(" ")
destring tmp_4-tmp_6, replace
tostring tmp_4-tmp_6, replace format(%02.0f)
replace tmp_4="" if tmp_4=="."
replace tmp_5="" if tmp_5=="."
replace tmp_6="" if tmp_6=="."
drop tmp
foreach x of varlist _fuente_financ-_categoria_gasto {
	replace `x'=`x'[_n-1] if missing(`x')
}
ren (F G H I J K L M N O P Q) (mto_cert_01 mto_cert_02 mto_cert_03 mto_cert_04 mto_cert_05 mto_cert_06 mto_cert_07 mto_cert_08 mto_cert_09 mto_cert_10 mto_cert_11 mto_cert_12)
keep if tmp_1!="" & tmp_6!=""
egen id_ppto=concat(_sec_func _fuente_financ _categoria_gasto tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6), p(".")
keep id_ppto mto_cert_*
order id_ppto mto_cert_*
destring mto_cert_*, replace
recode mto_cert_* (.=0)

save "tmp_cert.dta", replace

// compromiso anual

import excel using "${archivo_compa}", clear
drop A C E R S T U

gen _fuente_financ=substr(B,1,2) if inlist(B,"00 RECURSOS ORDINARIOS","09 RECURSOS DIRECTAMENTE RECAUDADOS","13 DONACIONES Y TRANSFERENCIAS","19 RECURSOS POR OPERACIONES OFICIALES DE CREDITO")
gen _sec_func=substr(B,1,4) if substr(B,5,2)=="  " & substr(B,11,1)==" " & substr(B,19,1)==" " & substr(B,27,1)==" "
gen _categoria_gasto=B if B=="5" | B=="6"
gen tmp=strtrim(stritrim(subinstr(B,"."," ",.))) if length(B)<20 & substr(B,1,1)=="2"
split tmp, gen(tmp_) p(" ")
destring tmp_4-tmp_6, replace
tostring tmp_4-tmp_6, replace format(%02.0f)
replace tmp_4="" if tmp_4=="."
replace tmp_5="" if tmp_5=="."
replace tmp_6="" if tmp_6=="."
drop tmp
foreach x of varlist _fuente_financ-_categoria_gasto {
	replace `x'=`x'[_n-1] if missing(`x')
}
ren (F G H I J K L M N O P Q) (mto_compa_01 mto_compa_02 mto_compa_03 mto_compa_04 mto_compa_05 mto_compa_06 mto_compa_07 mto_compa_08 mto_compa_09 mto_compa_10 mto_compa_11 mto_compa_12)
keep if tmp_1!="" & tmp_6!=""
egen id_ppto=concat(_sec_func _fuente_financ _categoria_gasto tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6), p(".")
keep id_ppto mto_compa_*
order id_ppto mto_compa_*
destring mto_compa_*, replace
recode mto_compa_* (.=0)

save "tmp_compa.dta", replace

// metas físicas

import excel using "${archivo_metas}", clear
keep B G H I K
ren (B G H I K) (sec_func cant_meta_sem cant_meta_anual avan_fisico_sem avan_fisico_anual)
keep if length(sec_func)==4
destring *, replace

save "tmp_metas.dta", replace

// cc

// import excel using "${archivo_cc}", clear first
// drop if sec_func==0
//
// save "tmp_cc.dta", replace

// ppto

import excel using "${archivo_ppto}", clear first
drop if sec_func==0 | (mto_pia==0 & mto_pim==0)
tostring sec_func, gen(_sec_func) format(%04.0f)
gen _fuente_financ=substr(rubro,1,2)
gen _categoria_gasto=substr(categoria_gasto,1,1)
gen tmp_1="2"
local i=2
foreach x of varlist generica subgenerica subgenerica_det especifica especifica_det {
	gen tmp_`i' = substr(`x',1,(strpos(`x',".")-1))
	local ++i
}
destring tmp_4-tmp_6, replace
tostring tmp_4-tmp_6, replace format(%02.0f)
egen id_ppto=concat(_sec_func _fuente_financ _categoria_gasto tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6), p(".")
drop _sec_func _fuente_financ _categoria_gasto tmp_1
merge 1:1 id_ppto using "tmp_cert.dta", nogen
merge 1:1 id_ppto using "tmp_compa.dta", nogen
merge m:1 sec_func using "tmp_metas.dta", nogen update replace keep(1 3 4 5)
drop id_ppto
drop mto_certificado mto_compro_anual
egen double mto_certificado	=rowtotal(		mto_cert_01 -	mto_cert_12)
egen double mto_at_compro	=rowtotal(	 mto_at_comp_01 -mto_at_comp_12)
egen double mto_compro_anual=rowtotal(	   mto_compa_01 -  mto_compa_12)
egen double mto_devengado	=rowtotal(	 mto_devenga_01 -mto_devenga_12)
egen double mto_girado		=rowtotal(	  mto_girado_01 - mto_girado_12)
egen double mto_pagado		=rowtotal(	  mto_pagado_01 - mto_pagado_12)

order mto_pia mto_modificaciones mto_pim mto_cert_* mto_certificado mto_compa_* mto_compro_anual mto_at_comp_* mto_at_compro mto_devenga_* mto_devengado mto_girado_* mto_girado mto_pagado_* mto_pagado, last
*order id_ppto, last

recode mto_pia-mto_pagado (.=0)

gen tmp_1="2"
egen clasificador=concat(tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6), p(".")
order clasificador, before(mto_pia)
drop tmp_*
cap drop clasificador_nombre
gen clasificador_nombre=clasificador+". "+substr(especifica_det,strpos(especifica_det,".")+1,.)
order clasificador_nombre, after(clasificador)

gen cui=substr(producto_proyecto,1,7)
order cui, before(producto_proyecto)
destring cui, replace

// partidas especiales

// format clasificador_nombre %-114s
// cap drop partida
// gen partida=""
// replace partida="ESPECIAL - CONTRALORIA" 	if partida=="" & strpos(clasificador,"2.4.2.03.01.01")==1 & strpos(tipo_prod_proy,"2")==1
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.1.1."		)==1
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.1.3."		)==1
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.2.1."		)==1
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.1.06."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.1.11."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.02.01."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.02.02."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.02.04."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.04."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.07.01."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.07.02."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.07.11.99")==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.08.01."	)==1 // OK
// replace partida="ESPECIAL - PARTIDA" 		if partida=="" & strpos(clasificador,"2.3.2.08.01.02")==1 // OK
// replace partida="ESPECIAL - SENTENCIAS" 	if partida=="" & strpos(clasificador,"2.5.5."		)==1 // OK
// replace partida="ESPECIAL - ACTIVIDAD" 		if partida=="" & strpos(activ_obra_accinv,"5006269")==1
// replace partida="ESPECIAL - ACTIVIDAD" 		if partida=="" & strpos(activ_obra_accinv,"5006373")==1
// replace partida="ESPECIAL - ACTIVIDAD" 		if partida=="" & strpos(activ_obra_accinv,"6000050")==1
// replace partida="ESPECIAL - ACTIVIDAD" 		if partida=="" & strpos(activ_obra_accinv,"6000051")==1
// replace partida="ESPECIAL - ACTIVIDAD" 		if partida=="" & strpos(activ_obra_accinv,"4000221")==1
// replace partida="ESPECIAL - FONDES" 		if partida=="" & inlist(sec_func,564,565)
// replace partida="ESPECIAL - SOS VD" 		if partida=="" & sec_func==298
// replace partida="ESPECIAL - SOS VV" 		if partida=="" & sec_func==299
// replace partida="ESPECIAL - LEY 31728" 		if partida=="" & sec_func==554
// replace partida="ESPECIAL - DU 011" 		if partida=="" & sec_func==555
// // replace partida="ESPECIAL - IOARR 148 PM" 	if partida=="" & inlist(sec_func,125,126,127,128,129,130,131,132,133,134,135,164,166,167,453,454,455,456,457,458,459,470,474)
// replace partida="ESPECIAL - INVERSION" 		if partida=="" & strpos(clasificador,"2.6."			)==1 & strpos(tipo_prod_proy,"2")==1
// replace partida="NORMAL" if partida==""
// order partida, before(mto_pia)

gen restriccion_clas=""
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.4.2.03.01.01")==1 & strpos(tipo_prod_proy,"2")==1
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.1.1."		)==1
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.1.3."		)==1
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.2.1."		)==1
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.1.06."	)==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.1.11."	)==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.02.01.")==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.02.02.")==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.02.04.")==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.04."	)==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.07.01.")==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.07.02.")==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.07.11.99")==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.08.01.")==1 // OK
replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.3.2.08.01.02")==1 // OK
*replace restriccion_clas="ESPECIAL - PARTIDA" 	if restriccion_clas=="" & strpos(clasificador,"2.5.5."		)==1 // OK

gen restriccion_actv=""
replace restriccion_actv="ESPECIAL - ACTIVIDAD" if restriccion_actv=="" & strpos(activ_obra_accinv,"5006269")==1
replace restriccion_actv="ESPECIAL - ACTIVIDAD" if restriccion_actv=="" & strpos(activ_obra_accinv,"5006373")==1
replace restriccion_actv="ESPECIAL - ACTIVIDAD" if restriccion_actv=="" & strpos(activ_obra_accinv,"6000050")==1
replace restriccion_actv="ESPECIAL - ACTIVIDAD" if restriccion_actv=="" & strpos(activ_obra_accinv,"6000051")==1
replace restriccion_actv="ESPECIAL - ACTIVIDAD" if restriccion_actv=="" & strpos(activ_obra_accinv,"4000221")==1

gen restriccion_prod=""
replace restriccion_prod="ESPECIAL - PRODUCTO" if restriccion_prod=="" & inlist(cui,3000132,3000133)

gen restriccion_meta=""
replace restriccion_meta="ESPECIAL - FONDES" 	if restriccion_meta=="" & inlist(sec_func,564,565)
replace restriccion_meta="ESPECIAL - SOS VD" 	if restriccion_meta=="" & sec_func==298
replace restriccion_meta="ESPECIAL - SOS VV" 	if restriccion_meta=="" & sec_func==299
replace restriccion_meta="ESPECIAL - LEY 31728" if restriccion_meta=="" & sec_func==554
replace restriccion_meta="ESPECIAL - DU 011" 	if restriccion_meta=="" & sec_func==555

replace restriccion_clas="LIBERADA" if restriccion_clas==""
replace restriccion_actv="LIBERADA" if restriccion_actv==""
replace restriccion_prod="LIBERADA" if restriccion_prod==""
replace restriccion_meta="LIBERADA" if restriccion_meta==""

replace clasificador_nombre="2.3.1.06.01.03. REPUESTOS Y ACCESORIOS DE CONSTRUCCION Y MAQUINAS " if clasificador=="2.3.1.06.01.03"
replace clasificador_nombre="2.3.2.05.01.02. ALQUILER DE VEHICULOS " if clasificador=="2.3.2.05.01.02"
replace clasificador_nombre="2.3.2.05.01.04. ALQUILER DE MAQUINARIAS Y EQUIPOS " if clasificador=="2.3.2.05.01.04"
replace clasificador_nombre="2.3.2.09.01.01. LOCACIÓN DE SERVICIOS " if clasificador=="2.3.2.09.01.01"
replace clasificador_nombre="2.3.2.07.13.98. OTROS SERVICIOS TÉCNICOS Y PROFESIONALES P. JURÍDICAS " if clasificador=="2.3.2.07.13.98"

gen sec_func2="IOARRs DE EMERGENCIA" if inlist(cui,2596012,2595890,2595899,2596016,2596015,2595895,2595919,2595921,2595741,2596226,2595892,2595957,2595825,2595897,2595969,2595989,2595985,2595828,2595759,2595752,2595842,2595771,2595777,2595782,2595787,2595784,2595808,2595961,2595843,2595811,2595819,2595845,2595967,2595986,2595980,2595983,2595849,2595850,2595851,2595854,2595852,2595991,2595996,2595855,2590033,2596145,2596151,2596120,2596142,2590004,2596144,2596160,2596115,2596114,2596158,2585939,2585935,2585929,2585973,2606825,2606838,2607020,2607032,2607361,2607394,2607503)
replace sec_func2="META 554 LEY 31728 - ANEXO IV (FORTALECIMIENTO)" if sec_func==554
replace sec_func2="META 555 DU 011-2023" if sec_func==555

gen clasif_grupo=clasificador_nombre
replace clasif_grupo="A. ATENCIÓN DE EMERGENCIAS VIALES" if clasificador=="2.3.1.03.01.01" & sec_func==555
replace clasif_grupo="B. SERVICIOS DE MANTENIMIENTO VIAL" if inlist(clasificador,"2.3.2.04.04.05","2.3.2.05.01.04","2.3.2.04.03.01","2.3.2.07.11.02") & sec_func==555
replace clasif_grupo="C. SERVICIOS PARA LA ELABORACIÓN DE EXPEDIENTES TÉCNICOS" if (inlist(clasificador,"2.3.2.09.01.01") | inlist(clasificador,"2.3.2.07.07.01","2.3.2.07.13.98","2.3.2.01.02.01","2.3.2.01.02.02","2.3.2.05.01.02","2.3.1.05.01.02","2.3.2.01.02.99","2.3.1.07.01.01","2.3.2.06.01.02")) & sec_func==555
replace clasif_grupo="D. HABILITACIÓN DE POOL DE MAQUINARIA MTC" if clasificador=="2.3.1.06.01.03" & sec_func==555

// gen ProgSetDU11yFort=0
// gen ProgOctDU11yFort=0
// gen ProgNovDU11yFort=0
// gen ProgDicDU11yFort=0

// // Fortalecimiento
//
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==554 & clasificador=="2.3.1.03.01.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.01.02.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=14400 	if sec_func==554 & clasificador=="2.3.2.01.02.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.01.02.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=36000 	if sec_func==554 & clasificador=="2.3.2.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.07.09.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=323303.33	if sec_func==554 & clasificador=="2.3.2.09.01.01" & _n==1
//
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=0 		if sec_func==554 & clasificador=="2.3.1.03.01.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.01.02.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=32000 	if sec_func==554 & clasificador=="2.3.2.01.02.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.01.02.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=80000 	if sec_func==554 & clasificador=="2.3.2.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.07.09.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=715950	if sec_func==554 & clasificador=="2.3.2.09.01.01" & _n==1
//
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=0 		if sec_func==554 & clasificador=="2.3.1.03.01.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.01.02.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=32000 	if sec_func==554 & clasificador=="2.3.2.01.02.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.01.02.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=80000 	if sec_func==554 & clasificador=="2.3.2.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.07.09.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=629950	if sec_func==554 & clasificador=="2.3.2.09.01.01" & _n==1
//
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0 		if sec_func==554 & clasificador=="2.3.1.03.01.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.01.02.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=14400 	if sec_func==554 & clasificador=="2.3.2.01.02.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.01.02.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=36000 	if sec_func==554 & clasificador=="2.3.2.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0 		if sec_func==554 & clasificador=="2.3.2.07.09.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=579000	if sec_func==554 & clasificador=="2.3.2.09.01.01" & _n==1
//
// // DU 011-2023
//
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=600000	if sec_func==555 & clasificador=="2.3.1.03.01.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==555 & clasificador=="2.3.1.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0		 	if sec_func==555 & clasificador=="2.3.1.06.01.03" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.01.02.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.01.02.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0			if sec_func==555 & clasificador=="2.3.2.01.02.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.04.03.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=150000 	if sec_func==555 & clasificador=="2.3.2.05.01.04" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.06.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.07.07.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.07.11.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=0			if sec_func==555 & clasificador=="2.3.2.07.13.98" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgSetDU11yFort=220800	if sec_func==555 & clasificador=="2.3.2.09.01.01" & _n==1
//
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=824328	if sec_func==555 & clasificador=="2.3.1.03.01.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=0			if sec_func==555 & clasificador=="2.3.1.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=0		 	if sec_func==555 & clasificador=="2.3.1.06.01.03" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=30000		if sec_func==555 & clasificador=="2.3.2.01.02.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=49253		if sec_func==555 & clasificador=="2.3.2.01.02.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=100		if sec_func==555 & clasificador=="2.3.2.01.02.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=19900		if sec_func==555 & clasificador=="2.3.2.04.03.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=13775		if sec_func==555 & clasificador=="2.3.2.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=0		 	if sec_func==555 & clasificador=="2.3.2.05.01.04" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=590 		if sec_func==555 & clasificador=="2.3.2.06.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=258567	if sec_func==555 & clasificador=="2.3.2.07.07.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=425 		if sec_func==555 & clasificador=="2.3.2.07.11.02" & _n==1
// *bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.07.11.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=93500		if sec_func==555 & clasificador=="2.3.2.07.13.98" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=457055	if sec_func==555 & clasificador=="2.3.2.09.01.01" & _n==1
// *bys sec_func fuente_financ clasificador: replace ProgOctDU11yFort=1459715	if sec_func==555 & clasificador=="2.3.2.09.01.01" & _n==1
//
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=2500000	if sec_func==555 & clasificador=="2.3.1.03.01.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=48150		if sec_func==555 & clasificador=="2.3.1.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=600000 	if sec_func==555 & clasificador=="2.3.1.06.01.03" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=60000		if sec_func==555 & clasificador=="2.3.2.01.02.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=80000		if sec_func==555 & clasificador=="2.3.2.01.02.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=100		if sec_func==555 & clasificador=="2.3.2.01.02.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=392000	if sec_func==555 & clasificador=="2.3.2.04.03.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=60000		if sec_func==555 & clasificador=="2.3.2.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=0		 	if sec_func==555 & clasificador=="2.3.2.05.01.04" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.06.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=570597	if sec_func==555 & clasificador=="2.3.2.07.07.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.07.11.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=337305	if sec_func==555 & clasificador=="2.3.2.07.13.98" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgNovDU11yFort=722883	if sec_func==555 & clasificador=="2.3.2.09.01.01" & _n==1
//
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=3500000	if sec_func==555 & clasificador=="2.3.1.03.01.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=68150		if sec_func==555 & clasificador=="2.3.1.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0		 	if sec_func==555 & clasificador=="2.3.1.06.01.03" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=80000		if sec_func==555 & clasificador=="2.3.2.01.02.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=80000		if sec_func==555 & clasificador=="2.3.2.01.02.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=100		if sec_func==555 & clasificador=="2.3.2.01.02.99" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=4000000	if sec_func==555 & clasificador=="2.3.2.04.03.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=60000		if sec_func==555 & clasificador=="2.3.2.05.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=527664	if sec_func==555 & clasificador=="2.3.2.05.01.04" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.06.01.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0			if sec_func==555 & clasificador=="2.3.2.07.07.01" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0 		if sec_func==555 & clasificador=="2.3.2.07.11.02" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=0			if sec_func==555 & clasificador=="2.3.2.07.13.98" & _n==1
// bys sec_func fuente_financ clasificador: replace ProgDicDU11yFort=772038	if sec_func==555 & clasificador=="2.3.2.09.01.01" & _n==1
//
// bys sec_func2 clasificador: replace ProgSetDU11yFort=400000	if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.2.03.02.03" & _n==1 // 2.3 OBRA
// bys sec_func2 clasificador: replace ProgSetDU11yFort=0 		if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.8.01.03.01" & _n==1 // 3.1 ET
// bys sec_func2 clasificador: replace ProgSetDU11yFort=30000	if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.8.01.04.03" & _n==1 // 4.3 SUP
//
// bys sec_func2 clasificador: replace ProgOctDU11yFort=1247235.592 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.2.03.02.03" & _n==1
// bys sec_func2 clasificador: replace ProgOctDU11yFort=60000		 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.8.01.03.01" & _n==1
// bys sec_func2 clasificador: replace ProgOctDU11yFort=138581.7325 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.8.01.04.03" & _n==1
//
// bys sec_func2 clasificador: replace ProgNovDU11yFort=35270933.28 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.2.03.02.03" & _n==1
// bys sec_func2 clasificador: replace ProgNovDU11yFort=513962		 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.8.01.03.01" & _n==1
// bys sec_func2 clasificador: replace ProgNovDU11yFort=3918992.587 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.8.01.04.03" & _n==1
//
// bys sec_func2 clasificador: replace ProgDicDU11yFort=26120585.54 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.2.03.02.03" & _n==1
// bys sec_func2 clasificador: replace ProgDicDU11yFort=0 			 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.8.01.03.01" & _n==1
// bys sec_func2 clasificador: replace ProgDicDU11yFort=2902287.283 if sec_func2=="IOARRs DE EMERGENCIA" & clasificador=="2.6.8.01.04.03" & _n==1

preserve
	import excel using "ProgDU11yFort_vf.xlsx", clear firstrow
	drop if sec_func2==""
	keep sec_func2 clasificador nro ProgSetDU11yFort ProgOctDU11yFort ProgNovDU11yFort ProgDicDU11yFort
	save "tmp_DU11yFort.dta", replace
restore

bys sec_func2 clasificador: gen nro=_n

merge 1:1 sec_func2 clasificador nro using "tmp_DU11yFort.dta", nogen
drop nro

copy "completo_gasto_siafol_XXXX2023_XXXX.xlsx" "completo_${archivo_ppto}x", replace public

export excel using "completo_${archivo_ppto}x", sheetmodify sheet(BD) cell(A2)
*export excel using "completo_${archivo_ppto}x", sheetmodify sheet(BD) first(var) cell(A1)
*export excel using "completo_${archivo_ppto}x", replace sheet(BD) first(var)

cap erase "tmp_cert.dta"
cap erase "tmp_compa.dta"
cap erase "tmp_metas.dta"
cap erase "tmp_DU11yFort.dta"
