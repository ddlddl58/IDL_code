pro CALIPSO_get_aod



for month = 1,12 do begin
Mon2 = String( month, format = '(i2.2)' )

for year = 2006,2010 do begin
Yr4  = String( year, format = '(i4.4)' )

if year eq 2004 or year eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

for day = 1,Dayofmonth[month-1] do begin
Day2 = String( day, format = '(i2.2)' )

NYMD = year * 10000L + month * 100L + day * 1L
print, NYMD

; Inputfile Info.
InDir = '/z1/gengguannan/meic_120918/'+ Yr4 +'/'
Infile = InDir + 'ts_10_12.'+ Yr4 + Mon2 + Day2 +'.bpch'


Undefine, DataInfo_OPSO4
CTM_Get_Data, DataInfo_OPSO4, 'OD-MAP-$', Tracer = 6, File = Infile
OPSO4 = *( DataInfo_OPSO4[0].Data )

Undefine, DataInfo_OPBC
CTM_Get_Data, DataInfo_OPBC, 'OD-MAP-$', Tracer = 9, File = Infile
OPBC = *( DataInfo_OPBC[0].Data )

Undefine, DataInfo_OPOC
CTM_Get_Data, DataInfo_OPOC, 'OD-MAP-$', Tracer = 12, File = Infile
OPOC = *( DataInfo_OPOC[0].Data )

Undefine, DataInfo_OPSSa
CTM_Get_Data, DataInfo_OPSSa, 'OD-MAP-$', Tracer = 15, File = Infile
OPSSa = *( DataInfo_OPSSa[0].Data )

Undefine, DataInfo_OPSSc
CTM_Get_Data, DataInfo_OPSSc, 'OD-MAP-$', Tracer = 18, File = Infile
OPSSc = *( DataInfo_OPSSc[0].Data )

Undefine, DataInfo_OPD
CTM_Get_Data, DataInfo_OPD, 'OD-MAP-$', Tracer = 4, File = Infile
OPD = *( DataInfo_OPD[0].Data )

OPAOD = OPSO4 + OPBC + OPOC + OPSSa + OPSSc + OPD

    



endfor
endfor


OutDir = ''
Outfile = ''


endfor

end
