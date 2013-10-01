pro ascii2bpch_grid1
 
   ; Resolve external functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak
   
   ; Arguments
   Filename = '/home/gengguannan/indir/area_mask_1.asc'
   Outfile  = '/home/gengguannan/indir/area_mask_1_025x025.bpch'

   ; Clean up common blocks, etc.
   CTM_CleanUp

;   InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
   InType = CTM_Type( 'GENERIC', Res=[0.25d0,0.25d0], Halfpolar=0, Center180=0 )
   InGrid = CTM_Grid( InType, /No_Vertical )

   inxmid = InGrid.xmid
   inymid = InGrid.ymid

   ; Define variables
   Line = ''

   junk = Fltarr( 106, 100 )
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

   for I = 1136,1241 do begin
   for J = 448,547 do begin

   if (junk[I-1136,547-J] ge 0) then Target[I,J] = junk[I-1136,547-J]

   endfor
   endfor

   print,'Urban popu', total(Target)
   print,max(Target,min=min),min,mean(Target)
   
   ;====================================================================
   ; Save population data out in bpch format
   ;====================================================================
 
   ; Tau values at beginning & end of this year
   Tau0 = Nymd2Tau( 1985*10000L + 1*100L + 1L )

   ; Make a DATAINFO structure for fossil fuel

      Success = CTM_Make_DataInfo( Float( Target ),     $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='LANDMAP',        $
                                Tracer=802,             $
                                Tau0=Tau0,              $
                                Unit='',                $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_Global )


     CTM_WriteBpch, ThisDataInfo, ThisFileInfo, Filename=Outfile

end
