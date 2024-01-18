clear all
set more off

glo xfile "hoja_20240116_181352.xls"

cd "C:\Melissa30\WorkBooks"

import excel using "${xfile}", clear

gen FF=B+". "+C if inlist(B,"1","2","3","4","5")
gen CUI=subinstr(C,".","",.) if inlist(substr(C,1,1),"2","3")
gen AAO=subinstr(D,".","",.) if inlist(substr(D,1,1),"4","5","6")
gen Meta=E if length(E)==4
gen Clasif=E if substr(E,1,1)=="2"
gen CER=E if substr(E,1,4)=="CER-"
replace CER="CER-XXXXX" if CER=="" & G!="" & H!="" & substr(E,1,1)=="2"
gen Glosa=F if substr(CER,1,4)=="CER-"

gen PIA=G if substr(CER,1,4)=="CER-"
gen PIM=H if substr(CER,1,4)=="CER-"
gen Cert=I if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
gen CompA=J if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
gen CompM=K if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
gen Dev01=L if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev02=M if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev03=N if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev04=O if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev05=P if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev06=Q if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev07=R if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev08=S if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev09=T if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev10=U if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev11=V if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"
// gen Dev12=W if substr(CER,1,4)=="CER-" & CER!="CER-XXXXX"

keep FF CUI AAO Meta Clasif CER Glosa PIA PIM Cert CompA CompM Dev*

foreach x of varlist FF CUI AAO Meta Clasif {
	replace `x'=`x'[_n-1] if `x'==""
}
drop if CER==""

destring PIA PIM Cert Comp* Dev*, replace
recode PIA PIM Cert Comp* Dev* (.=0)
drop if PIA==0 & PIM==0 & Cert==0 & CompA==0 & CompM==0

cd "C:\Users\servpres_16\Documents\aron\Data"

local dhm=substr("${xfile}",8,11)
di "`dhm'"
export excel using "ejec_cert_`dhm'.xlsx", replace first(var) sheet(BD) cell(A2)

putexcel set "ejec_cert_`dhm'.xlsx", sheet(BD) modify
putexcel H1 = "=SUBTOTALES(9;H3:H10000)"
putexcel I1 = "=SUBTOTALES(9;I3:I10000)"
putexcel J1 = "=SUBTOTALES(9;J3:J10000)"
putexcel K1 = "=SUBTOTALES(9;K3:K10000)"
putexcel L1 = "=SUBTOTALES(9;L3:L10000)"
putexcel M1 = "=SUBTOTALES(9;M3:M10000)" // Dev01
// putexcel N1 = "=SUBTOTALES(9;N3:N10000)" // Dev02
// putexcel O1 = "=SUBTOTALES(9;O3:O10000)" // Dev03
// putexcel P1 = "=SUBTOTALES(9;P3:P10000)" // Dev04
// putexcel Q1 = "=SUBTOTALES(9;Q3:Q10000)" // Dev05
// putexcel R1 = "=SUBTOTALES(9;R3:R10000)" // Dev06
// putexcel S1 = "=SUBTOTALES(9;S3:S10000)" // Dev07
// putexcel T1 = "=SUBTOTALES(9;T3:T10000)" // Dev08
// putexcel U1 = "=SUBTOTALES(9;U3:U10000)" // Dev09
// putexcel V1 = "=SUBTOTALES(9;V3:V10000)" // Dev10
// putexcel W1 = "=SUBTOTALES(9;W3:W10000)" // Dev11
// putexcel X1 = "=SUBTOTALES(9;X3:X10000)" // Dev12
