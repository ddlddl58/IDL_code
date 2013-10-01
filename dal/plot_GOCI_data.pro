pro plot_GOCI_data

FORWARD_FUNCTION CTM_Grid, CTM_Type

InType = CTM_Type( 'generic', Res=[ 0.1d0, 0.1d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'GEOS5', Resolution=[ 2d0/3d0,0.5d0 ] )
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

close, /all

for t = 6,6 do begin

avg = fltarr(InGrid.IMX, InGrid.JMX)
nod = fltarr(InGrid.IMX, InGrid.JMX)

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


GOCI_file = '/data1/guannan/data/GOCI/goci_aop_2011'+ Mon2 + Day2 + tim2 +'.bpch'

Undefine, DataInfo
CTM_Get_Data, DataInfo, 'IJ-AVG-$', Tracer = 26, File = GOCI_file
AOD = *( DataInfo[0].Data )
print,max(AOD)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if AOD[I,J] ge 0 then begin
      avg[I,J] = avg[I,J] + AOD[I,J]
      nod[I,J] = nod[I,J] + 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor

print,max(nod),min(nod)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0) $
      then avg[I,J] = avg[I,J] / nod[I,J] $
      else avg[I,J] = -999
  endfor
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

i1_index = where(inxmid ge limit[1] and inxmid le limit[3])
j1_index = where(inymid ge limit[0] and inymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
;print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data = avg[I1:I2,J1:J2]

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

endfor

end
