pro no2_month_file_ind

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, CTM_Get_Data

year_factor  = [1/1.317,1,1.200]
month_factor = [0.0604,0.0668,0.0794,0.0829,0.083,0.0872,0.0815,0.0844,0.0892,0.0913,0.0941,0.0998]

for M = 0,2  do begin

flag = 1L
for N = 0,11 do begin

year =  M+2005
month = N+1

Yr4 = string( year, format = '(i4.4)')
Mon2 = string( month, format = '(i2.2)')

; Tau values at beginning & end of this year
NYMD0 = Year * 10000L + Month * 100L + 1L
Tau0 = Nymd2Tau( NYMD0 )
print, NYMD0

;SET MODEL
InType   = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InGrid   = CTM_Grid( InType, /No_Vertical )

xmid =InGrid.xmid
ymid =InGrid.ymid

no2  = FltArr( InGrid.IMX, InGrid.JMX )

filename1='/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/ind-'+ Yr4 +'-05x0666.bpch'
filename2='/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_ind_2006.geos5.05x0666'
filename3='/z2/geos/GEOS_0.5x0.666_CH/Streets_200607/China_mask.geos5.05x0666'
outfile  ='/z3/gengguannan/indir/NO2/SE_Asia_ind-'+ Yr4 +'-05x0666.bpch'

ctm_get_data, datainfo1, filename=filename1, tau0=Tau0, tracer=1
data18=*(datainfo1[0].data)

ctm_get_data, datainfo2, filename=filename2, tau0=nymd2tau(20060101), tracer=1
data28=*(datainfo2[0].data)

ctm_get_data, datainfo3, filename=filename3, tau0=nymd2tau(19850101), tracer=802
China_mask=*(datainfo3[0].data)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if China_mask[I,J] eq 1                                            $
        then no2[I,J] = data18                                         $
        else no2[I,J] = data28 * year_factor[M] * month_factor[N]
  endfor
endfor

; Make a DATAINFO structure
Success = CTM_Make_DataInfo( Float( no2 ),              $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='ANTHSRCE',       $
                                Tracer=1,               $
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

