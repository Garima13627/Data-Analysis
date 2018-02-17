/*Importing Datasets*/
PROC IMPORT DBMS=csv OUT=train  replace
  DATAFILE="/folders/myfolders/train.csv";
  GETNAMES=YES;
RUN;

PROC IMPORT DBMS=csv OUT=test replace
  DATAFILE="/folders/myfolders/test.csv";
  GETNAMES=YES;
RUN;

/*Survival based on gender using if else*/
DATA gender_submit(KEEP=survived passengerid );
  SET test;
  IF sex = "female" THEN survived = 1;
  ELSE survived = 0;
 RUN;
 
 PROC EXPORT DATA=gender_submit DBMS=csv
  OUTFILE= "/folders/myfolders/gender_sub.csv" REPLACE;
RUN;

/*Descriptive Statistics using Proc Freq*/
/*One Dimension Frequency Table*/
PROC FREQ DATA = train;
  TABLES survived;
RUN;

/*Two Dimension Frequency Table*/
PROC FREQ DATA = train;
  TABLES sex*survived ;
RUN;

/*Three Dimension Frequency Table*/
PROC FREQ DATA = train;
  TABLES pclass*sex*survived ;
RUN;

/*Proc Freq for Continous Data*/
DATA train_bin;
  SET train;
RUN;
  
PROC FREQ DATA = train_bin;
  TABLES age *survived   ;
RUN;


/*Proc Freq for Categorical Data*/
DATA train_bin;
  LENGTH age_grp $20;
  SET train;
  IF .< age <= 10    THEN age_grp = "0-le10";
  ELSE IF 10<age<=20 THEN age_grp = "gt10-le20";
  ELSE IF 20<age<=30 THEN age_grp = "gt20-le30";
  ELSE IF 30<age<=40 THEN age_grp = "gt30-le40";
  ELSE IF 40<age<=50 THEN age_grp = "gt40-le50";
  ELSE IF 50<age     THEN age_grp = "gt50-le20";
RUN;

PROC FREQ DATA = train_bin;
  TABLES age_grp *survived /nocol nopercent;
RUN;

/*Graphs with Proc Freq*/
PROC FREQ DATA = train;
  TABLES embarked*survived /NOCOL NOPERCENT PLOTS = FREQPLOT  ;
RUN;


/*Descriptive Statistics with Proc Means*/
/*Proc means with Var and class*/
PROC MEANS DATA= train mean min max;
VAR Age ;
CLASS Survived Sex;
RUN;

/*Proc means with By Statement*/
PROC SORT DATA= train OUT=trainmeanssort;
BY survived sex;
RUN;

PROC MEANS DATA= trainmeanssort mean min max;
VAR Age ;
BY survived sex;
RUN;

/*Descriptive Statistics with Proc Summary*/
/*Proc Summary with Var and class*/
PROC SUMMARY DATA= train mean min max print;
VAR Age ;
CLASS Survived Sex;
RUN;

/*Proc Summary with Var and class*/
PROC TABULATE DATA= train;
CLASS sex;
VAR survived;
TABLE sex*survived,mean; 
RUN;

/*Proc Plot*/
PROC PLOT DATA=train;
PLOT survived*sex;
RUN;

/*Proc Univariate*/
PROC UNIVARIATE DATA=train;
VAR survived;
RUN;

/*****Regressions*****/
/*Removing Missing Values*/
data train;
  set train;
  if Age=. then Age=0;
  if Cabin='' then Cabin='Null';
  if Embarked then Embarked='Null';
run;

/*logistic regression between Survived and Age */
proc logistics data=train;
model survived=Age;
run;


/*logistic regression between Survived and Sex */
proc logistics data=train;
class sex;
model survived=sex;
run;

/*logistic regression between Survived and Pclass */
proc logistics data=train;
model survived=Pclass;
run;

/*logistic regression between Survived,Age,Sex and Pclass*/
proc logistics data=train;
class sex;
model survived=Age sex Pclass;
run;





