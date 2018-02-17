Solving a system of nonlinear equations

WPS/Proc Python, Pyhton is a better language for this problem?
I included macro call to WPS below.

Note WPS/Proc Python returms a macro variable , fromPy, with the solution

Two simultaneous non-linear equations

     log(x) + log(y)         = log(5);
     (log(x) + 2 * log(y))/2 = log(10);

see
https://stackoverflow.com/questions/48832731/solving-a-system-of-nonlinear-equations-in-r


HAVE
====

   log(x) + log(y)         = log(5)
   (log(x) + 2 * log(y))/2 = log(10)


PROCESS (Working code)
======================

    x, y = symbols('x, y');
    * set up the equations so that the result is 0;

    eq1=log(x) + log(y) - log(5);
    eq2=(log(x) + 2 * log(y))/2 - log(10);

    solution=solve([eq1, eq2], (x, y)); * this doess all the work;

    * SAS/WPS check using macro variable fromPy;

    %let x=%scan(&frompy.,1,%str( ));
    %let y=%scan(&frompy.,2,%str( ));
    %put &=x &=y;

    data chk;
      eq1=log(&x) + log(&y) - log(5);
      eq2=(log(&x) + 2 * log(&y))/2 - log(10);
    run;quit;



OUTPUT
======

  Macro variable fromPy

  %put &=fromPy;

  FROMPY = 1/4      20

  Check (x,y) pair

  * worked;
  WORK.CHK total obs=1

  Obs    EQ1    EQ2

   1      0      0

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;


* data ie equations are in the WPS script;
* this returns a SAS/WPS macro variable from python;
%utl_submit_wps64("
options set=PYTHONHOME 'C:\Users\backup\AppData\Local\Programs\Python\Python35\';
options set=PYTHONPATH 'C:\Users\backup\AppData\Local\Programs\Python\Python35\lib\';
proc python;
submit;
from sympy import *;
import pandas as pd;
x, y = symbols('x, y');
eq1=log(x) + log(y) - log(5);
eq2=(log(x) + 2 * log(y))/2 - log(10);
solution=solve([eq1, eq2], (x, y));
print(solution);
df=pd.DataFrame(solution);
df.to_clipboard(index=False,header=False);
endsubmit;
run;quit;
",returnVarName=fromPy);

%put &=fromPy;

FROMPY  = 1/4      20

%let x=%scan(&frompy.,1,%str( ));
%let y=%scan(&frompy.,2,%str( ));
%put &=x &=y;

data chk;
  eq1=log(&x) + log(&y) - log(5);
  eq2=(log(&x) + 2 * log(&y))/2 - log(10);
run;quit;

Up to 40 obs WORK.CHK total obs=1

Obs    EQ1    EQ2

 1      0      0

* this returns a SAS/WPS macro variable from python;
%utl_submit_wps64("
options set=PYTHONHOME 'C:\Users\backup\AppData\Local\Programs\Python\Python35\';
options set=PYTHONPATH 'C:\Users\backup\AppData\Local\Programs\Python\Python35\lib\';
proc python;
submit;
from sympy import *;
import pandas as pd;
x, y = symbols('x, y');
eq1=log(x) + log(y) - log(5);
eq2=(log(x) + 2 * log(y))/2 - log(10);
solution=solve([eq1, eq2], (x, y));
print(solution);
df=pd.DataFrame(solution);
df.to_clipboard(index=False,header=False);
endsubmit;
run;quit;
",returnVarName=fromPy);

%put &=fromPy;

%let x=%scan(&frompy.,1,%str( ));
%let y=%scan(&frompy.,2,%str( ));
%put &=x &=y;

data chk;
  eq1=log(&x) + log(&y) - log(5);
  eq2=(log(&x) + 2 * log(&y))/2 - log(10);
run;quit;

Up to 40 obs WORK.CHK total obs=1

Obs    EQ1    EQ2

 1      0      0

*          _ _
  ___ __ _| | | __      ___ __  ___
 / __/ _` | | | \ \ /\ / / '_ \/ __|
| (_| (_| | | |  \ V  V /| |_) \__ \
 \___\__,_|_|_|   \_/\_/ | .__/|___/
                         |_|
;


%macro utl_submit_wps64(pgmx,resolve=Y,returnVarName=)/des="submiit a single quoted sas program to wps";

  * whatever you put in the Python or R clipboard will be returned in the macro variable
    returnVarName;

  * if you delay resolution, use resove=Y to resolve macros and macro variables passed to python;

  * write the program to a temporary file;

  %utlfkil(%sysfunc(pathname(work))/wps_pgmtmp.wps);
  %utlfkil(%sysfunc(pathname(work))/wps_pgm.wps);
  %utlfkil(%sysfunc(pathname(work))/wps_pgm001.wps);
  %utlfkil(wps_pgm.lst);

  filename wps_pgm "%sysfunc(pathname(work))/wps_pgmtmp.wps" lrecl=32756 recfm=v;
  data _null_;
    length pgm  $32756 cmd $32756;
    file wps_pgm ;
    %if %upcase(%substr(&resolve,1,1))=Y %then %do;
       pgm=resolve(&pgmx);
    %end;
    %else %do;
      pgm=&pgmx;
    %end;
    semi=countc(pgm,';');
      do idx=1 to semi;
        cmd=cats(scan(pgm,idx,';'),';');
        len=length(strip(cmd));
        put cmd $varying32756. len;
        putlog cmd $varying32756. len;
      end;
  run;

  filename wps_001 "%sysfunc(pathname(work))/wps_pgm001.wps" lrecl=255 recfm=v ;
  data _null_ ;
    length textin $ 32767 textout $ 255 ;
    file wps_001;
    infile "%sysfunc(pathname(work))/wps_pgmtmp.wps" lrecl=32767 truncover;
    format textin $char32767.;
    input textin $char32767.;
    putlog _infile_;
    if lengthn( textin ) <= 255 then put textin ;
    else do while( lengthn( textin ) > 255 ) ;
       textout = reverse( substr( textin, 1, 255 )) ;
       ndx = index( textout, ' ' ) ;
       if ndx then do ;
          textout = reverse( substr( textout, ndx + 1 )) ;
          put textout $char255. ;
          textin = substr( textin, 255 - ndx + 1 ) ;
    end ;
    else do;
      textout = substr(textin,1,255);
      put textout $char255. ;
      textin = substr(textin,255+1);
    end;
    if lengthn( textin ) le 255 then put textin $char255. ;
    end ;
  run ;

  %put ****** file %sysfunc(pathname(work))/wps_pgm.wps ****;

  filename wps_fin "%sysfunc(pathname(work))/wps_pgm.wps" lrecl=255 recfm=v ;
  data _null_;
      retain switch 0;
      infile wps_001;
      input;
      file wps_fin;
      if substr(_infile_,1,1) = '.' then  _infile_= substr(left(_infile_),2);
      select;
         when(left(upcase(_infile_))=:'SUBMIT;')     switch=1;
         when(left(upcase(_infile_))=:'ENDSUBMIT;')  switch=0;
         otherwise;
      end;
      if lag(switch)=1 then  _infile_=compress(_infile_,';');
      if left(upcase(_infile_))= 'ENDSUBMIT' then _infile_=cats(_infile_,';');
      put _infile_;
      putlog _infile_;
  run;quit;

  %let _loc=%sysfunc(pathname(wps_fin));
  %let _w=%sysfunc(compbl(C:/Progra~1/worldp~1/bin/wps.exe -autoexec c:\oto\Tut_Otowps.sas -config c:\cfg\wps.cfg));
  %put &_loc;

  filename rut pipe "&_w -sysin &_loc";
  data _null_;
    file print;
    infile rut;
    input;
    put _infile_;
    putlog _infile_;
  run;

  filename rut clear;
  filename wps_pgm clear;
  data _null_;
    infile "wps_pgm.lst";
    input;
    putlog _infile_;
  run;quit;

  * use the clipboard to create macro variable;
  %if "&returnVarName" ne ""  %then %do;
    filename clp clipbrd ;
    data _null_;
     infile clp;
     input;
     putlog "*******  " _infile_;
     call symputx("&returnVarName.",_infile_,"G");
    run;quit;
  %end;


%mend utl_submit_wps64;


