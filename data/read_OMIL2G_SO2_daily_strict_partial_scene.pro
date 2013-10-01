pro read_OMIL2G_SO2_daily_strict_partial_scene

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau

;Filelist = '~gengguannan/temp/url'
Filelist = '~gengguannan/temp/2006.so2.1'
Open_File, Filelist, Ilun, /Get_LUN

line = ''

while ( not EOF( Ilun ) ) do begin

ReadF, Ilun, line 

len = strlen(line)

filetag = strmid(line,len-55,55)
Yr4 = strmid(line,len-35,4)
Mon2 = strmid(line,len-30,2)
Day2 = strmid(line,len-28,2)

Infile  = '/z2/satellite/OMI/so2/NASA_Grid/'+ Yr4 +'/'+ Mon2 +'/' + filetag
;Infile = '/home/wangsiwen/' + filetag
Outfile = '/z3/gengguannan/satellite/so2/'+ Yr4 +'/'+ Mon2 +'/omi_so2_'+ Yr4 + Mon2 + Day2 +'_0125x0125.bpch'


;SET MODEL
InType   = CTM_Type( 'generic', Res=[ 0.125, 0.125 ], HalfPolar=0, Center180=0 )
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
   filter = { maxsolarzenithangle: 70, $ ;filter out pixels on edges of swaths 
              maxCloudFraction: 0.3,  $  ;Filter out cloudy pixels
              rottenPixels: 1         $  ;Filter out rotten pixels (0-based)
            }
;----------------------------------------------------------------------

;GET DATA
IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

fId = H5F_OPEN( Infile)
   if ( fId lt 0 ) then Message, 'Error opening file!'

   groupid = H5G_OPEN(fid,'/HDFEOS/GRIDS/OMI Total Column Amount SO2/Data Fields/')

   dataId_1 = H5D_OPEN( groupid, "NumberOfCandidateScenes")
   NumberOfCandidateScenes = H5D_READ(dataId_1)
   help,NumberOfCandidateScenes
   H5D_CLOSE,dataId_1

   dataId_2 = H5D_OPEN( groupid, "CloudPressure")
   CloudPressure = H5D_READ(dataId_2)
   help,CloudPressure
   H5D_CLOSE,dataId_2

   dataId_3 = H5D_OPEN( groupid, "RadiativeCloudFraction")
   RadiativeCloudFraction = H5D_READ(dataId_3)
   help,RadiativeCloudFraction
   H5D_CLOSE,dataId_3

   dataId_4 = H5D_OPEN( groupid, "SceneNumber")
   SceneNumber = H5D_READ(dataId_4)
   help,SceneNumber
   H5D_CLOSE,dataId_4

   dataId_5 = H5D_OPEN( groupid, "SolarZenithAngle")
   SolarZenithAngle = H5D_READ(dataId_5)
   help,SolarZenithAngle
   H5D_CLOSE,dataId_5

   dataId_6 = H5D_OPEN( groupid, "TerrainHeight")
   TerrainHeight = H5D_READ(dataId_6)
   help,TerrainHeight
   H5D_CLOSE,dataId_6

   dataId_7 = H5D_OPEN( groupid, "ColumnAmountSO2_PBL")
   so2pbl = H5D_READ(dataId_7)
   help,so2pbl
   H5D_CLOSE,dataId_7


   H5G_CLOSE,groupid

H5F_CLOSE,fId 
;---------------------------------------------------------------------
; FILTER BEGINS HERE
;---------------------------------------------------------------------

a_so2 = fltarr(InGrid.IMX,InGrid.JMX,8)
a_sn = fltarr(InGrid.IMX,InGrid.JMX,8)
so2 = fltarr(InGrid.IMX,InGrid.JMX)

For I =0, InGrid.IMX-1 do begin
For J =0, InGrid.JMX-1 do begin
   For L = 0, 8-1 do begin 
   a_so2[I,J,L] = -999.0
   ncs = NumberOfCandidateScenes[I,J]
   if (L ge ncs) then continue
   sn = SceneNumber[I,J,L]
   if (sn lt 4) or (sn gt 25) then continue
   sza = SolarZenithAngle[I,J,L]
   if (sza gt 70) then continue
   rcf = RadiativeCloudFraction[I,J,L] 
   if (rcf gt 0.3) then continue
   cp = CloudPressure[I,J,L]
   if (cp gt 800) and (rcf gt 0.01)then continue
   th = TerrainHeight[I,J,L]
   if (th gt 2000) then continue
   a_so2[I,J,L] = so2pbl[I,J,L]
   a_sn[I,J,L] = sn
   if (a_so2[I,J,L] lt -10.0) or (a_so2[I,J,L] gt 10.0) then a_sn[I,J,L] = 0.0
   Endfor
   so2[I,J] = -999.0
   ind = where(a_sn[I,J,*] gt 0 )
   if (ind[0] gt -1) then so2[I,J] = mean(a_so2[I,J,ind])
Endfor
Endfor

  ; Make a DATAINFO structure
   success = CTM_Make_DataInfo( so2,                    $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=26,              $
                                Tau0= tau0,             $
                                Unit='DU',              $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = OutFile


endwhile

Close,    Ilun
Free_LUN, Ilun

end
