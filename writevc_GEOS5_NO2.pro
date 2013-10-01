; $ Id: writevc.pro v2.1 2004/04/06 16:45:00 mayfu Exp $
; Adapted from $ Id: writehchovc.pro v1.1 2004/03/12 08:45:00 mayfu Exp $
;=======================================================================
;
; (tmf, 04/06/2004)
; Writes trace gas troposheric vertical column from daily outputted files. 
;
; (tmf, 03/12/2004)
; Writes the GEOS-CHEM HCHO vertical columns with and without 
; biogenic isoprene emissions.
;
;=======================================================================

;@calvc.pro

pro writevc_geos5_NO2, Year=year, Month=month, Date_b=Date_b, Date_e=Date_e

; Time set
Year = 2006L
Month =  06L
Date_b = 01L
Date_e = 30L

;====================================================================
; Initializing
;====================================================================

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = String( Month, Format = '(i2.2)' )

rtag = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
ytag = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']

yr_name = strmid(strtrim(string(year),2), 2,2)
monthyeartag = rtag[month-1] + yr_name

NYMD0 = Year * 10000L + Month * 100L + 1L
print, NYMD0

; Input and output data file directary:
InDir = '/data/wsw/INTEX-B/'
OutDir='/data/wsw/Power_Plant/'
   
; InputFile Info.
InMonthlyFileName = InDir + 'ctm.' + Yr4 + Mon2 + '01.month.intex.bpch'

TracerID = 25 
InDIAG  = 'TIME-SER'
OutDIAG = 'IJ-AVG-$'
OutTracerID = 1

; Model Info
ModelName = 'GEOS5'
Resolution = [2.0d0/3.0d0, 0.5d0]

; Output file
OutFileName =  OutDir + 'ctm.vc_daily_' + Yr4 + Mon2 + '_NO2_month_intex.05x0666.bpch'
OutFileName2 =  OutDir + 'ctm.vc_monthly_' + Yr4 + Mon2 + '_NO2_month_intex.05x0666.bpch'
;====================================================================
; Setup model parameters
;====================================================================
InType = CTM_Type( ModelName, Resolution=Resolution )
InGrid = CTM_Grid( InType )
;====================================================================
; Read Data
;====================================================================
; Monthly data
; Tropopause layer number
CTM_Get_Data, DataInfo_tpl, 'TR-PAUSE', Tracer = 1, File = InMonthlyFileName, tau0 = nymd2tau(NYMD0)
tpl = *( DataInfo_tpl[0].Data )
help, tpl  
;====================================================================
; Loop over time blocks
;====================================================================
N_Time = Date_e - Date_b + 1L
; Allocate array to store the vertical column
VC = FltArr( InGrid.IMX, InGrid.JMX, N_Time )

Flag = 1

   IF ( Month lt 12L ) then begin
      NYMD1 = Year * 10000L + (Month + 1L) * 100L + 1L
   endif else begin
      NYMD1 = (Year + 1L) * 10000L + 100L + 1L
   endelse

   For T = 0L, N_Time-1L do begin

      Date2 = String( T+Date_b, format = '(i2.2)' )
      Date_now = NYMD0 + (T+Date_b-1) * 1L
      Tau0 = nymd2tau(Date_now)
      Tau1 = Tau0 + 24.0
      print, date_now, tau1

      InDailyFileName = InDir + 'ts_satellite.' + Yr4 + Mon2 + Date2 + '.month.intex.bpch'

      ; Daily data
      ; trace gas mixing ratio
      Undefine, DataInfo_g
      CTM_Get_Data, DataInfo_g, InDIAG, Tracer = TracerID, File = InDailyFileName

      ; psptop (Ps - Ptop)
      Undefine, DataInfo_p
      CTM_Get_Data, DataInfo_p, 'PEDGE-$', Tracer =1, File = InDailyFileName
     
      ; grab the datablock
      UnDefine, mixingratio
      UnDefine, psptop

      mixingratio = *( DataInfo_g[0].Data )
      psptop = *( DataInfo_p[0].Data )

      print, 'Total Mixingratio=',total(mixingratio)

      ; Loop over global grids     
      For J = 0L, 133-1L do begin
      For I = 0L, 121-1L do begin

          tempvc = 0.0d0
          tropopause = Long(Fix(tpl[I,J]))
          For L = 0L, tropopause-2L do begin
              tempvc = Double( InGrid.EtaEdge[L] - InGrid.EtaEdge[L+1] ) *   $ 
                       Double( mixingratio[I,J,L] ) * (1.0d-9) + tempvc
          endfor
          VC[I+375,J+158,T] = Double(psptop[I,J]) * (100.0d0) * (6.022d23) / $
                        (9.8d0) / (0.02897d0) * tempvc / (10000.d0)/1.0E+15
      
      endfor
      endfor

      ;------------------------------------------
      ; make data array
      ;------------------------------------------
      ; Make a DATAINFO structure for this NEWDATA
      Success = CTM_Make_DataInfo( VC[*,*,T],            $
                                   ThisDataInfo,         $
                                   ModelInfo=InType,     $
                                   GridInfo=InGrid,      $
                                   DiagN=OutDIAG,        $
                                   Tracer=OutTracerID,   $
                                   Tau0=Tau0,            $
                                   Tau1=Tau1,            $
                                   Unit='E+15molec/cm2', $
                                   Dim=[InGrid.IMX,      $
                                        InGrid.JMX,      $
                                        0, 0],           $
                                   First=[1L, 1L, 1L],   $
                                   /No_vertical )

      If (flag )                                         $
            then NewDataInfo = [ ThisDataInfo ]          $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      Flag = 0L

   endfor

   ;====================================================================
   ; Calculate monthly mean
   ;====================================================================
   MonthlyVC = FltArr( InGrid.IMX, InGrid.JMX )

   ; Loop over global grids     
   For J = 0L, InGrid.JMX-1L do begin
   For I = 0L, InGrid.IMX-1L do begin
      MonthlyVC[I,J] = Total( VC[I,J,*] ) / Float( N_Time )
   endfor
   endfor

   ;====================================================================
   ; Output to bpch files 
   ; Write out the full emission file first
   ;====================================================================
   ; Write to binary punch file 
   CTM_WriteBpch, NewDataInfo, FileName = OutFileName

   ;====================================================================
   ; All done!
   ;====================================================================



      success = CTM_Make_DataInfo( MonthlyVC[*,*],       $
                                   ThisDataInfo2,        $
                                   ModelInfo=InType,     $
                                   GridInfo=InGrid,      $
                                   DiagN=OutDIAG,        $
                                   Tracer=OutTracerID,   $
                                   Tau0= nymd2tau(NYMD0),$
                                   Unit='E+15molec/cm2', $
                                   Dim=[InGrid.IMX,      $
                                        InGrid.JMX,      $
                                        0, 0],           $
                                   First=[1L, 1L, 1L],   $
                                   /No_vertical )

      If (flag )                                         $
            then NewDataInfo = [ ThisDataInfo2 ]         $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo2 ]

      Flag = 0L


   CTM_WriteBpch, ThisDatainfo2, FileName = OutFileName2

end
;=======================================================================
; End of Code
;=======================================================================
