clear all

run "dataset_jae.do"



** Dataset complete



* insert sipmple LP responses in AIPW IR plots

** Local Projection regressions for any labour or product market reform

sort identifier year



capture drop LP_prod_ref_* LP_lab_ref_* _Year



gen LP_prod_ref =.

gen LP_prod_refse =.

gen LP_lab_ref =.

gen LP_lab_refse =.

gen _Year = _n if _n<=5

label var _Year "Year" 


*set trace on
forvalues i=1/5 {



	* specification: simple LP estimates product market reforms

		  

		xtscc ly`i' ///
		l(0/5).prod_ref lab_ref outpg l(0/3).dly f(1/`i').prod_ref gcf_gdp g_hc, fe 

		  

		  * Store for IR plots

replace LP_prod_ref = _b[prod_ref] if _Year==`i'

replace LP_prod_refse = _se[prod_ref] if _Year==`i'

}



forvalues i=1/5 {



	* specification: simple LP estimate labour market reforms

	

		qui xtscc ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc, fe  

		  

			  * Store for IR plots

replace LP_lab_ref = _b[lab_ref] if _Year==`i'

replace LP_lab_refse = _se[lab_ref] if _Year==`i' 	

}





//Doubly robust (DR) estimation AIPW



*Controls

global controls3 "fe_outpg fe_dly fe_ldly fe_l2dly fe_l3dly fe_gcf_gdp fe_g_hc"

global controls4 "outpg l3dly l2dly dly ldly gcf_gdp g_hc"



*logit controls

global controls_prod_ref "l_outpg ldly l2dly l3dly l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag t t2 t3 l_gcf_gdp l_g_hc"



global controls_lab_ref "l_outpg ldly l2dly l3dly l_prod_ref l_exp l_adj l_Unemploymentrate l_Inflationrate l_yrsoffc l_any_elec l_ideol_gov l_polfrag l_sep_te l_sep_re t_l t2_l t3_l l_gcf_gdp l_g_hc"



* DR - IPWRA - ATE weighted by IPWT (Davidian/Lunt) WITH DIFFERENT SLOPE/CFEs (beta1.NEQ.beta0)

* ATE split by bin

* no truncations (use phat0)

sort country year

qui logit prod_ref $controls_prod_ref i.identifier 



* raw prscore, not truncated (pihat0)

cap drop pihat0
predict pihat0



* truncate ipws at .10 (pihat)

*cap drop pihat
gen pihat=pihat0

replace pihat = .9 if pihat>.9 & pihat~=.

replace pihat = .1 if pihat<.1 & pihat~=.





* sort again

sort identifier year

xtset identifier year



capture drop LPIP_prod_ref_* LPIP_lab_ref_* _Year


cap drop LPIP_prod_ref
gen LPIP_prod_ref =.
cap drop LPIP_prod_refse
gen LPIP_prod_refse =.


cap drop LPIP_lab_ref
gen LPIP_lab_ref =.
cap drop LPIP_lab_refse
gen LPIP_lab_refse =.

 



************ Product market reforms, code adapted from Jorda & Taylor (2016)



capture drop a invwt

gen a=prod_ref // define treatment indicator as a from Lunt et al.

gen invwt=a/pihat0 + (1-a)/(1-pihat0) if pihat0~=. // invwt from Lunt et al.

	forvalues i=1/5 {



* Within transform the data	

	qui reg ly`i' $controls4



foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg EU_outpg dly ldly l2dly l3dly gcf_gdp g_hc {

by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)

}



foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg EU_outpg dly ldly l2dly l3dly gcf_gdp g_hc {

by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)

}

	

	capture drop mu1 mu0

	gen mu0=.

	gen mu1=.

	

		qui reg fe_ly`i'  $controls3 l(1/5).prod_ref f(1/`i').prod_ref lab_ref [pweight=invwt] if year>1982 & year<2014 & prod_ref==0,  cluster(identifier)

		capture drop temp

		predict temp

		replace mu0 = temp if year>1982 & year<2014   



		

		qui reg fe_ly`i'  $controls3 l(1/5).prod_ref f(1/`i').prod_ref lab_ref [pweight=invwt]  if year>1982 & year<2014 & prod_ref==1,  cluster(identifier)

		capture drop temp

		predict temp

		replace mu1 = temp if year>1982 & year<2014  

			

	generate mdiff1=(-(a-pihat0)*mu1/pihat0)-((a-pihat0)*mu0/(1-pihat0))

	generate iptw=(2*a-1)*fe_ly`i'*invwt

	generate dr1=iptw+mdiff1

	

	qui gen ATE_IPWRA=1  // constant for convenience in next reg to get mean

	

	xtset, clear

	xi: qui reg dr1 ATE_IPWRA, nocons vce(bootstrap, seed(234) cluster(identifier) reps(500))  

		  eststo DR6_`i' 

		  xtset identifier year

		  xtcd2

		  *estadd scalar cdt=r(CD)

		  

	sum dr1 

	

	capture drop iptw mdiff1 dr1 mu1 mu0 ATE_IPWRA

	capture scalar drop dr1m



replace LPIP_prod_ref = _b[ATE_IPWRA] if _Year==`i'

replace LPIP_prod_refse = _se[ATE_IPWRA] if _Year==`i'

	

	drop Mav_ly1 - fe_g_hc

	}



* plots product market reforms unconditional IR ATEs



capture drop x_* up5_* dn5_* up10_* dn10_*



foreach var of varlist LPIP_prod_ref LP_prod_ref {

	gen x_`var'      = `var' 

	gen up5_`var'    = `var' + 1.96 * `var'se

	gen dn5_`var'    = `var' - 1.96 * `var'se

	gen up10_`var'   = `var' + 1.64 * `var'se

	gen dn10_`var'   = `var' - 1.64 * `var'se

	}

	

capture drop _Zero

gen _Zero = 0





twoway	(rarea up5_LPIP_prod_ref dn5_LPIP_prod_ref _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIP_prod_ref dn10_LPIP_prod_ref _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIP_prod_ref _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		(line x_LP_prod_ref _Year, lcolor(black) lpattern(dot) lwidth(med)), scheme(s1color) legend(off) title("AIPW Product market, unconditional")
		graph rename gr1a

	

	*Table 6

	

esttab DR6_1 DR6_2 DR6_3 DR6_4 DR6_5 ///
	using "table6.rtf", replace ///
	title("Table 6. ATE-IP (DR) i.p. weights, product market reforms, unconditional") ///
	b(3) se(3) sfmt(2) obslast label scalars(cdt moransip)  nonum star(* 0.10 ** 0.05 *** 0.01)



capture drop ATE_IPWRA*





	 

	 **************** Labour market reforms, code adapted from Jorda & Taylor (2016) 



drop pihat pihat0



global controls3 "fe_outpg fe_dly fe_ldly fe_l2dly fe_l3dly fe_gcf_gdp fe_g_hc"

qui logit lab_ref $controls_lab_ref i.identifier



*fe_dly fe_ldly





* raw prscore, not truncated (pihat0)

cap predict pihat





capture drop a invwt

gen a=lab_ref // define treatment indicator as a from Lunt et al.

gen invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.

	forvalues i=1/5 {

	* Within transform the data	

	qui reg ly1 lab_ref Outputgap dly ldly gcf_gdp g_hc



foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg EU_outpg dly ldly l2dly l3dly gcf_gdp g_hc { 

by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)

}



foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg EU_outpg dly ldly l2dly l3dly gcf_gdp g_hc {

by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)

}

	

	capture drop mu1 mu0

	gen mu0=.

	gen mu1=.

	

		qui reg fe_ly`i'  $controls3 l(1/5).lab_ref f(1/`i').lab_ref prod_ref [pweight=invwt] if year>1982 & year<2014 & lab_ref==0,  cluster(identifier)

		capture drop temp

		predict temp

		replace mu0 = temp if year>1982 & year<2014   



		

		qui reg fe_ly`i'  $controls3 l(1/5).lab_ref f(1/`i').lab_ref prod_ref [pweight=invwt] if year>1982 & year<2014 & lab_ref==1,  cluster(identifier)

		capture drop temp

		predict temp

		replace mu1 = temp if year>1982 & year<2014  



	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))

	generate iptw=(2*a-1)*fe_ly`i'*invwt

	generate dr1=iptw+mdiff1

	

	qui gen ATE_IPWRA=1  // constant for convenience in next reg to get mean

	xtset, clear

	xi: qui reg dr1 ATE_IPWRA, nocons vce(bootstrap, seed(234) cluster(identifier) reps(500))  

		  eststo DR6_`i' 

		  xtset identifier year

		  xtcd2

		  *estadd scalar cdt=r(CD)

		  

	sum dr1 

	

	capture drop iptw mdiff1 dr1 mu1 mu0 ATE_IPWRA

	capture scalar drop dr1m

	

replace LPIP_lab_ref = _b[ATE_IPWRA] if _Year==`i'

replace LPIP_lab_refse = _se[ATE_IPWRA] if _Year==`i'

	

	drop Mav_ly1 - fe_g_hc

	}



	

* Plots 

	

capture drop x_* up5_* dn5_* up10_* dn10_*



foreach var of varlist LPIP_lab_ref LP_lab_ref {

	gen x_`var'      = `var' 

	gen up5_`var'    = `var' + 1.96 * `var'se

	gen dn5_`var'    = `var' - 1.96 * `var'se

	gen up10_`var'   = `var' + 1.64 * `var'se

	gen dn10_`var'   = `var' - 1.64 * `var'se

	}

	

capture drop _Zero

gen _Zero = 0





twoway	(rarea up5_LPIP_lab_ref dn5_LPIP_lab_ref _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LPIP_lab_ref dn10_LPIP_lab_ref _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LPIP_lab_ref _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		(line x_LP_lab_ref _Year, lcolor(black) lpattern(dot) lwidth(med)), scheme(s1color) legend(off) title("AIPW Labour market, unconditional")
		graph rename gr2a

		

	

gr combine gr1a gr2a, col(1) 

graph rename ga



graph export ../figure7.pdf, replace

graph save   ../figure7.gph, replace

	

	

	*Table 6

	

esttab DR6_1 DR6_2 DR6_3 DR6_4 DR6_5 ///
	using "table6b.rtf" , replace ///
	title("Table 6. ATE-IP (DR) i.p. weights, labour market reforms, unconditional") ///
	b(3) se(3) sfmt(2) obslast label scalars(cdt moransip) nonum star(* 0.10 ** 0.05 *** 0.01)



capture drop ATE_IPWRA*







