clear all
run "dataset_jae.do"
*cd "X:\My Desktop\Narrative reforms"

sort identifier year
** Dataset complete

** Local Projection regressions for any labour or product market reform

capture drop LP_prod_ref_* LP_lab_ref_* _Year

gen LP_prod_ref =.
gen LP_prod_refse =.
gen LP_lab_ref =.
gen LP_lab_refse =.

gen _Year = _n if _n<=5
label var _Year "Year" 


 xtreg ly1 prod_ref outpg, fe vce(cluster identifier) // sets outreg2 table2
outreg2 using "table2",  bdec(3) pdec(3) word replace

forvalues i=1/5 {

	* specification: simple LP estimates product market reforms


		qui xtreg ly`i' ///
		l(0/5).prod_ref lab_ref outpg l(0/3).dly f(1/`i').prod_ref gcf_gdp g_hc, fe vce(cluster identifier)
		  *estat ic
		  predict res if e(sample), residuals 
		  xtcd2 res
		  mat first=r(CD)
		  local cdfp=first[1,1]
		  
		qui xtscc ly`i' ///
		l(0/5).prod_ref lab_ref outpg l(0/3).dly f(1/`i').prod_ref gcf_gdp g_hc, fe 

		outreg2 using "table2", adds(R-squared, `e(r2_w)', Pesaran CD-test statistic, `cdfp' ) drop(f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared) bdec(3) pdec(3) word append
		
		drop res
		  
		  * Store for IR plots
replace LP_prod_ref = _b[prod_ref] if _Year==`i'
replace LP_prod_refse = _se[prod_ref] if _Year==`i'
	
}


forvalues i=1/5 {

	* specification: simple LP estimate labour market reforms

		qui xtreg ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc, fe vce(cluster identifier)
		  *estat ic
		  predict res if e(sample), residuals 
		  xtcd2 res
		  mat first=r(CD)
		  local cdfp=first[1,1]
		 
		  
		qui xtscc ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc, fe  

		outreg2 using "table2", adds(R-squared, `e(r2_w)', Pesaran CD-test statistic, `cdfp' ) drop(f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared) bdec(3) pdec(3) word append
		
			  drop res
		  
			  * Store for IR plots
replace LP_lab_ref = _b[lab_ref] if _Year==`i'
replace LP_lab_refse = _se[lab_ref] if _Year==`i' 	

}



capture drop x_* up5_* dn5_* up10_* dn10_*

foreach var of varlist LP_prod_ref LP_lab_ref  {
	gen x_`var'      = `var' 
	gen up5_`var'    = `var' + 1.96 * `var'se
	gen dn5_`var'    = `var' - 1.96 * `var'se
	gen up10_`var'   = `var' + 1.64 * `var'se
	gen dn10_`var'   = `var' - 1.64 * `var'se
	}
	
capture drop _Zero
gen _Zero = 0


twoway	(rarea up5_LP_prod_ref dn5_LP_prod_ref _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_prod_ref dn10_LP_prod_ref _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_prod_ref _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, scheme(s1color) legend(off) title("LP product market, unconditional")
		graph rename gr1a


twoway	(rarea up5_LP_lab_ref dn5_LP_lab_ref _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_lab_ref dn10_LP_lab_ref _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_lab_ref _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, scheme(s1color) legend(off) title("LP labour market, unconditional")
		graph rename gr2b
		

gr combine gr1a gr2b, col(1)
graph rename ga

graph export ../figure2.pdf, replace
graph save   ../figure2.gph, replace





* Product market reform with neutral, loose and tight fiscal policy

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

*gen _Year = _n if _n<=5
label var _Year "Year"


qui xtreg ly1 prod_ref lab_ref if BP_adj_exp==0, fe  // sets outreg2 table3
outreg2 using "table3", drop(l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared)  bdec(3) pdec(3) word replace

* Product market reforms

forvalues i=1/5 {


	* specification: simple LP estimate (fiscal adjustment=tight)

		qui xtscc ly`i' ///
		l(0/5).prod_ref lab_ref outpg l(0/3).dly f(1/`i').prod_ref gcf_gdp g_hc if BP_adj_exp==1, fe 
outreg2 using "table3", adds(R-squared, `e(r2_w)') drop(outpg gcf_gdp g_hc l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared) bdec(3) pdec(3) word append

replace LP_prod_ref_tight = _b[prod_ref] if _Year==`i'
replace LP_prod_ref_tightse = _se[prod_ref] if _Year==`i'

}


forvalues i=1/5 {


	* specification: simple LP estimate (neutral fiscal policy)

		qui xtscc ly`i' ///
		l(0/5).prod_ref lab_ref outpg l(0/3).dly f(1/`i').prod_ref gcf_gdp g_hc if BP_adj_exp==0, fe 
outreg2 using "table3", adds(R-squared, `e(r2_w)') drop(outpg gcf_gdp g_hc l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared) bdec(3) pdec(3) word append

replace LP_prod_ref_neutral = _b[prod_ref] if _Year==`i'
replace LP_prod_ref_neutralse = _se[prod_ref] if _Year==`i'

}

forvalues i=1/5 {


	* specification: simple LP estimate (Fiscal expansion)
	
		qui xtscc ly`i' ///
		l(0/5).prod_ref l(0/5).lab_ref outpg l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref gcf_gdp g_hc if BP_adj_exp==-1, fe 
outreg2 using "table3", adds(R-squared, `e(r2_w)') drop(outpg gcf_gdp g_hc l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared) bdec(3) pdec(3) word append

replace LP_prod_ref_expansive = _b[prod_ref] if _Year==`i'
replace LP_prod_ref_expansivese = _se[prod_ref] if _Year==`i'

}

* Labour market reform with neutral, loose and tight fiscal policy
qui xtreg ly1 prod_ref lab_ref if BP_adj_exp==0, fe  // sets outreg2 table3
outreg2 using "table3b", drop(l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared)  bdec(3) pdec(3) word replace

* Labour market reforms

forvalues i=1/5 {


	* specification: simple LP estimate (fiscal adjustment=tight)
	
		qui xtscc ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc if BP_adj_exp==1, fe 
outreg2 using "table3b", adds(R-squared, `e(r2_w)') drop(outpg gcf_gdp g_hc l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared) bdec(3) pdec(3) word append

replace LP_lab_ref_tight = _b[lab_ref] if _Year==`i'
replace LP_lab_ref_tightse = _se[lab_ref] if _Year==`i' 
		
}


forvalues i=1/5 {


	* specification: simple LP estimate (neutral fiscal policy)

		qui xtscc ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc if BP_adj_exp==0, fe 
outreg2 using "table3b", adds(R-squared, `e(r2_w)') drop(outpg gcf_gdp g_hc l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared) bdec(3) pdec(3) word append

replace LP_lab_ref_neutral = _b[lab_ref] if _Year==`i'
replace LP_lab_ref_neutralse = _se[lab_ref] if _Year==`i' 	

}

forvalues i=1/5 {


	* specification: simple LP estimate (Fiscal expansion)
	
		qui xtscc ly`i' ///
		l(0/5).lab_ref prod_ref outpg l(0/3).dly f(1/`i').lab_ref gcf_gdp g_hc if BP_adj_exp==-1, fe 
outreg2 using "table3b", adds(R-squared, `e(r2_w)') drop(outpg gcf_gdp g_hc l(0/3).dly f(1/`i').prod_ref f(1/`i').lab_ref l(1/5).prod_ref l(1/5).lab_ref R-squared) bdec(3) pdec(3) word append

replace LP_lab_ref_expansive = _b[lab_ref] if _Year==`i'
replace LP_lab_ref_expansivese = _se[lab_ref] if _Year==`i' 

}


* plots


capture drop x_* up5_* dn5_* up10_* dn10_*

foreach var of varlist LP_prod_ref_tight LP_lab_ref_tight LP_prod_ref_neutral LP_lab_ref_neutral LP_prod_ref_expansive LP_lab_ref_expansive  {
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
		, scheme(s1color) legend(off) title("Product market: tight")
		graph rename g1a


twoway	(rarea up5_LP_prod_ref_neutral dn5_LP_prod_ref_neutral _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_prod_ref_neutral dn10_LP_prod_ref_neutral _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_prod_ref_neutral _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, scheme(s1color) legend(off) title("Product market: neutral")
		graph rename g2a
		

twoway	(rarea up5_LP_prod_ref_expansive dn5_LP_prod_ref_expansive _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_prod_ref_expansive dn10_LP_prod_ref_expansive _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_prod_ref_expansive _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, scheme(s1color) legend(off) title("Product market: loose")
		graph rename g3a
		
		
		
twoway	(rarea up5_LP_lab_ref_tight dn5_LP_lab_ref_tight _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_lab_ref_tight dn10_LP_lab_ref_tight _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_lab_ref_tight _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, scheme(s1color) legend(off) title("Labour market: tight")
		graph rename g1b


twoway	(rarea up5_LP_lab_ref_neutral dn5_LP_lab_ref_neutral _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_lab_ref_neutral dn10_LP_lab_ref_neutral _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_lab_ref_neutral _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, scheme(s1color) legend(off) title("Labour market: neutral")
		graph rename g2b
		

twoway	(rarea up5_LP_lab_ref_expansive dn5_LP_lab_ref_expansive _Year, ///
				fcolor(gs14) lcolor(gs14) lpattern(solid)) ///
		(rarea up10_LP_lab_ref_expansive dn10_LP_lab_ref_expansive _Year, ///
				fcolor(gs11) lcolor(gs14) lpattern(solid)) ///
		(line x_LP_lab_ref_expansive _Year, lcolor(black) lpattern(solid) lwidth(med)) ///
		(line _Zero _Year, lcolor(black) lpattern(dash) lwidth(med)) ///
		, scheme(s1color) legend(off) title("Labour market: loose")
		graph rename g3b


gr combine g1a g2a g3a g1b g2b g3b,  ysize(13) col(1)
graph rename ga, replace

graph export ../figure3.pdf, replace
graph save   ../figure3.gph, replace
		


/*
twoway (kdensity pihat0 if prod_ref==1, lpattern(dash) color(black) lwidth(medthick)) ///
	(kdensity pihat0 if prod_ref==0, color(gray) lwidth(medthick)), ///
	legend(label(1 "Treatment") label(2 "Control")) ///
	ytitle("Frequency") ///
	xtitle("Distribution of estimated probabilities of product market reforms") ///
	plotregion(lpattern(blank)) scheme(s1color) legend(on)
graph save grh_prodref, replace  
graph export "Graph_prod_ref.pdf", as(pdf) replace
*/





