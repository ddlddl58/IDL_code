pro plot_mark_max_month

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

no2 = fltarr(InGrid.IMX,InGrid.JMX,12)
max = fltarr(InGrid.IMX,InGrid.JMX)

year = 2006
for m = 0,12-1 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( m+1, format = '(i2.2)')

nymd = Year * 10000L + (m+1) * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

filename1 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200607/China_mask.geos5.05x0666'
filename2 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_monthly_'+ Yr4 + Mon2 +'_NO2.month.05x0666.power.plant.bpch'
;filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_monthly_average_'+ Yr4 + Mon2 +'_05x0666.bpch'

CTM_Get_Data, datainfo1, tracer = 802, tau0 = nymd2tau(19850101), filename = filename1
China_mask = *(datainfo1[0].data)

CTM_Get_Data, datainfo2, tracer = 1, tau0 = tau0, filename = filename2
data18 = *(datainfo2[0].data)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    no2[I,J,m] = data18[I,J]
  endfor
endfor

endfor


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if ( China_mask[I,J] eq 1 )  $
       then max[I,J] = where(no2[I,J,*] eq max(no2[I,J,*])) + 1  $
       else max[I,J] = 999
  endfor
endfor



;plot
limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 1.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 1, row = 1

;portrait
xmax = 8
ymax = 12

xsize= 4
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $
             Bits=8,          Filename='/home/gengguannan/result/bishe/max_value_month_model.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = 0L
maxdata = 5L

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

max_temp = fltarr(InGrid.IMX,InGrid.JMX)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (max[I,J] ge 3 and max[I,J] le 5 ) then max_temp[I,J] = 1
    if (max[I,J] ge 6 and max[I,J] le 8 ) then max_temp[I,J] = 2
    if (max[I,J] ge 9 and max[I,J] le 11 ) then max_temp[I,J] = 3
    if (max[I,J] ge 1 and max[I,J] le 2 ) then max_temp[I,J] = 4
    if (max[I,J] eq 12 ) then max_temp[I,J] = 4
  endfor
endfor

map = max_temp[I1:I2,J1:J2]

;Myct, 34,/REVERSE
Myct, 34

tvmap,map,                                              $
limit=limit,                                            $
/cbar,                                                  $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
;divisions = 6,                                         $
;cbformat='(f4.0)',                                      $
cbposition=[0.025, 0.03, 0.95, 0.06 ],                  $
cbunit='',                                              $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='Month of maximum NO2 concentration - GEOS-Chem',             $
/Quiet,/Noprint,                                        $
position=position1,                                     $
/grid, skip=1,gcolor=gcolor

    TopTitle = 'Spring        Summer        Autumn        Winter'
;    TopTitle = ''
      XYOutS, 0.525, 0.036, TopTitle,  $
      /Normal,                        $ ; Use normal coordinates
      Color=!MYCT.BLACK,              $ ; Set text color to black
      CharSize=0.9,                   $ ; Set size to twice normal size
      Align=0.5                         ; Cen    ter text

close_device

end
