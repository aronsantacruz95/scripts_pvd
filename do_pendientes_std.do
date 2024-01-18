clear all
set more off
set rmsg on, permanently

glo fecha "1801241700"

cd "C:\Users\servpres_16\Documents\aron\Data\"

// STD PVD

import excel using "ReportePendientes_OPP_${fecha}.xlsx", clear cellra(A4) first
replace Trámite=NºDocOrigen if Trámite==""
replace Copia="COPIA" if Copia=="COPIA A TRABAJADOR"

gen id1=Trámite+Copia
duplicates tag id1, gen(dup_tmp1)
duplicates tag id1 Est, gen(dup_tmp2)
drop if Est=="Pendiente" & dup_tmp1>dup_tmp2
drop dup_tmp1 dup_tmp2
duplicates tag Trámite, gen(dup_tmp1) // se puede borrar

duplicates drop id1, force
duplicates r Trámite
duplicates tag Trámite, gen(dup)
drop if dup>0 & Copia=="COPIA"

gen Congreso=""
replace Congreso="CONGRESO" if strpos(NºDocOrigen,"-CR")
replace Congreso="CONGRESO" if strpos(NºDocOrigen,"/CR")
replace Congreso="CONGRESO" if strpos(NºDocOrigen,".CR")
replace Congreso="NO" if Congreso==""
replace Congreso="NO" if strpos(NºDocOrigen,"-MTC")

ren NºDocOrigen Doc

keep Trámite Asignado Asunto FechDocOrigen Asignadoen Copia Congreso Doc
ren Trámite HR_PVD

save "tmp_std_pvd.dta", replace

// STD MTC

import excel using "ReporteMTC_OPP_${fecha}.xlsx", clear first
ren Observaciónúltimoquederivó HR_PVD
ren HojadeRuta HR_MTC
replace HR_PVD=HR_MTC if HR_PVD==""
duplicates drop HR_PVD, force
gen Congreso="NO"
replace Congreso="CONGRESO" if Remitente=="CONGRESO DE LA REPÚBLICA"
ren Númerodedocumento Doc
keep HR_MTC Fechadecreación Remitente Asunto HR_PVD Congreso Doc

merge 1:1 HR_PVD using "tmp_std_pvd.dta"

gen Categoría=""
replace Categoría="Trámites Internos PVD Pendientes" if _merge==2 & Categoría==""
replace Categoría="Trámites MTC Pendientes en STD PVD" if _merge==3 & Categoría==""
replace Categoría="Trámites MTC Pendientes no está en STD PVD" if HR_MTC==HR_PVD & Categoría==""
replace Categoría="Trámites MTC Atendidos o Derivados" if _merge==1 & Categoría==""

replace FechDocOrigen=Fechadecreación if FechDocOrigen==.
drop Fechadecreación

order HR_PVD HR_MTC Doc Congreso Asunto FechDocOrigen Asignadoen Asignado Categoría
keep HR_PVD HR_MTC Doc Congreso Asunto FechDocOrigen Asignadoen Asignado Categoría
sort FechDocOrigen Asignadoen

ren FechDocOrigen Fecha_Origen
ren Asignadoen Fecha_Asignación
replace Asignado=">>PENDIENTE DE ASIGNACIÓN<<" if Asignado=="" & inlist(Categoría,"Trámites Internos PVD Pendientes","Trámites MTC Pendientes en STD PVD")
replace Asignado=">>PENDIENTE DE RECEPCIÓN<<" if Asignado=="" & Categoría=="Trámites MTC Pendientes no está en STD PVD"
replace Asignado=">>ATENDIDO O DERIVADO<<" if Asignado=="" & Categoría=="Trámites MTC Atendidos o Derivados"
replace HR_PVD="" if Categoría=="Trámites MTC Pendientes no está en STD PVD"

drop Categoría

gen STD=""
replace STD="PVD" if HR_PVD!=""
replace STD="MTC" if HR_MTC!=""
replace STD="MTC+PVD" if HR_PVD!="" & HR_MTC!=""

gen Aviso_Congreso=""
order Aviso_Congreso, after(Congreso)

export excel using "reporte_pendientes_${fecha}.xlsx", replace first(var) sheet(BD) // 100 COL ASUNTO
cap erase "tmp_std_pvd.dta"
putexcel set "reporte_pendientes_${fecha}.xlsx", sheet(BD) modify
putexcel E2 = `"=SI(D2="CONGRESO";SI(DIAS.LAB.INTL(G2;HOY();1;{"1/01/2024";"28/03/2024";"29/03/2024";"1/05/2024";"7/06/2024";"29/06/2024";"23/07/2024";"28/07/2024";"29/07/2024";"6/08/2024";"30/08/2024";"8/10/2024";"1/11/2024";"8/12/2024";"9/12/2024";"25/12/2024"})>8;        "VCTO. "&TEXTO(DIA.LAB.INTL(G2;8;1;{"1/01/2024";"28/03/2024";"29/03/2024";"1/05/2024";"7/06/2024";"29/06/2024";"23/07/2024";"28/07/2024";"29/07/2024";"6/08/2024";"30/08/2024";"8/10/2024";"1/11/2024";"8/12/2024";"9/12/2024";"25/12/2024"});"dd/mm/yyyy")&" - "&TEXTO(DIAS.LAB.INTL(G2;HOY();1;{"1/01/2024";"28/03/2024";"29/03/2024";"1/05/2024";"7/06/2024";"29/06/2024";"23/07/2024";"28/07/2024";"29/07/2024";"6/08/2024";"30/08/2024";"8/10/2024";"1/11/2024";"8/12/2024";"9/12/2024";"25/12/2024"})-9;"00")&" DIAS DE ATRASO";          "VCTO. "&TEXTO(DIA.LAB.INTL(G2;8;1;{"1/01/2024";"28/03/2024";"29/03/2024";"1/05/2024";"7/06/2024";"29/06/2024";"23/07/2024";"28/07/2024";"29/07/2024";"6/08/2024";"30/08/2024";"8/10/2024";"1/11/2024";"8/12/2024";"9/12/2024";"25/12/2024"});"dd/mm/yyyy"));"-")"'
