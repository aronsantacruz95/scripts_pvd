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

glo fecha "03052023"

glo archivo_ppto        "gasto_siafol_${fecha}_0800.xls" // archivo de ejecución presupuestal
glo archivo_cert   "gasto_cert_siafol_${fecha}_0800.xls" // archivo de certificacion
glo archivo_compa "gasto_compa_siafol_${fecha}_0800.xls" // archivo de compromiso anual
glo archivo_metas 		"metas_siafol_${fecha}_0800.xls" // archivo de metas físicas

cd "C:\Users\a\Documents\aron\Data\"

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

// ppto

import excel using "${archivo_ppto}", clear first
drop if sec_func==0
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
merge m:1 sec_func using "tmp_metas.dta", nogen update replace
drop id_ppto
drop mto_certificado mto_compro_anual
egen double mto_certificado	=rowtotal(		mto_cert_01 -	mto_cert_12)
egen double mto_at_compro	=rowtotal(	 mto_at_comp_01 -mto_at_comp_12)
egen double mto_compro_anual=rowtotal(	   mto_compa_01 -  mto_compa_12)
egen double mto_devengado	=rowtotal(	 mto_devenga_01 -mto_devenga_12)
egen double mto_girado		=rowtotal(	  mto_girado_01 - mto_girado_12)
egen double mto_pagado		=rowtotal(	  mto_pagado_01 - mto_pagado_12)

order mto_pia mto_modificaciones mto_pim mto_cert_* mto_certificado mto_at_comp_* mto_at_compro mto_compa_* mto_compro_anual mto_devenga_* mto_devengado mto_girado_* mto_girado mto_pagado_* mto_pagado, last

recode mto_pia-mto_pagado (.=0)

gen tmp_1="2"
egen clasificador=concat(tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6), p(".")
order clasificador, before(mto_pia)
drop tmp_*

gen cui=substr(producto_proyecto,1,7)
order cui, before(producto_proyecto)
destring cui, replace

export excel using "completo_${archivo_ppto}x", replace sheet(BD) first(var)
cap erase "tmp_cert.dta"
cap erase "tmp_compa.dta"
cap erase "tmp_metas.dta"
