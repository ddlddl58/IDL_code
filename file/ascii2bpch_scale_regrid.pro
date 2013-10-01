pro ascii2bpch_scale_regrid
 
   ; Resolve external functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak, CTM_BoxSize, CTM_RegridH, CTM_NamExt, CTM_ResExt
   
   ; Arguments
   Filename = '/home/gengguannan/indir/intex-b/2006_Asia_dom_NOx.asc'
   Factorfile = '/home/gengguannan/indir/intexb_scaled/factor_dom.asc'
   Outfile  = '/home/gengguannan/indir/intexb_scaled/NOx_dom_2006.05x0666'

   ; Clean up common blocks, etc.
   CTM_CleanUp

   NewType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
   ;NewType = CTM_Type('GENERIC', Res=[0.25d0,0.25d0],halfpolar=0,center180=0)
   NewGrid = CTM_Grid( NewType)

   OldType = CTM_Type('GENERIC', Res=[0.1d0,0.1d0],halfpolar=0,center180=0)
   OldGrid = CTM_Grid( OldType)

   oldxmid = OldGrid.xmid
   oldymid = OldGrid.ymid


   ;====================================================================
   ; emission file
   ;====================================================================

   ; Define variables
   Line = ''

   junk = Fltarr(980,670)
   Target  = FltArr( OldGrid.IMX, OldGrid.JMX )

   ; Open the file
   Open_File, Filename, Ilun, /Get_LUN
 
   ; Skip header
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line

   ; Read the line
   ReadF, Ilun, junk
   help, junk
 
   Close,    Ilun
   Free_LUN, Ilun

   for I = 2400L,3379L do begin
   for J = 770L,1439L do begin

   if (junk[I-2400,1439-J] ge 0) then Target[I,J] = junk[I-2400,1439-J]*1000

   endfor
   endfor

   ;====================================================================
   ; factor file
   ;====================================================================

   ; Define variables
   Line = ''

   temp = Fltarr(617,473)
   Factor  = FltArr( OldGrid.IMX, OldGrid.JMX )

   ; Open the file
   Open_File, Factorfile, Ilun, /Get_LUN

   ; Skip header
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line
   ReadF, Ilun, Line

   ; Read the line
   ReadF, Ilun, temp
   help, temp

   Close,    Ilun
   Free_LUN, Ilun

   for I = 2534L,3150L do begin
   for J = 963L,1435L do begin

   if (temp[I-2534,1435-J] ge 0) then Factor[I,J] = temp[I-2534,1435-J]

   endfor
   endfor

   OldData = FltArr( OldGrid.IMX, OldGrid.JMX )

   for I = 0,OldGrid.IMX-1 do begin
   for J = 0,OldGrid.JMX-1 do begin

   OldData[I,J] = Target[I,J] * Factor[I,J]

   endfor
   endfor

   help, OldData
   print,total(OldData)

   ;regrid
   NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /Double, /Quiet )

   help, NewData
   print,total(NewData)
   
   ;====================================================================
   ; Save population data out in bpch format
   ;====================================================================
 
   ; Tau values at beginning & end of this year
   Tau0 = Nymd2Tau( 2006*10000L + 1*100L + 1L )

   ; Make a DATAINFO structure for fossil fuel

      Success = CTM_Make_DataInfo( Float( NewData ),     $
                                ThisDataInfo,            $
                                ThisFileInfo,            $
                                ModelInfo=NewType,       $
                                GridInfo=NewGrid,        $
                                DiagN='ANTHSRCE',        $
                                Tracer=1,                $
                                Tau0=Tau0,               $
                                Unit='Kg/year',          $
                                Dim=[NewGrid.IMX,        $
                                     NewGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],      $
                                /No_Global )


     CTM_WriteBpch, ThisDataInfo, ThisFileInfo, Filename=Outfile

end
