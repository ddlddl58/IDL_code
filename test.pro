pro test
 
   ; Resolve external functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak, CTM_BoxSize, CTM_RegridH, CTM_NamExt, CTM_ResExt

   OldType = CTM_Type('GENERIC', Res=[0.125d0,0.125d0],halfpolar=0,center180=0)
   OldGrid = CTM_Grid( OldType)

   oldxmid = OldGrid.xmid
   oldymid = OldGrid.ymid

   ; Define variables
   average = Fltarr(OldGrid.IMX,OldGrid.JMX)
   
   for month = 6,8 do begin
   Mon2 = String( month, Format = '(i2.2)' )
   
   ; Arguments
   Filename = '/home/gengguannan/no2_2006'+ Mon2 +'.asc'
   Outfile  = '/home/gengguannan/JJA.bpch'

   ; Clean up common blocks, etc.
   CTM_CleanUp

   ; Define variables
   Line = ''

   junk = Fltarr(1440,2880)
   Target  = FltArr( OldGrid.IMX, OldGrid.JMX )

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

   ; Use CTM_INDEX to get the right lon & lat
   ; NOTE: (I,J) are FORTRAN notation (starts from 1)!
   ;CTM_Index, InType, I, J, Center=[ Lon, Lat ], /Non_Interactive

   ; Read the line
   ReadF, Ilun, junk
   help, junk
   print,total(junk)
 
   Close,    Ilun
   Free_LUN, Ilun

   for I = 0L,2880L-1L do begin
   for J = 0L,1440L-1L do begin

   if (junk[I,1439-J] ge 0) then Target[I,J] = junk[I,1439-J]/100

   endfor
   endfor

   print,total(Target)
   print,max(Target,min=min),min,mean(Target)

   for I = 0,OldGrid.IMX-1 do begin
     for J = 0,OldGrid.JMX-1 do begin
       if Target[I,J] ge 0 then begin
         average[I,J] += Target[I,J]
         nod[I,J] += 1
       endif
     endfor
   endfor

   endfor
 
   for I = 0,OldGrid.IMX-1 do begin
     for J = 0,OldGrid.JMX-1 do begin
       if nod[I,J] gt 0 then begin
         average[I,J] /= nod[I,J]
       endif else begin
         average[I,J] = -999
       endelse
     endfor
   endfor

   print,max(average,min=min)

   ;====================================================================
   ; Save population data out in bpch format
   ;====================================================================
 
   ; Tau values at beginning & end of this year
   Tau0 = Nymd2Tau( 2006*10000L + 1*100L + 1L )

   ; Make a DATAINFO structure for fossil fuel

      Success = CTM_Make_DataInfo( Float( average ),     $
                                ThisDataInfo,            $
                                ThisFileInfo,            $
                                ModelInfo=OldType,       $
                                GridInfo=OldGrid,        $
                                DiagN='IJ-AVG-$',        $
                                Tracer=1,                $
                                Tau0=Tau0,               $
                                Unit='E+15molec/cm2',    $
                                Dim=[OldGrid.IMX,        $
                                     OldGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],      $
                                /No_vertical )


     CTM_WriteBpch, ThisDataInfo, ThisFileInfo, Filename=Outfile

end
