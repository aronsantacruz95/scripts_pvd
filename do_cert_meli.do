clear all
set more off

glo xfile "hoja_20231019_115540.xls"

cd "C:\Melissa30\WorkBooks"

import excel using "${xfile}", clear

gen FF=B+". "+C if inlist(B,"1","2","3","4","5")
gen CUI=subinstr(C,".","",.)
replace CUI="" if FF!=""
gen Proyecto=subinstr(C,".","",.)+". "+D if inlist(substr(C,1,1),"2","3")
gen AAO=subinstr(D,".","",.)+". "+E if inlist(substr(D,1,1),"4","5","6")
gen Meta=E if length(E)==4
gen Desc_meta=G if G!="" & substr(G,1,1)!="2"
gen Clasif=G if substr(G,1,1)=="2"
gen Desc_clasif=G+". "+H if substr(G,1,1)=="2"
gen CER=H if substr(H,1,4)=="CER-"
replace CER="CER-XXXXX" if CER=="" & H!="" & J!="" & K!=""
gen Glosa=I if substr(CER,1,4)=="CER-"

gen PIA=J if substr(CER,1,4)=="CER-"
gen PIM=K if substr(CER,1,4)=="CER-"
gen Cert=L if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
gen Comp=M if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
*gen CompM=N if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
*gen Dev=O if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
gen Dev=N if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"

keep FF CUI Proyecto AAO Meta Desc_meta Clasif Desc_clasif CER Glosa PIA PIM Cert Comp /* CompM */ Dev

foreach x of varlist FF CUI Proyecto AAO Meta Desc_meta Clasif Desc_clasif {
	replace `x'=`x'[_n-1] if `x'==""
}
drop if CER==""
destring PIA PIM Cert Comp Dev, replace
recode PIA PIM Cert Comp Dev (.=0)

drop if PIA==0 & PIM==0 & Cert==0 & Comp==0 & Dev==0

gen Partida="LIBERADA"

replace Partida="RESTRINGIDA" if substr(CUI,1,1)=="2"
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.1.1."		)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.1.3."		)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.2.1."		)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.1.6."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.1.11."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.2.1."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.2.2."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.2.4."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.4."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.7.1."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.7.2."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.7.11.99")==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.8.1."	)==1
replace Partida="RESTRINGIDA" if strpos(Clasif,"2.3.2.8.1.2")==1

replace Partida="RESTRINGIDA" if strpos(AAO,"5006269")==1
replace Partida="RESTRINGIDA" if strpos(AAO,"5006373")==1
replace Partida="RESTRINGIDA" if strpos(AAO,"6000050")==1
replace Partida="RESTRINGIDA" if strpos(AAO,"6000051")==1
replace Partida="RESTRINGIDA" if strpos(AAO,"4000221")==1

replace Partida="RESTRINGIDA" if inlist(CUI,"3000132","3000133")
destring CUI, replace

replace Partida="RESTRINGIDA" if inlist(Meta,"0554","0555")
destring Meta, replace

cd "C:\Users\servpres_16\Documents\aron\Data"

local dhm=substr("${xfile}",8,11)
di "`dhm'"
export excel using "ejec_cert_`dhm'.xlsx", replace first(var) sheet(BD)
