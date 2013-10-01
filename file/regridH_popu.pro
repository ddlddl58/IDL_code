pro regridH_popu

   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
FORWARD_FUNCTION CTM_Type,    CTM_Grid,   CTM_BoxSize, $
                 CTM_RegridH, CTM_NamExt, CTM_ResExt, TAU2YYMMDD

;NewType = CTM_Type('GENERIC', Res=[0.125d0,0.125d0],halfpolar=0,center180=0)
NewType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
NewGrid = CTM_Grid( NewType)

OldType = CTM_Type('GENERIC', Res=[0.5d0,0.5d0],halfpolar=0,center180=0)
;OldType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
OldGrid = CTM_Grid( OldType)

close, /all

;infile = '/home/gengguannan/indir/popu/urban_popu_2010_05x05.bpch'
;outfile= '/home/gengguannan/indir/popu/urban_popu_2010_05x0666.bpch'
infile = '/home/gengguannan/indir/province_mask_05x05.bpch'
outfile = '/home/gengguannan/indir/province_mask_05x0666.bpch'


; Input data array
CTM_GET_DATA, DataInfo, tracer = 802, Filename = InFile, tau0=nymd2tau(19850101)
Dim = [NewGrid.IMX, NewGrid.JMX, 1, 1]

For D = 0, N_Elements(DataInfo)-1  do begin

OldData=fltarr(Oldgrid.IMX,OldGrid.JMX)

      ; Old data array
      OldData = *( DataInfo.Data)

      help, OldData
      print, DataInfo[D].Dim
      print, DataInfo[D].First

      result=tau2yymmdd(DataInfo[D].tau0,  /NFORMAT)
      time=result[0]

      print,'Processing data for YYMMDD: ', string(time,format='(i8)')

      ;NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /per_Unit_Area, /Double, /Quiet )
      NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /Double, /Quiet )
      help, NewData
      print,total(NewData)

Mask = fltarr(NewGrid.IMX,NewGrid.JMX)

for I = 0,NewGrid.IMX-1 do begin
  for J = 0,NewGrid.JMX-1 do begin
    if NewData[I,J] gt 0 then Mask[I,J] = 1
  endfor
endfor


      ; Make a DATAINFO structure
      Success = CTM_Make_DataInfo( Float( Mask ),              $
                                   ThisDataInfo,                  $
                                   ModelInfo=NewType,             $
                                   GridInfo=NewGrid,              $
                                   DiagN=DataInfo[D].Category,    $
                                   Tracer=DataInfo[D].Tracer,     $
                                   Tau0=DataInfo[D].Tau0,         $
                                   Tau1=DataInfo[D].Tau1,         $
                                   Unit=DataInfo[D].Unit,         $
                                   Dim= Dim,           $
                                   First=DataInfo[D].First) 


         NewDataInfo = ThisDataInfo

         ; Undefine stuff for safety's sake
         UnDefine, OldData
         UnDefine, NewData
         UnDefine, ThisDataInfo

Endfor

CTM_WriteBpch, NewDataInfo, FileName= Outfile
CTM_Cleanup

end
