clear all
run "dataset_jae.do"

*graphs reforms, and fiscal policy stance and reforms

* Fiscal policy stance
* bins
gen tight = BP_adj_exp==1 if BP_adj_exp!=.
gen neutral = BP_adj_exp==0 if BP_adj_exp!=.
gen loose = BP_adj_exp==-1 if BP_adj_exp!=.

* Fiscal policy stance and reforms (Figure 1)
label var ref_interaction "Product & labour market reform"
label var lab_ref "Labour market reform"
label var prod_ref "Product market reform"

replace lab_ref=2 if lab_ref==1 & ref_interaction==0
replace prod_ref=2 if prod_ref==1 & ref_interaction==0
replace ref_interaction=2 if ref_interaction==1

xtline prod_ref lab_ref ref_interaction tight neutral loose if year>1984 & year<2014, recast(bar) yscale(off) byopts(noyrescale noiyaxes noiytick noiylabel noiytitle) legend(size(small))

*Product market reforms (figure A1.1)
replace Electricity=0 if Electricity==-1 
replace Gas=0 if Gas==-1 
replace Telecommunications=0 if Telecommunications==-1 
replace PostalServices=0 if PostalServices==-1 
replace RailTransport=0 if RailTransport==-1 
replace AirTransport=0 if AirTransport==-1 
replace RoadTransport=0 if RoadTransport==-1

replace Electricity=7 if Electricity==1 
replace Gas=6 if Gas==1 
replace Telecommunications=5 if Telecommunications==1 
replace PostalServices=4 if PostalServices==1 
replace RailTransport=3 if RailTransport==1 
replace AirTransport=2 if AirTransport==1 
replace RoadTransport=1 if RoadTransport==1

xtline Electricity Gas Telecommunications PostalServices RailTransport AirTransport RoadTransport if year>1984, recast(bar) yscale(off) byopts(noyrescale noiyaxes noiytick noiylabel noiytitle) legend(size(small))

* Labour market reforms (figure A1.2)
replace EPLregularworkers=0 if EPLregularworkers==-1 
replace EPLtemporaryworkers=0 if EPLtemporaryworkers==-1 
replace Unemploymentbenefitsoverall=0 if Unemploymentbenefitsoverall==-1 
replace Unemploymentbenefitsreplaceme=0 if Unemploymentbenefitsreplaceme==-1 
replace Unemploymentbenefitsduration=0 if Unemploymentbenefitsduration==-1 

replace EPLregularworkers=5 if EPLregularworkers==1 
replace EPLtemporaryworkers=4 if EPLtemporaryworkers==1 
replace Unemploymentbenefitsoverall=3 if Unemploymentbenefitsoverall==1 
replace Unemploymentbenefitsreplaceme=2 if Unemploymentbenefitsreplaceme==1 
replace Unemploymentbenefitsduration=1 if Unemploymentbenefitsduration==1 


xtline EPLregularworkers EPLtemporaryworkers Unemploymentbenefitsoverall  Unemploymentbenefitsreplaceme Unemploymentbenefitsduration if year>1984, recast(bar) yscale(off) byopts(noyrescale noiyaxes noiytick noiylabel noiytitle) legend(size(small))

* Fiscal policy stance and reforms Alesina type (Figure A1.3) 
drop tight neutral loose
gen tight = alesina_adj==1 if alesina_adj!=.
gen neutral = alesina_adj==0 & alesina_exp==0
gen loose = alesina_exp==1 if alesina_exp!=.

label var ref_interaction "Product & labour market reform"
label var lab_ref "Labour market reform"
label var prod_ref "Product market reform"

replace lab_ref=2 if lab_ref==1 & ref_interaction==0
replace prod_ref=2 if prod_ref==1 & ref_interaction==0
replace ref_interaction=2 if ref_interaction==1

xtline prod_ref lab_ref ref_interaction tight neutral loose if year>1984 & year<2014, recast(bar) yscale(off) byopts(noyrescale noiyaxes noiytick noiylabel noiytitle) legend(size(small))



****** Balancning tests 
* product market
clear all
run "dataset_jae.do"
sort identifier year
reg ly1 l(0/5).prod_ref l(0/1).lab_ref outpg l(0/1).dly gcf_gdp g_hc f(1/1).prod_ref f(1/1).lab_ref


foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref  Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_treat_prod=`var' if prod_ref==1 & e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_control_prod=`var' if prod_ref==0 & e(sample)
}
 
ttest outpg_treat_prod = outpg_control_prod if e(sample), unpaired unequal
ttest dly_treat_prod = dly_control_prod  if e(sample), unpaired unequal   
ttest gcf_gdp_treat_prod = gcf_gdp_control_prod  if e(sample), unpaired unequal 
ttest g_hc_treat_prod = g_hc_control_prod  if e(sample), unpaired unequal 
 


** conditional of fiscal stance
*tight
clear all
run "dataset_jae.do"
sort identifier year

reg ly1 l(0/5).prod_ref l(0/1).lab_ref outpg l(0/1).dly gcf_gdp g_hc f(1/1).prod_ref f(1/1).lab_ref if BP_adj_exp==1


foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref  Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_treat_prod=`var' if prod_ref==1 & e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_control_prod=`var' if prod_ref==0 & e(sample)
}

ttest outpg_treat_prod = outpg_control_prod if e(sample), unpaired unequal
ttest dly_treat_prod = dly_control_prod  if e(sample), unpaired unequal   
ttest gcf_gdp_treat_prod = gcf_gdp_control_prod  if e(sample), unpaired unequal 
ttest g_hc_treat_prod = g_hc_control_prod  if e(sample), unpaired unequal 
 
*neutral
clear all
run "dataset_jae.do"
sort identifier year

reg ly1 l(0/5).prod_ref l(0/1).lab_ref outpg l(0/1).dly gcf_gdp g_hc f(1/1).prod_ref f(1/1).lab_ref if BP_adj_exp==0


foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref  Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_treat_prod=`var' if prod_ref==1 & e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_control_prod=`var' if prod_ref==0 & e(sample)
}

ttest outpg_treat_prod = outpg_control_prod if e(sample), unpaired unequal
ttest dly_treat_prod = dly_control_prod  if e(sample), unpaired unequal   
ttest gcf_gdp_treat_prod = gcf_gdp_control_prod  if e(sample), unpaired unequal 
ttest g_hc_treat_prod = g_hc_control_prod  if e(sample), unpaired unequal 
 

*loose
clear all
run "dataset_jae.do"
sort identifier year

reg ly1 l(0/5).prod_ref l(0/1).lab_ref outpg l(0/1).dly gcf_gdp g_hc f(1/1).prod_ref f(1/1).lab_ref if BP_adj_exp==-1


foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref  Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_treat_prod=`var' if prod_ref==1 & e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_control_prod=`var' if prod_ref==0 & e(sample)
}

ttest outpg_treat_prod = outpg_control_prod if e(sample), unpaired unequal
ttest dly_treat_prod = dly_control_prod  if e(sample), unpaired unequal   
ttest gcf_gdp_treat_prod = gcf_gdp_control_prod  if e(sample), unpaired unequal 
ttest g_hc_treat_prod = g_hc_control_prod  if e(sample), unpaired unequal 
 

** Labour market
clear all
run "dataset_jae.do"
sort identifier year

reg ly1 l(0/5).prod_ref l(0/1).lab_ref outpg l(0/1).dly gcf_gdp g_hc f(1/1).prod_ref f(1/1).lab_ref if BP_adj_exp==-1

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref  Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_treat_lab=`var' if lab_ref==1 & e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_control_lab=`var' if lab_ref==0 & e(sample)
}

ttest outpg_treat_lab = outpg_control_lab if e(sample), unpaired unequal
ttest dly_treat_lab = dly_control_lab  if e(sample), unpaired unequal   
ttest gcf_gdp_treat_lab = gcf_gdp_control_lab  if e(sample), unpaired unequal 
ttest g_hc_treat_lab = g_hc_control_lab  if e(sample), unpaired unequal 
 
*tight
clear all
run "dataset_jae.do"
sort identifier year

reg ly1 l(0/5).prod_ref l(0/1).lab_ref outpg l(0/1).dly gcf_gdp g_hc f(1/1).prod_ref f(1/1).lab_ref if BP_adj_exp==1

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref  Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_treat_lab=`var' if lab_ref==1 & e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_control_lab=`var' if lab_ref==0 & e(sample)
}

ttest outpg_treat_lab = outpg_control_lab if e(sample), unpaired unequal
ttest dly_treat_lab = dly_control_lab  if e(sample), unpaired unequal   
ttest gcf_gdp_treat_lab = gcf_gdp_control_lab  if e(sample), unpaired unequal 
ttest g_hc_treat_lab = g_hc_control_lab  if e(sample), unpaired unequal 

*Neutral
clear all
run "dataset_jae.do"
sort identifier year

reg ly1 l(0/5).prod_ref l(0/1).lab_ref outpg l(0/1).dly gcf_gdp g_hc f(1/1).prod_ref f(1/1).lab_ref if BP_adj_exp==0

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref  Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_treat_lab=`var' if lab_ref==1 & e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_control_lab=`var' if lab_ref==0 & e(sample)
}

ttest outpg_treat_lab = outpg_control_lab if e(sample), unpaired unequal
ttest dly_treat_lab = dly_control_lab  if e(sample), unpaired unequal   
ttest gcf_gdp_treat_lab = gcf_gdp_control_lab  if e(sample), unpaired unequal 
ttest g_hc_treat_lab = g_hc_control_lab  if e(sample), unpaired unequal 

*Loose
clear all
run "dataset_jae.do"
sort identifier year

reg ly1 l(0/5).prod_ref l(0/1).lab_ref outpg l(0/1).dly gcf_gdp g_hc f(1/1).prod_ref f(1/1).lab_ref if BP_adj_exp==-1


foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref  Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_treat_lab=`var' if lab_ref==1 & e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 l_prod_ref l_lab_ref Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
gen `var'_control_lab=`var' if lab_ref==0 & e(sample)
}

ttest outpg_treat_lab = outpg_control_lab if e(sample), unpaired unequal
ttest dly_treat_lab = dly_control_lab  if e(sample), unpaired unequal   
ttest gcf_gdp_treat_lab = gcf_gdp_control_lab  if e(sample), unpaired unequal 
ttest g_hc_treat_lab = g_hc_control_lab  if e(sample), unpaired unequal  

