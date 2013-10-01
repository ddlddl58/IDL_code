;This code was created to average daily gridded GEOS_Chem results to annual/seasonal/mothly data.

pro no2_ctm_season_average_column

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
;InType = CTM_Type('GENERIC', Res=[0.25d0,0.25d0],halfpolar=0,center180=0)
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid
close, /all

year = 2005
Yr4  = String( Year, format = '(i4.4)' )

no2 = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

for m = 0,12-1 do begin
for d = 0,31-1 do begin

mon2 = string(m+1, format='(i2.2)')
day2 = string(d+1, format='(i2.2)')

nymd0 = year*10000L + (m+1)*100L + 31L
nymd  = year*10000L + (m+1)*100L + (d+1)*1L
print,nymd
tau0 = nymd2tau(nymd)

if (nymd eq 20050229) then continue
if (nymd eq 20050230) then continue
if (nymd eq 20050231) then continue
if (nymd eq 20050431) then continue
if (nymd eq 20050631) then continue
;if (nymd eq 20050707) then continue
if (nymd eq 20050931) then continue
if (nymd eq 20051131) then continue
;if (nymd eq 20060101) then continue
if (nymd eq 20060228) then continue
if (nymd eq 20060229) then continue
if (nymd eq 20060230) then continue
if (nymd eq 20060231) then continue
if (nymd eq 20060301) then continue
if (nymd eq 20060302) then continue
;if (nymd eq 20060425) then continue
if (nymd eq 20060431) then continue
if (nymd eq 20060517) then continue
if (nymd eq 20060631) then continue
if (nymd eq 20060931) then continue
;if (nymd eq 20061004) then continue
if (nymd eq 20061131) then continue
if (nymd eq 20070229) then continue
if (nymd eq 20070230) then continue
if (nymd eq 20070231) then continue
if (nymd eq 20070431) then continue
if (nymd eq 20070631) then continue
if (nymd eq 20070931) then continue
if (nymd eq 20071131) then continue
if (nymd eq 20080230) then continue
if (nymd eq 20080231) then continue
if (nymd eq 20080431) then continue
if (nymd eq 20080611) then continue
if (nymd eq 20080631) then continue
if (nymd eq 20080926) then continue
if (nymd eq 20080927) then continue
if (nymd eq 20080928) then continue
if (nymd eq 20080929) then continue
if (nymd eq 20080931) then continue
if (nymd eq 20081131) then continue
if (nymd eq 20090229) then continue
if (nymd eq 20090230) then continue
if (nymd eq 20090231) then continue
if (nymd eq 20090431) then continue
if (nymd eq 20090631) then continue
if (nymd eq 20090931) then continue
if (nymd eq 20091131) then continue
if (nymd eq 20100229) then continue
if (nymd eq 20100230) then continue
if (nymd eq 20100231) then continue
if (nymd eq 20100431) then continue
if (nymd eq 20100631) then continue
if (nymd eq 20100931) then continue
if (nymd eq 20101131) then continue

;infile = '/z3/wangsiwen/Satellite/DPGC_OMI_05x06_NegIncl_06prof/OMI_0.66x0.50_'+ Yr4 +'_'+ Mon2 +'_'+ Day2
infile = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.bpch'
;infile = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.plus.ubpower/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.bpch'
;infile = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.ubpower/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.bpch'


CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile
data18 = *(datainfo1[0].data)

;OMI_ARRAY = fltarr(InGrid.IMX,InGrid.JMX)
;restore,filename=infile
;data18 = OMI_ARRAY/1.0E+15


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (data18[I,J] gt 0) then begin
       no2[I,J] += data18[I,J] 
       nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor

print,max(nod,min=min),min,mean(nod)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  no2[I,J] /= nod[I,J]  $
        else  no2[I,J] = 0
  endfor
endfor

print,max(no2,min=min),min,mean(no2)

;outfile = '/z3/gengguannan/GEOS_Chem/2006_SO2/ctm.vc_4-10_'+Yr4+'_SO2.05x0666.power.plant.bpch'
;outfile = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_4-10_'+Yr4+'_NO2.05x0666.power.plant.bpch'
outfile = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic/ctm.vc_annual_'+ Yr4 +'_NO2.bpch'
;outfile = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.plus.ubpower/ctm.vc_annual_'+ Yr4 +'_NO2.bpch'
;outfile = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.ubpower/ctm.vc_annaul_'+ Yr4 +'_NO2.bpch'


   success = CTM_Make_DataInfo( no2,       $
                                ThisDataInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=1,               $
                                Tau0= nymd2tau(nymd0),             $
                                Unit='E+15molec/cm2',              $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   success = CTM_Make_DataInfo( nod,       $
                                ThisDataInfo2,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=88,              $
                                Tau0= nymd2tau(nymd0),             $
                                Unit='unitless',              $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   NewDataInfo = [ThisDataInfo, ThisDataInfo2]

   CTM_WriteBpch, NewDataInfo, FileName = OutFile


end
