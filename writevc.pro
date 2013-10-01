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
; (wsw, 10/08/2010)
; Replace PS-PTOP to PEDGE
;=======================================================================

;@calvc.pro

pro writevc

; Time set
Year = 2004L
Month = 1L

;Day   1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
;Day = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28]
Day = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = String( Month, Format = '(i2.2)' )

NYMD0 = Year * 10000L + Month * 100L + 1L
NYMD1 = Year * 10000L + Month * 100L + 1L

; Input and output data file directary:
InDir = '/z5/gengguannan/GEOS_Chem/meic_120713/'+ Yr4 +'/'
OutDir= '/z5/gengguannan/outdir/temp/'
   
; InputFile Info.
;ctm_file = InDir + 'ctm.' + Yr4 + Mon2 + '01.bpch'
ctm_file = InDir + 'ctm.'+ Yr4 +'0101.bpch'
;ctm_file = InDir + 'ctm.20060701.bpch'


; Output file
OutFileName =  OutDir +'ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.meic.05x0666.bpch'
OutFileName2 =  OutDir +'ctm.vc_monthly_'+ Yr4 + Mon2 +'_NO2.meic.05x0666.bpch'


;====================================================================
; Setup model parameters
;====================================================================

InType = CTM_Type( 'GEOS5', Resolution=[ 2d0/3d0,0.5d0 ] )
InGrid = CTM_Grid( InType )

;====================================================================
; Read Data
;====================================================================
; Monthly data
; Tropopause layer number
Undefine, DataInfo_tpl
CTM_Get_Data, DataInfo_tpl, 'TR-PAUSE', Tracer = 1, File = ctm_file, tau0 = nymd2tau(NYMD1)
tpl = *( DataInfo_tpl[0].Data )
help, tpl  

;====================================================================
; Loop over time blocks
;====================================================================

N_Time = n_elements(Day)
VC = FltArr( InGrid.IMX, InGrid.JMX, N_Time )

flag = 1

   For T = 0L, N_Time-1L do begin

      Day2 = String( Day[T], format = '(i2.2)' )
      NYMD2 = Year * 10000L + Month * 100L + Day[T] * 1L
      Tau0 = nymd2tau(NYMD2)
      Tau1 = Tau0 + 24.0
      print,NYMD2

      DailyFile = InDir + 'ts_13_15.'+ Yr4 + Mon2 + Day2 +'.bpch'

      ; Daily data
      ; trace gas mixing ratio
      Undefine, DataInfo_g
      Undefine, mixingratio
      CTM_Get_Data, DataInfo_g, 'TIME-SER', Tracer = 25, File = DailyFile
      mixingratio = *( DataInfo_g[0].Data )

      print, 'Total Mixingratio=',total(mixingratio)

      ; Daily data
      ; Ps
      Undefine, DataInfo_p
      Undefine, ps
      CTM_Get_Data, DataInfo_p, 'PEDGE-$', Tracer = 1, File = DailyFile
      ps = *( DataInfo_p[0].Data )
     
      ; Loop over global grids     
      For J = 0L, 133-1L do begin
      For I = 0L, 121-1L do begin

          tempvc = 0.0d0
          tropopause = Long(Fix(tpl[I,J]))

          For L = 0L, tropopause-2L do begin
              tempvc = Double( InGrid.EtaEdge[L] - InGrid.EtaEdge[L+1] ) *   $ 
                       Double( mixingratio[I,J,L] ) * (1.0d-9) + tempvc
          endfor

          VC[I+375,J+158,T] = Double(ps[I,J]) * (100.0d0) * (6.022d23) / $
                        (9.8d0) / (0.02897d0) * tempvc / (10000.0d0)/1.0E+15
      
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
                                   DiagN='IJ-AVG-$',     $
                                   Tracer=1,             $
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

   CTM_WriteBpch, NewDataInfo, FileName = OutFileName

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

      success = CTM_Make_DataInfo( MonthlyVC[*,*],       $
                                   ThisDataInfo2,        $
                                   ModelInfo=InType,     $
                                   GridInfo=InGrid,      $
                                   DiagN='IJ-AVG-$',     $
                                   Tracer=1,             $
                                   Tau0= nymd2tau(NYMD0),$
                                   Unit='E+15molec/cm2', $
                                   Dim=[InGrid.IMX,      $
                                        InGrid.JMX,      $
                                        0, 0],           $
                                   First=[1L, 1L, 1L],   $
                                   /No_vertical )


     CTM_WriteBpch, ThisDataInfo2, FileName = OutFileName2

CTM_Cleanup


end
;=======================================================================
; End of Code
;=======================================================================
