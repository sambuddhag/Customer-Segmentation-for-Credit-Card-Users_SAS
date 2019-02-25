libname b "/folders/myfolders/Final Case Study 1 - Credit Card Segmentation";
proc import datafile="/folders/myfolders/Final Case Study 1 - Credit Card Segmentation/CC GENERAL.csv" 
dbms=csv out=b.CC replace;
guessingrows=max; 
run; 

/* Data Exploration */

Proc contents data=b.cc varnum;
run;

/* Advanced data prepration */

data b.cc1;
set b.cc;
Mnth_avg_pur = PURCHASES/TENURE;
Mnth_avg_cash_adv = CASH_ADVANCE/TENURE;
if ONEOFF_PURCHASES=0 & INSTALLMENTS_PURCHASES=0 then purchase_type = 0;
if ONEOFF_PURCHASES>0 & INSTALLMENTS_PURCHASES=0 then purchase_type = 1;
if ONEOFF_PURCHASES=0 & INSTALLMENTS_PURCHASES>0 then purchase_type = 2;
if ONEOFF_PURCHASES>0 & INSTALLMENTS_PURCHASES>0 then purchase_type = 3;
Avg_amt_Pur = PURCHASES/PURCHASES_TRX;
Avg_cash_adv = CASH_ADVANCE / CASH_ADVANCE_TRX;
Bal_To_limit = BALANCE/CREDIT_LIMIT;
Pay_by_min   = PAYMENTS/MINIMUM_PAYMENTS;
run;

/* Outlier Treatment */ 

proc means data=b.cc1 n nmiss mean std min max p1 p5 p10 p25 p50 p75 p90 p95 p99;
run;

data b.cc2;
set b.cc1;
if Avg_amt_Pur=. then Avg_amt_Pur = 0;
if Avg_cash_adv=. then Avg_cash_adv=0;

proc means data=b.cc2 n nmiss mean std min max p1 p5 p10 p25 p50 p75 p90 p95 p99;
run;

/* Creating valid observations to identify outliers */

data b.cc3;
set b.cc2;

valid_obs_2=1;
if BALANCE > 5727.53 or
PURCHASES > 5276.46 or
ONEOFF_PURCHASES > 3912.2173709 or
INSTALLMENTS_PURCHASES > 2219.7438751 or
CASH_ADVANCE > 5173.1911125 or
CASH_ADVANCE_TRX > 16.8981202 or
PURCHASES_TRX > 64.4251306 or
CREDIT_LIMIT > 11772.09 or
PAYMENTS > 7523.26 or
MINIMUM_PAYMENTS > 5609.1065423 or
TENURE > 14.19398 or
Mnth_avg_pur> 447.1927461 or
Mnth_avg_cash_adv > 475.2502131 or
Avg_amt_Pur > 394.9205613 or
Avg_cash_adv > 1280.2161506 or
Bal_To_limit > 1.168371 or
Pay_by_min > 249.9238993
then valid_obs_2=0;


valid_obs_3=1;
if BALANCE > 7809.06 or
PURCHASES > 7413.09 or
ONEOFF_PURCHASES > 5572.1073709 or
INSTALLMENTS_PURCHASES > 3124.0819903 or
CASH_ADVANCE > 7270.3511125 or
CASH_ADVANCE_TRX > 23.7227669 or
PURCHASES_TRX > 89.2827797 or
CREDIT_LIMIT > 15410.91 or
PAYMENTS > 10418.32 or
MINIMUM_PAYMENTS > 7981.5565423 or
TENURE > 15.5323108 or
Mnth_avg_pur > 627.7015327 or
Mnth_avg_cash_adv > 668.3863278 or
Avg_amt_Pur > 555.4455004 or
Avg_cash_adv > 1815.8716675 or
Bal_To_limit > 1.5580933 or
Pay_by_min > 370.2108139
then valid_obs_3=0;
run;


proc freq data=b.cc3;
table valid_obs_2 valid_obs_3;
run;

/* Outlier Treatment---using 3SD */ 

data b.cc4;
set b.cc3;
if BALANCE >7809.06 Then BALANCE =  7809.06  ;
if PURCHASES >7413.09   Then PURCHASES =  7413.09   ;
if ONEOFF_PURCHASES >5572.1073709   Then ONEOFF_PURCHASES =  5572.1073709   ;
if INSTALLMENTS_PURCHASES >3124.0819903   Then INSTALLMENTS_PURCHASES =  3124.0819903   ;
if CASH_ADVANCE >7270.3511125  Then CASH_ADVANCE =  7270.3511125  ;
if CASH_ADVANCE_FREQUENCY >0.7355084 Then CASH_ADVANCE_FREQUENCY =  0.7355084 ;
if CASH_ADVANCE_TRX >23.7227669  Then CASH_ADVANCE_TRX =  23.7227669   ;
if PURCHASES_TRX >89.2827797   Then PURCHASES_TRX =  89.2827797   ;
if CREDIT_LIMIT >15410.91   Then CREDIT_LIMIT =  15410.91   ;
if PAYMENTS >10418.32   Then PAYMENTS =  10418.32  ;
if MINIMUM_PAYMENTS >7981.5565423   Then MINIMUM_PAYMENTS =  7981.5565423   ;
if Mnth_avg_pur> 627.7015327 Then Mnth_avg_pur= 627.7015327 ;
if Mnth_avg_cash_adv >668.3863278 Then Mnth_avg_cash_adv = 668.3863278;
if Avg_amt_Pur > 555.4455004 Then Avg_amt_Pur = 555.4455004;
if Avg_cash_adv > 1815.8716675 Then Avg_cash_adv = 1815.8716675;
if Bal_To_limit > 1.5580933Then Bal_To_limit = 1.5580933;
if Pay_by_min > 370.2108139 Then Pay_by_min = 370.2108139;  
run;

/**************** MISSING VALUE TREATMENT *********************/

data b.cc5;
set b.cc4;
if CREDIT_LIMIT=. then CREDIT_LIMIT= 4494.45;
if MINIMUM_PAYMENTS=. then MINIMUM_PAYMENTS= 864.2065423;
if Bal_To_limit=. then Bal_To_limit=0.3889264;
if Pay_by_min=. then Pay_by_min =9.3500701;
run;

/* Factor Analysis */

proc factor data=b.cc5 method=principal 
mineigen=0 nfactors=6 scree rotate= varimax reorder;
var 
BALANCE
BALANCE_FREQUENCY
PURCHASES
ONEOFF_PURCHASES
INSTALLMENTS_PURCHASES
CASH_ADVANCE
PURCHASES_FREQUENCY
ONEOFF_PURCHASES_FREQUENCY
PURCHASES_INSTALLMENTS_FREQUENCY
CASH_ADVANCE_FREQUENCY
CASH_ADVANCE_TRX
PURCHASES_TRX
CREDIT_LIMIT
PAYMENTS
MINIMUM_PAYMENTS
PRC_FULL_PAYMENT
TENURE;
run;

/* Standardizing segmentation variable and selection valid_obs*/

data b.cc6;
set b.cc5 (rename=ONEOFF_PURCHASES_FREQUENCY=ONEOFF_PER_FREQ);
 
data b.cc7;
set b.cc6 (rename=PURCHASES_INSTALLMENTS_FREQUENCY=PER_INST_FREQ);

data b.cc8;
set b.cc7;
z_ONEOFF_PURCHASES=ONEOFF_PURCHASES;
z_PAYMENTS=PAYMENTS;
z_CASH_ADVANCE_TRX=CASH_ADVANCE_TRX;
z_CASH_ADVANCE=CASH_ADVANCE;
z_PER_INST_FREQ=PER_INST_FREQ;
z_INSTALLMENTS_PURCHASES=INSTALLMENTS_PURCHASES;
z_MINIMUM_PAYMENTS=MINIMUM_PAYMENTS;
z_CREDIT_LIMIT=CREDIT_LIMIT;
z_ONEOFF_PER_FREQ=ONEOFF_PER_FREQ;
z_TENURE=TENURE;
z_BALANCE_FREQUENCY=BALANCE_FREQUENCY;
run;

/*  VARIABLE STANDARDIZATION */

proc standard data=b.cc8 out=b.cc9 mean=0 std=1;
var 
z_ONEOFF_PURCHASES
z_PAYMENTS
z_CASH_ADVANCE_TRX
z_CASH_ADVANCE
z_PER_INST_FREQ
z_INSTALLMENTS_PURCHASES
z_MINIMUM_PAYMENTS
z_CREDIT_LIMIT
z_ONEOFF_PER_FREQ
z_TENURE
z_BALANCE_FREQUENCY;
run;


/*  Clustering  */

proc fastclus data=b.cc9 out=cluster cluster=cluster3 maxclusters=3 maxiter=100;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_CASH_ADVANCE_TRX
z_CASH_ADVANCE
z_PER_INST_FREQ
z_INSTALLMENTS_PURCHASES
z_MINIMUM_PAYMENTS
z_CREDIT_LIMIT
z_ONEOFF_PER_FREQ
z_TENURE
z_BALANCE_FREQUENCY;
run;

proc fastclus data=cluster out=cluster cluster=cluster4 maxclusters=4 maxiter=100;
var 
z_ONEOFF_PURCHASES
z_PAYMENTS
z_CASH_ADVANCE_TRX
z_CASH_ADVANCE
z_PER_INST_FREQ
z_INSTALLMENTS_PURCHASES
z_MINIMUM_PAYMENTS
z_CREDIT_LIMIT
z_ONEOFF_PER_FREQ
z_TENURE
z_BALANCE_FREQUENCY;
run;

proc fastclus data=cluster out=cluster cluster=cluster5 maxclusters=5 maxiter=100;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_CASH_ADVANCE_TRX
z_CASH_ADVANCE
z_PER_INST_FREQ
z_INSTALLMENTS_PURCHASES
z_MINIMUM_PAYMENTS
z_CREDIT_LIMIT
z_ONEOFF_PER_FREQ
z_TENURE
z_BALANCE_FREQUENCY;
run;

proc fastclus data=cluster out=cluster cluster=cluster6 maxclusters=6 maxiter=100;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_CASH_ADVANCE_TRX
z_CASH_ADVANCE
z_PER_INST_FREQ
z_INSTALLMENTS_PURCHASES
z_MINIMUM_PAYMENTS
z_CREDIT_LIMIT
z_ONEOFF_PER_FREQ
z_TENURE
z_BALANCE_FREQUENCY;
run;

proc fastclus data=cluster out=cluster cluster=cluster7 maxclusters=7 maxiter=100;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_CASH_ADVANCE_TRX
z_CASH_ADVANCE
z_PER_INST_FREQ
z_INSTALLMENTS_PURCHASES
z_MINIMUM_PAYMENTS
z_CREDIT_LIMIT
z_ONEOFF_PER_FREQ
z_TENURE
z_BALANCE_FREQUENCY;
run;


/* cluster size check*/


proc freq data=cluster;
tables cluster3 cluster4 cluster5 cluster6 cluster7;
run;


/** Profiling **/

proc tabulate data=cluster;
var 
ONEOFF_PURCHASES
PAYMENTS
CASH_ADVANCE_TRX
CASH_ADVANCE
PER_INST_FREQ
INSTALLMENTS_PURCHASES
MINIMUM_PAYMENTS
CREDIT_LIMIT
ONEOFF_PER_FREQ
TENURE
BALANCE_FREQUENCY;

class cluster3 cluster4 cluster5 cluster6 cluster7;

table 
(ONEOFF_PURCHASES
PAYMENTS
CASH_ADVANCE_TRX
CASH_ADVANCE
PER_INST_FREQ
INSTALLMENTS_PURCHASES
MINIMUM_PAYMENTS
CREDIT_LIMIT
ONEOFF_PER_FREQ
TENURE
BALANCE_FREQUENCY)*mean, cluster3 cluster4 cluster5 cluster6 cluster7 ALL;
run;

/**************************END*********************************/
