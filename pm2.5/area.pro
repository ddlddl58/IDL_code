pro area

array = fltarr(7,2)

for year = 2004,2010 do begin
Yr4 = String( year, format='(i4.4)')

Infile1 = '/home/gengguannan/work/pm2.5/pm2.5/gc/gc_aod_0.66x0.50_yearly.'+ Yr4
;Infile1 = '/home/gengguannan/work/pm2.5/pm2.5/sate_based/MISR_pm2.5_0.66x0.50_yearly.'+ Yr4

RESTORE,filename = Infile1

Infile2 = '/home/gengguannan/satellite/aod/MISR/MISR_0.66x0.50_yearly.'+ Yr4

RESTORE,filename = Infile2



InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

limit = [22,110,42,123]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

close, /all

temp_gc = 0
temp_misr = 0
ngrid = 0

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if avg_misr_aod[I,J] gt 0 then begin
      temp_gc += avg_gc_aod[I,J]
      temp_misr += avg_misr_aod[I,J]
      ngrid += 1
    endif
  endfor
endfor

array[year-2004,0] = temp_gc/ngrid
array[year-2004,1] = temp_misr/ngrid

endfor

print,array

end
