compile_opt strictarr

;================================================================
; relative humidity correction
;================================================================

function RHfactor,RH,Rho

; SO4
if Rho eq 1700 then eta = [0.120, 0.141, 0.159, 0.174, 0.205, 0.247, 0.419]
; OC
if Rho eq 1800 then eta = [0.110, 0.136, 0.148, 0.159, 0.181, 0.208, 0.278]
; EC
if Rho eq 1000 then eta = [0.035, 0.035, 0.035, 0.042, 0.049, 0.052, 0.066]
; SALA
if Rho eq 2200 then eta = [0.129, 0.207, 0.233, 0.256, 0.306, 0.372, 0.613]

RH_old = [0, 50, 70, 80, 90, 95, 99]

RhoWater = 1000

growth = INTERPOL( eta, RH_old, RH) / eta[0]
factor = Rho * growth^3 / (Rho * growth^3 + (1 - growth^3) * RhoWater)

return,factor

end

;================================================================
; Read GC output to caculate PM2.5 & AOD
;================================================================

pro read_GC_output_2h

InType = CTM_Type( 'GEOS5', Resolution=[ 2d0/3d0,0.5d0 ] )
InGrid = CTM_Grid( InType )

NumSOA = 5


; Time set
for year = 2004,2010 do begin
Yr4  = String( year, format = '(i4.4)' )

if year eq 2004 or year eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

for month = 1,12 do begin
Mon2 = String( month, format = '(i2.2)' )

for day = 1,Dayofmonth[month-1] do begin
Day2 = String( day, format = '(i2.2)' )

NYMD = year * 10000L + month * 100L + day * 1L
print, NYMD


; Inputfile Info.
InDir = '/z1/gengguannan/meic_120918/'+ Yr4 +'/'
Infile1 = InDir + 'ts_24h_avg.'+ Yr4 + Mon2 + Day2 +'.bpch'
Infile2 = InDir + 'ts_10_12.'+ Yr4 + Mon2 + Day2 +'.bpch'


; Outputfile Info.
OutDir = '/home/gengguannan/work/pm2.5/pm2.5/gc/daily/'+ Yr4 +'/'
Outfile = OutDir + 'model_pm2.5_aod_10_12.'+ Yr4 + Mon2 + Day2 +'.hdf'


;================================================================
; Read Data
;================================================================

; Conversion factor
Pt = fltarr( 121, 133, 48 )


Undefine, DataInfo_TEPU
CTM_Get_Data, DataInfo_TEPU, 'DAO-3D-$', Tracer = 3, File = Infile1
TEPU = *( DataInfo_TEPU[0].Data )
T = TEPU[*,*,0]


Undefine, DataInfo_BXHEIGHT
CTM_Get_Data, DataInfo_BXHEIGHT, 'BXHGHT-$', Tracer = 1, File = Infile1
BXHEIGHT = *( DataInfo_BXHEIGHT[0].Data )
Box = BXHEIGHT[*,*,0]


Undefine, DataInfo_PEDGE
CTM_Get_Data, DataInfo_PEDGE, 'PEDGE-$', Tracer = 1, File = Infile1
PEDGE = *( DataInfo_PEDGE[0].Data )
P = PEDGE[*,*]


Pt[*,*,0] = P
for z = 1,47 do begin
  Pt[*,*,z] = Pt[*,*,z-1] * ( exp(-((Box * 9.8) / (287 * T))))
endfor
P = (Pt[*,*,0:46] + Pt[*,*,1:47]) / 2
P = P[*,*,0]

factor = (P * 1e2 * 1e6 * 1e-9) / (8.31 * T)



; Caculate PM2.5 & AOD
tracer = fltarr( 121, 133, 14 )

; 0=SO4 1=NO3 2=NH4 3=OC+SOA 4=BC 5=Dust 6=Salt 7=SOA 8=PM25sum 9=PM25RH50 10=SNA 11=OC+BC 12=AOD 13=AOD_corrected

;0
Undefine, DataInfo_SO4
CTM_Get_Data, DataInfo_SO4, 'IJ-AVG-$', Tracer = 27, File = Infile1
SO4 = *( DataInfo_SO4[0].Data )
tracer[*,*,0] = SO4[*,*,0] * factor * 96


;1
Undefine, DataInfo_NO3
CTM_Get_Data, DataInfo_NO3, 'IJ-AVG-$', Tracer = 32, File = Infile1
NO3 = *( DataInfo_NO3[0].Data )
tracer[*,*,1] = NO3[*,*,0] * factor * 62


;2
Undefine, DataInfo_NH4
CTM_Get_Data, DataInfo_NH4, 'IJ-AVG-$', Tracer = 31, File = Infile1
NH4 = *( DataInfo_NH4[0].Data )
tracer[*,*,2] = NH4[*,*,0] * factor * 18


;3
Undefine, DataInfo_OCPI
CTM_Get_Data, DataInfo_OCPI, 'IJ-AVG-$', Tracer = 35, File = Infile1
OCPI = *( DataInfo_OCPI[0].Data )
Undefine, DataInfo_OCPO
CTM_Get_Data, DataInfo_OCPO, 'IJ-AVG-$', Tracer = 37, File = Infile1
OCPO = *( DataInfo_OCPO[0].Data )
tracer[*,*,3] = ( OCPI[*,*,0] + OCPO[*,*,0] ) * factor * 12

if NumSOA gt 0 then begin

Undefine, DataInfo_SOA1
CTM_Get_Data, DataInfo_SOA1, 'IJ-AVG-$', Tracer = 46, File = Infile1
SOA1 = *( DataInfo_SOA1[0].Data )

Undefine, DataInfo_SOA2
CTM_Get_Data, DataInfo_SOA2, 'IJ-AVG-$', Tracer = 47, File = Infile1
SOA2 = *( DataInfo_SOA2[0].Data )

Undefine, DataInfo_SOA3
CTM_Get_Data, DataInfo_SOA3, 'IJ-AVG-$', Tracer = 48, File = Infile1
SOA3 = *( DataInfo_SOA3[0].Data )

Undefine, DataInfo_SOA4
CTM_Get_Data, DataInfo_SOA4, 'IJ-AVG-$', Tracer = 49, File = Infile1
SOA4 = *( DataInfo_SOA4[0].Data )

tSOA = SOA1[*,*,0]*150 + SOA2[*,*,0]*160 + SOA3[*,*,0]*220 + SOA4[*,*,0]*130

endif

if NumSOA eq 5 then begin

Undefine, DataInfo_SOA5
CTM_Get_Data, DataInfo_SOA5, 'IJ-AVG-$', Tracer = 50, File = Infile1
SOA5 = *( DataInfo_SOA5[0].Data )

tSOA = tSOA + SOA5[*,*,0]*150

endif

tracer[*,*,7] = tSOA * factor

tracer[*,*,3] = tracer[*,*,3] + tracer[*,*,7]


;4
Undefine, DataInfo_BCPI
CTM_Get_Data, DataInfo_BCPI, 'IJ-AVG-$', Tracer = 34, File = Infile1
BCPI = *( DataInfo_BCPI[0].Data )
Undefine, DataInfo_BCPO
CTM_Get_Data, DataInfo_BCPO, 'IJ-AVG-$', Tracer = 36, File = Infile1
BCPO = *( DataInfo_BCPO[0].Data )
tracer[*,*,4] = ( BCPI[*,*,0] + BCPO[*,*,0] ) * factor * 12


;5
Undefine, DataInfo_DST1
CTM_Get_Data, DataInfo_DST1, 'IJ-AVG-$', Tracer = 51, File = Infile1
DST1 = *( DataInfo_DST1[0].Data )
Undefine, DataInfo_DST2
CTM_Get_Data, DataInfo_DST2, 'IJ-AVG-$', Tracer = 52, File = Infile1
DST2 = *( DataInfo_DST2[0].Data )
tracer[*,*,5] = ( DST1[*,*,0] + 0.38 * DST2[*,*,0] ) * factor * 29


;6
Undefine, DataInfo_SALA
CTM_Get_Data, DataInfo_SALA, 'IJ-AVG-$', Tracer = 55, File = Infile1
SALA = *( DataInfo_SALA[0].Data )
tracer[*,*,6] = SALA[*,*,0] * factor * 36


;8 : PM2.5
tracer[*,*,8] = total(tracer[*,*,0:7],3)


;9 : PM2.5 at RH=50
tSNA = SO4[*,*,0] * 96 + NO3[*,*,0] * 62 + NH4[*,*,0] * 18
tOCi = OCPI[*,*,0] * 12 * 1.8
tOCo = OCPO[*,*,0] * 12 * 1.8
tBCi = BCPI[*,*,0] * 12
tBCo = BCPO[*,*,0] * 12
tD = ( DST1[*,*,0] + 0.38 * DST2[*,*,0] ) * 29
tSa = SALA[*,*,0] * 36

tracer[*,*,9] = tSNA * RHfactor(50, 1700) * factor + $
                tOCi * RHfactor(50, 1800) * factor + $
                tSOA * RHfactor(50, 1800) * factor + $
                tOCo                      * factor + $
                tBCi * RHfactor(50, 1000) * factor + $
                tBCo                      * factor + $
                tD                        * factor + $
                tSa  * RHfactor(50, 2200) * factor


;10 : SNA
tracer[*,*,10] = tSNA * RHfactor(50, 1700) * factor


;11 : OC+BC
tracer[*,*,11] = tOCi * RHfactor(50, 1800) * factor + $
                 tOCo                      * factor + $
                 tBCi * RHfactor(50, 1000) * factor + $
                 tBCo                      * factor


;12 : AOD
Undefine, DataInfo_OPSO4
CTM_Get_Data, DataInfo_OPSO4, 'OD-MAP-$', Tracer = 6, File = Infile2
OPSO4 = *( DataInfo_OPSO4[0].Data )

Undefine, DataInfo_OPBC
CTM_Get_Data, DataInfo_OPBC, 'OD-MAP-$', Tracer = 9, File = Infile2
OPBC = *( DataInfo_OPBC[0].Data )

Undefine, DataInfo_OPOC
CTM_Get_Data, DataInfo_OPOC, 'OD-MAP-$', Tracer = 12, File = Infile2
OPOC = *( DataInfo_OPOC[0].Data )

Undefine, DataInfo_OPSSa
CTM_Get_Data, DataInfo_OPSSa, 'OD-MAP-$', Tracer = 15, File = Infile2
OPSSa = *( DataInfo_OPSSa[0].Data )

Undefine, DataInfo_OPSSc
CTM_Get_Data, DataInfo_OPSSc, 'OD-MAP-$', Tracer = 18, File = Infile2
OPSSc = *( DataInfo_OPSSc[0].Data )

Undefine, DataInfo_OPD
CTM_Get_Data, DataInfo_OPD, 'OD-MAP-$', Tracer = 4, File = Infile2
OPD = *( DataInfo_OPD[0].Data )

OPAOD = OPSO4 + OPBC + OPOC + OPSSa + OPSSc + OPD
tracer[*,*,12] = total(OPAOD,3)


;13 : AOD_corrected
monthname = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

factorfile = '/home/gengguannan/indir/CALIPSO_factor/CALIPSO-ADJ-20120821LR'+ monthname[month-1] +'-CH.h5'

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

fId = H5F_OPEN(factorfile)

if ( fId lt 0 ) then Message, 'Error opening file!'

dataId = H5D_OPEN( fId, 'CALIPSOADJ' )
CAL_factor = H5D_READ(dataId)

OPAOD_corrected = fltarr(121,133,47)

for level = 0,47-1 do begin
  for I = 0,121-1 do begin
    for J = 0,133-1 do begin
      OPAOD_corrected[I,J,level] = OPAOD[I,J,level]*CAL_factor[I,J,level+40]
    endfor
  endfor
endfor

tracer[*,*,13] = total(OPAOD_corrected,3)



print,max(tracer[*,*,9]),mean(tracer[*,*,9])
print,max(tracer[*,*,12]),mean(tracer[*,*,12])
print,max(tracer[*,*,13]),mean(tracer[*,*,13])


data1 = tracer[*,*,8]
data2 = tracer[*,*,9]
data3 = tracer[*,*,12]
data4 = tracer[*,*,13]
data5 = tracer[*,*,10]
data6 = tracer[*,*,11]


; Find out if HDF is supported on this platform
IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_START(Outfile,/RDWR,/Create)
IF ( FID lt 0 ) then Message, 'Error opening file!'

HDF_SETSD, FID, data1, 'dry_pm2.5',   $
           Longname='Surface pm2.5',  $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data2, 'pm2.5',       $
           Longname='Surface pm2.5',  $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data3, 'aod',         $
           Longname='aod column',     $
           Unit='unitless',           $
           FILL=-999.0
HDF_SETSD, FID, data4,'aod_corrected',$
           Longname='aod column',     $
           Unit='unitless',           $
           FILL=-999.0
HDF_SETSD, FID, data5, 'SNA',         $
           Longname='SNA',            $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data6, 'carbon',      $
           Longname='carbon',         $
           Unit='ug/m3',              $
           FILL=-999.0

HDF_SD_End, FID


CTM_CLEANUP


endfor
endfor
endfor


end
