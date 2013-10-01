pro simple_average_GOCI

FORWARD_FUNCTION CTM_Grid, CTM_Type

OutType = CTM_Type( 'generic', Res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all


lonlat_file = '/data1/guannan/data/lonlat_GOCI.bin'

sz = lonarr(2)

openr, 1, lonlat_file
readu, 1, sz

lon = fltarr(sz)
lat = fltarr(sz)

readu, 1, lon, lat
close, 1

for t = 7,7 do begin

avg = fltarr(sz(0), sz(1))
nod1 = fltarr(sz(0), sz(1))

for m = 4,5 do begin
for d = 1,31 do begin

Mon2 = string( m, format = '(i2.2)')
Day2 = string( d, format = '(i2.2)')
tim2 = string( t, format = '(i2.2)')

nymd = m*10000L + d*100L + t*1L
;print,nymd

if nymd eq 043100 then continue
if nymd eq 043101 then continue
if nymd eq 043102 then continue
if nymd eq 043103 then continue
if nymd eq 043104 then continue
if nymd eq 043105 then continue
if nymd eq 043106 then continue
if nymd eq 043107 then continue
if nymd eq 052200 then continue
if nymd eq 052501 then continue
if nymd eq 052502 then continue
if nymd eq 052605 then continue
if nymd eq 051807 then continue


GOCI_file = '/data1/guannan/data/GOCI/AOP_2011'+ Mon2 + Day2 + tim2 +'.bin'

openr, 1, GOCI_file

AOD = fltarr(sz(0), sz(1))

readu, 1, AOD
close, 1

for I = 0,sz(0)-1 do begin
  for J = 0,sz(1)-1 do begin
    if AOD[I,J] ge 0 then begin
      avg[I,J] = avg[I,J] + AOD[I,J]
      nod1[I,J] = nod1[I,J] + 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor

print,max(nod1),min(nod1)

for I = 0,sz(0)-1 do begin
  for J = 0,sz(1)-1 do begin
    if (nod1[I,J] gt 0) $
      then avg[I,J] = avg[I,J] / nod1[I,J] $
      else avg[I,J] = -999
  endfor
endfor


GOCI = fltarr(OutGrid.IMX,OutGrid.JMX)
nod2 = fltarr(OutGrid.IMX,OutGrid.JMX)

for I = 0,sz(0)-1 do begin
  for J = 0,sz(1)-1 do begin
    x = where( (lon[I,J] gt (outxmid - 0.125)) and (lon[I,J] le (outxmid + 0.125)))
    y = where( (lat[I,J] gt (outymid - 0.125)) and (lat[I,J] le (outymid + 0.125)))
    if (avg[I,J] gt -999) then begin
        GOCI[x,y] = GOCI[x,y] + avg[I,J]
        nod2[x,y] = nod2[x,y] + 1
    endif
  endfor
endfor

print,max(nod2),min(nod2)

for I = 0,OutGrid.IMX-1 do begin
  for J = 0,OutGrid.JMX-1 do begin
    if (nod2[I,J] gt 0L) $
        then  GOCI[I,J] = GOCI[I,J] / nod2[I,J] $
        else  GOCI[I,J] = -999.0
  endfor
endfor

m = where((116.381 gt (outxmid - 0.125)) and (116.381 le (outxmid + 0.125)))
n = where(( 39.977 gt (outymid - 0.125)) and ( 39.977 le (outymid + 0.125)))

print, m , n
print, 'reslut', GOCI[m,n]

endfor

;plot
limit=[20,110,50,150]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 1.0

multipanel, omargin=[0.05,0.02,0.02,0.05]

;portrait
xmax = 8
ymax = 12

xsize= 4
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $
             Bits=8,          Filename='/data1/guannan/result/GOCI_'+ tim2 +'.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 1

i1_index = where(outxmid ge limit[1] and outxmid le limit[3])
j1_index = where(outymid ge limit[0] and outymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
;print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data=GOCI[I1:I2,J1:J2]

;print,max(data),min(data)

Myct,22

tvmap,data,                                             $
limit=limit,                                            $
/cbar,                                                  $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
CSFAC = 0.8,                                            $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='GOCI April-May 2011 : '+ tim2,                   $
/Quiet,/Noprint,                                        $
position=position1,                                     $
/grid, skip=1,gcolor=gcolor

close_device

end
