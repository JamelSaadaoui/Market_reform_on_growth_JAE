clear all
use "deH_W_data.dta"
*ssc install  hprescott
encode country, generate(identifier)
xtset identifier year
spset identifier
xtdes 

gen EUmember=1
replace EUmember=0 if country=="Australia"
replace EUmember=0 if country=="Austria" & year<1995
replace EUmember=0 if country=="Canada"
replace EUmember=0 if country=="Czech Republic" & year<2004
replace EUmember=0 if country=="Finland" & year<1995
replace EUmember=0 if country=="Greece" & year<1981
replace EUmember=0 if country=="Iceland"
replace EUmember=0 if country=="Japan"
replace EUmember=0 if country=="New Zealand"
replace EUmember=0 if country=="Norway"
replace EUmember=0 if country=="Portugal" & year<1986
replace EUmember=0 if country=="Republic of Korea"
replace EUmember=0 if country=="Spain" & year<1986
replace EUmember=0 if country=="Sweden" & year<1995
replace EUmember=0 if country=="Switzerland"
replace EUmember=0 if country=="United States"

gen EU_outpg = EUmember*EU15
replace EU_outpg=. if EU_outpg==0
gen l_EU_outpg=l.EU_outpg

* variable capturing debt burden
replace GeneralgovernmentdebttoGDPr=. if country=="United States" & year<2001 
gen debt_burden=GeneralgovernmentdebttoGDPr*Shortterminterestrates
gen l_debt_burden=l.debt_burden

* create pr. capita real growth rates at PPP (2011 US$) from PWT
gen gdppc=rgdpna/pop
sort identifier year 
by identifier: gen gdp_growth=ln(gdppc/l.gdppc)
by identifier: gen ly=sum(gdp_growth) if year>1982 & year<2014 // cumulative log diffs (cumulative growth rate in percentage terms) equvalent to taking longer period log-diffs

by identifier: replace ly=. if year==1983 | year==1984 // same sample as data for fiscal policy stance
by identifier: replace ly=. if gdp_growth==.

* construct the output gap using the HP filter on log of y
gen logy=ln(rgdpna)					
bysort identifier: hprescott logy, stub(HP) smooth(100)
	// VERY HIGH smoothing (see Jorda & Taylor 2016)
	
sum identifier
local countries = r(max)

gen hplogy=.
forvalues i=1/`countries' {
	replace hplogy = HP_logy_`i' if identifier==`i'
}

* actual GDP less potential GDP as a percent of potential GDP

gen intermediate_outpg=.
forvalues i=1/`countries' {
	replace intermediate_outpg = HP_logy_sm_`i' if identifier==`i'
}

gen outpg=((logy-intermediate_outpg)/intermediate_outpg)*100
**Regardless of the calculation of outputgaps, the IMF data with a production function approach works better in the estimations for consistency we use the HP filter on our own data
*/

* Gross investments per capita
gen ckpc=rkna/pop
gen gcf_pc=ln(ckpc/l.ckpc)

* Gross investment relative to GDP (gross capital formation)
gen ckgdp=rkna/rgdpna
gen gcf_gdp=ln(ckgdp/l.ckgdp)

* Growth in human capital
gen g_hc=(hc/l.hc)-1

* create dependent variable lags 
sort identifier year
by identifier: gen dly = gdp_growth
by identifier: gen ldly = l.gdp_growth
by identifier: gen l2dly = l2.gdp_growth
by identifier: gen l3dly = l3.gdp_growth

* dep vars for h-step ahead forecast (h=1,...,5) for cumulative changes in growth rates
local var ly 

foreach v of local var {
	forvalues i=1/5 {
		if "`v'"=="ly" {
		gen `v'`i' = f`i'.`v' - `v'
		}
		label var `v'`i' "Year `i'"
	}
}

*Create employment varaible for Okun test of the main results 
gen empr=emp/pop 

* create dependent variable lags (employment)

sort identifier year
by identifier: gen dempr = d.empr
by identifier: replace dempr=. if dly==.
by identifier: gen ldempr = l.dempr
by identifier: replace ldempr=. if ldly==.
by identifier: gen l2dempr = l2.dempr
by identifier: replace l2dempr=. if l2dly==.
by identifier: gen l3dempr = l3.dempr
by identifier: replace l3dempr=. if l3dly==.

* dep var for h-step ahead forecast (h=1,...,5) for people working as share of population
by identifier: replace empr=. if year<1985 | year>2014 
by identifier: replace empr=. if ly==.

local var empr

foreach v of local var {
	forvalues i=1/5 {
		if "`v'"=="empr" {
		gen `v'`i' = f`i'.`v' - `v'
		}
		label var `v'`i' "Year `i'"
	}
}


* create dependent variable lags (unemployment rate)
sort identifier year
by identifier: gen dUnemploymentrate = d.Unemploymentrate
by identifier: replace dUnemploymentrate=. if dly==.
by identifier: gen ldUnemploymentrate = l.dUnemploymentrate
by identifier: replace ldUnemploymentrate=. if ldly==.
by identifier: gen l2dUnemploymentrate = l2.dUnemploymentrate
by identifier: replace  l2dUnemploymentrate=. if l2dly==.
by identifier: gen l3dUnemploymentrate = l3.dUnemploymentrate
by identifier: replace l3dUnemploymentrate=. if l3dly==.

* dep var for h-step ahead forecast (h=1,...,5) for people working as share of population
by identifier: replace Unemploymentrate=. if year<1985 | year>2014 
by identifier: replace Unemploymentrate=. if ly==.

local var Unemploymentrate

foreach v of local var {
	forvalues i=1/5 {
		if "`v'"=="Unemploymentrate" {
		gen `v'`i' = f`i'.`v' - `v'
		}
		label var `v'`i' "Year `i'"
	}
}



* Generate refom indicies/treatment indicators based on IMF narrative reform database
* dummy=1 if any of the underlying areas of the two reform types are equal to one
gen prod_ref=0
replace prod_ref=1 if Electricity==1 | Gas==1 | Telecommunications==1 |PostalServices==1 | RailTransport==1 |AirTransport==1 | RoadTransport==1 
replace prod_ref=. if year<1970
replace prod_ref=. if year<1990 & country=="Czech Republic"
*Falsification test: 
gen fprod_ref=f2.prod_ref

gen lab_ref=0
replace lab_ref=1 if EPLregularworkers==1 | EPLtemporaryworkers==1 | Unemploymentbenefitsoverall==1 | ///
 Unemploymentbenefitsreplaceme==1 | Unemploymentbenefitsduration==1 
replace lab_ref=. if year<1970
replace lab_ref=. if year<1990 & country=="Czech Republic"
*Falsification test: 
gen flab_ref=f2.lab_ref
 
gen ref_interaction = prod_ref*lab_ref
 
* Create fiscal policy stance variables
*drop if year>2014
replace BP_adj_exp=1 if d.Cyclicallyadjustedgovernmentp>0 & l.BP_adj_exp==1 // creates the fiscal policy stance after the initiation of adj or exp
replace BP_adj_exp=-1 if d.Cyclicallyadjustedgovernmentp<0 & l.BP_adj_exp==-1 
replace BP_adj_exp=0 if BP_adj_exp==.
replace BP_adj_exp=. if Cyclicallyadjustedgovernmentp==. // using this variables assumes a linear effect of fiscal policy stance

* dummies for fiscal policy stance
gen adj=0 
replace adj=1 if BP_adj_exp==1
replace adj=. if BP_adj_exp==.

gen neutr=0
replace neutr=1 if BP_adj_exp==0
replace neutr=. if BP_adj_exp==.

gen exp=0 
replace exp=1 if BP_adj_exp==-1
replace exp=. if BP_adj_exp==.

* Alesina-type fiscal adjustments and expansions 
gen alesina_adj=0 if Cyclicallyadjustedgovernmentp!=.
replace alesina_adj=1 if d.Cyclicallyadjustedgovernmentp>1.5 
replace alesina_adj=. if Cyclicallyadjustedgovernmentp==.
replace alesina_adj=0 if l.alesina_adj==. & Cyclicallyadjustedgovernmentp!=.
replace alesina_adj=1 if l.alesina_adj==1 & d.Cyclicallyadjustedgovernmentp>0 & Cyclicallyadjustedgovernmentp!=.

gen alesina_exp=0
replace alesina_exp=1 if d.Cyclicallyadjustedgovernmentp<-1.5 & Cyclicallyadjustedgovernmentp!=.
replace alesina_exp=1 if l.alesina_exp==1 & d.Cyclicallyadjustedgovernmentp<0 & Cyclicallyadjustedgovernmentp!=.
replace alesina_exp=. if Cyclicallyadjustedgovernmentp==.



*Create political reform predictor variables
* Any election (executive or legislative)
gen any_elec=exelec+legelec
replace any_elec=1 if any_elec==2

*ideological position of gov.
replace ngov6seat=. if ngov6seat==0
replace ngov5seat=. if ngov5seat==0
replace ngov4seat=. if ngov4seat==0
replace ngov3seat=. if ngov3seat==0
replace ngov2seat=. if ngov2seat==0
replace ngov1seat=. if ngov1seat==0
gen ideol_gov6=(ngov6seat*ngov6rlc)
gen ideol_gov5=(ngov5seat*ngov5rlc)
gen ideol_gov4=(ngov4seat*ngov4rlc)
gen ideol_gov3=(ngov3seat*ngov3rlc)
gen ideol_gov2=(ngov2seat*ngov2rlc)
gen ideol_gov1=(ngov1seat*ngov1rlc)
replace ideol_gov6=0 if ideol_gov6==.
replace ideol_gov5=0 if ideol_gov5==.
replace ideol_gov4=0 if ideol_gov4==.
replace ideol_gov3=0 if ideol_gov3==.
replace ideol_gov2=0 if ideol_gov2==.
replace ideol_gov1=0 if ideol_gov1==.
gen ideol_gov=(ideol_gov1+ideol_gov2+ideol_gov3+ideol_gov4+ideol_gov5+ideol_gov6)/nnum_gov_seats
drop ideol_gov6-ideol_gov1

*ideological fragmentation of gov.
gen polfrag1=((ngov1seat/nnum_gov_seats)*(ngov1rlc-ideol_gov)^2)
gen polfrag2=((ngov2seat/nnum_gov_seats)*(ngov2rlc-ideol_gov)^2)
gen polfrag3=((ngov3seat/nnum_gov_seats)*(ngov3rlc-ideol_gov)^2)
gen polfrag4=((ngov4seat/nnum_gov_seats)*(ngov4rlc-ideol_gov)^2)
gen polfrag5=((ngov5seat/nnum_gov_seats)*(ngov5rlc-ideol_gov)^2)
gen polfrag6=((ngov6seat/nnum_gov_seats)*(ngov6rlc-ideol_gov)^2)
replace polfrag1=0 if polfrag1==.
replace polfrag2=0 if polfrag2==.
replace polfrag3=0 if polfrag3==.
replace polfrag4=0 if polfrag4==.
replace polfrag5=0 if polfrag5==.
replace polfrag6=0 if polfrag6==.
gen polfrag=polfrag1+polfrag2+polfrag3+polfrag4+polfrag5+polfrag6
replace polfrag=. if ngov1rlc==. & ngov2rlc==. & ngov3rlc==. & ngov4rlc==. & ngov5rlc==. & ngov6rlc==.
drop polfrag1-polfrag6

*maximum ideological distance in gov.
gen max_dist=max(ngov1rlc, ngov2rlc, ngov3rlc, ngov4rlc, ngov5rlc, ngov6rlc)-min(ngov1rlc, ngov2rlc, ngov3rlc, ngov4rlc, ngov5rlc, ngov6rlc)

*efective number of gov. parties
gen shareseats1=(ngov1seat/nnum_gov_seats)^2
gen shareseats2=(ngov2seat/nnum_gov_seats)^2
gen shareseats3=(ngov3seat/nnum_gov_seats)^2
gen shareseats4=(ngov4seat/nnum_gov_seats)^2
gen shareseats5=(ngov5seat/nnum_gov_seats)^2
gen shareseats6=(ngov6seat/nnum_gov_seats)^2
replace shareseats1=0 if shareseats1==.
replace shareseats2=0 if shareseats2==.
replace shareseats3=0 if shareseats3==.
replace shareseats4=0 if shareseats4==.
replace shareseats5=0 if shareseats5==.
replace shareseats6=0 if shareseats6==.
gen engp=1/(shareseats1+shareseats2+shareseats3+shareseats4+shareseats5+shareseats6)
drop shareseats1-shareseats6

* create lags of reform predictors
foreach var of varlist prod_ref lab_ref gcf_gdp g_hc Cyclicallyadjustedgovernmentp Outputgap outpg dly Unemploymentrate Inflationrate  ideol_gov polfrag ///
                       max_dist engp BP_adj_exp exp adj legelec exelec any_elec yrsoffc sep_te sep_re {
by identifier, sort: gen l_`var'=l.`var'
}

*Duration dependence variables
//Time since last reform: (for product market reforms)
sort country year
generate t=0
by country: replace t=cond((prod_ref==0 & prod_ref[_n-1]==1)|prod_ref[_n-1]==.,1,t[_n-1]+1)
replace t=. if prod_ref==.
replace t=0 if t[_n-1]==. & prod_ref==1
order t, after(prod_ref)
gen t2=t^2
gen t3=t^3
order t2, after(t)
order t3, after(t2)

//Time since last reform: (for labour market reforms)
sort country year
generate t_l=0
by country: replace t_l=cond((lab_ref==0 & lab_ref[_n-1]==1)|lab_ref[_n-1]==.,1,t_l[_n-1]+1)
replace t_l=. if lab_ref==.
replace t_l=0 if t_l[_n-1]==. & lab_ref==1
order t_l, after(lab_ref)
gen t2_l = t_l^2
gen t3_l = t_l^3
order t2_l, after(t_l)
order t3_l, after(t2_l)


//Time since last joint reform:
sort country year
generate t_j=0
by country: replace t_j=cond((ref_interaction==0 & ref_interaction[_n-1]==1)|ref_interaction[_n-1]==.,1,t_j[_n-1]+1)
replace t_j=. if ref_interaction==.
replace t_j=0 if t_j[_n-1]==. & ref_interaction==1
order t_j, after(ref_interaction)
gen t2_j = t_j^2
gen t3_j = t_j^3
order t2_j, after(t_j)
order t3_j, after(t2_j)
