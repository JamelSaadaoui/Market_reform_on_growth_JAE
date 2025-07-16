clear all
run "dataset_jae.do"

*ssc install xtcd2

*drop if EPLregularworkers==-1 | EPLtemporaryworkers==-1 | Unemploymentbenefitsoverall==-1 | Unemploymentbenefitsreplaceme==-1 | Unemploymentbenefitsduration==-1

** Dataset complete

* Compute simple LP for response plots
sort identifier year

capture drop sLP_prod_ref_* sLP_lab_ref_* _Year

gen sLP_prod_ref_tight =.
gen sLP_prod_ref_neutral =.
gen sLP_prod_ref_expansive =.
gen sLP_prod_ref_tightse =.
gen sLP_prod_ref_neutralse =.
gen sLP_prod_ref_expansivese =.

gen sLP_lab_ref_tight =.
gen sLP_lab_ref_neutral =.
gen sLP_lab_ref_expansive =. 
gen sLP_lab_ref_tightse =.
gen sLP_lab_ref_neutralse =.
gen sLP_lab_ref_expansivese =. 

gen _Year = _n if _n<=5
label var _Year "Year" 

* Product market reforms

forvalues i=1/5 {


	* specification: simple LP estimate (fiscal adjustment=tight)

		qui xtscc ly`i' ///
		l(0/5).prod_ref lab_ref outpg l(0/3).dly f(1/`i').prod_ref gcf_gdp g_hc if BP_adj_exp==1, fe 

replace sLP_prod_ref_tight = _b[prod_ref] if _Year==`i'
replace sLP_prod_ref_tightse = _se[prod_ref] if _Year==`i'

}


forvalues i=1/5 {


	* specification: simple LP estimate (neutral fiscal policy)

		qui xtscc ly`i' ///
		l(0/5).prod_ref lab_ref outpg l(0/3).dly f(1/`i').prod_ref gcf_gdp g_hc if BP_adj_exp==0, fe 

replace sLP_prod_ref_neutral = _b[prod_ref] if _Year==`i'
replace sLP_prod_ref_neutralse = _se[prod_ref] if _Year==`i'

}

forvalues i=1/5 {


	* specification: simple LP estimate (Fiscal expansion)
	
		qui xtscc ly`i' ///
		l(0/5).prod_ref l(0/5).lab_ref outpg l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref gcf_gdp g_hc if BP_adj_exp==-1, fe 

replace sLP_prod_ref_expansive = _b[prod_ref] if _Year==`i'
replace sLP_prod_ref_expansivese = _se[prod_ref] if _Year==`i'

}

* Labour market reform with neutral, loose and tight fiscal policy

forvalues i=1/5 {


	* specification: simple LP estimate (fiscal adjustment=tight)
	
		qui xtscc ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc if BP_adj_exp==1, fe 

replace sLP_lab_ref_tight = _b[lab_ref] if _Year==`i'
replace sLP_lab_ref_tightse = _se[lab_ref] if _Year==`i' 
		
}


forvalues i=1/5 {


	* specification: simple LP estimate (neutral fiscal policy)

		qui xtscc ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc if BP_adj_exp==0, fe 

replace sLP_lab_ref_neutral = _b[lab_ref] if _Year==`i'
replace sLP_lab_ref_neutralse = _se[lab_ref] if _Year==`i' 	

}

forvalues i=1/5 {


	* specification: simple LP estimate (Fiscal expansion)
	
		qui xtscc ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc if BP_adj_exp==-1, fe 

replace sLP_lab_ref_expansive = _b[lab_ref] if _Year==`i'
replace sLP_lab_ref_expansivese = _se[lab_ref] if _Year==`i' 

}


//Doubly robust (DR) estimation AIPW

*Controls outcome regs
global controls3 "fe_outpg fe_l3dly fe_l2dly fe_dly fe_ldly fe_gcf_gdp fe_g_hc "
* For robustness: fe_gcf_gdp fe_g_hc

global controls4 "outpg l3dly l2dly dly ldly gcf_gdp g_hc"

*logit controls prod ref
global controls_prod_ref "l_outpg ldly l2dly l3dly l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate l_yrsoffc l_any_elec l_ideol_gov l_polfrag t t2 t3 l_gcf_gdp l_g_hc"

* For robustness: l_gcf_gdp l_g_hc l_EU_outpg l_debt_burden



* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH DIFFERENT SLOPE/CFEs (beta1.NEQ.beta0)
* ATE split by bin
* no truncations (use phat0)


* bins
gen tight = BP_adj_exp==1 if BP_adj_exp!=.
gen neutral = BP_adj_exp==0 if BP_adj_exp!=.
gen expansive = BP_adj_exp==-1 if BP_adj_exp!=.

logit prod_ref $controls_prod_ref i.identifier 


* raw prscore, not truncated (pihat0)
predict pihat0


*sort again
sort identifier year
xtset identifier year

* Define variables for Impulse Response plots

capture drop LP_prod_ref_* LP_lab_ref_* _Year

gen LP_prod_ref_tight =.
gen LP_prod_ref_neutral =.
gen LP_prod_ref_expansive =.
gen LP_prod_ref_tightse =.
gen LP_prod_ref_neutralse =.
gen LP_prod_ref_expansivese =.

gen LP_lab_ref_tight =.
gen LP_lab_ref_neutral =.
gen LP_lab_ref_expansive =. 
gen LP_lab_ref_tightse =.
gen LP_lab_ref_neutralse =.
gen LP_lab_ref_expansivese =. 


************ Product market reforms, code adapted from Jorda & Taylor (2016)

capture drop a invwt
gen a=prod_ref // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat0~=. // invwt from Lunt et al.
	forvalues i=1/5 {
	
	qui reg ly`i' $controls4 

* Within transform the data	
foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc EU_outpg {
by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc EU_outpg {
by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)
}

	
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	foreach bin in tight neutral expansive {
	
		/*qui*/ reg fe_ly`i'  $controls3  l(1/5).prod_ref f(1/`i').prod_ref lab_ref [pweight=invwt] ///
			if year>1982 & year<2014 & `bin'==1 & prod_ref==0,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu0 = temp if year>1982 & year<2014 & `bin'==1  

		
		/*qui*/ reg fe_ly`i'  $controls3  l(0/5).prod_ref f(1/`i').prod_ref lab_ref [pweight=invwt] ///
			if year>1982 & year<2014 & `bin'==1 & prod_ref==1,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu1 = temp if year>1982 & year<2014 & `bin'==1  
		
		}
		
	*from Lunt et al
	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))
	generate iptw=(2*a-1)*fe_ly`i'*invwt
	generate dr1=iptw+mdiff1
	
	qui gen ATE_IPWRA_tight  = tight  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_neutral  = neutral  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_expansive  = expansive  // constant for convenience in next reg to get mean

	xtset, clear
	xi: qui reg dr1 ATE_IPWRA_tight ATE_IPWRA_neutral ATE_IPWRA_expansive, nocons vce(bootstrap, seed(234) cluster(identifier) reps(500))  
		  eststo DR6_`i' 
		  xtset identifier year
		  xtcd2
		  *estadd scalar cdt=r(CD)
		  
	capture drop iptw mdiff1 dr1 mu1 mu0 ATE_IPWRA*
	capture scalar drop dr1m
	
	
replace LP_prod_ref_tight = _b[ATE_IPWRA_tight] if _Year==`i'
replace LP_prod_ref_tightse = _se[ATE_IPWRA_tight] if _Year==`i'

replace LP_prod_ref_neutral = _b[ATE_IPWRA_neutral] if _Year==`i'
replace LP_prod_ref_neutralse = _se[ATE_IPWRA_neutral] if _Year==`i'

replace LP_prod_ref_expansive = _b[ATE_IPWRA_expansive] if _Year==`i'
replace LP_prod_ref_expansivese = _se[ATE_IPWRA_expansive] if _Year==`i'
	
	drop Mav_ly1 - fe_EU_outpg
	
	}
	
	
	*Table 7
	
esttab DR6_1 DR6_2 DR6_3 DR6_4 DR6_5 ///
	using "table7.rtf" , replace ///
	title("Table 7. ATE-IP (DR) i.p. weights, product market reforms conditional on fiscal policy") ///
	b(3) se(3) sfmt(2) obslast label scalars(cdt moransip) nonum star(* 0.10 ** 0.05 *** 0.01)

capture drop ATE_IPWRA*

	 
	 **************** Labour market reforms, code adapted from Jorda & Taylor (2016) 

drop pihat 

global controls3 "fe_outpg fe_dly fe_ldly fe_l2dly fe_l3dly fe_gcf_gdp fe_g_hc"

*fe_gcf_gdp fe_g_hc

* logit cotrols lab ref
global controls_lab_ref "l_outpg ldly l2dly l3dly l_prod_ref l_exp l_adj l_Unemploymentrate l_Inflationrate l_yrsoffc l_any_elec l_ideol_gov l_polfrag l_sep_te l_sep_re t_l t2_l t3_l l_gcf_gdp l_g_hc "

* For robustness: l_gcf_gdp l_g_hc l_EU_outpg l_debt_burden

logit lab_ref $controls_lab_ref i.identifier


* raw prscore, not truncated (pihat)
predict pihat

/* truncate ipws at 10 (pihat) we use truncated propensity scores due to treated obs. with very low p scores
gen pihat0=pihat
replace pihat0 = .9 if pihat0>.9 & pihat0~=.
replace pihat0 = .1 if pihat0<.1 & pihat0~=.
*/

capture drop a invwt
gen a=lab_ref // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.
	forvalues i=1/5 {
* Within transform the data	
	qui reg ly`i' $controls4

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc EU_outpg {
by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc EU_outpg {
by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)
}
	
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	*set trace on
	foreach bin in tight neutral expansive {
	
		/*qui*/ reg fe_ly`i' $controls3 l(1/5).lab_ref f(1/`i').lab_ref prod_ref [pweight=invwt] ///
			if year>1982 & year<2014 & `bin'==1 & lab_ref==0,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu0 = temp if year>1982 & year<2014 & `bin'==1  

		
		qui reg fe_ly`i' $controls3  l(0/5).lab_ref f(1/`i').lab_ref prod_ref  [pweight=invwt] ///
			if year>1982 & year<2014 & `bin'==1 & lab_ref==1,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu1 = temp if year>1982 & year<2014 & `bin'==1  

		}
	*from Lunt et al
	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
	generate iptw=(2*a-1)*fe_ly`i'*invwt
	generate dr1=iptw+mdiff1
	
	qui gen ATE_IPWRA_tight  = tight  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_neutral  = neutral  // constant for convenience in next reg to get mean
	qui gen ATE_IPWRA_expansive  = expansive  // constant for convenience in next reg to get mean
	
	xtset, clear
	xi: qui reg dr1 ATE_IPWRA_tight ATE_IPWRA_neutral ATE_IPWRA_expansive, nocons vce(bootstrap, seed(234) cluster(identifier) reps(500))  
		  eststo DR6_`i' 
		  xtset identifier year
		  xtcd2
		  *estadd scalar cdt=r(CD)
		
	capture drop iptw mdiff1 dr1 mu1 mu0 ATE_IPWRA*
	capture scalar drop dr1m
	
	
replace LP_lab_ref_tight = _b[ATE_IPWRA_tight] if _Year==`i'
replace LP_lab_ref_tightse = _se[ATE_IPWRA_tight] if _Year==`i'

replace LP_lab_ref_neutral = _b[ATE_IPWRA_neutral] if _Year==`i'
replace LP_lab_ref_neutralse = _se[ATE_IPWRA_neutral] if _Year==`i'

replace LP_lab_ref_expansive = _b[ATE_IPWRA_expansive] if _Year==`i'
replace LP_lab_ref_expansivese = _se[ATE_IPWRA_expansive] if _Year==`i'
	
	drop Mav_ly1 - fe_EU_outpg
	
	}
	

capture drop x_* up5_* dn5_* up10_* dn10_*

foreach var of varlist LP_prod_ref_tight LP_lab_ref_tight LP_prod_ref_neutral LP_lab_ref_neutral LP_prod_ref_expansive LP_lab_ref_expansive sLP_prod_ref_tight sLP_lab_ref_tight sLP_prod_ref_neutral sLP_lab_ref_neutral sLP_prod_ref_expansive sLP_lab_ref_expansive {
	gen x_`var'      = `var' 
	gen up5_`var'    = `var' + 1.96 * `var'se
	gen dn5_`var'    = `var' - 1.96 * `var'se
	gen up10_`var'   = `var' + 1.64 * `var'se
	gen dn10_`var'   = `var' - 1.64 * `var'se
	}
	
capture drop _Zero
gen _Zero = 0


twoway	(rarea up5_LP_prod_ref_tight dn5_LP_prod_ref_tight _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_prod_ref_tight dn10_LP_prod_ref_tight _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_prod_ref_tight _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		(line x_sLP_prod_ref_tight _Year, lcolor(black) lpattern(dot) lwidth(med)), scheme(s1color) legend(off) title("Product market AIPW: tight")
		graph rename gr1a


twoway	(rarea up5_LP_prod_ref_neutral dn5_LP_prod_ref_neutral _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_prod_ref_neutral dn10_LP_prod_ref_neutral _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_prod_ref_neutral _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		(line x_sLP_prod_ref_neutral _Year, lcolor(black) lpattern(dot) lwidth(med)), scheme(s1color) legend(off) title("Product market AIPW: neutral")
		graph rename g2a
		

twoway	(rarea up5_LP_prod_ref_expansive dn5_LP_prod_ref_expansive _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_prod_ref_expansive dn10_LP_prod_ref_expansive _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_prod_ref_expansive _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		(line x_sLP_prod_ref_expansive _Year, lcolor(black) lpattern(dot) lwidth(med)), scheme(s1color) legend(off) title("Product market AIPW: loose")
		graph rename g3a
		
		
		
twoway	(rarea up5_LP_lab_ref_tight dn5_LP_lab_ref_tight _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_lab_ref_tight dn10_LP_lab_ref_tight _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_lab_ref_tight _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		(line x_sLP_lab_ref_tight _Year, lcolor(black) lpattern(dot) lwidth(med)), scheme(s1color) legend(off) title("Labour market AIPW: tight")
		graph rename g1b


twoway	(rarea up5_LP_lab_ref_neutral dn5_LP_lab_ref_neutral _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_lab_ref_neutral dn10_LP_lab_ref_neutral _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_lab_ref_neutral _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		(line x_sLP_lab_ref_neutral _Year, lcolor(black) lpattern(dot) lwidth(med)), scheme(s1color) legend(off) title("Labour market AIPW: neutral")
		graph rename g2b
		

twoway	(rarea up5_LP_lab_ref_expansive dn5_LP_lab_ref_expansive _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_lab_ref_expansive dn10_LP_lab_ref_expansive _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_lab_ref_expansive _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		(line x_sLP_lab_ref_expansive _Year, lcolor(black) lpattern(dot) lwidth(med)), scheme(s1color) legend(off) title("Labour market AIPW: loose")
		graph rename g3b


gr combine gr1a g2a g3a g1b g2b g3b, ysize(13) col(1) 
graph rename ga

graph export ../figure4.pdf, replace
graph save   ../figure4.gph, replace
	
	
	
	
	*Table 7
	
esttab DR6_1 DR6_2 DR6_3 DR6_4 DR6_5 ///
	using "table7b.rtf" , replace ///
	title("Table 7. ATE-IP (DR) i.p. weights, labour market reforms conditional on fiscal policy") ///
	b(3) se(3) sfmt(2) obslast label scalars(cdt moransip) nonum star(* 0.10 ** 0.05 *** 0.01)

capture drop ATE_IPWRA*
