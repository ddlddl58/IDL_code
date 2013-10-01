pro average

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
;InType = CTM_Type( 'generic', res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all

for y = 2006,2006 do begin

no2_omi = fltarr(InGrid.IMX,InGrid.JMX)
no2_gc = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

;for y = 2005,2010 do begin
for m = 6,8 do begin
for d = 1,31 do begin

Yr4  = String( y, format='(i4.4)')
mon2 = string( m, format='(i2.2)')
day2 = string( d, format='(i2.2)')

nymd = y*10000L + m*100L + d*1L
print,nymd
tau0 = nymd2tau(nymd)

date = m*100L + d*1L
if (date eq 0229) then continue
if (date eq 0230) then continue
if (date eq 0231) then continue
if (date eq 0431) then continue
if (date eq 0631) then continue
if (date eq 0931) then continue
if (date eq 1131) then continue

if (nymd eq 20060228) then continue
if (nymd eq 20060301) then continue
if (nymd eq 20060302) then continue
if (nymd eq 20080927) then continue
if (nymd eq 20080928) then continue
if (nymd eq 20080929) then continue
;if (nymd eq 20060101) then continue
;if (nymd eq 20060425) then continue
;if (nymd eq 20061004) then continue


;infile1 = '/home/gengguannan/satellite/no2/OMI_KNMI_v2.0_DPGC/05x0666/'+ Yr4 +'/OMI_0.66x0.50_'+ Yr4 +'_'+ Mon2 +'_'+ Day2
infile1 = '/home/gengguannan/satellite/no2/OMI_KNMI_v2.0/05x0666/'+ Yr4 +'/OMI_0.66x0.50_'+ Yr4 +'_'+ Mon2 +'_'+ Day2

OMI_ARRAY = fltarr(InGrid.IMX,InGrid.JMX)
restore,filename=infile1
data18 = OMI_ARRAY/1e15

print,max(data18)

;infile2 = '/home/gengguannan/work/ur_emiss/gc/meic_s1/'+ Yr4 +'/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.meic_s1.05x0666.bpch'
infile2 = '/home/gengguannan/work/ur_emiss/gc/meic/'+ Yr4 +'/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.meic.05x0666.bpch'
;infile2 = '/home/gengguannan/work/ur_emiss/gc/siwen/'+ Yr4 +'/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.month.05x0666.power.plant.bpch'
;infile2 = '/home/gengguannan/work/ur_emiss/gc/scaled_intexb/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.scaled.intexb.05x0666.bpch'

CTM_Get_Data, datainfo, tracer = 1, tau0 = tau0, filename = infile2
data28 = *(datainfo[0].data)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (data18[I,J] gt 0) then begin
       no2_omi[I,J] += data18[I,J]
       no2_gc[I,J] += data28[I,J]
       nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor
;endfor

print,max(nod,min=min),min,mean(nod)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0) then begin
      no2_omi[I,J] /= nod[I,J]
      no2_gc[I,J]  /= nod[I,J]
    endif else begin
      no2_omi[I,J] = -999
      no2_gc[I,J]  = -999
    endelse
  endfor
endfor

print,max(no2_omi,min=min),min,mean(no2_omi)
print,max(no2_gc, min=min),min,mean(no2_gc)

;OMI
outfile1 = '/home/gengguannan/work/ur_emiss/satellite/test.bpch'
;outfile1 = '/home/gengguannan/work/ur_emiss/satellite/omi_no2_seasonal_average_'+ Yr4 +'_JJA_05x0666.bpch'
;outfile1 = '/home/gengguannan/work/ur_emiss/satellite/omi_v2_dpgc_no2_yearly_average_2009-2010_05x0666.bpch'
;outfile1 = '/home/gengguannan/work/ur_emiss/satellite/omi_v2_dpgc_no2_yearly_average_'+ Yr4 +'_05x0666.bpch'

;GC
;outfile2 = '/home/gengguannan/work/ur_emiss/gc/meic_s1/ctm.vc_seasonal_'+ Yr4 +'_JJA_NO2.meic_s1.05x0666.bpch'
;outfile2 = '/home/gengguannan/work/ur_emiss/gc/meic/ctm.vc_seasonal_'+ Yr4 +'_JJA_NO2.meic.05x0666.bpch'
;outfile2 = '/home/gengguannan/work/ur_emiss/gc/siwen/ctm.vc_seasonal_'+ Yr4 +'_JJA_NO2.power.plant.05x0666.bpch'
;outfile2 = '/home/gengguannan/work/ur_emiss/gc/meic/ctm.vc_yearly_2009-2010_NO2.meic.05x0666.bpch'
;outfile2 = '/home/gengguannan/work/ur_emiss/gc/meic/ctm.vc_yearly_'+ Yr4 +'_NO2.meic.05x0666.bpch'
;outfile2 = '/home/gengguannan/work/ur_emiss/gc/meic_s1/ctm.vc_yearly_'+ Yr4 +'_NO2.meic_s1.05x0666.bpch'
;outfile2 = '/home/gengguannan/work/ur_emiss/gc/siwen/ctm.vc_yearly_'+ Yr4 +'_NO2.power.plant.05x0666.bpch'
;outfile2 = '/home/gengguannan/work/ur_emiss/gc/scaled_intexb/ctm.vc_seasonal_'+ Yr4 +'_JJA_NO2.scaled.intexb.05x0666.bpch'
outfile2 = '/home/gengguannan/work/ur_emiss/gc/meic/test.bpch'

nymd0 = y * 10000L + 1 * 100L + 1 * 1L

   success = CTM_Make_DataInfo( no2_omi,                 $
                                ThisDataInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='IJ-AVG-$',        $
                                Tracer=1,                $
                                Tau0= nymd2tau(nymd0),   $
                                Unit='E+15molec/cm2',    $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],      $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = outfile1

   success = CTM_Make_DataInfo( no2_gc,                  $
                                ThisDataInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='IJ-AVG-$',        $
                                Tracer=1,                $
                                Tau0= nymd2tau(nymd0),   $
                                Unit='E+15molec/cm2',    $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],      $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = outfile2

endfor

end
