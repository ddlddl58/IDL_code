pro average_simple

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
;InType = CTM_Type( 'generic', res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all

no2_gc = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

for y = 2006,2006 do begin
for m = 6,8 do begin
for d = 1,31 do begin

Yr4  = String( y, format='(i4.4)')
mon2 = string( m, format='(i2.2)')
day2 = string( d, format='(i2.2)')

nymd = y*10000L + m*100L + d*1L
print,nymd
tau0 = nymd2tau(nymd)

if (nymd eq 20050631) then continue
if (nymd eq 20060631) then continue
if (nymd eq 20070631) then continue

infile = '/home/gengguannan/work/ur_emiss/meic/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.meic.05x0666.bpch'
;infile = '/z3/gengguannan/outdir/ur_emiss/'+ Yr4 +'/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.month.05x0666.power.plant.bpch'
;infile = '/z3/gengguannan/outdir/ur_emiss/scenario/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.s8.05x0666.bpch'

CTM_Get_Data, datainfo, tracer = 1, tau0 = tau0, filename = infile
data18 = *(datainfo[0].data)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (data18[I,J] gt 0) then begin
       no2_gc[I,J] += data18[I,J]
       nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor
endfor

print,max(nod,min=min),min,mean(nod)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then no2_gc[I,J] /= nod[I,J]  $
        else no2_gc[I,J] = -999
  endfor
endfor

print,max(no2_gc,min=min),min,mean(no2_gc)


;OMI
;outfile = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2006_JJA_05x0666.bpch'
;outfile = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2009_JJA_025x025.bpch'

;GC
;outfile = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2007_JJA_NO2.month.05x0666.power.plant.bpch'
;outfile = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2006_JJA_NO2.s8.05x0666.bpch'
outfile = '/home/gengguannan/work/ur_emiss/ctm.vc_seasonal_2006_JJA_NO2.meic.05x0666.bpch'

   success = CTM_Make_DataInfo( no2_gc,                  $
                                ThisDataInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='IJ-AVG-$',        $
                                Tracer=1,                $
                                Tau0= nymd2tau(20060101),$
                                Unit='E+15molec/cm2',    $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],      $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = outfile

end
