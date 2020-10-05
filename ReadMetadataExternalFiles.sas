/*
Read Metadata - External Files and coluns
*/

data MetadataExternalFile;
	length uri uri2 uri3 TableName Tree Path $256;
	nobj=1;
	rc2=1;
	rc3=1;
	rc4=1;
	rc4=5;
	n=1;
	n2=1;

	do while(nobj >= 0);
		nobj=metadata_getnobj("omsobj:ExternalTable?@Id contains '.'",n,uri);

		if (nobj>=0) then
			do;
				rc1=metadata_getattr(uri,"Name",TableName);
				TableName=TableName;
				n=n+1;
				rc2=metadata_getnasn(uri,"Trees",n2,uri2);
				rc3=metadata_getattr(uri2,"Name",Tree);
				rc4=metadata_getnasn(uri,"OwningFile",n2,uri3);
				rc5=metadata_getattr(uri3,"FileName",Path);

				if Tree in("02. Legado","01. Gestor") then
					do;
						output;
					end;
			end;
	end;

	drop n n2 rc1 rc2 rc3 rc4 rc5 nobj uri2 uri3;
run;

PROC SORT data=MetadataExternalFile out=MetadataExternalFile;
	BY TableName;
RUN;

Data MetadataColumn;
	keep uri TableName Path;
	set MetadataExternalFile;
run;

Data MetadataColumn;
	set MetadataColumn;
	length uri uri2 TableName SASColumnName
		SASColumnLength SASColumnType SASFormat SASInformat
		SASPrecision SASScale $256;
	n2=1;
	rc2=1;

	do while(rc2 >= 0);
		rc2=metadata_getnasn(uri,"Columns",n2,uri2);

		if (rc2>=0) then
			do;
				rc=metadata_getattr(uri2,"SASColumnName",SASColumnName);
				rc=metadata_getattr(uri2,"SASColumnLength",SASColumnLength);
				rc=metadata_getattr(uri2,"SASColumnType",SASColumnType);
				rc=metadata_getattr(uri2,"SASFormat",SASFormat);
				c=metadata_getattr(uri2,"SASInformat",SASInformat);
				rc=metadata_getattr(uri2,"SASPrecision",SASPrecision);
				rc=metadata_getattr(uri2,"SASScale",SASScale);
				n2=n2+1;
				output;
			end;
	end;

	drop n2 rc2 rc uri uri2 c;
run;

data MetadadosParametros;
	length Colunas Atributos $5000.;
	length tamanho $20;
	length formato $30;
	length informato $30;

	do until (eof);
		set MetadataColumn end=eof;
		Colunas=catx(' ',Colunas,SASColumnName);
		Caminho=Path;

		if SASColumnType = 'C' then
			do;
				tipo = '$';
			end;
		else
			do;
				tipo = '';
			end;

		tamanho = '';
		formato = '';
		informato = '';

		if not missing(SASColumnLength) then
			do;
				tamanho = cats('length=',tipo,SASColumnLength);
			end;

		if not missing(SASFormat) then
			do;
				formato = cats('format=',SASFormat);
			end;

		if not missing(SASInformat) then
			do;
				informato = cats('informat=',SASInformat);
			end;

		Atributos = catx(' ',Atributos,SASColumnName,tamanho,formato,informato);
	end;

	drop SASColumnLength SASColumnName SASColumnType SASFormat SASInformat SASPrecision SASScale TableName;
	drop tipo tamanho formato informato Path;
run;
