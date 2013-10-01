pro plot_MODIS_data

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak, CTM_BoxSize, CTM_RegridH, CTM_NamExt, CTM_ResExt

CTM_CleanUp


InType = CTM_Type( 'generic', Res=[ 0.1d0, 0.1d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

OutType = CTM_Type( 'generic', Res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all


limit=[20,110,50,150]

i1_index = where(inxmid ge limit[1] and inxmid le limit[3])
j1_index = where(inymid ge limit[0] and inymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

i3_index = where(outxmid ge limit[1] and outxmid le limit[3])
j3_index = where(outymid ge limit[0] and outymid le limit[2])
I3 = min(i3_index, max = I4)
J3 = min(j3_index, max = J4)



avg = fltarr(InGrid.IMX,InGrid.JMX)
nod1 = fltarr(InGrid.IMX,InGrid.JMX)

year = 2011
for Month = 4,5 do begin
for Day =1,31 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
Day2 = string( Day, format = '(i2.2)')

nymd = Year * 10000L + Month * 100L + Day * 1L
print,nymd

if (nymd eq 20110431) then continue


Filename = '/data1/guannan/data/MODIS/AODterraMODIS'+Yr4+Mon2+Day2+'.asc'


Target  = fltarr(InGrid.IMX,InGrid.JMX)

;==========================================================
; Read data and regrid
;==========================================================

Open_File, Filename, Ilun, /Get_LUN
ReadF, Ilun, Target
help, Target

Close,    Ilun
Free_LUN, Ilun

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if Target[I,J] gt 0 then begin
      avg[I,J] = avg[I,J] + Target[I,J]
      nod1[I,J] = nod1[I,J] + 1
    endif
  endfor
endfor

endfor
endfor

print,max(nod1),min(nod1)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod1[I,J] gt 0L)             $
        then  avg[I,J] = avg[I,J] / nod1[I,J]  $
        else  avg[I,J] = -999.0
  endfor
endfor

print,max(avg),min(avg)

MODIS = fltarr(OutGrid.IMX,OutGrid.JMX)
nod2 = fltarr(OutGrid.IMX,OutGrid.JMX)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    x = where( (inxmid[I] gt (outxmid - 0.125)) and (inxmid[I] le (outxmid + 0.125)))
    y = where( (inymid[J] gt (outymid - 0.125)) and (inymid[J] le (outymid + 0.125)))
    if (avg[I,J] gt 0) then begin
        MODIS[x,y] = MODIS[x,y] + avg[I,J]
        nod2[x,y] = nod2[x,y] + 1
    endif
  endfor
endfor

print,max(nod2),min(nod2)

for I = I3,I4 do begin
  for J = J3,J4 do begin
    if (nod2[I,J] gt 0L)             $
        then  MODIS[I,J] = MODIS[I,J] / nod2[I,J]  $
        else  MODIS[I,J] = -999.0
  endfor
endfor




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
             Bits=8,          Filename='/data1/guannan/result/MODIS-TERRA.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 1

data=MODIS[I3:I4,J3:J4]

print,max(data),min(data)

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
title='MODIS-TERRA April-May 2011',                   $
/Quiet,/Noprint,                                        $
position=position1,                                     $
/grid, skip=1,gcolor=gcolor

close_device



end
