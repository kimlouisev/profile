********************************************************************************
* 		Title: 		REGRESSION DISCONTINUITY EXERCISE
*					Columbia University
* 		Authors:	Kim Vidal (kbv2109)
*		Date: 		Nov 12, 2024
********************************************************************************


*************************
* Set working directory *
*************************

clear all

cd "/Users/kimvidal/Library/CloudStorage/GoogleDrive-kimlouise.vidal@gmail.com/My Drive/01 Grad School at Columbia/01 Academics/05 Fall 2024/Applied Econ/3 Assignment/Stata Assignment 2"

use "AEJfigs.dta"


************** 
* Question 2 *
**************

* Graphical analysis, binned averages of outcome as a function of age in months

	// Running variable is age cell, cutoff at 21
	twoway (scatter all agecell if agecell<21, mcolor(gs12)) ///
			(scatter all agecell if agecell>=21, mcolor(gs12)) ///
		   (lfit all agecell if agecell<21, lcolor(blue)) ///
		   (lfit all agecell if agecell>=21, lcolor(red)), ///
		   xline(21)  xtitle("Age") ytitle("Mortality (all)")

	graph export "graphs/unbinned averages.jpg", replace

		   
* Binned averages
	
	// First create bins
	egen xbin = cut(agecell), at(19(0.08)23)  // to get 24 bins across two years, as in the paper
	bysort xbin: egen ymean = mean(all)
	bysort xbin: egen xmean = mean(agecell)

	// Plot binned averages with linear fit
	twoway (scatter ymean xmean if xmean<21, mcolor(gs12)) ///
		   (scatter ymean xmean if xmean>=21, mcolor(gs12)) ///
			(lfitci all agecell if agecell<21, ///
				lcolor(blue) ciplot(rline) blcolor(blue) blpattern(dash)) ///
			(lfitci all agecell if agecell>=21, ///
				lcolor(red) ciplot(rline) blcolor(red) blpattern(dash)), ///
		   xline(21) xtitle("Age") ///
		   ytitle("Mortality rate from all causes (per 100,000)") ///
		   legend(order(1 "Data" 4 "Below 21" 6 "Above 21")) ///
	title("Binned averages of mortality" "as a function of age in months")

	graph export "graphs/binned averages.jpg", replace
	
	tab agecell, sum(all)
	display 105.26835 - 94.269913
	
	
************** 
* Question 3 *
**************

* Exploring several RDD econometric specifications

	* Specification 1: linear w/o interaction terms
	* Specification 2: linear w interaction terms
	* Specification 3: quadratic w/o interaction terms
	* Specification 4: quadratic w/ interaction terms
	
	* Note: Need to restrict from ages 20-22 y/o, and center age around 0
	* Create tables and graphs
	
***

* 


* Gen new variables

	// Use new running var
	gen age = agecell - 21
	gen over21 = age >= 0
	
	// Create squared term
	gen age_sq = age * age
	
	// Create interaction terms
	gen ageXover21 = age * over21
	gen age_sqXover21 = age_sq * over21

	
* Create linear specifications
	
	* Specification 1: linear w/o interaction terms
	reg all over21 age, robust
	predict all_hat5
	est store all_hat5
	
	* Specification 2: linear w interaction terms
	reg all over21 age ageXover21, robust
	predict all_hat6
	est store all_hat6
	
	* Format regression output 

	etable, estimates(all_hat5 all_hat6) ///
		showstars showstarsnote ///
		title("Linear Specifications_19 to 23") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", replace sheet(Sheet1))

		
	*  Overlaying different specifications in one graph
		
		twoway ///
			(scatter all age, mcolor(gs12)) ///
			(line all_hat5 age if over21==0, lcolor(blue)) ///
			(line all_hat5 age if over21==1, lcolor(blue)) ///
			(line all_hat6 age if over21==0, lcolor(red)) ///
			(line all_hat6 age if over21==1, lcolor(red)), ///
		   legend(order(1 "Data" 2 "Fit 1: No Interaction" 4 "Fit 2: With Interaction")) ///
			xline(0) ///
			ytitle("Mortality rate from all causes (per 100,000)") ///
			title("Linear RDD Specifications on Mortality" "(19-23 y/o)")
			
		graph export "graphs/linear specifications_19to23.jpg", replace		
	
	
	/// 	yscale(range(0 .)) ylabel(0(20)120) ///

			
			
* Create quadratic specifications
		
		
	* Specification 3: quadratic w/o interaction terms
	reg all over21 age age_sq, robust 
	predict all_hat7
	est store all_hat7
	
	* Specification 4: quadratic w/ interaction terms
	reg all over21 age age_sq ageXover21 age_sqXover21, robust 
	predict all_hat8
	est store all_hat8

	* Format regression output 

	etable, estimates(all_hat7 all_hat8) ///
		showstars showstarsnote ///
		title("Quadratic Specifications_19 to 23") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", modify sheet(Sheet2))
		
	*  Overlaying different specifications in one graph
				
		twoway ///
			(scatter all age, mcolor(gs12)) ///
			(line all_hat7 age if over21==0, lcolor(blue)) ///
			(line all_hat7 age if over21==1, lcolor(blue)) ///
			(line all_hat8 age if over21==0, lcolor(red)) ///
			(line all_hat8 age if over21==1, lcolor(red)), ///
		   legend(order(1 "Data" 2 "Fit 1: No Interaction" 4 "Fit 2: With Interaction")) ///
			xline(0) ///
			ytitle("Mortality rate from all causes (per 100,000)") ///
			title("Quadratic RDD Specifications on Mortality" "(19-23 y/o)")
		
		graph export "graphs/quadratic specifications_19to23_all.jpg", replace 
		
		
	* Combine all regression specifications 

	etable, estimates(all_hat5 all_hat6 all_hat7 all_hat8) ///
		showstars showstarsnote ///
		title("Linear and Quadratic Specifications (19-23 y/o)") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", modify sheet(Sheet3))




* Drop ages below 20 and above 22

preserve

	drop if agecell<20 | agecell>22

	
* Create linear specifications
	
	* Specification 1: linear w/o interaction terms
	reg all over21 age, robust
	predict all_hat1
	est store all_hat1
	
	* Specification 2: linear w interaction terms
	reg all over21 age ageXover21, robust
	predict all_hat2
	est store all_hat2
	
	* Format regression output 

	etable, estimates(all_hat1 all_hat2) ///
		showstars showstarsnote ///
		title("Linear Specifications_20 to 22") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", modify sheet(Sheet4))

		
	*  Overlaying different specifications in one graph
		
		twoway ///
			(scatter all age, mcolor(gs12)) ///
			(line all_hat1 age if over21==0, lcolor(blue)) ///
			(line all_hat1 age if over21==1, lcolor(blue)) ///
			(line all_hat2 age if over21==0, lcolor(red)) ///
			(line all_hat2 age if over21==1, lcolor(red)), ///
			legend(order(1 "Data" 2 "Fit 1: No Interaction" 4 "Fit 2: With Interaction")) ///
			xline(0) ///
			ytitle("Mortality rate from all causes (per 100,000)") ///
			title("Linear RDD Specifications on Mortality" "(20-22 y/o)")
			
		graph export "graphs/linear specifications_20to22.jpg", replace		
	
	
	/// 	yscale(range(0 .)) ylabel(0(20)120) ///

			
			
* Create quadratic specifications
		
		
	* Specification 3: quadratic w/o interaction terms
	reg all over21 age age_sq, robust 
	predict all_hat3
	est store all_hat3
	
	* Specification 4: quadratic w/ interaction terms
	reg all over21 age age_sq ageXover21 age_sqXover21, robust 
	predict all_hat4
	est store all_hat4

	* Format regression output 

	etable, estimates(all_hat3 all_hat4) ///
		showstars showstarsnote ///
		title("Quadratic Specifications_20 to 22") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", modify sheet(Sheet5))
		
	*  Overlaying different specifications in one graph
				
		twoway ///
			(scatter all age, mcolor(gs12)) ///
			(line all_hat3 age if over21==0, lcolor(blue)) ///
			(line all_hat3 age if over21==1, lcolor(blue)) ///
			(line all_hat4 age if over21==0, lcolor(red)) ///
			(line all_hat4 age if over21==1, lcolor(red)), ///
		   legend(order(1 "Data" 2 "Fit 1: No Interaction" 4 "Fit 2: With Interaction")) ///
			xline(0) ///
			ytitle("Mortality rate from all causes (per 100,000)") ///
			title("Quadratic RDD Specifications on Mortality" "(20-22 y/o)")
		
		graph export "graphs/quadratic specifications_20to22_all.jpg", replace 
		
		
	* Combine all regression specifications 

	etable, estimates(all_hat1 all_hat2 all_hat3 all_hat4) ///
		showstars showstarsnote ///
		title("Linear and Quadratic Specifications") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", modify sheet(Sheet6))
	
restore
 
************** 
* Question 4 *
**************


* Exploring several RDD econometric specifications

	* Specification 1: quadratic w/o interaction terms
	* Specification 2: quadratic w/ interaction terms
	
	* Note: Stay with the original 19-23 y/o age range, and center age around 0
	* Use mva and internal causes separately as Y outcomes, & alcohol consumption as X variable
	* Create tables and graphs
	
***


*~~~~~~~~~*
* Alcohol *
*~~~~~~~~~*

			
* Create quadratic specifications
		
		
	* Specification 1: quadratic w/o interaction terms
	reg alcohol over21 age age_sq, robust 
	predict alcohol_hat1
	est store alcohol_hat1
	
	* Specification 2: quadratic w/ interaction terms
	reg alcohol over21 age age_sq ageXover21 age_sqXover21, robust 
	predict alcohol_hat2
	est store alcohol_hat2

	
	* Format regression output 

	etable, estimates(alcohol_hat1 alcohol_hat2) ///
		showstars showstarsnote ///
		title("Quadratic Specifications on Alcohol Consumption_19 to 23") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", modify sheet(Sheet7))
		
	*  Overlaying different specifications in one graph
				
		twoway ///
			(scatter alcohol age, mcolor(gs12)) ///
			(line alcohol_hat1 age if over21==0, lcolor(blue)) ///
			(line alcohol_hat1 age if over21==1, lcolor(blue)) ///
			(line alcohol_hat2 age if over21==0, lcolor(red)) ///
			(line alcohol_hat2 age if over21==1, lcolor(red)), ///
		   legend(order(1 "Data" 2 "Fit 1: No Interaction" 4 "Fit 2: With Interaction")) ///
			xline(0) ///
			ytitle("Alcohol Consumption") ///			
			title("Quadratic RDD Specifications on Alcohol Consumption " "(19-23 y/o)")

		graph export "graphs/quadratic specifications_alcohol.jpg", replace 

*~~~~~*
* MVA *
*~~~~~*

	* Specification 1: quadratic w/o interaction terms
	reg mva over21 age age_sq, robust 
	predict mva_hat1
	est store mva_hat1

	
	* Specification 2: quadratic w/ interaction terms
	reg mva over21 age age_sq ageXover21 age_sqXover21, robust 
	predict mva_hat2
	est store mva_hat2
	
	* Format regression output 

	etable, estimates(mva_hat1 mva_hat2) ///
		showstars showstarsnote ///
		title("Quadratic Specifications on Motor Vehicle Accidents_19 to 23") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", modify sheet(Sheet8))

	*  Overlaying different specifications in one graph
				
		twoway ///
			(scatter mva age, mcolor(gs12)) ///
			(line mva_hat1 age if over21==0, lcolor(blue)) ///
			(line mva_hat1 age if over21==1, lcolor(blue)) ///
			(line mva_hat2 age if over21==0, lcolor(red)) ///
			(line mva_hat2 age if over21==1, lcolor(red)), ///
		   legend(order(1 "Data" 2 "Fit 1: No Interaction" 4 "Fit 2: With Interaction")) ///
			xline(0) ///
			ytitle("Mortality rate from Motor Vehicle Accidents") ///
			title("Quadratic RDD Specifications on Motor Vehicle Accidents" "(19-23 y/o)") 

		graph export "graphs/quadratic specifications_mva.jpg", replace 



*~~~~~~~~~~*
* Internal *
*~~~~~~~~~~*

	* Specification 1: quadratic w/o interaction terms
	reg internal over21 age age_sq, robust 
	predict internal_hat1
	est store internal_hat1
	
	* Specification 2: quadratic w/ interaction terms
	reg internal over21 age age_sq ageXover21 age_sqXover21, robust 
	predict internal_hat2
	est store internal_hat2
	
	* Format regression output 

	etable, estimates(internal_hat1 internal_hat2) ///
		showstars showstarsnote ///
		title("Quadratic Specifications on Internal Causes of Death_19 to 23") ///
		mstat(N) mstat(r2) mstat(r2_a) ///		
		export("graphs/tables.xlsx", modify sheet(Sheet9))
	

	*  Overlaying different specifications in one graph
				
		twoway ///
			(scatter internal age, mcolor(gs12)) ///
			(line internal_hat1 age if over21==0, lcolor(blue)) ///
			(line internal_hat1 age if over21==1, lcolor(blue)) ///
			(line internal_hat2 age if over21==0, lcolor(red)) ///
			(line internal_hat2 age if over21==1, lcolor(red)), ///
		   legend(order(1 "Data" 2 "Fit 1: No Interaction" 4 "Fit 2: With Interaction")) ///
			xline(0) ///
			ytitle("Mortality rate from Internal Causes of Death") ///
			title("Quadratic RDD Specifications on Internal Causes of Death" "(19-23 y/o)")

		graph export "graphs/quadratic specifications_internal.jpg", replace

 
 
************** 
* Optional Q *
**************

//ssc install cmogram


* Graphs

	* Mortality
		cmogram all age, cut(0) scatter line(0) lfit
		cmogram all age, cut(0) scatter line(0) lowess	
		graph export "graphs/local_linear_all.jpg", replace 

		
	* Alcohol Consumption
		cmogram alcohol age, cut(0) scatter line(0) lfit
		cmogram alcohol age, cut(0) scatter line(0) lowess	
		graph export "graphs/local_linear_alcohol.jpg", replace 
		
	* Motor Vehicle Accidents
		cmogram mva age, cut(0) scatter line(0) lfit
		cmogram mva age, cut(0) scatter line(0) lowess	
		graph export "graphs/local_linear_mva.jpg", replace 
		
	* Internal Causes of Death
		cmogram internal age, cut(0) scatter line(0) lfit
		cmogram internal age, cut(0) scatter line(0) lowess		
		graph export "graphs/local_linear_internal.jpg", replace 
		

	
	
	