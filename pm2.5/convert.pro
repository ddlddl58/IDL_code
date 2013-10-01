pro convert

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

nymd = Year * 10000L + Month * 100L + Day * 1L
if nymd eq 20081001 then continue
if nymd eq 20081002 then continue
if nymd eq 20081003 then continue
if nymd eq 20081004 then continue
if nymd eq 20081005 then continue
if nymd eq 20081006 then continue
if nymd eq 20081007 then continue
if nymd eq 20081008 then continue
if nymd eq 20081009 then continue
if nymd eq 20081010 then continue
if nymd eq 20081011 then continue
if nymd eq 20081012 then continue
if nymd eq 20081013 then continue
if nymd eq 20081014 then continue
if nymd eq 20081015 then continue
if nymd eq 20081220 then continue
if nymd eq 20081221 then continue
if nymd eq 20081222 then continue


misr_pm_dry = fltarr(InGrid.IMX,InGrid.JMX)
misr_pm = fltarr(InGrid.IMX,InGrid.JMX)


; Read files
filename1 = '/home/gengguannan/satellite/aod/MISR/'+Yr4+'/MISR_0.66x0.50_'+Yr4+Mon2+Day2

RESTORE,filename=filename1

filename2 = '/home/gengguannan/work/pm2.5/pm2.5/gc/daily/'+Yr4+'/ratio_0.66x0.50_'+Yr4+Mon2+Day2

RESTORE,filename=filename2


; caculate
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if misr_array[I,J] gt 0 and ratio_dry[I,J] gt 0 $
      then misr_pm_dry[I,J] = ratio_dry[I,J] * misr_array[I,J] $
      else misr_pm_dry[I,J] = -999
    if misr_array[I,J] gt 0 and ratio[I,J] gt 0 $
      then misr_pm[I,J] = ratio[I,J] * misr_array[I,J] $
      else misr_pm[I,J] = -999
  endfor
endfor


SAVE,misr_pm,misr_pm_dry,filename='/home/gengguannan/work/pm2.5/pm2.5/sate_based/daily/'+Yr4+'/MISR_pm2.5_0.66x0.50_'+Yr4+Mon2+Day2


endfor
endfor
endfor

end
