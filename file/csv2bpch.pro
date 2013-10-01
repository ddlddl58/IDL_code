pro csv2bpch

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak

for y = 2004,2007 do begin

flag = 1
for m = 1,12 do begin

Year = y
Month = m
Yr4 = string( Year, format='(i4.4)' )
Mon2 = string( Month, format='(i2.2)' )

;InFile =  '/home/gengguannan/indir/power_plant_emission/csv/Power_Plant_NOx_emission_'+ Yr4 +'_month_lt_100MW.csv'
InFile =  '/home/gengguannan/indir/power_plant_emission/csv/Power_Plant_SO2_emission_'+ Yr4 +'_month.csv'
;OutFile = '/home/gengguannan/indir/power_plant_emission/bpch/Power_Plant_NOx_emission_'+ Yr4 +'_month_lt_100MW_05x0666.bpch'
OutFile = '/z3/gengguannan/indir/inventory/SO2/Power_Plant_SO2_emission_'+ Yr4 +'_month_05x0666.bpch'

   
InType = CTM_Type('GEOS5', Res=[2d0/3d0, 0.5d0])
;InType = CTM_Type('GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid(InType)

xmid =InGrid.xmid
ymid =InGrid.ymid

NYMD0 = Year * 10000L + Month * 100L + 1L
tau0  = nymd2tau( NYMD0 )
print, NYMD0

; Define variables
Line  = ''
Delim = ','

sum_emis = FltArr( InGrid.IMX, InGrid.JMX )
sum_cap = FltArr( InGrid.IMX, InGrid.JMX )

;K=0 ; For error Lon & Lat control
Open_File, InFile, Ilun, /Get_LUN
   
ReadF, Ilun, Line
 
while ( not EOF( Ilun ) ) do begin
 
ReadF, Ilun, Line
 
Result = StrBreak( Line, Delim )
 
lon = Float( Result[1] )
lat = Float( Result[2] )
cap = Float( Result[3] ) 
emis = Float( Result[m+3] )

;---------------------------------------------------------------------------
; Note: This algorithm can not treat Lontitude with *.333334 and *.666667,
;       check the input data before running. (wsw, 24/02/10)
;---------------------------------------------------------------------------

Indi = where( (lon gt (xmid - 0.333333)) and (lon le (xmid + 0.333333)))
;Indi = where( (Lon gt (xmid - 0.25)) and (Lon le (xmid + 0.25)))
Indj = where( (lat gt (ymid - 0.25)) and (lat le (ymid + 0.25)))
;print,Indi
;print,Indj

sum_cap[Indi, Indj] += cap  
sum_emis[Indi, Indj] += emis*1000*10000  ; Convert [E+4 t] to [kg]

;print,'K = ', K
;K = K + 1 
 
; Undefine stuff
UnDefine,  Result
UnDefine,  lat
UnDefine,  lon
UnDefine,  cap
UnDefine,  emis
     
endwhile

Close,    Ilun
Free_LUN, Ilun

print,total(sum_cap)
print,total(sum_emis)


   ; Make a DATAINFO structure for fossil fuel
   
    Success = CTM_Make_DataInfo( Float( sum_emis ),     $                
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='ANTHSRCE',       $
                                Tracer=26,              $
                                Tau0=Tau0,              $
                                Unit='kg/month',        $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_Global )

  if (flag )                                          $
   then NewDataInfo = [ ThisDataInfo ]                $   
   else NewDataInfo = [ NewDataInfo, ThisDataInfo ]    

  if (flag )                                          $
   then NewFileInfo = [ ThisFileInfo ]                $
   else NewFileInfo = [ NewFileInfo, ThisFileInfo ]
    
  Flag = 0L

endfor
    CTM_WriteBpch, NewDataInfo, NewFileInfo, FileName = Outfile

    CTM_CleanUp

endfor
END
