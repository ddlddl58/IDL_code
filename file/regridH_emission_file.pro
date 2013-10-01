pro regridH_emission_file

   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
FORWARD_FUNCTION CTM_Type,    CTM_Grid,   CTM_BoxSize, $
                 CTM_RegridH, CTM_NamExt, CTM_ResExt, TAU2YYMMDD

;NewType = CTM_Type('GENERIC', Res=[0.25d0,0.25d0],halfpolar=0,center180=0)
NewType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
NewGrid = CTM_Grid( NewType)

OldType = CTM_Type('GENERIC', Res=[0.1d0,0.1d0],halfpolar=0,center180=0)
;OldType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
OldGrid = CTM_Grid( OldType)

;====================================================================
; Define the path name for each of the REAL*4 files that
; contain D. Streets' emission data -- change if necessary!
;====================================================================
Flag = 1L

Year = 2005
for Month = 1,12 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
NYMD = Year * 10000L + Month * 100L + 1L
Tau0 = nymd2tau(NYMD)

infile = '/z3/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/tra-'+ Yr4 +'-01x01.bpch'
outfile= '/z3/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/tra-'+ Yr4 +'-05x0666.bpch'

;infile = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_2007_month_all_size.01x01.bpch'
;outfile= '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_2007_month_all_size.025x025.bpch'


; Input data array
CTM_GET_DATA, DataInfo, tracer = 1, Filename = InFile, tau0=tau0
Dim = [NewGrid.IMX, NewGrid.JMX, 1, 1]


For D = 0, N_Elements(DataInfo)-1  do begin

OldData=fltarr(Oldgrid.IMX,OldGrid.JMX)

      ; USW denotes when we can reuse the mapping weights
      USW = 1L - Flag

      ; Old data array
      OldData = *( DataInfo.Data)

      help, OldData
      print, DataInfo[D].Dim
      print, DataInfo[D].First
      print,total(OldData)

      result=tau2yymmdd(DataInfo[D].tau0,  /NFORMAT)
      time=result[0]

      print,'Processing data for ', string(time,format='(i8)')

      ;NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /per_Unit_Area, /Double, /Quiet )
      NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /Double, /Quiet )
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
         if ( Flag )                                   $
            then NewDataInfo = [ ThisDataInfo ]              $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

         ; Reset FLAG to a nonzero value
         Flag = 0L

         ; Undefine stuff for safety's sake
         UnDefine, OldData
         UnDefine, NewData
         UnDefine, ThisDataInfo
endfor
Endfor

CTM_WriteBpch, NewDataInfo, FileName= Outfile
 
end

