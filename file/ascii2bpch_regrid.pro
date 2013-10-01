pro ascii2bpch_regrid
 
   ; Resolve external functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak, CTM_BoxSize, CTM_RegridH, CTM_NamExt, CTM_ResExt
   
   ; Arguments
   Filename = '/home/gengguannan/indir/intexb_scaled/wrong/scaled_tra.asc'
   Outfile  = '/home/gengguannan/indir/intexb_scaled/NOx_tra_2006.05x0666'

   ; Clean up common blocks, etc.
   CTM_CleanUp

   NewType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
   ;NewType = CTM_Type('GENERIC', Res=[0.25d0,0.25d0],halfpolar=0,center180=0)
   NewGrid = CTM_Grid( NewType)

   OldType = CTM_Type('GENERIC', Res=[0.1d0,0.1d0],halfpolar=0,center180=0)
   OldGrid = CTM_Grid( OldType)


   oldxmid = OldGrid.xmid
   oldymid = OldGrid.ymid

   ; Define variables
   Line = ''

   junk = Fltarr(617,473)
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

   for I = 2534L,3150L do begin
   for J = 963L,1435L do begin

   if (junk[I-2534,1435-J] ge 0) then Target[I,J] = junk[I-2534,1435-J]*1000

   endfor
   endfor

   print,total(Target)
   print,max(Target,min=min),min,mean(Target)

   ;regrid
   NewData = CTM_RegridH( Target, OldGrid, NewGrid, /Double, /Quiet )

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
