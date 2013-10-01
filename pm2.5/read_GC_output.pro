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

pro read_GC_output_hourly

InType = CTM_Type( 'GEOS5', Resolution=[ 2d0/3d0,0.5d0 ] )
InGrid = CTM_Grid( InType )

NumSOA = 5


; Time set
for year = 2008,2010 do begin
Yr4  = String( year, format = '(i4.4)' )

if year eq 2004 or year eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

for month = 1,12 do begin
Mon2 = String( month, format = '(i2.2)' )

for day = 1,Dayofmonth[month-1] do begin
Day2 = String( day, format = '(i2.2)' )

NYMD = year * 10000L + month * 100L + day * 1L
tau1 = nymd2tau(NYMD)


for time = 1,24 do begin
Tim2 = String( time, format = '(i2.2)' )
tau0 = tau1 + time


; Inputfile Info.
InDir = '/z1/gengguannan/meic_120918/'+ Yr4 +'/'
Infile = InDir + 'ts.'+ Yr4 + Mon2 + Day2 +'.bpch'


; Outputfile Info.
OutDir = '/home/gengguannan/work/pm2.5/pm2.5/gc/hourly/'+ Yr4 +'/'
Outfile = OutDir + 'model_pm2.5_aod.'+ Yr4 + Mon2 + Day2 + Tim2 +'.hdf'


;================================================================
; Read Data
;================================================================

; Conversion factor
Pt = fltarr( 121, 133, 48 )


Undefine, DataInfo_TEPU
CTM_Get_Data, DataInfo_TEPU, 'DAO-3D-$', Tracer = 3, File = Infile, tau0 = tau0
TEPU = *( DataInfo_TEPU[0].Data )
T = TEPU[*,*,0]


Undefine, DataInfo_BXHEIGHT
CTM_Get_Data, DataInfo_BXHEIGHT, 'BXHGHT-$', Tracer = 1, File = Infile, tau0 = tau0
BXHEIGHT = *( DataInfo_BXHEIGHT[0].Data )
Box = BXHEIGHT[*,*,0]


Undefine, DataInfo_PEDGE
CTM_Get_Data, DataInfo_PEDGE, 'PEDGE-$', Tracer = 1, File = Infile, tau0 = tau0
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

; 0=SO4 1=NO3 2=NH4 3=OCi 4=OCo 5=SOA 6=BCi 7=BCo 8=Dust 9=Salt 10=PM25sum 11=PM25RH50 12=AOD

;0
Undefine, DataInfo_SO4
CTM_Get_Data, DataInfo_SO4, 'IJ-AVG-$', Tracer = 27, File = Infile, tau0 = tau0
SO4 = *( DataInfo_SO4[0].Data )
tracer[*,*,0] = SO4[*,*,0] * factor * 96


;1
Undefine, DataInfo_NO3
CTM_Get_Data, DataInfo_NO3, 'IJ-AVG-$', Tracer = 32, File = Infile, tau0 = tau0
NO3 = *( DataInfo_NO3[0].Data )
tracer[*,*,1] = NO3[*,*,0] * factor * 62


;2
Undefine, DataInfo_NH4
CTM_Get_Data, DataInfo_NH4, 'IJ-AVG-$', Tracer = 31, File = Infile, tau0 = tau0
NH4 = *( DataInfo_NH4[0].Data )
tracer[*,*,2] = NH4[*,*,0] * factor * 18


;3
Undefine, DataInfo_OCPI
CTM_Get_Data, DataInfo_OCPI, 'IJ-AVG-$', Tracer = 35, File = Infile, tau0 = tau0
OCPI = *( DataInfo_OCPI[0].Data )
tracer[*,*,3] = OCPI[*,*,0] * factor * 12


;4
Undefine, DataInfo_OCPO
CTM_Get_Data, DataInfo_OCPO, 'IJ-AVG-$', Tracer = 37, File = Infile, tau0 = tau0
OCPO = *( DataInfo_OCPO[0].Data )
tracer[*,*,4] = OCPO[*,*,0] * factor * 12

if NumSOA gt 0 then begin

Undefine, DataInfo_SOA1
CTM_Get_Data, DataInfo_SOA1, 'IJ-AVG-$', Tracer = 46, File = Infile, tau0 = tau0
SOA1 = *( DataInfo_SOA1[0].Data )

Undefine, DataInfo_SOA2
CTM_Get_Data, DataInfo_SOA2, 'IJ-AVG-$', Tracer = 47, File = Infile, tau0 = tau0
SOA2 = *( DataInfo_SOA2[0].Data )

Undefine, DataInfo_SOA3
CTM_Get_Data, DataInfo_SOA3, 'IJ-AVG-$', Tracer = 48, File = Infile, tau0 = tau0
SOA3 = *( DataInfo_SOA3[0].Data )

Undefine, DataInfo_SOA4
CTM_Get_Data, DataInfo_SOA4, 'IJ-AVG-$', Tracer = 49, File = Infile, tau0 = tau0
SOA4 = *( DataInfo_SOA4[0].Data )

tSOA = SOA1[*,*,0]*150 + SOA2[*,*,0]*160 + SOA3[*,*,0]*220 + SOA4[*,*,0]*130

endif

if NumSOA eq 5 then begin

Undefine, DataInfo_SOA5
CTM_Get_Data, DataInfo_SOA5, 'IJ-AVG-$', Tracer = 50, File = Infile, tau0 = tau0
SOA5 = *( DataInfo_SOA5[0].Data )

tSOA = tSOA + SOA5[*,*,0]*150

endif

tracer[*,*,5] = tSOA * factor


;6
Undefine, DataInfo_BCPI
CTM_Get_Data, DataInfo_BCPI, 'IJ-AVG-$', Tracer = 34, File = Infile, tau0 = tau0
BCPI = *( DataInfo_BCPI[0].Data )
tracer[*,*,6] = BCPI[*,*,0] * factor * 12


;7
Undefine, DataInfo_BCPO
CTM_Get_Data, DataInfo_BCPO, 'IJ-AVG-$', Tracer = 36, File = Infile, tau0 = tau0
BCPO = *( DataInfo_BCPO[0].Data )
tracer[*,*,7] = BCPO[*,*,0] * factor * 12


;8
Undefine, DataInfo_DST1
CTM_Get_Data, DataInfo_DST1, 'IJ-AVG-$', Tracer = 51, File = Infile, tau0 = tau0
DST1 = *( DataInfo_DST1[0].Data )
Undefine, DataInfo_DST2
CTM_Get_Data, DataInfo_DST2, 'IJ-AVG-$', Tracer = 52, File = Infile, tau0 = tau0
DST2 = *( DataInfo_DST2[0].Data )
tracer[*,*,8] = ( DST1[*,*,0] + 0.38 * DST2[*,*,0] ) * factor * 29


;9
Undefine, DataInfo_SALA
CTM_Get_Data, DataInfo_SALA, 'IJ-AVG-$', Tracer = 55, File = Infile, tau0 = tau0
SALA = *( DataInfo_SALA[0].Data )
tracer[*,*,9] = SALA[*,*,0] * factor * 36


;10 : PM2.5
tracer[*,*,10] = total(tracer[*,*,0:9],3)


;11 : PM2.5 at RH=35
tSNA = SO4[*,*,0] * 96 + NO3[*,*,0] * 62 + NH4[*,*,0] * 18
tOCi = OCPI[*,*,0] * 12 * 1.8
tOCo = OCPO[*,*,0] * 12 * 1.8
tBCi = BCPI[*,*,0] * 12
tBCo = BCPO[*,*,0] * 12
tD = ( DST1[*,*,0] + 0.38 * DST2[*,*,0] ) * 29
tSa = SALA[*,*,0] * 36

tracer[*,*,11] = tSNA * RHfactor(50, 1700) * factor + $
                 tOCi * RHfactor(50, 1800) * factor + $
                 tSOA * RHfactor(50, 1800) * factor + $
                 tOCo                      * factor + $
                 tBCi * RHfactor(50, 1000) * factor + $
                 tBCo                      * factor + $
                 tD                        * factor + $
                 tSa  * RHfactor(50, 2200) * factor


;12 : AOD
Undefine, DataInfo_OPSO4
CTM_Get_Data, DataInfo_OPSO4, 'OD-MAP-$', Tracer = 6, File = Infile, tau0 = tau0
OPSO4 = *( DataInfo_OPSO4[0].Data )

Undefine, DataInfo_OPBC
CTM_Get_Data, DataInfo_OPBC, 'OD-MAP-$', Tracer = 9, File = Infile, tau0 = tau0
OPBC = *( DataInfo_OPBC[0].Data )

Undefine, DataInfo_OPOC
CTM_Get_Data, DataInfo_OPOC, 'OD-MAP-$', Tracer = 12, File = Infile, tau0 = tau0
OPOC = *( DataInfo_OPOC[0].Data )

Undefine, DataInfo_OPSSa
CTM_Get_Data, DataInfo_OPSSa, 'OD-MAP-$', Tracer = 15, File = Infile, tau0 = tau0
OPSSa = *( DataInfo_OPSSa[0].Data )

Undefine, DataInfo_OPSSc
CTM_Get_Data, DataInfo_OPSSc, 'OD-MAP-$', Tracer = 18, File = Infile, tau0 = tau0
OPSSc = *( DataInfo_OPSSc[0].Data )

Undefine, DataInfo_OPD
CTM_Get_Data, DataInfo_OPD, 'OD-MAP-$', Tracer = 4, File = Infile, tau0 = tau0
OPD = *( DataInfo_OPD[0].Data )

OPAOD = OPSO4 + OPBC + OPOC + OPSSa + OPSSc + OPD
tracer[*,*,12] = total(OPAOD,3)


data1  = tracer[*,*,0]
data2  = tracer[*,*,1]
data3  = tracer[*,*,2]
data4  = tracer[*,*,3]
data5  = tracer[*,*,4]
data6  = tracer[*,*,5]
data7  = tracer[*,*,6]
data8  = tracer[*,*,7]
data9  = tracer[*,*,8]
data10 = tracer[*,*,9]
data11 = tracer[*,*,10]
data12 = tracer[*,*,11]
data13 = tracer[*,*,12]


; Find out if HDF is supported on this platform
IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_START(Outfile,/RDWR,/Create)
IF ( FID lt 0 ) then Message, 'Error opening file!'

HDF_SETSD, FID, data1, 'SO4',         $
           Longname='SO4',            $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data2, 'NO3',         $
           Longname='NO3',            $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data3, 'NH4',         $
           Longname='NH4',            $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data4, 'OCPI',        $
           Longname='OCPI',           $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data5, 'OCPO',        $
           Longname='OCPO',           $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data6, 'SOA',         $
           Longname='SOA',           $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data7, 'BCPI',        $
           Longname='BCPI',           $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data8, 'BCPO',        $
           Longname='BCPO',           $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data9, 'DUST',        $
           Longname='DUST',           $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data10, 'SALA',        $
           Longname='SALA',           $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data11, 'PM2.5',      $
           Longname='PM2.5_DRY',      $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data12, 'PM2.5_50',   $
           Longname='PM2.5_35%',      $
           Unit='ug/m3',              $
           FILL=-999.0
HDF_SETSD, FID, data13, 'aod',        $
           Longname='aod column',     $
           Unit='unitless',           $
           FILL=-999.0
HDF_SD_End, FID


CTM_CLEANUP

undefine,tracer
undefine,T
undefine,Box
undefine,P
undefine,tSOA
undefine,data1
undefine,data2
undefine,data3
undefine,data4
undefine,data5
undefine,data6
undefine,data7
undefine,data8
undefine,data9
undefine,data10
undefine,data11
undefine,data12
undefine,data13
undefine,data14

endfor
endfor
endfor
endfor

end
