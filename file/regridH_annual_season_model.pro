pro regridH_annual_season_model

   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
FORWARD_FUNCTION CTM_Type,    CTM_Grid,   CTM_BoxSize, $
                 CTM_RegridH, CTM_NamExt, CTM_ResExt, TAU2YYMMDD

NewType = CTM_Type('GENERIC', Res=[0.5d0,0.5d0],halfpolar=0,center180=0)     
;NewType = CTM_Type( 'GEOS5', Resolution=[2.5d0,2d0])
NewGrid = CTM_Grid( NewType)

;OldType = CTM_Type('GENERIC', Res=[0.5d0,0.5d0],halfpolar=0,center180=0)
OldType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
OldGrid = CTM_Grid( OldType)


Year = 2005
Month = 1
Day = 1

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
Day2 = string( Day, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + Day * 1L
Tau0 = nymd2tau(NYMD)
print,nymd


;infile = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.month.05x0666.power.plant.bpch'
;outfile = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.month.05x05.power.plant.bpch'
infile = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x0666.bpch'
outfile= '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x05.bpch'

; Input data array
CTM_GET_DATA, DataInfo, tracer = 1, Filename = InFile
Dim = [NewGrid.IMX, NewGrid.JMX, 1, 1]

For D = 0, N_Elements(DataInfo)-1  do begin

OldData=fltarr(Oldgrid.IMX,OldGrid.JMX)

      ; Old data array
      OldData = *( DataInfo.Data)

      help, OldData
      print, DataInfo[D].Dim
      print, DataInfo[D].First
      print, max(OldData),mean(OldData),total(OldData)

      result=tau2yymmdd(DataInfo[D].tau0,  /NFORMAT)
      time=result[0]

      print,'Processing data for YYMMDD: ', string(time,format='(i8)')

      NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /per_Unit_Area, /Double, /Quiet )
      ;NewData = CTM_RegridH( OldData, OldGrid, NewGrid, /Double, /Quiet )

      help, NewData
      print,max(NewData),mean(NewData),total(NewData)

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


         NewDataInfo = ThisDataInfo

         ; Undefine stuff for safety's sake
         UnDefine, OldData
         UnDefine, NewData
         UnDefine, ThisDataInfo

Endfor

CTM_WriteBpch, NewDataInfo, FileName= Outfile

end
