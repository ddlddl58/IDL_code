pro calc_ratio

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


; Region set
limit=[15,70,55,136]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)


; Time set
for Year = 2004,2005 do begin
Yr4 = string( Year, format = '(i4.4)')

if Year eq 2004 or Year eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

for Month = 1,12 do begin
Mon2 = string( Month, format = '(i2.2)')

for Day = 1,Dayofmonth[Month-1] do begin
Day2 = string( Day, format = '(i2.2)')

ctm_cleanup


pm_dry = fltarr(InGrid.IMX,InGrid.JMX)
pm  = fltarr(InGrid.IMX,InGrid.JMX)
aod = fltarr(InGrid.IMX,InGrid.JMX)
;misr_pm_dry = fltarr(InGrid.IMX,InGrid.JMX)
;misr_pm = fltarr(InGrid.IMX,InGrid.JMX)
ratio_dry = fltarr(InGrid.IMX,InGrid.JMX)
ratio = fltarr(InGrid.IMX,InGrid.JMX)



filename = '/home/gengguannan/work/pm2.5/pm2.5/gc/daily/'+Yr4+'/model_pm2.5_aod_10_12.'+Yr4+Mon2+Day2+'.hdf'

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(filename,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

data1 = HDF_GETSD(fId,'pm2.5')

data2 = HDF_GETSD(fId,'pm2.5RH50')

data3 = HDF_GETSD(fId,'AOD')

HDF_SD_END, FID

pm_dry[375:495,158:290] = data1
pm[375:495,158:290] = data2
aod[375:495,158:290] = data3


; caculate
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if aod[I,J] gt 0 then begin
      ratio_dry[I,J] = pm_dry[I,J] / aod[I,J]
      ratio[I,J] = pm[I,J] / aod[I,J]
    endif else begin
      ratio_dry[I,J] = -999
      ratio[I,J] = -999
    endelse
  endfor
endfor


SAVE,ratio,ratio_dry,filename='/home/gengguannan/work/pm2.5/pm2.5/gc/daily/'+Yr4+'/ratio_0.66x0.50_'+Yr4+Mon2+Day2


endfor
endfor
endfor

end
