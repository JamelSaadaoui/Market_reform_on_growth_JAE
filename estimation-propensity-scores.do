clear all
run "dataset_jae.do"

** Dataset complete


*logit controls
global controls_prod_ref "l_outpg ldly l2dly l3dly l_gcf_gdp l_g_hc l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag t t2 t3 "

global controls_lab_ref "l_outpg ldly l2dly l3dly l_gcf_gdp l_g_hc l_prod_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag l_sep_te l_sep_re t_l t2_l t3_l"

global controls_ref_interaction "l_outpg ldly l2dly l3dly l_gcf_gdp l_g_hc l_prod_ref l_lab_ref l_exp l_adj l_Unemploymentrate l_Inflationrate  l_yrsoffc l_any_elec l_ideol_gov l_polfrag l_sep_te l_sep_re t_j t2_j t3_j"


*The probabilities with which the AIPw regressions are weighted 

sort identifier year


qui logit prod_ref $controls_prod_ref i.identifier
lroc, nograph
local a= r(area)
qui margins, dydx(_all) post
outreg2 using "table5", adds(Area under ROC curve, `a') drop(t t2 t3 i.identifier) bdec(3) pdec(3) word replace
qui logit prod_ref $controls_prod_ref i.identifier
predict pscore, pr

*figure 4
graph twoway (kdensity pscore if prod_ref==0, color(black)) (kdensity pscore if prod_ref==1, lpattern(dash) color(black)), xtitle(Estimated probability of treatment: Product market) ytitle(Frequency) legend(order(1 "Control" 2 "Treatment")) plotregion(lpattern(blank)) scheme(s1color)
drop pscore

qui logit lab_ref $controls_lab_ref i.identifier
lroc, nograph
local a= r(area)
qui margins, dydx(_all) post
outreg2 using "table5", noomitted adds(Area under ROC curve, `a') drop(t_l t2_l t3_l i.identifier) bdec(3) pdec(3) word append
qui logit lab_ref $controls_lab_ref i.identifier
predict pscore, pr

* figure 5
graph twoway (kdensity pscore if lab_ref==0, color(black)) (kdensity pscore if lab_ref==1, lpattern(dash) color(black)), xtitle(Estimated probability of treatment: Labour market) ytitle(Frequency) legend(order(1 "Control" 2 "Treatment")) plotregion(lpattern(blank)) scheme(s1color)
drop pscore

qui logit ref_interaction $controls_ref_interaction i.identifier
lroc, nograph
local a= r(area)
qui margins, dydx(_all) post
outreg2 using "table5", noomitted adds(Area under ROC curve, `a') drop(t_j t2_j t3_j i.identifier) bdec(3) pdec(3) word append
qui logit ref_interaction $controls_ref_interaction i.identifier
predict pscore, pr

*figure 6
graph twoway (kdensity pscore if ref_interaction==0, color(black)) (kdensity pscore if ref_interaction==1, lpattern(dash) color(black)), xtitle(Estimated probability of treatment: Product and labour market) ytitle(Frequency) legend(order(1 "Control" 2 "Treatment")) plotregion(lpattern(blank)) scheme(s1color)
drop pscore

