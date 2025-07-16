clear all
run "dataset_jae.do"
drop t t2 t3
save "data for simulation.dta", replace 

clear all
set more off, permanently
set seed 28100100
program placeboreforms, rclass
         syntax [, c(real 1)]
         clear
use  "data for simulation.dta"
		 
		 gen random_ref=rbinomial(1, 0.15)

		 //Time since last placebo reform:
		sort country year
		generate t=0
		by country: replace t=cond((random_ref==0 & random_ref[_n-1]==1)|random_ref[_n-1]==.,1,t[_n-1]+1)
		replace t=. if random_ref==.
		replace t=0 if t[_n-1]==. & random_ref==1
		order t, after(random_ref)
		gen t2=t^2
		gen t3=t^3
		

		 global controls3 "fe_outpg fe_l3dly fe_l2dly fe_dly fe_ldly fe_gcf_gdp fe_g_hc"

		 global controls_prod_ref "l_outpg ldly l2dly l3dly l_gcf_gdp l_g_hc l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag t t2 t3 l_gcf_gdp l_g_hc"
		 
		 
		 qui logit random_ref $controls_lab_ref i.identifier 

* raw pscore, not truncated (pihat0)
predict pihat0


* sort again
sort identifier year
xtset identifier year

************ Product market reforms, code adapted from Jorda & Taylor (2016)

gen pihat=pihat0
replace pihat = .9 if pihat>.9 & pihat~=.
replace pihat = .1 if pihat<.1 & pihat~=.

capture drop a invwt
gen a=random_ref // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.
	
	* SAME OUTCOME REG IN BOTH T&C 
	
	qui reg ly1 $controls4

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)
}
	
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	
	
		/*qui*/ 
		reg fe_ly1  $controls3 l(1/5).random_ref f(1/1).random_ref prod_ref [pweight=invwt] ///
			if year>1982 & year<2014 & random_ref==0,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu0 = temp if year>1982 & year<2014   

		
		/*qui*/  
		reg fe_ly1  $controls3 l(1/5).random_ref f(1/1).random_ref prod_ref [pweight=invwt]  ///
			if year>1982 & year<2014 & random_ref==1,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu1 = temp if year>1982 & year<2014  
		
	*from Lunt et al
	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
	generate iptw=(2*a-1)*fe_ly1*invwt
	generate dr1=iptw+mdiff1
	
	qui gen ATE_IPWRA=1  // constant for convenience in next reg to get mean
	qui xtscc dr1 ATE_IPWRA, nocons 
		 
		 return scalar b1=_b[ATE_IPWRA]
		 return scalar se1=_se[ATE_IPWRA]		 
		 

end

simulate b_1=r(b1) se_1=r(se1), reps(10000): placeboreforms
gen tfrac=b_1/se_1
gen tfrac1=((b_1/se_1)>2) | ((b_1/se_1)<-2)
sum tfrac1 
egen mean_tfrac1=mean(tfrac1) 
estadd scalar meanb= round(mean_tfrac1, .001)

set scheme s1mono
hist b_1, frequency xtitle(1-year forecast) addplot(pci 0 0.002 1000 0.002) legend(off)

graph save Graph "graph_lab_1.gph", replace

************************-------------------------*********************

clear all
set more off, permanently
set seed 28100100
program placeboreforms, rclass
         syntax [, c(real 1)]
         clear
use  "data for simulation.dta"
		 
		 gen random_ref=rbinomial(1, 0.15)

		 //Time since last placebo reform:
		sort country year
		generate t=0
		by country: replace t=cond((random_ref==0 & random_ref[_n-1]==1)|random_ref[_n-1]==.,1,t[_n-1]+1)
		replace t=. if random_ref==.
		replace t=0 if t[_n-1]==. & random_ref==1
		order t, after(random_ref)
		gen t2=t^2
		gen t3=t^3
		

		 global controls3 "fe_outpg fe_l3dly fe_l2dly fe_dly fe_ldly fe_gcf_gdp fe_g_hc"

		 global controls_prod_ref "l_outpg ldly l2dly l3dly l_gcf_gdp l_g_hc l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag t t2 t3 l_gcf_gdp l_g_hc"
		 
		 qui logit random_ref $controls_lab_ref i.identifier 

* raw pscore, not truncated (pihat0)
predict pihat0


gen pihat=pihat0
replace pihat = .9 if pihat>.9 & pihat~=.
replace pihat = .1 if pihat<.1 & pihat~=.

* sort again
sort identifier year
xtset identifier year

************ Product market reforms, code adapted from Jorda & Taylor (2016)

capture drop a invwt
gen a=random_ref // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.
	
	* SAME OUTCOME REG IN BOTH T&C 
	
	qui reg ly2 $controls4

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)
}
	
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	
	
		/*qui*/ 
		reg fe_ly2  $controls3 l(1/5).random_ref f(1/2).random_ref prod_ref [pweight=invwt] ///
			if year>1982 & year<2014 & random_ref==0,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu0 = temp if year>1982 & year<2014   

		
		/*qui*/  
		reg fe_ly2  $controls3 l(1/5).random_ref f(1/2).random_ref prod_ref [pweight=invwt]  ///
			if year>1982 & year<2014 & random_ref==1,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu1 = temp if year>1982 & year<2014  
		
	*from Lunt et al
	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
	generate iptw=(2*a-1)*fe_ly2*invwt
	generate dr1=iptw+mdiff1
	
	qui gen ATE_IPWRA=1  // constant for convenience in next reg to get mean
	qui xtscc dr1 ATE_IPWRA, nocons 	
	
		 return scalar b1=_b[ATE_IPWRA]
		 return scalar se1=_se[ATE_IPWRA]		 
		 

end
simulate b_1=r(b1) se_1=r(se1), reps(10000): placeboreforms
gen tfrac=b_1/se_1
gen tfrac1=((b_1/se_1)>2) | ((b_1/se_1)<-2)
sum tfrac1 
egen mean_tfrac1=mean(tfrac1) 
estadd scalar meanb= round(mean_tfrac1, .001)

set scheme s1mono
hist b_1, frequency xtitle(2-year forecast) addplot(pci 0 -0.003 1000 -0.003) legend(off)

graph save Graph "graph_lab_2.gph", replace


********************-----------------****************

clear all
set more off, permanently
set seed 28100100
program placeboreforms, rclass
         syntax [, c(real 1)]
         clear
use  "data for simulation.dta"
		 
		 gen random_ref=rbinomial(1, 0.15)

		 //Time since last placebo reform:
		sort country year
		generate t=0
		by country: replace t=cond((random_ref==0 & random_ref[_n-1]==1)|random_ref[_n-1]==.,1,t[_n-1]+1)
		replace t=. if random_ref==.
		replace t=0 if t[_n-1]==. & random_ref==1
		order t, after(random_ref)
		gen t2=t^2
		gen t3=t^3
		

		 global controls3 "fe_outpg fe_l3dly fe_l2dly fe_dly fe_ldly fe_gcf_gdp fe_g_hc"

		 global controls_prod_ref "l_outpg ldly l2dly l3dly l_gcf_gdp l_g_hc l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag t t2 t3 l_gcf_gdp l_g_hc"
		 
		 qui logit random_ref $controls_lab_ref i.identifier 

* raw pscore, not truncated (pihat0)
predict pihat0


gen pihat=pihat0
replace pihat = .9 if pihat>.9 & pihat~=.
replace pihat = .1 if pihat<.1 & pihat~=.

* sort again
sort identifier year
xtset identifier year

************ Product market reforms, code adapted from Jorda & Taylor (2016)

capture drop a invwt
gen a=random_ref // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.
	
	* SAME OUTCOME REG IN BOTH T&C 
	
	qui reg ly3 $controls4

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)
}
	
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	
	
		/*qui*/ 
		reg fe_ly3  $controls3 l(1/5).random_ref f(1/3).random_ref prod_ref [pweight=invwt] ///
			if year>1982 & year<2014 & random_ref==0,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu0 = temp if year>1982 & year<2014   

		
		/*qui*/  
		reg fe_ly3  $controls3 l(1/5).random_ref f(1/3).random_ref prod_ref [pweight=invwt]  ///
			if year>1982 & year<2014 & random_ref==1,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu1 = temp if year>1982 & year<2014  
		
	*from Lunt et al
	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
	generate iptw=(2*a-1)*fe_ly3*invwt
	generate dr1=iptw+mdiff1
	
	qui gen ATE_IPWRA=1  // constant for convenience in next reg to get mean
	qui xtscc dr1 ATE_IPWRA, nocons 	
		 
		 return scalar b1=_b[ATE_IPWRA]
		 return scalar se1=_se[ATE_IPWRA]		 
		 

end
simulate b_1=r(b1) se_1=r(se1), reps(10000): placeboreforms
gen tfrac=b_1/se_1
gen tfrac1=((b_1/se_1)>2) | ((b_1/se_1)<-2)
sum tfrac1 
egen mean_tfrac1=mean(tfrac1) 
estadd scalar meanb= round(mean_tfrac1, .001)

set scheme s1mono
hist b_1, frequency xtitle(3-year forecast) addplot(pci 0 -0.007 1000 -0.007) legend(off)

graph save Graph "graph_lab_3.gph", replace


********************--------------------*******************/


clear all
set more off, permanently
set seed 28100100
program placeboreforms, rclass
         syntax [, c(real 1)]
         clear
use  "data for simulation.dta"
		 
		 gen random_ref=rbinomial(1, 0.15)

		 //Time since last placebo reform:
		sort country year
		generate t=0
		by country: replace t=cond((random_ref==0 & random_ref[_n-1]==1)|random_ref[_n-1]==.,1,t[_n-1]+1)
		replace t=. if random_ref==.
		replace t=0 if t[_n-1]==. & random_ref==1
		order t, after(random_ref)
		gen t2=t^2
		gen t3=t^3
		

		 global controls3 "fe_outpg fe_l3dly fe_l2dly fe_dly fe_ldly fe_gcf_gdp fe_g_hc"

		 global controls_prod_ref "l_outpg ldly l2dly l3dly l_gcf_gdp l_g_hc l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag t t2 t3 l_gcf_gdp l_g_hc"
		 
		 qui logit random_ref $controls_lab_ref i.identifier 

* raw pscore, not truncated (pihat0)
predict pihat0

gen pihat=pihat0
replace pihat = .9 if pihat>.9 & pihat~=.
replace pihat = .1 if pihat<.1 & pihat~=.

* sort again
sort identifier year
xtset identifier year

************ Product market reforms, code adapted from Jorda & Taylor (2016)

capture drop a invwt
gen a=random_ref // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.
	
	* SAME OUTCOME REG IN BOTH T&C 
	
	qui reg ly4 $controls4

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)
}
	
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	
	
		/*qui*/ 
		reg fe_ly4  $controls3 l(1/5).random_ref f(1/4).random_ref prod_ref [pweight=invwt] ///
			if year>1982 & year<2014 & random_ref==0,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu0 = temp if year>1982 & year<2014   

		
		/*qui*/  
		reg fe_ly4  $controls3 l(1/5).random_ref f(1/4).random_ref prod_ref [pweight=invwt]  ///
			if year>1982 & year<2014 & random_ref==1,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu1 = temp if year>1982 & year<2014  
		
	*from Lunt et al
	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
	generate iptw=(2*a-1)*fe_ly4*invwt
	generate dr1=iptw+mdiff1
	
	qui gen ATE_IPWRA=1  // constant for convenience in next reg to get mean
	qui xtscc dr1 ATE_IPWRA, nocons 
		 
		 return scalar b1=_b[ATE_IPWRA]
		 return scalar se1=_se[ATE_IPWRA]		 
		 

end
simulate b_1=r(b1) se_1=r(se1), reps(10000): placeboreforms
gen tfrac=b_1/se_1
gen tfrac1=((b_1/se_1)>2) | ((b_1/se_1)<-2)
sum tfrac1 
egen mean_tfrac1=mean(tfrac1) 
estadd scalar meanb= round(mean_tfrac1, .001)

set scheme s1mono
hist b_1, frequency xtitle(4-year forecast) addplot(pci 0 -0.006 1000 -0.006) legend(off)

graph save Graph "graph_lab_4.gph", replace

************************-------------*************************


clear all
set more off, permanently
set seed 28100100
program placeboreforms, rclass
         syntax [, c(real 1)]
         clear
use  "data for simulation.dta"
		 
		 gen random_ref=rbinomial(1, 0.15)

		 //Time since last placebo reform:
		sort country year
		generate t=0
		by country: replace t=cond((random_ref==0 & random_ref[_n-1]==1)|random_ref[_n-1]==.,1,t[_n-1]+1)
		replace t=. if random_ref==.
		replace t=0 if t[_n-1]==. & random_ref==1
		order t, after(random_ref)
		gen t2=t^2
		gen t3=t^3
		

		 global controls3 "fe_outpg fe_l3dly fe_l2dly fe_dly fe_ldly fe_gcf_gdp fe_g_hc"

		 global controls_prod_ref "l_outpg ldly l2dly l3dly l_gcf_gdp l_g_hc l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag t t2 t3 l_gcf_gdp l_g_hc"
		 
		 
		 qui logit random_ref $controls_lab_ref i.identifier 

* raw pscore, not truncated (pihat0)
predict pihat0

gen pihat=pihat0
replace pihat = .9 if pihat>.9 & pihat~=.
replace pihat = .1 if pihat<.1 & pihat~=.

* sort again
sort identifier year
xtset identifier year

************ Product market reforms, code adapted from Jorda & Taylor (2016)

capture drop a invwt
gen a=random_ref // define treatment indicator as a from Lunt et al.
gen invwt=a/pihat + (1-a)/(1-pihat) if pihat~=. // invwt from Lunt et al.
	
	* SAME OUTCOME REG IN BOTH T&C 
	
	qui reg ly5 $controls4

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: egen Mav_`var'=mean(`var') if e(sample)
}

foreach var of varlist ly1 ly2 ly3 ly4 ly5 Outputgap outpg dly ldly l2dly l3dly gcf_gdp g_hc {
by identifier, sort: gen fe_`var'=`var' - Mav_`var' if e(sample)
}
	
	capture drop mu1 mu0
	gen mu0=.
	gen mu1=.
	
	
		/*qui*/ 
		reg fe_ly5  $controls3 l(1/5).random_ref f(1/5).random_ref prod_ref [pweight=invwt] ///
			if year>1982 & year<2014 & random_ref==0,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu0 = temp if year>1982 & year<2014   

		
		/*qui*/  
		reg fe_ly5  $controls3 l(1/5).random_ref f(1/5).random_ref prod_ref [pweight=invwt]  ///
			if year>1982 & year<2014 & random_ref==1,  cluster(identifier)
		capture drop temp
		predict temp
		replace mu1 = temp if year>1982 & year<2014  
		
	*from Lunt et al
	generate mdiff1=(-(a-pihat)*mu1/pihat)-((a-pihat)*mu0/(1-pihat))
	generate iptw=(2*a-1)*fe_ly5*invwt
	generate dr1=iptw+mdiff1
	
	qui gen ATE_IPWRA=1  // constant for convenience in next reg to get mean
	qui xtscc dr1 ATE_IPWRA, nocons  
		 
		 return scalar b1=_b[ATE_IPWRA]
		 return scalar se1=_se[ATE_IPWRA]		 
		 

end
simulate b_1=r(b1) se_1=r(se1), reps(10000): placeboreforms
gen tfrac=b_1/se_1
gen tfrac1=((b_1/se_1)>2) | ((b_1/se_1)<-2)
sum tfrac1 
egen mean_tfrac1=mean(tfrac1) 
estadd scalar meanb= round(mean_tfrac1, .001)

set scheme s1mono
hist b_1, frequency xtitle(5-year forecast) addplot(pci 0 -0.008 1000 -0.008) legend(off)

graph save Graph "graph_lab_5.gph", replace


*cd "/Users/rasmuswiese/Desktop/Narrative reforms" 

gr combine graph_lab_1.gph graph_lab_2.gph graph_lab_3.gph graph_lab_4.gph graph_lab_5.gph,  title("Unconditional ATEs of placebo labour market reforms") ycommon

graph save Graph "placebo_labour_comb.gph", replace



*kdensity b_1
*hist b_1

		 
		 
