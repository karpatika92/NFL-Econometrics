clear
import excel "C:\Users\karpatika\Documents\RAJK\ÖKO BESZÁMOLÓ\NFL DATABASE 2003-2008_OK_final_popec.xlsx", sheet("DB_FINAL") firstrow
cd "C:\Users\karpatika\Documents\RAJK\ÖKO BESZÁMOLÓ\"
destring,replace

destring PCT2, replace force dpcomma
drop if ContractValue==0
g LNCV=ln(ContractValue)
*************jáccott-e?*****************
g played=0
replace played=1 if YearsinNFL>0
g played4=0
replace played4=1 if YearsinNFL>2
********MOBILITÁS**********
gen mobility=Weightlbs/Yard
g freq=1
graph bar (count) freq, over(College)
scatter No mobility 
graph export no_mobility.png, replace
graph twoway (lfit LNCV mobility) (scatter LNCV mobility)
graph export c_mobility.png, replace
hist mobility
graph export hist_mobility.png, replace
**********Általános leíró***************
hist YearsinNFL
graph export years.png, replace
hist No
tabulate played played4
 tabstat No RAT2 PCT2 Yard Weightlbs YDSA2 LNCV mobility, by(played4) stat(mean sd min max) save
 return list
 matrix cucc1=r(Stat1)
 matrix cucc2=r(Stat2)
 matrix cucc3=r(StatTotal)
putexcel b3=matrix(cucc1) using leiro.xls, sheet ("tabstat") modify
putexcel b7=matrix(cucc2) using leiro.xls, sheet ("tabstat") modify
putexcel b11=matrix(cucc3) using leiro.xls, sheet ("tabstat") modify 

foreach var of varlist No RAT2 PCT2 Yard Weightlbs YDSA2 LNCV mobility  {
egen std`var'=std(`var')
}

graph box stdNo stdRAT2  stdPCT2  stdYDSA2 stdmobility , over(played4, sort(played4))
graph export draftbox.png, replace
****DRAFT LEÍRÓ******
/*
hist RAT2
graph export rat_2.png, replace
hist Yard
graph export 40Yard.png, replace
hist Weightlbs
graph export weigth.png, replace
hist PCT2
graph export pct.png, replace
hist YDSA2
graph export YDS_A.png, replace

scatter No RAT2
graph export no_rat.png, replace
scatter LNCV RAT2
graph export c_rat.png, replace

scatter No Yard
graph export no_40yard.png, replace

scatter LNCV Yard
graph export c_40yard.png, replace
scatter No Weightlbs
graph export no_weigth.png, replace

scatter LNCV Weightlbs
graph export c_weigth.png, replace
scatter No PCT2
graph export no_pct.png, replace

scatter LNCV PCT2
graph export c_pct.png, replace
scatter No YDSA2
graph export no_ydsa.png, replace

scatter LNCV YDSA2
graph export c_YDSA.png, replace

scatter LNCV No
graph export CV_No.png, replace
*/
drop AT BL CD CV DN EF EX FP GH

**************DRAFT ELEMZÉS****************

********Hiányzó lukak kitömése*********
g rat_agg=RAT2
replace rat_agg=RAT1 if rat_agg==.
g pct_agg=PCT2
replace pct_agg=PCT1 if pct_agg==.
g yda_agg=YDSA2
replace yda_agg=YDSA1 if yda_agg==.
g comp_agg=COMP2
replace comp_agg=COMP1 if comp_agg==.
g int_agg=INT2
replace int_agg=INT1 if int_agg==.
g int_pc=int_agg/comp_agg
hist int_pc
/*
scatter pct_agg No
graph export pct_no.png, replace

scatter int_pc No
graph export int_no.png, replace

scatter rat_agg No
graph export rat_no.png, replace

scatter pct_agg LNCV
graph export pct_pcv.png, replace

scatter int_pc LNCV
graph export int_cv.png, replace

scatter rat_agg LNCV
graph export rat_cv.png, replace
*/
******Adatok elmentése*********
save mindenadat, replace


*********magyarázott változó: No; minél kisebb annál jobb******

************************Sok kontrolll*************************
use mindenadat
reg No mobility
outreg2 using "draftreg.xls", replace ctitle("No - Mobility - Multiple")
reg No mobility pct_agg yda_agg int_pc
outreg2 using "draftreg.xls", append ctitle("No - Mobility with College Controls - Multiple")

reg No mobility pct_agg yda_agg int_pc i.YearofDRAFT Yard 
outreg2 using "draftreg.xls", append ctitle("No - Mobility with College & Draftyear Controls")

*****Sorrend becslés*********
reg No mobility pct_agg yda_agg int_pc i.YearofDRAFT Yard if YearofDRAFT < 2016
predict NoHat_reg if YearofDRAFT == 2016
poisson No mobility pct_agg yda_agg int_pc i.YearofDRAFT Yard if YearofDRAFT < 2016
predict NoHat_poi if YearofDRAFT == 2016
reg LNCV mobility pct_agg yda_agg int_pc i.YearofDRAFT Yard if YearofDRAFT < 2016
predict LNCVHat_reg if YearofDRAFT == 2016


*******************************Csak rating******************************************
reg No mobility rat_agg
outreg2 using "draftreg.xls", append ctitle("No - Mobility with College Controls - RAT")

reg No mobility rat_agg i.YearofDRAFT Yard 
outreg2 using "draftreg.xls", append ctitle("No - Mobility with College & Draftyear Controls - RAT")

corr LNCV No
g draftin=1/No
g lndraft=ln(Player)
corr LNCV draftin
corr LNCV lndraft if lndraft>=0
scatter draftin LNCV
graph export draftinlnvc.png, replace
***********magyarázott változó: CONTRACT VALUE*********************
reg LNCV mobility
outreg2 using "draftreg.xls", append ctitle("Contract Value - Mobility")

reg LNCV mobility pct_agg yda_agg int_pc
outreg2 using "draftreg.xls", append ctitle("Contract Value - Mobility with College Controls")

reg LNCV mobility pct_agg yda_agg int_pc i.YearofDRAFT Yard 
outreg2 using "draftreg.xls", append ctitle("Contract Value - Mobility with College & Draftyear Controls")
********************************
*********************LNCV - RAT*****************
reg LNCV mobility rat_agg
outreg2 using "draftreg.xls", append ctitle("Contract Value - Mobility with College Controls - RAT")

reg LNCV mobility rat_agg i.YearofDRAFT Yard 
outreg2 using "draftreg.xls", append ctitle("Contract Value - Mobility with College & Draftyear Controls - RAT")
**********************MÓR***********************
reg No mobility pct_agg yda_agg int_pc i.YearofDRAFT Yard 
des No
************************SORT Spearman rangkorreláció*****************************

*******************************
*******************************draftteameff****
tab YearofDRAFT played4
preserve
keep if YearofDRAFT<2016
probit played4 rat_agg  LNCV mobility i.YearofDRAFT Draftteameff
outreg2 using "probit.xls", replace ctitle("Probit")
logit played4 rat_agg  LNCV mobility i.YearofDRAFT Draftteameff
outreg2 using "probit.xls", replace ctitle("Logit")
reg played4 rat_agg  LNCV mobility i.YearofDRAFT Draftteameff
outreg2 using "probit.xls", replace ctitle("Linear Probability Model")

restore
***panel értelmezés*********
reshape long Exper COMP ATT PCT YDS FUML YDSA TD_ INT QBRAT Team Teameff SACK FUM YDSL YG RUSH RAVG RYDS RYG_ , i(Name) j(time)
encode Name, gen(id)
xtset  id time

**********szarok kidobálása
*drop if QBRAT==.
*drop if QBRAT==0
capture drop year
g year=YearofDRAFT+t-4
g inNFL=0
replace inNFL=1 if t>2
****************kéne egy olyan, hogy hány éve játszik adott évben az NFLben
*********NFL descriptive**********************
/*hist QBRAT
scatter QBRAT LNCV if inNFL==1
graph export qbratLNCV.png, replace
graph twoway (lfit QBRAT RAT2) (scatter QBRAT RAT2)
graph export qbrrat.png, replace*/
**************Above agerage QBR***********
bysort t: egen QBRAT_avg=median(QBRAT)
capture gen aavg=QBRAT>QBRAT_avg
capture gen FUM_A=FUM/ATT
capture gen SACK_A=SACK/ATT
capture gen INT_A=INT/A
capture gen TD_A=TD/A
tabstat No ATT PCT TD_A Yard Weightlbs YDSA LNCV mobility RAVG SACK_A FUM_A INT_A YDSL RYG_, by(aavg) stat(mean sd min max) save
 return list
 matrix cucc1=r(Stat1)
 matrix cucc2=r(Stat2)
 matrix cucc3=r(StatTotal)
putexcel b3=matrix(cucc1) using leiro_NFL.xls, sheet ("tabstat") modify
putexcel b7=matrix(cucc2) using leiro_NFL.xls, sheet ("tabstat") modify
putexcel b11=matrix(cucc3) using leiro_NFL.xls, sheet ("tabstat") modify 

*****************************************************************
***********NFL teljesítmény becslQ függvény**********************
**************************************************
*******************NFL leíró ismét***************
hist QBRAT
scatter Exper QBRAT
scatter Teameff QBRAT
scatter Player QBRAT
scatter No QBRAT
*******Magyarázott: QBRAT **********************
xtreg QBRAT No Exper Teameff i.t if t>2
xtreg QBRAT LNCV Exper Teameff i.t if t>2
xtreg QBRAT No Exper Teameff i.t if t>2
