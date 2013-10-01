pro regridH

   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
FORWARD_FUNCTION CTM_Type,    CTM_Grid,   CTM_BoxSize, $
                 CTM_RegridH, CTM_NamExt, CTM_ResExt, TAU2YYMMDD

NewType = CTM_Type('GENERIC', Res=[1d0,1d0],halfpolar=0,center180=0)
;NewType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
;NewType = CTM_Type( 'GEOS5', Resolution=[2.5d0,2d0])
NewGrid = CTM_Grid( NewType)

;OldType = CTM_Type('GENERIC', Res=[0.5d0,0.5d0],halfpolar=0,center180=0)
OldType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
OldGrid = CTM_Grid( OldType)

;====================================================================
; Define the path name for each of the REAL*4 files that
; contain D. Streets' emission data -- change if necessary!
;====================================================================
Flag = 1L

Year=1985

Yr4  = String( Year, format = '(i4.4)' )
NYMD = Year * 10000L + 1 * 100L + 1L
Tau0 = nymd2tau(NYMD)

;infile = '/home/gengguannan/indir/mask/region_mask_05x05.bpch'
;outfile = '/home/gengguannan/indir/mask/region_mask_05x0666.bpch'
infile = '/public/geos/GEOS_0.5x0.666_CH/Streets_200607/China_mask.geos5.05x0666'
outfile = '/home/gengguannan/indir/mask/China_mask.1x1'
;infile = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_4-10_2006_NO2.05x0666.power.plant.bpch'
;outfile = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_4-10_2006_NO2.2x2.5.power.plant.bpch'



; Input data array
CTM_GET_DATA, DataInfo, Filename = InFile, tau0=tau0
Dim = [NewGrid.IMX, NewGrid.JMX, 1, 1]

For D = 0, N_Elements(DataInfo)-1  do begin

OldData=fltarr(Oldgrid.IMX,OldGrid.JMX)

      ; USW denotes when we can reuse the mapping weights
      ;USW = 1L - Flag

      ; Old data array
      OldData = *( DataInfo.Data)

      help, OldData
      print, DataInfo[D].Dim
      print, DataInfo[D].First

      result=tau2yymmdd(DataInfo[D].tau0,  /NFORMAT)
      time=result[0]

      print,'Processing data for YYMMDD: ', string(time,format='(i8)')

      NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /per_Unit_Area, /Double, /Quiet )
      ;NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /Double, /Quiet )
      help, NewData
      print,total(NewData)

      ; Make a DATAINFO structure
      Success = CTM_Make_DataInfo( Float( NewData ),              $
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

         ; NEWDATAINFO is an array of DATAINFO Structures
         ; Append THISDATAINFO onto the NEWDATAINFO array
         NewDataInfo =  ThisDataInfo

         ; Undefine stuff for safety's sake
         UnDefine, OldData
         UnDefine, NewData
         UnDefine, ThisDataInfo

Endfor

CTM_WriteBpch, NewDataInfo, FileName= Outfile
 
end
