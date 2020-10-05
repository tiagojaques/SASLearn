%macro unlock(lib=,dataset=);
	%let path=%sysfunc(pathname(&lib.));
	%let dset=%lowcase(&dataset.).sas7bdat;

	%if not %sysfunc(fexist(&path./&dset.)) %then
		%do;
			filename cmd pipe "mv -v ""&path./&dset."" ""&path./&dset._mv""; cp -v ""&path./&dset._mv"" -v ""&path./&dset.""; rm ""&path./&dset._mv""";
			data _null_;
				infile cmd;
				input;
				put _infile_;
			run;
		%end;
	%else %put %upcase(error): &lib..&dataset. Lock file exists - dataset being updated aborting unlock procedure.;
%mend;

%unlock(lib=,dataset=);