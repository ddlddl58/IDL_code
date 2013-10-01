pro test

FORWARD_FUNCTION CTM_Grid, CTM_Type

; Time set
y = 2007
Yr4  = String( y, format='(i4.4)')

data1 = fltarr(121,133)
data2 = fltarr(121,133)
nod = fltarr(121,133)

for m = 1,12 do begin
mon2 = string( m, format='(i2.2)')

for d = 1,31 do begin
day2 = string( d, format='(i2.2)')

nymd = y*10000L + m*100L + d*1L
print,nymd
date = m*100L + d*1L
if (date eq 0229) then continue
if (date eq 0230) then continue
if (date eq 0231) then continue
if (date eq 0431) then continue
if (date eq 0631) then continue
if (date eq 0931) then continue
if (date eq 1131) then continue


; Infile info
InDir = '/z1/gengguannan/meic_120918/'+ Yr4 +'/'
Infile = InDir + 'ts_10_12.'+ Yr4 + Mon2 + Day2 +'.bpch'

Undefine, DataInfo1
CTM_Get_Data, DataInfo1, 'IJ-AVG-$', Tracer = 35, File = Infile
part1 = *( DataInfo1[0].Data )

Undefine, DataInfo2
CTM_Get_Data, DataInfo2, 'IJ-AVG-$', Tracer = 37, File = Infile
part2 = *( DataInfo2[0].Data )

aod1 = total(part1,3)
aod2 = total(part2,3)

; Average
for I = 0,121-1 do begin
  for J = 0,133-1 do begin
     data1[I,J] += aod1[I,J]
     data2[I,J] += aod2[I,J]
     nod[I,J] += 1
  endfor
endfor

CTM_Cleanup

endfor
endfor

print,max(nod,min=min),min,mean(nod)

for I = 0,121-1 do begin
  for J = 0,133-1 do begin
    if (nod[I,J] gt 0L) then begin
      data1[I,J] /= nod[I,J]
      data2[I,J] /= nod[I,J]
    endif
  endfor
endfor

print,max(data1,min=min),min,mean(data1)
print,max(data2,min=min),min,mean(data2)


InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

limit=[-11,70,55,150]


!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 2, row = 1

xmax = 8
ymax = 12

xsize= 8
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device,                        $
  /PS, /Color, Bits=8,              $
  Filename='/home/gengguannan/work/pm2.5/result/test3.ps', $
  /portrait, /Inches,               $
  XSize=XSize, YSize=YSize,         $
  XOffset=XOffset, YOffset=YOffset

data18 = fltarr(InGrid.IMX,InGrid.JMX)
data28 = fltarr(InGrid.IMX,InGrid.JMX)

data18[375:495,158:290] = data1
data28[375:495,158:290] = data2

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = data18[I1:I2,J1:J2]
data828 = data28[I1:I2,J1:J2]
print,max(data818),max(data828)

; plot
Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 10

Myct,22

tvmap,data818,                                          $
limit=limit,                                            $
/cbar,                                                  $
mindata = 0,                                      $
maxdata = 200,                                          $
cbmin = 0, cbmax = 200,                           $
divisions = 6,                                         $
format = '(f6.1)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='',                            $
/Quiet,/Noprint,                                        $
position=position1,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data828,                                          $
limit=limit,                                            $
/cbar,                                                  $
mindata = 0,                                      $
maxdata = 100,                                            $
cbmin = 0, cbmax = 100,                             $
divisions = 6,                                         $
format = '(f6.1)',                                      $
cbposition=[0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='',                              $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

close_device

end
