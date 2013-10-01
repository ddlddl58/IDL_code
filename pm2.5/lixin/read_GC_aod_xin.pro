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

pro read_GC_aod_xin

InType = CTM_Type( 'GEOS5', Resolution=[ 2d0/3d0,0.5d0 ] )
InGrid = CTM_Grid( InType )


; Time set
for year = 2006,2006 do begin
Yr4  = String( year, format = '(i4.4)' )

for month = 7,7 do begin
Mon2 = String( month, format = '(i2.2)' )

NYMD = year * 10000L + month * 100L + 1 * 1L
print, NYMD

; Inputfile Info.
InDir = '/z2/lixin/gc_output/06Jul_BJ_orig/'
Infile = InDir + 'ctm.'+ Yr4 + Mon2 +'.bpch'


; Outputfile Info.
OutDir = '/home/gengguannan/work/pm2.5/pm2.5/gc_xin/daily/'+ Yr4 +'/'
Outfile = OutDir + 'model_aod.'+ Yr4 + Mon2 +'.hdf'


;===============================================================
; Read Data
;===============================================================
tracer = fltarr(121, 133, 7)

;0
Undefine, DataInfo_OPSO4
CTM_Get_Data, DataInfo_OPSO4, 'OD-MAP-$', Tracer = 6, File = Infile
OPSO4 = *( DataInfo_OPSO4[0].Data )
tracer[*,*,0] = total(OPSO4,3)

;1
Undefine, DataInfo_OPBC
CTM_Get_Data, DataInfo_OPBC, 'OD-MAP-$', Tracer = 9, File = Infile
OPBC = *( DataInfo_OPBC[0].Data )
tracer[*,*,1] = total(OPBC,3)

;2
Undefine, DataInfo_OPOC
CTM_Get_Data, DataInfo_OPOC, 'OD-MAP-$', Tracer = 12, File = Infile
OPOC = *( DataInfo_OPOC[0].Data )
tracer[*,*,2] = total(OPOC,3)

;3
Undefine, DataInfo_OPSSa
CTM_Get_Data, DataInfo_OPSSa, 'OD-MAP-$', Tracer = 15, File = Infile
OPSSa = *( DataInfo_OPSSa[0].Data )
tracer[*,*,3] = total(OPSSa,3)

;4
Undefine, DataInfo_OPSSc
CTM_Get_Data, DataInfo_OPSSc, 'OD-MAP-$', Tracer = 18, File = Infile
OPSSc = *( DataInfo_OPSSc[0].Data )
tracer[*,*,4] = total(OPSSc,3)

;5
Undefine, DataInfo_OPD
CTM_Get_Data, DataInfo_OPD, 'OD-MAP-$', Tracer = 4, File = Infile
OPD = *( DataInfo_OPD[0].Data )
tracer[*,*,5] = total(OPD,3)

;6
tracer[*,*,6] = total(tracer[*,*,0:5],3)



data1  = tracer[*,*,0]
data2  = tracer[*,*,1]
data3  = tracer[*,*,2]
data4  = tracer[*,*,3]
data5  = tracer[*,*,4]
data6  = tracer[*,*,5]
data7  = tracer[*,*,6]

; Find out if HDF is supported on this platform
IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_START(Outfile,/RDWR,/Create)
IF ( FID lt 0 ) then Message, 'Error opening file!'

HDF_SETSD, FID, data1,'OPSO4',          $
           Longname='OPSO4',             $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, data2,'OPBC',           $
           Longname='OPBC',              $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, data3,'OPOC',           $
           Longname='OPOC',              $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, data4,'OPSSa',          $
           Longname='OPSSa',             $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, data5,'OPSSc',          $
           Longname='OPSSc',             $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, data6,'OPD',            $
           Longname='OPD',               $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, data7,'AOD',            $
           Longname='AOD column',        $
           Unit='unitless',              $
           FILL=-999.0
HDF_SD_End, FID


CTM_CLEANUP


endfor
endfor


end
