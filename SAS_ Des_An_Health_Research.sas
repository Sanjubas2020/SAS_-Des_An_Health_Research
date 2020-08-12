/*set libname as r*/

Libname r "C:\SASP\Data";
run;

/*set libname of actual XPT file*/

Libname XPTfile xport 'C:\SASP\Health\Ex_Files_SAS_EssT_Desc_Health\Exercise Files\Ch01\01_04\LLCP2014.XPT';
run;

/*data step reads it in and unpacks it into libname mapped to r*/

data r.BRFSS_a;
    set XPTfile.LLCP2014;
run;

/*verify success*/

proc contents data=r.BRFSS_a;
run;



/*Drop and keep variables*/
data r.BRFSS_b;
	set r.BRFSS_a (keep =
		VETERAN3 
		ASTHMA3
		DIABETE3
		SLEPTIM1
		_AGE_G
		SMOKE100
		SMOKDAY2
		SEX
		_HISPANC
		_MRACE1
		MARITAL
		GENHLTH
		HLTHPLN1
		EDUCA
		INCOME2
		_BMI5CAT
		EXERANY2);
run;

proc contents data = r.BRFSS_b;
run;

/*If you want to keep most of the variables, then use
the drop command instead*/

data Drop_Example;
	set r.BRFSS_a (drop =
		VETERAN3 
		ASTHMA3
		DIABETE3
		SLEPTIM1
		_AGE_G
		SMOKE100
		SMOKDAY2
		SEX
		_HISPANC
		_MRACE1
		MARITAL
		GENHLTH
		HLTHPLN1
		EDUCA
		INCOME2
		_BMI5CAT
		EXERANY2);
run; 

Proc Contents data=Drop_Example;
run;


/*proc freq without options*/

proc freq data=r.BRFSS_b;
	tables VETERAN3;
run;

/*check exclusions with the missing option*/

proc freq data=r.BRFSS_b;
	tables VETERAN3 / missing;
	tables DIABETE3 / missing;
	tables SLEPTIM1 / missing;
	tables ASTHMA3 / missing;
run;

data r.BRFSS_c;
	set r.BRFSS_b;
	if VETERAN3 = 1;
run;

/*alternative using delete option*/

data Delete_Example;
	set r.BRFSS_b;
	if VETERAN3 ne 1 then delete;
run;

/*apply diabetes exclusion*/

data r.BRFSS_d;
	set r.BRFSS_c;
	if DIABETE3 in (1, 2, 3, 4);
run;


data r.BRFSS_e;
	set r.BRFSS_d;
	if ASTHMA3 in (1, 2);
run;

/*Apply continuous exlusions*/

data r.BRFSS_f;
	set r.BRFSS_e;
	if SLEPTIM1 < 77;
run;

/*alternative using other operators*/

data Other_Operators;
	set r.BRFSS_e;
	if SLEPTIM1 ge 77 then delete;
run;

/*check exclusions*/

proc freq data=r.BRFSS_f;
	tables VETERAN3 / missing;
	tables DIABETE3 / missing;
	tables ASTHMA3 / missing;
	tables SLEPTIM1 / missing;
run;

/*removing rows if the values are missing*/

proc freq data=r.BRFSS_a;
	tables VETERAN3 /missing;
run;

/*Example of keeping only non-missing*/

data BRFSS_NoVetMissing1;
	set r.BRFSS_a;
	if VETERAN3 ne .;
run;

proc freq data=BRFSS_NoVetMissing1;
	tables VETERAN3 /missing;
run;

/*Example of deleting the missing*/

data BRFSS_NoVetMissing2;
	set r.BRFSS_a;
	if VETERAN3 = . then delete;
run;
/**/



/*/chapter 3 *Developing the Analytic Dataset*/*/

data r.BRFSS_g;
	set r.BRFSS_f;

	DIABETE4 = 9;
	
	if DIABETE3 in (1, 2) 
		then DIABETE4 = 1;
	
	if (DIABETE3 = 3 | DIABETE3 = 4)
		then DIABETE4 = 2;

run;

/*Check recode*/

/*proc freq without list option*/

proc freq data=r.BRFSS_g;
	table DIABETE3 * DIABETE4 / missing;
run;

/*Much easier to read with list option!*/

proc freq data=r.BRFSS_g;
	table DIABETE3 * DIABETE4 / list missing;
run;

/*first create NEVERSMK, then create grouping variable
based on NEVERSMK and SMOKDAY2*/

data r.BRFSS_h;
	set r.BRFSS_g;

	NEVERSMK = 0;

	if SMOKE100 = 2
		then NEVERSMK = 1;

	SMOKGRP = 9;

	if (SMOKDAY2 = 1 | SMOKDAY2 = 2)
		then SMOKGRP = 1;
	if (SMOKDAY2 = 3 | NEVERSMK = 1)
		then SMOKGRP = 2;
	
run;

/*Check recode for inconsistencies*/

proc freq data=r.BRFSS_h;
	table NEVERSMK * SMOKE100 / list missing;
	table SMOKGRP * SMOKDAY2 / list missing;
run;
/*indicator variables for age group*/

data r.BRFSS_j;
	set r.BRFSS_i;

	AGE2 = 0;
	if _AGE_G = 2
		then AGE2 = 1;

	AGE3 = 0;
	if _AGE_G = 3
		then AGE3 = 1;

	AGE4 = 0;
	if _AGE_G = 4
		then AGE4 = 1;

	AGE5 = 0;
	if _AGE_G = 5
		then AGE5 = 1;

	AGE6 = 0;
	if _AGE_G = 6
		then AGE6 = 1;

run;

proc freq data=r.BRFSS_j;
	tables AGE2*_AGE_G/list missing;
	tables AGE3*_AGE_G/list missing;
	tables AGE4*_AGE_G/list missing;
	tables AGE5*_AGE_G/list missing;
	tables AGE6*_AGE_G/list missing;
run;

/*indicator variables for income*/

data r.BRFSS_k;
	set r.BRFSS_j;

	INC1 = 0;
	if INCOME3 = 1
		then INC1 = 1;

	INC2 = 0;
	if INCOME3 = 2
		then INC2 = 1;

	INC3 = 0;
	if INCOME3 = 3
		then INC3 = 1;

	INC4 = 0;
	if INCOME3 = 4
		then INC4 = 1;

	INC5 = 0;
	if INCOME3 = 5
		then INC5 = 1;

	INC6 = 0;
	if INCOME3 = 6
		then INC6 = 1;

	INC7 = 0;
	if INCOME3 = 7
		then INC7 = 1;

run;

proc freq data=r.BRFSS_k;
	tables INC1*INCOME3/list missing;
	tables INC2*INCOME3/list missing;
	tables INC3*INCOME3/list missing;
	tables INC4*INCOME3/list missing;
	tables INC5*INCOME3/list missing;
	tables INC6*INCOME3/list missing;
	tables INC7*INCOME3/list missing;
run;



data r.BRFSS_l;
	set r.BRFSS_k;

	BLACK = 0;
	if RACEGRP = 2
		then BLACK = 1;

	ASIAN = 0;
	if RACEGRP = 4
		then ASIAN = 1;

	OTHRACE = 0;
	if RACEGRP in (3, 5, 6, 7)
		then OTHRACE = 1;

run;

proc freq data=r.BRFSS_l;
	tables BLACK*RACEGRP/list missing;
	tables ASIAN*RACEGRP/list missing;
	tables OTHRACE*RACEGRP/list missing;
run;

/*indicator variables for marital status*/

data r.BRFSS_m;
	set r.BRFSS_l;

	NEVERMAR = 0;
	if MARGRP = 3
		then NEVERMAR = 1;

	FORMERMAR = 0;
	if MARGRP = 2
		then FORMERMAR = 1;

run;

proc freq data=r.BRFSS_m;
	tables NEVERMAR*MARGRP/list missing;
	tables FORMERMAR*MARGRP/list missing;
run;

/*indicator variables for education*/

data r.BRFSS_n;
	set r.BRFSS_m;

	LOWED = 0;
	if EDGROUP in (1,2)
		then LOWED = 1;

	SOMECOLL  = 0;
	if EDGROUP = 3
		then SOMECOLL  = 1;

run;

proc freq data=r.BRFSS_n;
	tables LOWED*EDGROUP/list missing;
	tables SOMECOLL*EDGROUP/list missing;
run;

/*indicator variables for BMI*/

data r.BRFSS_o;
	set r.BRFSS_n;

	UNDWT = 0;
	if BMICAT = 1
		then UNDWT = 1;

	OVWT = 0;
	if BMICAT = 3
		then OVWT = 1;

	OBESE = 0;
	if BMICAT = 4
		then OBESE = 1;

run;

proc freq data=r.BRFSS_o;
	tables UNDWT*BMICAT/list missing;
	tables OVWT*BMICAT/list missing;
	tables OBESE*BMICAT/list missing;
run;

/*indicator variables for general health*/

data r.BRFSS_p;
	set r.BRFSS_o;

	FAIRHLTH = 0;
	if GENHLTH2 = 4
		then FAIRHLTH = 1;

	POORHLTH = 0;
	if GENHLTH2 = 5
		then POORHLTH = 1;

run;

proc freq data=r.BRFSS_p;
	tables FAIRHLTH*GENHLTH2/list missing;
	tables POORHLTH*GENHLTH2/list missing;
run;

/*indicator variables for three-level grouping variables*/

data r.BRFSS_q;
	set r.BRFSS_p;
	
	ASTHMAFLAG = 0;
	if ASTHMA3 = 1
		then ASTHMAFLAG = 1;
	
	DIABFLAG = 0;
	if DIABETE4 = 1
		then DIABFLAG = 1;

	MALE = 0;
	if SEX = 1
		then MALE = 1;

	HISPANIC = 0;
	if _HISPANC = 1
		then HISPANIC = 1;

	SMOKER = 0;
	if SMOKGRP = 1
		then SMOKER = 1;

	NOEXER = 0;
	if EXERANY3 = 1
		then NOEXER = 1;

	NOPLAN = 0;
	if HLTHPLN2 = 2
		then NOPLAN = 1;

run;

proc freq data=r.BRFSS_q;
	tables ASTHMAFLAG*ASTHMA3/list missing;
	tables DIABFLAG*DIABETE3/list missing;
	tables MALE*SEX/list missing;
	tables HISPANIC*_HISPANC/list missing;
	tables SMOKER*SMOKGRP/list missing;
	tables NOEXER*EXERANY3/list missing;
	tables NOPLAN*HLTHPLN2/list missing;
run;


*Review distribution of sleep duration*/

proc univariate data = r.BRFSS_p;
	var SLEPTIM1;
run;

/*May be helpful to look at frequencies*/

proc freq data = r.BRFSS_p;
	tables SLEPTIM1 /missing;
run;


/*Example: Create arbitrary grouping*/

data Grouping_Example;
	set r.BRFSS_p;

	SLEEPGRP = 9;

	if SLEPTIM1 le 5
		then SLEEPGRP = 1;
	if (SLEPTIM1 gt 5) & (SLEPTIM1 le 7)
		then SLEEPGRP = 2;
	if (SLEPTIM1 gt 7) & (SLEPTIM1 le 9)
		then SLEEPGRP = 3; 
	if SLEPTIM1 gt 9
		then SLEEPGRP = 4; 

	if SLEEPGRP = 1
		then SG1 = 1;
	else SG1 = 0;

	if SLEEPGRP = 2
		then SG2 = 1;
	else SG2 = 0;

	if SLEEPGRP = 3
		then SG3 = 1;
	else SG3 = 0;

	/*No SG4 - we would theoretically use SG4 as the
	reference group in a regression*/

run;

/*check recode*/

proc freq data=Grouping_Example;
	tables SLEPTIM1*SLEEPGRP/list missing;
	tables SLEEPGRP*SG1/list missing;
	tables SLEEPGRP*SG2/list missing;
	tables SLEEPGRP*SG3/list missing;
run;


proc contents varnum data = r.BRFSS_q;
run;

/*copy to a dataset named "analytic"*/
/*which will be used in subsequent code for analysis.*/

/*If variables need to be added to the analytic dataset,*/
/*that code should come before this code.*/

data r.analytic;
	set r.BRFSS_q;

run;
proc contents varnum data = r.analytic;
run;

/*chapyer 4 helpful plots*/

/*Creating bar chart*/

/*One group*/
proc gchart data=r.analytic;
	vbar DIABETE4 / discrete type=percent;
	run;
quit;

/*two groups*/
proc gchart data=r.analytic;
	vbar DIABETE4 / discrete type=percent subgroup = ASTHMA3;
	run;
quit;



/*Diabetes in a pie chart*/

proc gchart data=r.analytic;
        pie DIABETE4 / DISCRETE 
		VALUE=INSIDE
        PERCENT=INSIDE 
		SLICE=OUTSIDE;
RUN;

/*Age groups*/

proc gchart data=r.analytic;
        pie _AGE_G / DISCRETE 
		VALUE=INSIDE
        PERCENT=INSIDE 
		SLICE=OUTSIDE;
RUN;


/*Histogram of SLEPTIM1 (sleep duration) with 7 levels*/
/*in analytic dataset*/

PROC GCHART DATA=r.analytic;
      VBAR SLEPTIM1 / LEVELS=7;
RUN;

/*Histogram of _AGE80 (age) with 20 levels*/
/*in BRFSS_a*/

PROC GCHART DATA=r.BRFSS_a;
      VBAR _AGE80 / LEVELS=20;
RUN;

/*box plot of SLEPTIM1 (sleep duration)*/

PROC SGPLOT  DATA = r.analytic;
   VBOX SLEPTIM1;
run;

/*stratified by ASTHMA3 (asthma status)*/

PROC SGPLOT  DATA = r.analytic;
   VBOX SLEPTIM1 / category = ASTHMA3;
run;


/*Create SLEPTIM2 in Scatter_Example by suppressing ineligible values*/
/*for SLEPTIM1 so we can use it in a scatter plot*/

data Clean_Example;
	set r.BRFSS_a;

	SLEPTIM2 = SLEPTIM1;

	if SLEPTIM1 ge 77
		then SLEPTIM2 = .;

run;

/*scatter plot age by sleep duration*/

PROC GPLOT DATA=Clean_Example;
     PLOT SLEPTIM2*_AGE80;
RUN;

/*group scatter plot by gender*/

PROC GPLOT DATA=Clean_Example;
     PLOT SLEPTIM2*_AGE80 = SEX;
RUN;



/*one-way frequency of outcome ASTHMA3*/
/*to fill in top row of table shell*/

proc freq data = r.analytic;
	tables ASTHMA3 / missing;
run;



/*example of default output for two-way frequency*/

proc freq data = r.analytic;
	tables DIABETE4*ASTHMA3;
run;

/*Use grouping variables for two-way frequencies*/
/*to calculate estimates for the other rows*/

proc freq data = r.analytic;
	tables DIABETE4 / missing;
	tables DIABETE4*ASTHMA3 / list missing;
run;

/*One set for each confounder*/
/*Listed in order of Table 1*/

proc freq data = r.analytic;
	tables _AGE_G / missing;
	tables _AGE_G*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables SEX / missing;
	tables SEX*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables _HISPANC / missing;
	tables _HISPANC*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables RACEGRP / missing;
	tables RACEGRP*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables MARGRP / list missing;
	tables MARGRP*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables EDGROUP / missing;
	tables EDGROUP*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables INCOME3 / missing;
	tables INCOME3*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables BMICAT / missing;
	tables BMICAT*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables SMOKGRP / missing;
	tables SMOKGRP*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables EXERANY3 / missing;
	tables EXERANY3*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables HLTHPLN2 / missing;
	tables HLTHPLN2*ASTHMA3 / list missing;
run;

proc freq data = r.analytic;
	tables GENHLTH2 / missing;
	tables GENHLTH2*ASTHMA3 / list missing;
run;



/*Statistical tests for categorical table*/

/*PROC FREQ and chi-square with options to suppress extra numbers - easier to read*/
proc freq data = r.analytic;
	tables DIABETE4*ASTHMA3/nocol norow nopercent chisq;
run;

/*Multiples in one proc*/
proc freq data = r.analytic;
	tables DIABETE4*ASTHMA3/nocol norow nopercent chisq;
	tables _AGE_G*ASTHMA3/nocol norow nopercent chisq;
	tables SEX*ASTHMA3/nocol norow nopercent chisq;
	tables _HISPANC*ASTHMA3/nocol norow nopercent chisq;
	tables RACEGRP*ASTHMA3/nocol norow nopercent chisq;
	tables MARGRP*ASTHMA3/nocol norow nopercent chisq;
	tables EDGROUP*ASTHMA3/nocol norow nopercent chisq;
	tables INCOME3*ASTHMA3/nocol norow nopercent chisq;
	tables BMICAT*ASTHMA3/nocol norow nopercent chisq;
	tables SMOKGRP*ASTHMA3/nocol norow nopercent chisq;
	tables EXERANY3*ASTHMA3/nocol norow nopercent chisq;
	tables HLTHPLN2*ASTHMA3/nocol norow nopercent chisq;
	tables GENHLTH2*ASTHMA3/nocol norow nopercent chisq;
run;


/*Continuous descriptive analysis*/

proc univariate data=r.analytic normal plot;
	var SLEPTIM1;
run;


proc univariate data = r.analytic;
	var SLEPTIM1;
run;

/*What happens if you don't sort first by the BY variable?*/

proc univariate data = r.analytic;
	var SLEPTIM1;
	by DIABETE4;
run;

/*sort, then stratify by diabetes status*/

proc sort data = r.analytic;
	by DIABETE4;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by DIABETE4;
run;

/*analyze other stratifications*/

proc sort data = r.analytic;
	by _AGE_G;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by _AGE_G;
run;

proc sort data = r.analytic;
	by SEX;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by SEX;
run;

proc sort data = r.analytic;
	by _HISPANC;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by _HISPANC;
run;

proc sort data = r.analytic;
	by RACEGRP;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by RACEGRP;
run;

proc sort data = r.analytic;
	by MARGRP;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by MARGRP;
run;

proc sort data = r.analytic;
	by EDGROUP;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by EDGROUP;
run;

proc sort data = r.analytic;
	by INCOME3;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by INCOME3;
run;

proc sort data = r.analytic;
	by ASTHMA3;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by ASTHMA3;
run;

proc sort data = r.analytic;
	by BMICAT;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by BMICAT;
run;

proc sort data = r.analytic;
	by SMOKGRP;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by SMOKGRP;
run;

proc sort data = r.analytic;
	by EXERANY3;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by EXERANY3;
run;

proc sort data = r.analytic;
	by HLTHPLN2;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by HLTHPLN2;
run;

proc sort data = r.analytic;
	by GENHLTH2;
proc univariate data = r.analytic;
	var SLEPTIM1;
	by GENHLTH2;
run;


/*t-tests for continuous descriptive table*/

proc ttest data = r.analytic;
	class DIABETE4;
	var SLEPTIM1;
run;

proc ttest data = r.analytic;
	class SEX;
	var SLEPTIM1;
run;

proc ttest data = r.analytic;
	class ASTHMA3;
	var SLEPTIM1;
run;


/*One-way ANOVA tests for table*/

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class _AGE_G;
	model SLEPTIM1 = _AGE_G;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class _HISPANC;
	model SLEPTIM1 = _HISPANC;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class RACEGRP;
	model SLEPTIM1 = RACEGRP;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class MARGRP;
	model SLEPTIM1 = MARGRP;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class EDGROUP;
	model SLEPTIM1 = EDGROUP;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class INCOME3;
	model SLEPTIM1 = INCOME3;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class BMICAT;
	model SLEPTIM1 = BMICAT;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class SMOKGRP;
	model SLEPTIM1 = SMOKGRP;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class EXERANY3;
	model SLEPTIM1 = EXERANY3;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class HLTHPLN2;
	model SLEPTIM1 = HLTHPLN2;
run;

proc glm data = r.analytic PLOTS(MAXPOINTS=NONE);
	class GENHLTH2;
	model SLEPTIM1 = GENHLTH2;
run;
quit;


/*proc tabulate example*/
/*copy dataset because using labels/formats*/

data r.example;
	set r.analytic;
	label ASTHMA3 = "Asthma Status";
	label DIABETE4 = "Diabetes Status";
	label _AGE_G = "Age Group";
	label SEX = "Sex";
run;

/*set up formats*/

proc format;
	value asthma_f
	1 = "Has Asthma"
	2 = "No Asthma"
	;
	value diabete_f
	1 = "Diabetic"
	2 = "Non-diabetic"
	;
	value age_g_f
	1 = "18-24"
	2 = "25-34"
	3 = "35-44"
	4 = "45-54"
	5 = "55-64"
	6 = "65+"
	;
	value sex_f
	1 = "Male"
	2 = "Female"
	;
run;
	
/*apply formats in proc tabulate*/

proc tabulate data=r.example;
	format 	ASTHMA3 asthma_f.
			DIABETE4 diabete_f.
			_AGE_G age_g_f.
			SEX sex_f.;
	class 	ASTHMA3
			DIABETE4
			_AGE_G
			SEX;
	table (ALL DIABETE4 _AGE_G SEX),
			(ALL ASTHMA3)*(N colpctn*f=4.1);
run;

data r.example;
	set r.analytic;
	label SLEPTIM1 = "Sleep Duration (hrs/night)";
	label DIABETE4 = "Diabetes Status";
	label _AGE_G = "Age Group";
	label SEX = "Sex";
run;

/*set up formats*/

proc format;
	value diabetes_f
	1 = "Has Diabetes"
	2 = "No Diabetes"
	;

	value age_g_f
	1 = "18-24"
	2 = "25-34"
	3 = "35-44"
	4 = "45-54"
	5 = "55-64"
	6 = "65+"
	;
	value sex_f
	1 = "Male"
	2 = "Female"
	;
run;
	
/*apply formats in proc tabulate*/

proc tabulate data=r.example;
	format 	DIABETE4 diabetes_f.
			_AGE_G age_g_f.
			SEX sex_f.;
	class 	DIABETE4
			_AGE_G
			SEX;
	var SLEPTIM1;
	table ALL _AGE_G SEX,
			SLEPTIM1*(ALL DIABETE4)*(n colpctn*f=4.1 mean std);
run;


/*using ODS to print to screen*/

ods trace on;
proc freq data=r.analytic;
	tables DIABETE4*ASTHMA3;
run;
ods output close;

/*using ODS to output PROC FREQ results to WORK directory*/

ods trace on;
ods output CrossTabFreqs = Diab_Freq;
proc freq data=r.analytic;
	tables DIABETE4*ASTHMA3;
run;
ods output close;

/*Exporting dataset from work directory to *.csv*/

PROC EXPORT DATA= WORK.Diab_Freq
            OUTFILE= "C:\Users\Monika\Dropbox\R Stats Book\Analytics\Data\Diab_Freq.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


/*sort by ASTHMA3*/

proc sort data = r.analytic;
	by ASTHMA3;
run;

/*using ODS to print to screen*/

ods trace on;
proc univariate data=r.analytic;
	var SLEPTIM1;
	by ASTHMA3;
run;
ods trace off;

/*using ODS to output PROC UNIVARIATE results to WORK directory*/

ods trace on;
ods output Moments=Asthma_moments;
proc univariate data=r.analytic;
	var SLEPTIM1;
	by ASTHMA3;
run;
ods trace off;

/*Exporting dataset from work directory to *.csv*/

PROC EXPORT DATA= WORK.Asthma_moments 
            OUTFILE= "C:\Users\Monika\Dropbox\R Stats Book\Analytics\Data\Asthma_moments.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

/*Chapter 8 Tips and tricks*/

/*unweighted frequency table of income*/

proc freq data = r.BRFSS_a;
	tables INCOME2 / missing;
run;

/*weighted frequency using weight variable _LLCPWT*/

proc freq data = r.BRFSS_a;
	weight _LLCPWT;
	tables INCOME2 / missing;
run;


/*Create a grouping variable for quartiles of age*/
/*Use BRFSS_a variable _AGE80 as an example*/

/*Look at distribution of _AGE80*/

proc univariate data = r.BRFSS_a;
	var _AGE80;
run;

/*25th Percentile = 44 */
/*Median = 58 */
/*75th Percentile = 69*/

/*create grouping variable and indicator variables*/

data QuartileExample;
	set r.BRFSS_a;

	AGEQ = 9;

	if _AGE80 lt 44
		then AGEQ = 1;
		
	if (_AGE80 ge 44) & (_AGE80 lt 58)
		then AGEQ = 2;

	if (_AGE80 ge 58) & (_AGE80 lt 69)
		then AGEQ = 3;

	if _AGE80 ge 69
		then AGEQ = 4;

/*Indicator variables - Q1 is comparison group*/

	AGEQ2 = 0;
	if AGEQ = 2
		then AGEQ2 = 1;

	AGEQ3 = 0;
	if AGEQ = 3
		then AGEQ3 = 1;

	AGEQ4 = 0;
	if AGEQ = 4
		then AGEQ4 = 1;

run;

proc freq data = QuartileExample;
	tables _AGE80 * AGEQ / list missing;
	tables AGEQ * AGEQ2 / list missing;
	tables AGEQ * AGEQ3 / list missing;
	tables AGEQ * AGEQ4 / list missing;
run;


/*create index for chronic diseases*/

data IndexExample;
	set r.BRFSS_a;

	HAFLAG = 0;
	if CVDINFR4 = 1
		then HAFLAG = 1;

	ANGFLAG = 0;
	if CVDCRHD4 = 1
		then ANGFLAG = 1;

	STRKFLAG = 0;
	if CVDSTRK3 = 1
		then STRKFLAG = 1;

	ASTHMAFLAG = 0;
	if ASTHMA3 = 1
		then ASTHMAFLAG = 1;

	SKINCAFLAG = 0;
	if CHCSCNCR = 1
		then SKINCAFLAG = 1;

	OTHCAFLAG = 0;
	if CHCOCNCR = 1
		then OTHCAFLAG = 1;

	COPDFLAG = 0;
	if CHCCOPD1 = 1
		then COPDFLAG = 1;

	ARTHFLAG = 0;
	if HAVARTH3 = 1
		then ARTHFLAG = 1;

	DEPFLAG = 0;
	if ADDEPEV2 = 1
		then DEPFLAG = 1;

	KIDNEYFLAG = 0;
	if CHCKIDNY = 1
		then KIDNEYFLAG = 1;

	DIABFLAG = 0;
	if DIABETE3 = 1
		then DIABFLAG = 1;

	CDINDEX = HAFLAG + ANGFLAG + STRKFLAG + ASTHMAFLAG + SKINCAFLAG +
				OTHCAFLAG + COPDFLAG + ARTHFLAG + DEPFLAG + KIDNEYFLAG + DIABFLAG;

run;

/*check individual flags*/

proc freq data=IndexExample;
	tables HAFLAG * CVDINFR4 /list missing;
	tables ANGFLAG * CVDCRHD4 /list missing;
	tables STRKFLAG * CVDSTRK3 /list missing;
	tables ASTHMAFLAG * ASTHMA3 /list missing;
	tables SKINCAFLAG * CHCSCNCR /list missing;
	tables OTHCAFLAG * CHCOCNCR /list missing;
	tables COPDFLAG * CHCCOPD1 /list missing;
	tables ARTHFLAG * HAVARTH3 /list missing;
	tables DEPFLAG * ADDEPEV2 /list missing;
	tables KIDNEYFLAG * CHCKIDNY /list missing; 
	tables DIABFLAG * DIABETE3 /list missing;
run;

/*check index*/

proc freq data=IndexExample;
	tables CDINDEX /missing;
run;


/*use import wizard to import *.csv State_Descriptions*/

proc contents data = r.State_Descriptions;
run;

/*state codes in BRFSS_a*/

proc freq data=r.BRFSS_a;
	tables _STATE;
run;

/*state descriptions in another dataset*/

proc freq data=r.State_Descriptions;
	tables _STATE*STATEDESC /list;
run;

/*sort and merge descriptions onto BRFSS data*/

proc sort data=r.BRFSS_a;
	by _STATE;
proc sort data=r.State_Descriptions;
	by _STATE;
run;

data MergedExample;
	merge r.BRFSS_a r.State_Descriptions;
	by _STATE;
run;

/*show new descriptions*/

proc freq data=MergedExample;
	tables _STATE*STATEDESC / list missing;
run;

/*example of a select statement from PROC SQL*/

PROC SQL;
	SELECT *
	FROM r.State_Descriptions;
QUIT;

/*use where clause*/

PROC SQL;
	SELECT *
	FROM r.State_Descriptions
	WHERE _STATE > 25;
QUIT;
