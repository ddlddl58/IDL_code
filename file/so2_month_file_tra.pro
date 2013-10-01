pro so2_month_file_tra

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, CTM_Get_Data

year_factor  = [1/1.170,1,1.179]
month_factor = [0.0833,0.0833,0.0833,0.0833,0.0833,0.0833,0.0833,0.0833,0.0833,0.0833,0.0833,0.0833]

for M = 0,2  do begin

flag = 1L
for N = 0,11 do begin

year =  M+2005
month = N+1

Yr4 = string( year, format = '(i4.4)')
Mon2 = string( month, format = '(i2.2)')

Infile  = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_SO2_tra_2006.geos5.05x0666'
Outfile = '/z3/gengguannan/indir/SO2/Streets_SO2_tra_'+ Yr4 +'.geos5.05x0666'

;SET MODEL
InType   = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InGrid   = CTM_Grid( InType, /No_Vertical )

xmid =InGrid.xmid
ymid =InGrid.ymid

so2  = FltArr( InGrid.IMX, InGrid.JMX )

ctm_get_data, datainfo, filename=Infile, tau0=nymd2tau(20060101), tracer=26
data18=*(datainfo[0].data)

so2 = data18 * year_factor[M] * month_factor[N]

; Tau values at beginning & end of this year
NYMD0 = Year * 10000L + Month * 100L + 1L
Tau0 = Nymd2Tau( NYMD0 )
print, NYMD0

; Make a DATAINFO structure
Success = CTM_Make_DataInfo( Float( so2 ),              $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='ANTHSRCE',       $
                                Tracer=26,              $
                                Tau0=Tau0,              $
                                Unit='kg/month',        $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_Global )


If (flag )                                          $
       then NewDataInfo = [ ThisDataInfo ]          $
       else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

If (flag )                                          $
       then NewFileInfo = [ ThisFileInfo ]          $
       else NewFileInfo = [ NewFileInfo, ThisFileInfo ]

Flag = 0L

CTM_WriteBpch, newDataInfo, newFileInfo, Filename = Outfile

endfor
endfor

end

