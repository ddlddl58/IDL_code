pro ascii2bpch_grid
 
   ;====================================================================
   ; Initialize
   ;====================================================================

   ; Resolve external functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak

   title = ['dom','ind','pow','tra']
   month = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
;   month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
   year = 2005

   For M = 0,3 do begin 

   flag = 1
   For N = 0,11 do begin
   
   Yr4 = string( year, format = '(i4.4)')
   Mon2 = string( N+1, format = '(i2.2)')
   
   ; Arguments
   Filename = '/z3/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/'+ Yr4 +'/'+ title[M] +'_'+ Yr4 +'_'+ month[N] +'.asc'
   Outfile  = '/z3/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/'+ title[M] +'-'+ Yr4 +'-01x01.bpch'

   ; Clean up common blocks, etc.
   CTM_CleanUp
 
   InType = CTM_Type( 'GENERIC', Res=[0.1d0,0.1d0], Halfpolar=0, Center180=0 )  
   InGrid = CTM_Grid( InType, /No_Vertical )
 
   ; Define variables
   Line = ''

   ;Lon = 60 + findgen(980) * 0.1
   ;Lat = -13 + findgen(670) * 0.1

   junk = Fltarr( 980, 670 )
   Target  = FltArr( InGrid.IMX, InGrid.JMX )
   ;====================================================================
   ; Read data
   ;====================================================================

   ; Open the file
   Open_File, Filename, Ilun, /Get_LUN
 
   ; Skip header
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line

   ; Use CTM_INDEX to get the right lon & lat
   ; NOTE: (I,J) are FORTRAN notation (starts from 1)!
   ;CTM_Index, InType, I, J, Center=[ Lon, Lat ], /Non_Interactive

   ; Read the line
   ReadF, Ilun, junk
   help, junk
   print,total(junk)
 
   Close,    Ilun
   Free_LUN, Ilun

   for I = 2400, 3379 do begin
   for J = 770, 1439 do begin

   if (junk[I-2400,1439-J] ge 0) then Target[I,J] = junk[I-2400,1439-J]*1000 ;convert unit(ggn)

   endfor
   endfor

   print,'Totle ammount', total(Target)
   print,max(Target,min=min),min,mean(Target)
   
   ;====================================================================
   ; Save fossil fuel data out in bpch format
   ;====================================================================
 
   ; Tau values at beginning & end of this year
   Tau0 = Nymd2Tau( Year*10000L + ( N+1 )*100L + 1L )

   ; Make a DATAINFO structure for fossil fuel

      Success = CTM_Make_DataInfo( Float( Target ),        $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='ANTHSRCE',       $
                                Tracer=1,               $
                                Tau0=Tau0,              $
                                Unit='kg/month',        $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_Global )


     If (flag )                                        $
            then NewDataInfo = [ ThisDataInfo ]        $

            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

     If (flag )                                          $
            then NewFileInfo = [ ThisFileInfo ]          $

            else NewFileInfo = [ NewFileInfo, ThisFileInfo ]

     Flag =0L

Endfor

     CTM_WriteBpch, newDataInfo, newFileInfo, Filename=Outfile

Endfor

end
