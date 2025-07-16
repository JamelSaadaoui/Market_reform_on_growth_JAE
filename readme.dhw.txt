Jakob de Haan and Rasmus Wiese, "The Impact of Product and Labour
Market Reforms on Growth: Evidence for OECD Countries Based on Local
Projections", Journal of Applied Econometrics, Vol. 37, No. 4, 2022,
pp. 746-770.

All data are in the file deH_W_data.csv. (and deH_W_data.dta to ease
replication with the associated STATA do.files). 

The data form an unbalanced macroeconomic panel dataset that includes
data on the following 25 countries:

  Australia, Austria, Belgium, Canada, Czech Republic, Denmark,
  Finland, France, Germany, Greece, Iceland, Ireland, Italy,
  Japan,Luxembourg, Netherlands, New Zealand, Norway, Portugal,
  Republic of Korea, Spain, Sweden, Switzerland, United Kingdom, and
  United States

Below are details on every variable included in the dataset:
 
"country" -- the country

"year" -- the year in calendar time

"Cyclicallyadjustedgovernmentp" -- the cyclically adjusted primary
balance in percent of potential GDP. OECD-Economic Outlook No. 103.
Variable code: NLGXQA.
https://www.oecd-ilibrary.org/economics/data/oecd-economic-outlook-statistics-and-projections/oecd-economic-outlook-no-103-edition-2018-1_494f29a4-en

"BP_adj_exp" -- the indicator of structural breaks in the cyclically
adjusted primary balance in percent of potential GDP. BP_adj_exp=1
indicates an upward structural break, BP_adj_exp=-1 indicates a
downward structural break. This variable is constructed by running the
Bai & Perron endogenous structural break filter on the individual
times series for each country's cyclically adjusted primary balance in
percent of potential GDP, see paper for details.
 
"GeneralgovernmentdebttoGDPr" -- the general government debt-to-GDP
ratio. IMF- World Economic Outlook April 2018. Variable code:
GGXWDG_NGDP.
https://www.imf.org/external/pubs/ft/weo/2018/01/weodata/index.aspx 

"Inflationrate" -- the annual growth rate in the consumer price index.
IMF International Financial Statistics. Variable code: PCPI_PC_PP_PT.
http://data.imf.org/?sk=4C514D48-B6BA-49ED-8AB9-52B0C1A0179B&sId=1501617220735

"Outputgap" -- the outpus gap. IMF- World Economic Outlook April 2018.
Variable code: NGAP_NPGDP.
https://www.imf.org/external/pubs/ft/weo/2018/01/weodata/index.aspx

"Unemploymentrate" -- the unemployment rate. IMF International
Financial Statistics. Variable code: LUR_PT. 
http://data.imf.org/?sk=4C514D48-B6BA-49ED-8AB9-52B0C1A0179B

"Shortterminterestrates" -- the short term interest rate. OECD- Main
Economic Indicators (2018). Variable code: STINT.
https://data.oecd.org/interest/short-term-interest-rates.htm

"EPLregularworkers" -- employment protection legislation reforms of
regular workers.

"EPLtemporaryworkers" -- employment protection legislation reforms of
temporary workers.

"Unemploymentbenefitsoverall" -- unemployment benefit reforms overall.

"Unemploymentbenefitsreplaceme" -- unemployment benefit reforms of
replacement rates.

"Unemploymentbenefitsduration" -- unemployment benefit reforms of
unemployment duration.

"Electricity", "Gas", "Telecommunications", "PostalServices",
"RailTransport", "RoadTransport" -- reforms in the respective product
markets.

"pop" -- the population size in millions. Feenstra, R.C., Inklaar, R.,
& Timmer, M.P. (2015).
https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt9.0 

"emp" -- the number of persons engaged (in millions). Feenstra, R.C.,
Inklaar, R., & Timmer, M.P. (2015).
https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt9.0

"hc" -- the human capital index, based on years of schooling and
returns to education. Feenstra, R.C., Inklaar, R., & Timmer, M.P.
(2015). https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt9.0

"rgdpna" -- the real GDP at constant 2017 national prices (in mil.
2017US$). Feenstra, R.C., Inklaar, R., & Timmer, M.P. (2015).
https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt9.0

"rkna" -- the capital services at constant 2017 national prices
(2017=1). Feenstra, R.C., Inklaar, R., & Timmer, M.P. (2015).
https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt9.0

"Ngov1rlc", "Ngov2rlc", "Ngov3rlc", "Ngov4rlc", "Ngov5rlc", "Ngov6rlc"
-- the coding of right, left or centre government ideology from the
largest government party to the smallest. left=1, centre=2, right=3.
The authors own update of the Database of Political Institutions (DPI
2015)

"ngov1seat", "ngov2seat", "ngov3seat", "ngov4seat", "ngov5seat",
"ngov6seat" -- the number of seats held by each party from the
largest government party to the smallest. The authors own update of
the Database of Political Institutions (DPI 2015)

"nnum_gov_seats" -- the total number of seats held by the government.
The authors own update of the Database of Political Institutions (DPI
2015)

"yrsoffc" -- chief executive years in office. DPI 2015

"legelec" -- legislative election held. The authors own update of the
Database of Political Institutions (DPI 2015)

"exelec" -- presidential election held. The authors own update of the
Database of Political Institutions (DPI 2015)

"sep_re" -- the Strictness of employment protection for regular
employment. OECD - Employment and Labour Market Statistics.
https://www-oecd-ilibrary-org.proxy-ub.rug.nl/employment/data/oecd-employment-and-labour-market-statistics_lfs-data-en
 
"sep_te" -- the Strictness of employment protection for temporary
employment. OECD - Employment and Labour Market Statistics.
https://www-oecd-ilibrary-org.proxy-ub.rug.nl/employment/data/oecd-employment-and-labour-market-statistics_lfs-data-en

"EU15" -- the output gap of the EU core 15 countries. AMECO.
https://dashboard.tech.ec.europa.eu/qs_digit_dashboard_mt/public/sense/app/667e9fba-eea7-4d17-abf0-ef20f6994336/sheet/f38b3b42-402c-44a8-9264-9d422233add2/state/analysis/

The following Stata .do files are also included:

  AIPW-conditional-IR-plots.do
  AIPW-unconditional-tables-plots.do
  Dataset_jae.do
  descriptive-tables-figures.do
  Estimation-propensity-scores.do
  Placebo-lab-ref-unconditional.do
  Placebo-prod-ref-loose.do
  structural-growth-IR-plots.do

Like the .csv file, these are ASCII files in DOS format.
