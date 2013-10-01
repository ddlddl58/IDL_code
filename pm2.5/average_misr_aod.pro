pro average_misr_aod

FORWARD_FUNCTION CTM_Grid, CTM_Type

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
for y = 2004,2004 do begin
Yr4  = String( y, format='(i4.4)')

if y eq 2004 or y eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

;for m = 1,12 do begin
;mon2 = string( m, format='(i2.2)')

avg_misr_aod = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_aod = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)


for m = 1,5 do begin
mon2 = string( m, format='(i2.2)')

for d = 1,Dayofmonth[m-1] do begin
day2 = string( d, format='(i2.2)')

nymd = y*10000L + m*100L + d*1L
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


; Infile info
Infile1 = '/home/gengguannan/satellite/aod/MISR/'+Yr4+'/MISR_0.66x0.50_'+Yr4+Mon2+Day2

RESTORE,filename = Infile1


gc_aod = fltarr(InGrid.IMX,InGrid.JMX)

Infile2 = '/home/gengguannan/work/pm2.5/pm2.5/gc/daily/'+Yr4+'/model_pm2.5_aod_10_12.'+Yr4+Mon2+Day2+'.hdf'

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(Infile2,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

data = HDF_GETSD(fId,'AOD')

HDF_SD_END, FID

gc_aod[375:495,158:290] = data



; Average
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if misr_array[I,J] gt 0 then begin
      avg_misr_aod[I,J] = avg_misr_aod[I,J] + misr_array[I,J]
      avg_gc_aod[I,J] = avg_gc_aod[I,J] + gc_aod[I,J]
      nod[I,J] = nod[I,J] + 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor

print,max(nod)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod[I,J] gt 0L) then begin
      avg_misr_aod[I,J] = avg_misr_aod[I,J] / nod[I,J]
      avg_gc_aod[I,J] = avg_gc_aod[I,J] / nod[I,J]
    endif else begin
      avg_misr_aod[I,J] = -999
      avg_gc_aod[I,J] = -999
    endelse
  endfor
endfor

print,max(avg_misr_aod),mean(avg_misr_aod)
print,max(avg_gc_aod),mean(avg_gc_aod)

; Write into file
Outfile1 = '/home/gengguannan/satellite/aod/MISR/MISR_0.66x0.50_5m.'+ Yr4

SAVE,avg_misr_aod,nod,filename = Outfile1

Outfile2 = '/home/gengguannan/work/pm2.5/pm2.5/gc/gc_aod_0.66x0.50_5m.'+ Yr4

SAVE,avg_gc_aod,nod,filename = Outfile2

endfor

end
