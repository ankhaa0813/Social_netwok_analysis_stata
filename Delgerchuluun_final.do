*==================================================================================================
						*Social network analysis around COVID-19 in Twitter
								*Stata for evidence based economic policy
									  *Final assignment

								*Ankhbayar Delgerchuluun
								         *12211529
										 
										 *2023-03-15
*==================================================================================================

*******                            CONTENT of DO file 

*______                   1. Preparing and merging datasets 
*______                   2. Preparing desctiptive statistics
*______                   3. Defining the topics
*______                   4. Drawing figures
*______                   5. Network analysis using nwcommands


                           * 1. Preparing and merging datasets 
                           * ---------------------------------
						   
*Additional packages
*ssc install nwcommands 
*ssc install grc1leg
*ssc install schemepack

	***Defining the paths using global macros. All data files and xls templates of results are saved in data folder while all the results and other files are located in the data folder. 
	
global datadir "C:\Users\USER\OneDrive\Documents\stata course\sna\data"
global workdir "C:\Users\USER\OneDrive\Documents\stata course\sna\work"

	*** Converting data from xls to dta
* Year- 2020
foreach  i of numlist 14 15 16 17 18 19 20 21{

import excel "$datadir\2020-03-11-`i'.xlsx", sheet("2020-03-11-`i'") firstrow

	save "$datadir\2020-03-11-`i'.dta", replace
clear
}
* Year- 2021
foreach  i of numlist 17 18 19 20 21{

import excel "$datadir\2021-03-11-`i'.xlsx", sheet("2021-03-11-`i'") firstrow

	save "$datadir\2021-03-11-`i'.dta", replace
clear
}

	*** Mergind dta files
* Year- 2020
use  "$datadir\2020-03-11-14.dta", replace

foreach  i of numlist  14 15 16 17 18 19 20 21 {
   append using "$datadir\2020-03-11-`i'.dta", force nonotes nolabel
}

count
* Year- 2021
foreach  i of numlist 17 18 19 20 21 {
    
   append using "$datadir\2021-03-11-`i'.dta", force nonotes nolabel

}
count 
	***Removing irrelevant variables from the dataset
keep id conversation_id referenced_tweetsreplied_toid referenced_tweetsretweetedid referenced_tweetsquotedid author_id in_reply_to_user_id in_reply_to_username retweeted_user_id retweeted_username quoted_user_id quoted_username created_at text lang public_metricsreply_count public_metricsretweet_count public_metricsquote_count public_metricslike_count reply_settings authorcreated_at authorusername authorname authorlocation authorprotected authorpublic_metricsfollowers_ authorpublic_metricsfollowing_ authorpublic_metricslisted_cou authorpublic_metricstweet_coun authorverified authorverified_type created_at

save "$datadir\data.dta", replace

                           * 2. Preparing desctiptive statistics
                           * ---------------------------------

	***Creating time variables because twitter saved date variables in different format and these variables are used to prepare descriptive statistics
use "$datadir\data.dta", replace

*Year-Month-Day-Hour-Minute-Second variable
gen str date_str= substr(created_at, 1,4)+ " " + substr(created_at, 6,2)+ " " + substr(created_at, 9,2)+ " " + substr(created_at, 12,8)
gen double date=clock(date_str, "Y M D hms")
*Formatting
format date %tc
list date in 1/10

*Year
gen str year= substr(created_at, 1,4)
destring year, replace
list year in 1/10

*Hour
gen str hours= substr(created_at, 12, 2)
destring hours, replace
list hours in 1/10

*Minutes
gen str minutes= substr(created_at, 15, 2)
destring minutes, replace
list minutes in 1/10

	***Copying template from the data directory to the working directory to export the descriptive statistics to the xls file
copy "$datadir\result_template.xlsx" "$workdir\results.xlsx", replace

*Preparing descriptive statistic- Table 1 Column 1 - number of tweets
preserve
keep if year==2020
collapse (count) id, by(year hour)
replace id=id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(c5) keepcellfmt
restore

preserve
keep if year==2021
collapse (count) id, by(year hour)
replace id=id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(c14) keepcellfmt
restore

*Preparing descriptive statistic- Table 1 Column 5 number of unique users
preserve
keep if year==2020
duplicates drop author_id, force
collapse (count) author_id, by(year hour)
replace author_id=author_id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(g5) keepcellfmt
restore

preserve
keep if year==2021
duplicates drop author_id, force
collapse (count) author_id, by(year hour)
replace author_id=author_id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(g14) keepcellfmt
restore

	***2nd step- keeping tweets in English
tab lan 
keep if lan=="en"

*Preparing descriptive statistic- Table 1 Column 2 - number of tweets
preserve
keep if year==2020
collapse (count) id, by(year hour)
replace id=id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(d5) keepcellfmt
restore

preserve
keep if year==2021
collapse (count) id, by(year hour)
replace id=id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(d14) keepcellfmt
restore

*Preparing descriptive statistic- Table 1 Column 6 number of unique users
preserve
keep if year==2020
duplicates drop author_id, force
collapse (count) author_id, by(year hour)
replace author_id=author_id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(h5) keepcellfmt
restore

preserve
keep if year==2021
duplicates drop author_id, force
collapse (count) author_id, by(year hour)
replace author_id=author_id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(h14) keepcellfmt
restore

	***3rd step-removing original tweets
gen relationship=0

replace relationship=1 if retweeted_user_id!=. | quoted_user_id!=. | in_reply_to_user_id!=.
keep if relationship==1

*Preparing descriptive statistic- Table 1 Column 3 - number of tweets
preserve
keep if year==2020
collapse (count) id, by(year hour)
replace id=id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(e5) keepcellfmt
restore
preserve
keep if year==2021
collapse (count) id, by(year hour)
replace id=id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(e14) keepcellfmt
restore

*Preparing descriptive statistic- Table 1 Column 7 number of unique users
preserve
keep if year==2020
duplicates drop author_id, force
collapse (count) author_id, by(year hour)
replace author_id=author_id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(i5) keepcellfmt
restore

preserve
keep if year==2021
duplicates drop author_id, force
collapse (count) author_id, by(year hour)
replace author_id=author_id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(i14) keepcellfmt
restore

	***Removing duplicated relationships

gen original_name="."

replace original_name=in_reply_to_username if in_reply_to_user_id!=.
replace original_name=quoted_username if quoted_user_id!=.
replace original_name=retweeted_username if retweeted_user_id!=.

gen original_user_id=.

replace original_user_id=in_reply_to_user_id if in_reply_to_user_id!=.
replace original_user_id=quoted_user_id if quoted_user_id!=.
replace original_user_id=retweeted_user_id if retweeted_user_id!=.

duplicates drop original_user_id author_id, force

*Preparing descriptive statistic- Table 1 Column 4 - number of tweets
preserve
keep if year==2020
collapse (count) id, by(year hour)
replace id=id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(f5) keepcellfmt
restore

preserve
keep if year==2021
collapse (count) id, by(year hour)
replace id=id/1000
drop year hour
export excel using "$workdir\results.xlsx", sheet("Descriptive", modify) cell(f14) keepcellfmt
restore

                           * 3. Defining the topics 
                           * ---------------------------------

*creating a new variable
gen topic=.

*defining its label
label define topic_lb ///
	1 "Drug search" ///
	2 "News" ///
	3 "Losses" ///
	4 "Economy" ///
	5 "Lockdown" ///
	6 "Updated cases" ///
, replace
 label values  topic topic_lb

*I used strpos command to tag tweets that contain the key words of certain topics

*Topic 1 Drug research

replace topic=1  if strpos(text, "vaccine") |  strpos(text, "study") | strpos(text, "community")  |  strpos(text, "administration") | strpos(text, "control") |  strpos(text, "bill") | ///
strpos(text, "symptom") |  strpos(text, "talk") | ///
strpos(text, "drug") |  strpos(text, "research")

*Topic 2 News

replace topic=2  if strpos(text, "records") |  strpos(text, "everyone") | strpos(text, "hour") | ///
strpos(text, "member") | strpos(text, "vote") |  strpos(text, "fight") | ///
strpos(text, "India") |  strpos(text, "staff") | strpos(text, "America") |  strpos(text, "measure")

*Topic 3 Lossess

replace topic=3  if strpos(text, "business") |  strpos(text, "worker") | strpos(text, "fund") | ///
strpos(text, "look") | strpos(text, "service") |  strpos(text, "Italy") | ///
strpos(text, "employee") |  strpos(text, "market") | strpos(text, "support") |  strpos(text, "relief")

*Topic 4 Economy	

replace topic=4  if strpos(text, "economy") |  strpos(text, "nation") | strpos(text, "anyone") | ///
strpos(text, "rate") | strpos(text, "return") |  strpos(text, "border") | ///
strpos(text, "system") |  strpos(text, "supply") | strpos(text, "advice") |  strpos(text, "read")

*Topic 5 Lockdown	

replace topic=5  if strpos(text, "minister") |  strpos(text, "question") | strpos(text, "travel") | ///
strpos(text, "update") | strpos(text, "cover") |  strpos(text, "face") | ///
strpos(text, "watch") |  strpos(text, "lockdown") | strpos(text, "message") |  strpos(text, "warn")

*Topic 6 Updated cases

replace topic=6  if strpos(text, "hospital") |  strpos(text, "number") | strpos(text, "confirm") | ///
strpos(text, "country") | strpos(text, "increase") |  strpos(text, "person") | ///
strpos(text, "issue") |  strpos(text, "patient") | strpos(text, "action") |  strpos(text, "official")

tab topic year

save "$datadir\data_temp1.dta", replace

                           * 4. Drawing figures
                           * --------------------------------- 

	**Figure 1 Number of tweets and unique users over time
*Left panel for number of tweets
use "$datadir\data_temp1.dta", replace	
preserve 
*Transforming dataset to more suitable format by collapsing it
collapse (count) id, by(year hour)
*Defining a new variable for year

gen year20=id/1000 if year==2020
label var year20 "2020"
gen year21=id/1000 if year==2021
label var year21 "2021"
drop if id<100
*converting long data to wide format. I tried to use the reshape command but it wasn't suitable for data and purpose. So I decided to merge two datasets after I split them by the year
save "$workdir\figure1.dta", replace
keep if year==2020
drop year21
save "$workdir\2020.dta", replace
use "$workdir\figure1.dta", replace
keep if year==2021
drop year20
merge 1:1 hour using "$workdir\2020.dta"
keep if hour<22
sort hour
*Drawing bar graph for number of tweeets 
twoway (line year20 hour) (line  year21 hour), scheme(cblind1)  title(Tweets) name(tweets, replace) legend(rows(1)) xtitle("") plotregion(margin(zero)) xlabel(14(1)21) legend(size(*1.2))
restore 

*Right panel for number of unique users
preserve 
duplicates drop author_id hour, force
collapse (count) id, by(year hour)
gen year20=id/1000 if year==2020
 label var year20 "2020"
gen year21=id/1000 if year==2021
 label var year21 "2021"
drop if id<100
save "$workdir\figure1.dta", replace
keep if year==2020
drop year21
save "$workdir\2020.dta", replace
use "$workdir\figure1.dta", replace
keep if year==2021
drop year20
merge 1:1 hour using "$workdir\2020.dta"
sort hour
*twoway (line year20 hour, lcolor(blue)) (line  year21 hour, lcolor(maroon)), graphregion(fcolor(white) lcolor(none%99) ifcolor(white%0)) plotregion(fcolor(white) ifcolor(none)) title(Unique users) name(users, replace)
twoway (line year20 hour) (line  year21 hour), scheme(cblind1) title(Unique users) name(users, replace) legend(rows(1)) xtitle("")  plotregion(margin(zero))  xlabel(14(1)21) legend(size(*1.2))
restore 

*Combining two graphs and while showing aggregated legend for graphs
grc1leg users tweets,  rows(1) scheme(cblind1)  iscale(1)  ysize(5) xsize(12) ycommon graphregion(margin(zero))

*exporting graph as png file
graph export "$workdir\Figure1.png", as(png) name("Graph") replace

	**Figure 2 Number of tweets by subtopics and year
	
*Drawing bar graph for unique users
graph bar (count) id, over(year, label(labsize(vsmall))) over(topic, label(labsize(small)))  scheme(cblind1) ytitle("")
*Exporting the graphs
 graph export "$workdir\Figure2.png", as(png) name("Graph") replace
	

 
                           * 5. Network analysis using nwcommands
                           * ---------------------------------

use "$datadir\data_temp1.dta", replace
*Removing tweets before the WHO's media briefing. All the times of the dataset are recorded in UTC zone.

keep if hour>16

	***Randomization 

	***Defining a seed to get same results from the randomizaiton
	
set seed 20220315
gen random=runiform()
sort random 

	***I randomly selected 1000 users based on author_id which is unique for each users. To do this, I created random variable and selected users which has highest 1000 random number. 

*sample 1000, count
*sort topic



foreach  j of numlist 2020 2021 {
	
    foreach  i of numlist 1 2 3 4 5 6 {
    preserve
	keep if year==`j' 
	*Keeping tweets that belongs to certain topic
	keep if topic == `i' 
	*To get unique users, removed the duplicates from the datasets 
	duplicates drop author_id, force
	sort random
	*users which has highest random number
    gen insample_`j'_`i'=_n<=1000
	keep if insample_`j'_`i'==1
	save "$datadir\sample_`j'_`i'.dta", replace
	duplicates report author_id
	restore
}

}

	***Merging master datasets with randomly selected users information. Since each person have multiple tweets, m:1 option is used

foreach j of numlist 2020 2021 {
  foreach  i of numlist 1 2 3 4 5 6 {
	merge m:1 author_id using "$datadir\sample_`j'_`i'.dta"
    drop _merge
}
	
}

save "$datadir\data_temp2.dta", replace


	***Defining network and its descriptive statisitcs, and drawing plots

*First loop run through two different years
foreach  i of numlist 2020 2021 {
  use "$datadir\data_temp2.dta", replace
  *keeping certain year's data
  keep if year==`i'
  *I used the putexcel function to export the descriptive statistics of the networks and here defined a corresponding sheet and xls files
  
  putexcel set "$workdir\results.xlsx", modify  sheet("Networks_`i'")
  
  foreach  j of numlist 1 2 3 4 5 6 {
  *Second loop run through 6 topics and create network datasets for each of it
  preserve
  *Keeping key variables
  keep original_name authorusername insample_`i'_`j'
  *Sampled users and their tweets 
  keep if insample_`i'_`j'==1
  *Droping missing values to use nwcommands
  drop if original_name==""
  
   scalar drop _all
  *Creating network data set from edgelist which consists of two variables of two user name. Each row of the edgelist indicates one connection between corresponding actors.

  nwfromedge authorusername original_name, name(topic_`i'_`j')
  *defining the variable which contains the information about hte key users 
    gen keyusers=0
	replace keyusers=1 if _nodelab=="WHO"
	replace keyusers=2 if _nodelab=="CNN"
	replace keyusers=3 if _nodelab=="realDonaldTrump"
	replace keyusers=4 if _nodelab=="BBCNews"
	replace keyusers=5 if _nodelab=="UN"
	replace keyusers=6 if _nodelab=="DrTedros"
label define keyusers_lb ///
	0 "Users" ///
	1 "WHO" ///
	2 "CNN" ///
	3 "DonaldTrump" ///
	4 "BBCNews" ///
	5 "UN" ///
	6 "DrTedros" ///
, replace
   label values  keyusers keyusers_lb
   *Plotting the network while defining the color by keyusers 
    local tname "Drug search" "News" "Losses" "Economy" "Lockdown" "Updated cases"
	nwplot topic_`i'_`j', color(keyusers) name(topic_`i'_`j', replace) title(Topic `j')  legend(size(*0.8)) scheme(cblind1)
	graph export "$workdir\topic_`i'_`j'.png", as(png) name(topic_`i'_`j') replace
	
  *Estimating descriptive statistics of the network and exporting it to assigned xls file using putexcel function
  nwsummarize topic_`i'_`j', detail
  return list
  scalar   nodes=r(nodes)
  putexcel B`j'=nodes
  scalar   arcs=r(arcs)
  putexcel C`j'=arcs
  scalar   indg_central=r(indg_central)
  putexcel D`j'=indg_central
  scalar   outdg_central= r(outdg_central)
  putexcel E`j'=outdg_central
  scalar   bw_central= r(bw_central)
  putexcel F`j'=bw_central
  scalar   density=r(density)
  putexcel G`j'=density
  scalar   transitivity=r(transitivity)
  putexcel H`j'=transitivity
  scalar   reciprocity= r(reciprocity)
  putexcel I`j'=reciprocity

  restore
}

}
*Combining 6 graphs into one 
grc1leg topic_2020_1 topic_2020_2 topic_2020_3 topic_2020_4 topic_2020_5 topic_2020_6,  rows(2)  scheme(cblind1) iscale(0.4) imargin(0 0 0 0)
*Exporting the combined graph
graph export "$workdir\sna_2020.png", as(png) name("Graph") replace

grc1leg topic_2021_1 topic_2021_2 topic_2021_3 topic_2021_4 topic_2021_5 topic_2021_6,  rows(2)  scheme(cblind1) iscale(0.4) imargin(0 0 0 0)
graph export "$workdir\sna_2021.png", as(png) name("Graph") replace