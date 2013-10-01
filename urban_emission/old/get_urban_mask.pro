pro get_urban_mask
 
   ; Resolve external functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak, CTM_BoxSize, CTM_RegridH, CTM_NamExt, CTM_ResExt
   
   ; Arguments
   Filename = '/home/gengguannan/indir/urban_mask_01x01.asc'
   Outfile1  = '/home/gengguannan/indir/urban_mask_05x05_v3.bpch'
   Outfile2  = '/home/gengguannan/indir/urban_mask_05x0666_v3.bpch'

   ; Clean up common blocks, etc.
   CTM_CleanUp

   NewType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0] )
;   NewType = CTM_Type( 'GENERIC', Res=[0.125d0,0.125d0],halfpolar=0,center180=0 )
   NewGrid = CTM_Grid( NewType )

   OldType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0],halfpolar=0,center180=0 )
   OldGrid = CTM_Grid( OldType )

   InType = CTM_Type( 'GENERIC', Res=[0.1d0,0.1d0],halfpolar=0,center180=0 )
   InGrid = CTM_Grid( InType)


   oldxmid = OldGrid.xmid
   oldymid = OldGrid.ymid

   inxmid = InGrid.xmid
   inymid = InGrid.ymid


   ; Define variables
   Line = ''

   junk = Fltarr(570,310)
   temp = Fltarr(InGrid.IMX, InGrid.JMX )
   Target  = FltArr( OldGrid.IMX, OldGrid.JMX )
   Target_1  = FltArr( NewGrid.IMX, NewGrid.JMX )
   nod  = FltArr( OldGrid.IMX, OldGrid.JMX )

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

   for I = 2560L,3129L do begin
     for J = 1090L,1399L do begin

     if (junk[I-2560,1399-J] gt 0) then temp[I,J] = 1

     endfor
   endfor

   print,total(temp)
   print,max(temp,min=min),min,mean(temp)



   for I = 0,OldGrid.IMX-1 do begin
     for J = 0,OldGrid.JMX-1 do begin
       for X = 5*I,5*I+4 do begin
         for Y = 5*J,5*J+4 do begin
           if temp[X,Y] gt 0 then nod[I,J] +=1
         endfor
       endfor
     endfor
   endfor

print,max(nod),min(nod),mean(nod)


  for I = 0,OldGrid.IMX-1 do begin
     for J = 0,OldGrid.JMX-1 do begin
       if nod[I,J] gt 0 then Target[I,J] = 1
     endfor
  endfor


   ;regrid
   NewData = CTM_RegridH( Target, OldGrid, NewGrid, /Double, /Quiet )

   help, NewData
   print,total(NewData)
;
   for I = 0,NewGrid.IMX-1 do begin
     for J = 0,NewGrid.JMX-1 do begin
       if NewData[I,J] gt 0 then Target_1[I,J] = 1
     endfor
   endfor

   print,total(Target_1)

   
   ;====================================================================
   ; Save population data out in bpch format
   ;====================================================================
 
   ; Tau values at beginning & end of this year
   Tau0 = Nymd2Tau( 2006*10000L + 12*100L + 31L )

   ; Make a DATAINFO structure for fossil fuel

      Success = CTM_Make_DataInfo( Float( Target ),     $
                                ThisDataInfo,            $
                                ThisFileInfo,            $
                                ModelInfo=OldType,       $
                                GridInfo=OldGrid,        $
                                DiagN='LANDMAP',         $
                                Tracer=802,              $
                                Tau0=Tau0,               $
                                Unit='',                 $
                                Dim=[OldGrid.IMX,        $
                                     OldGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],      $
                                /No_Global )

     CTM_WriteBpch, ThisDataInfo, ThisFileInfo, Filename=Outfile1


     Success = CTM_Make_DataInfo( Float( Target_1 ),     $
                                ThisDataInfo,            $
                                ThisFileInfo,            $
                                ModelInfo=NewType,       $
                                GridInfo=NewGrid,        $
                                DiagN='LANDMAP',         $
                                Tracer=802,              $
                                Tau0=Tau0,               $
                                Unit='',                 $
                                Dim=[NewGrid.IMX,        $
                                     NewGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],      $
                                /No_Global )

     CTM_WriteBpch, ThisDataInfo, ThisFileInfo, Filename=Outfile2

end
