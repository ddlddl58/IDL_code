pro read_OMIL2G_NO2_daily

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau

;Filelist = '~gengguannan/temp/url'
Filelist = '~gengguannan/temp/2006.no2'
Open_File, Filelist, Ilun, /Get_LUN

line = ''

while ( not EOF( Ilun ) ) do begin

ReadF, Ilun, line 

len = strlen(line)

filetag = strmid(line,len-55,55)
Yr4 = strmid(line,len-35,4)
Mon2 = strmid(line,len-30,2)
Day2 = strmid(line,len-28,2)

Infile  = '/z2/satellite/OMI/no2/NASA_Grid/'+ Yr4 +'/'+ Mon2 +'/'+ filetag
Outfile = '/z3/gengguannan/satellite/no2/bishe/CF_0.6/'+ Mon2 +'/omi_no2_'+ Yr4 + Mon2 + Day2 +'_v003_tropCS060_025x025.bpch'

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
   filter = { maxCloudFraction: 0.6,  $  ;Filter out cloudy pixels
              maxCloudPressure: 800,  $  ;Filter out low clouds pixels
              rottenPixels: 1         $  ;Filter out rotten pixels (0-based)
            }
;----------------------------------------------------------------------

;GET DATA
IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

fId = H5F_OPEN(Infile)
   if ( fId lt 0 ) then Message, 'Error opening file!'

   dataId_1 = H5D_OPEN( fId, '/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/ColumnAmountNO2Trop')
   ColumnAmountNO2 = H5D_READ(dataId_1)
   help,ColumnAmountNO2

   dataId_2 = H5D_OPEN( fId, '/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/CloudPressure')
   CloudPressure = H5D_READ(dataId_2)
   help,CloudPressure

   dataId_3 = H5D_OPEN( fId, '/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/CloudFraction')
   CloudFraction = H5D_READ(dataId_3)
   help,CloudFraction

   dataId_4 = H5D_OPEN( fId, '/HDFEOS/GRIDS/ColumnAmountNO2/Data Fields/SceneNumber')
   SceneNumber = H5D_READ(dataId_4)
   help,SceneNumber


;---------------------------------------------------------------------
; FILTER BEGINS HERE
;---------------------------------------------------------------------

FOR M = 0,14 DO BEGIN

   For I =0, InGrid.IMX-1 do begin
   For J =0, InGrid.JMX-1 do begin

   if (CloudFraction[I,J,M] gt 0.6) then begin
      ColumnAmountNO2[I,J,M] = -999.0
   endif

   if (CloudPressure[I,J,M] gt 800 and CloudFraction[I,J,M] gt 0.01) then begin
      ColumnAmountNO2[I,J,M] = -999.0
   endif

   if (SceneNumber[I,J,M] le 3 or SceneNumber[I,J,M] ge 58) then begin
      ColumnAmountNO2[I,J,M] = -999.0
   endif

   ;if ( Nymd ge 20070625 ) then begin
 
   ;	 if (SceneNumber[I,J,M] ge 54 and SceneNumber[I,J,M] le 55) then begin
   ;        ColumnAmountNO2[I,J,M] = -999.0
   ;  	endif

   ;endif

   ;if ( Nymd ge 20080511 ) then begin

   ;     if (SceneNumber[I,J,M] ge 38 and SceneNumber[I,J,M] le 45) then begin
   ;        ColumnAmountNO2[I,J,M] = -999.0
   ;     endif

   ;endif

   ;if ( Nymd ge 20090124 ) then begin

   ;     if (SceneNumber[I,J,M] ge 28 and SceneNumber[I,J,M] le 45) then begin
   ;        ColumnAmountNO2[I,J,M] = -999.0
   ;     endif

   ;endif


   Endfor
   Endfor

ENDFOR

;GET AVERAGE

   VC_temp = fltarr(InGrid.IMX,InGrid.JMX)
   VC = fltarr(InGrid.IMX,InGrid.JMX)

   For I =0, InGrid.IMX-1 do begin
   For J =0, InGrid.JMX-1 do begin

   Ind = where(ColumnAmountNO2[I,J,*] gt 0.0 )

   if(Ind ne [-1])                                        $
     then VC_temp[I,J] = mean(ColumnAmountNO2[I,J,Ind])   $
     else VC_temp[I,J] = 0.0

   VC[I,J] = vc_temp[I,J]/1.0E+15

   Endfor
   Endfor

   print, max(VC, min=min), min, median(VC)

  ; Make a DATAINFO structure
   success = CTM_Make_DataInfo( VC[*,*],                $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=1,               $
                                Tau0= tau0,             $
                                Unit='E+15molec/cm2',   $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_vertical )


   CTM_WriteBpch, ThisDataInfo, FileName = OutFile

endwhile

Close,    Ilun
Free_LUN, Ilun

end
