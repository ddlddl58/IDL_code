pro test

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

year = 1998
For m = 0,12-1 do begin

OC_ratio = fltarr(30,91,144)
BC_ratio = fltarr(30,91,144)
BXHGHT = fltarr(30,91,144)
BC1_m = fltarr(144,91,30)
BC2_m = fltarr(144,91,30)
OC1_m = fltarr(144,91,30)
OC2_m = fltarr(144,91,30)
nod = fltarr(144,91,30)
OC_ratio_temp = fltarr(144,91,30)
BC_ratio_temp = fltarr(144,91,30)
BXHGHT_temp = fltarr(144,91,30)

For d = 0,31-1 do begin

Yr4  = string(year,format='(i4.4)')
Mon2 = string(m+1,format='(i2.2)')
Day2 = string(d+1,format='(i2.2)')

NYMD0 = year * 10000L + (m+1) * 100L + (d+1)
NYMD1 = year * 10000L + (m+1) * 100L + 1L

print,NYMD0

if (nymd0 eq 19960230) then continue
if (nymd0 eq 19960231) then continue
if (nymd0 eq 19960431) then continue
if (nymd0 eq 19960631) then continue
if (nymd0 eq 19960931) then continue
if (nymd0 eq 19961131) then continue
if (nymd0 eq 19970229) then continue
if (nymd0 eq 19970230) then continue
if (nymd0 eq 19970231) then continue
if (nymd0 eq 19970431) then continue
if (nymd0 eq 19970631) then continue
if (nymd0 eq 19970931) then continue
if (nymd0 eq 19971131) then continue
if (nymd0 eq 19980229) then continue
if (nymd0 eq 19980230) then continue
if (nymd0 eq 19980231) then continue
if (nymd0 eq 19980431) then continue
if (nymd0 eq 19980631) then continue
if (nymd0 eq 19980931) then continue
if (nymd0 eq 19981131) then continue



Infile1 = '/z3/wangsiwen/GEOS_Chem/GEOS_2x25/v9-01-01.standard.geos4.2x25.for.Lu/w.deposition/ts_24h_avg.'+ Yr4 + Mon2 + Day2 +'.bpch'
Infile2 = '/z3/wangsiwen/GEOS_Chem/GEOS_2x25/v9-01-01.standard.geos4.2x25.for.Lu/wo.deposition/ts_24h_avg.'+ Yr4 + Mon2 + Day2 +'.bpch'
Infile3 = '/z3/wangsiwen/GEOS_Chem/GEOS_2x25/v9-01-01.standard.geos4.2x25.for.Lu/wo.deposition/ctm.'+ Yr4 +'0101.bpch'
Outfile = '/z3/gengguannan/temp/'+ Yr4 + Mon2 + '.hdf'


CTM_Get_Data, datainfo_1, 'IJ-AVG-$', Tracer = 34, filename = Infile1; Tau0 = Nymd2Tau(NYMD0)
BCPI1 = *(datainfo_1[0].data)
help, BCPI1

CTM_Get_Data, datainfo_2, 'IJ-AVG-$', Tracer = 35, filename = Infile1; Tau0 = Nymd2Tau(NYMD0)
OCPI1 = *(datainfo_2[0].data)
help, OCPI1

CTM_Get_Data, datainfo_3, 'IJ-AVG-$', Tracer = 36, filename = Infile1; Tau0 = Nymd2Tau(NYMD0)
BCPO1 = *(datainfo_3[0].data)
help, BCPO1

CTM_Get_Data, datainfo_4, 'IJ-AVG-$', Tracer = 37, filename = Infile1; Tau0 = Nymd2Tau(NYMD0)
OCPO1 = *(datainfo_4[0].data)
help, OCPO1

CTM_Get_Data, datainfo_5, 'IJ-AVG-$', Tracer = 34, filename = Infile2; Tau0 = Nymd2Tau(NYMD0)
BCPI2 = *(datainfo_5[0].data)
help, BCPI2

CTM_Get_Data, datainfo_6, 'IJ-AVG-$', Tracer = 35, filename = Infile2; Tau0 = Nymd2Tau(NYMD0)
OCPI2 = *(datainfo_6[0].data)
help, OCPI2

CTM_Get_Data, datainfo_7, 'IJ-AVG-$', Tracer = 36, filename = Infile2; Tau0 = Nymd2Tau(NYMD0)
BCPO2 = *(datainfo_7[0].data)
help, BCPO2

CTM_Get_Data, datainfo_8, 'IJ-AVG-$', Tracer = 37, filename = Infile2; Tau0 = Nymd2Tau(NYMD0)
OCPO2 = *(datainfo_8[0].data)
help, OCPO2

;CTM_Get_Data, datainfo_9, 'BXHGHT-$', Tracer = 1, filename =Infile3, Tau0 = Nymd2Tau(NYMD1)
;BXHGHT_temp = *(datainfo_9[0].data)
;help, BXHGHT_temp

BC1 = BCPI1 + BCPO1
OC1 = OCPI1 + OCPO1

BC2 = BCPI2 + BCPO2
OC2 = OCPI2 + OCPO2

for I = 0,144-1 do begin
  for J = 0,91-1 do begin
    for K = 0,30-1 do begin
       BC1_m[I,J,K] += BC1[I,J,K]
       OC1_m[I,J,K] += OC1[I,J,K]
       BC2_m[I,J,K] += BC2[I,J,K]
       OC2_m[I,J,K] += OC2[I,J,K]
       nod[I,J,K] += 1
    endfor
  endfor
endfor

CTM_Cleanup

endfor

for I = 0,144-1 do begin
  for J = 0,91-1 do begin
    for K = 0,30-1 do begin
      BC1_m[I,J,K] = BC1_m[I,J,K] / nod[I,J,K]
      OC1_m[I,J,K] = OC1_m[I,J,K] / nod[I,J,K]
      BC2_m[I,J,K] = BC2_m[I,J,K] / nod[I,J,K]
      OC2_m[I,J,K] = OC2_m[I,J,K] / nod[I,J,K]
    endfor
  endfor
endfor

for I = 0,144-1 do begin
  for J = 0,91-1 do begin
    for K = 0,30-1 do begin
      BC_ratio_temp[I,J,K] = BC1_m[I,J,K] / BC2_m[I,J,K]
      OC_ratio_temp[I,J,K] = OC1_m[I,J,K] / OC2_m[I,J,K]
    endfor
  endfor
endfor

CTM_Get_Data, datainfo_9, 'BXHGHT-$', Tracer = 1, filename =Infile3, Tau0 = Nymd2Tau(NYMD1)
BXHGHT_temp = *(datainfo_9[0].data)
help, BXHGHT_temp


For I = 0,144-1L do begin
For J = 0,91-1L do begin
  BC_ratio[*,J,I] = BC_ratio_temp[I,J,*]
  OC_ratio[*,J,I] = OC_ratio_temp[I,J,*]
    BXHGHT[*,J,I] = BXHGHT_temp[I,J,*]
Endfor
Endfor

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)
HDF_SETSD, FID, BC_ratio, 'BC_ratio', $
           Longname='BC ratio',$
           Unit='unitless', $
           FILL=-999.0
HDF_SETSD, FID, OC_ratio, 'OC_ratio',$
           Longname='OC ratio',$
           Unit='unitless',$
           FILL=-999.0
HDF_SETSD, FID, BXHGHT, 'BoxHeight',$
           Longname='Grid Box Height',$
           Unit='m',$
           FILL=-999.0
HDF_SD_End, FID

endfor

end
