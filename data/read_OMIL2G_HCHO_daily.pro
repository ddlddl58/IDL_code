pro read_OMIL2G_HCHO_daily

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau

Filelist = '~gengguannan/temp/2006.hcho.1'
Open_File, Filelist, Ilun, /Get_LUN

line = ''

while ( not EOF( Ilun ) ) do begin

ReadF, Ilun, line

len = strlen(line)

filetag = strmid(line,len-56,56)
Yr4 = strmid(line,len-35,4)
Mon2 = strmid(line,len-30,2)
Day2 = strmid(line,len-28,2)

Infile  = '/z2/satellite/OMI/hcho/NASA_Grid/'+ Yr4 +'/'+ Mon2 +'/' + filetag
Outfile = '/z3/gengguannan/satellite/hcho/'+ Yr4 +'/'+ Mon2 +'/omi_hcho_'+ Yr4 + Mon2 + Day2 +'_025x025.bpch'


;SET MODEL
InType   = CTM_Type( 'generic', Res=[ 0.25, 0.25 ], HalfPolar=0, Center180=0 )
InGrid   = CTM_Grid( InType, /No_Vertical )
print, infile


;GET DATE
Year = Fix(Yr4)
Month = Fix(Mon2)
Day = Fix(Day2)
print,year,month,day

Nymd = Year * 10000L + Month * 100L + Day
tau0 = nymd2tau(Nymd)
print,Nymd

;----------------------------------------------------------------------
; SET USER PARAMETERS HERE
   filter = { maxsolarzenithangle: 80, $ ;filter out pixels on edges of swaths
              maxCloudFraction: 0.3,  $  ;Filter out cloudy pixels
              rottenPixels: 1         $  ;Filter out rotten pixels (0-based)
            }
;----------------------------------------------------------------------

;GET DATA
IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

fId = H5F_OPEN( Infile)
   if ( fId lt 0 ) then Message, 'Error opening file!'

   groupid = H5G_OPEN(fid,'/HDFEOS/GRIDS/OMI Total Column Amount HCHO/Data Fields/')

   dataId_1 = H5D_OPEN( groupid, "AMFCloudFraction")
   AMFCloudFraction = H5D_READ(dataId_1)
   help,AMFCloudFraction
   H5D_CLOSE,dataId_1

   dataId_2 = H5D_OPEN( groupid, "ColumnAmountHCHO")
   ColumnAmountHCHO = H5D_READ(dataId_2)
   help,ColumnAmountHCHO
   H5D_CLOSE,dataId_2

   dataId_3 = H5D_OPEN( groupid, "MainDataQualityFlag")
   MainDataQualityFlag = H5D_READ(dataId_3)
   help,MainDataQualityFlag
   H5D_CLOSE,dataId_3

   dataId_4 = H5D_OPEN( groupid, "SolarZenithAngle")
   SolarZenithAngle = H5D_READ(dataId_4)
   help,SolarZenithAngle
   H5D_CLOSE,dataId_4


   H5G_CLOSE,groupid

H5F_CLOSE,fId

;---------------------------------------------------------------------
; FILTER BEGINS HERE
;---------------------------------------------------------------------

FOR M = 0,15-1 DO BEGIN

   For I =0, InGrid.IMX-1 do begin
   For J =0, InGrid.JMX-1 do begin

   if (MainDataQualityFlag[I,J,M] ne 0) then begin
      ColumnAmountHCHO[I,J,M] = -999.0
   endif

   if (AMFCloudFraction[I,J,M] gt 0.3) then begin
      ColumnAmountHCHO[I,J,M] = -999.0
   endif

   if (SolarZenithAngle[I,J,M] gt 80) then begin
      ColumnAmountHCHO[I,J,M] = -999.0
   endif

   Endfor
   Endfor

ENDFOR


;GET AVERAGE

   hcho_temp = fltarr(InGrid.IMX,InGrid.JMX)
   hcho = fltarr(InGrid.IMX,InGrid.JMX)

   For I =0, InGrid.IMX-1 do begin
   For J =0, InGrid.JMX-1 do begin

   Ind = where(ColumnAmountHCHO[I,J,*] gt 0.0 )

   if(Ind ne [-1])                                        $
     then hcho_temp[I,J] = mean(ColumnAmountHCHO[I,J,Ind])   $
     else hcho_temp[I,J] = 0.0

   hcho[I,J] = hcho_temp[I,J]/1.0E+16

   Endfor
   Endfor

   print, max(hcho, min=min), min, median(hcho)


  ; Make a DATAINFO structure
   success = CTM_Make_DataInfo( hcho,                   $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=20,              $
                                Tau0= tau0,             $
                                Unit='E+16molec/cm2',              $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = OutFile


endwhile

Close,    Ilun
Free_LUN, Ilun

end

