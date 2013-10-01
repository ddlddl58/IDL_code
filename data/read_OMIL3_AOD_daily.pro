pro read_OMIL3_AOD_daily

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau

Filelist = '/z2/satellite/OMI/AOD/filelist'
Open_File, Filelist, Ilun, /Get_LUN

line = ''

while ( not EOF( Ilun ) ) do begin

ReadF, Ilun, line

len = strlen(line)

;filetag = strmid(line,len-29,26)
Yr4 = strmid(line,len-35,4)
Mon2 = strmid(line,len-30,2)
Day2 = strmid(line,len-28,2)
print,Yr4,Mon2,Day2

Infile  = '/z2/satellite/OMI/AOD/' + line
Outfile = '/z3/gengguannan/satellite/AOD/omi_AOD_'+ Yr4 + Mon2 + Day2 +'_025x025.bpch'

;SET MODEL
InType   = CTM_Type( 'generic', Res=[ 0.25, 0.25 ], HalfPolar=0, Center180=0 )
InGrid   = CTM_Grid( InType, /No_Vertical )
print, infile


;GET DATE
Year = Fix(Yr4)
Month= Fix(Mon2)
Day  = Fix(Day2)
print,year,month,day

Nymd = Year * 10000L + Month * 100L + Day
tau0 = nymd2tau(Nymd)
print,Nymd


;GET DATA
IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

fId = H5F_OPEN( Infile)
   if ( fId lt 0 ) then Message, 'Error opening file!'

   groupid = H5G_OPEN(fid,'/HDFEOS/GRIDS/ColumnAmountAerosol/Data Fields/')

   dataId_1 = H5D_OPEN( groupid,"AerosolOpticalThicknessMW")
   AerosolOpticalThickness = H5D_READ(dataId_1)
   help,AerosolOpticalThickness
   H5D_CLOSE,dataId_1

   H5G_CLOSE,groupid

H5F_CLOSE,fId


;GET AVERAGE
AOD_temp = fltarr(InGrid.IMX,InGrid.JMX)
AOD = fltarr(InGrid.IMX,InGrid.JMX)

For I =0, InGrid.IMX-1 do begin
  For J =0, InGrid.JMX-1 do begin
    Ind = where(AerosolOpticalThickness[I,J,*] gt 0.0 )

    if(Ind ne [-1])                                                 $
      then AOD_temp[I,J] = mean(AerosolOpticalThickness[I,J,Ind])   $
      else AOD_temp[I,J] = 0.0

    AOD[I,J] = AOD_temp[I,J]*0.001

  Endfor
Endfor

print, max(AOD, min=min), min, median(AOD)


; Make a DATAINFO structure
   success = CTM_Make_DataInfo( AOD,                    $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=46,              $
                                Tau0= tau0,             $
                                Unit='unitless',        $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = OutFile


endwhile

Close,    Ilun
Free_LUN, Ilun

end

