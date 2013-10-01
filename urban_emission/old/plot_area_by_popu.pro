pro plot_area_by_popu

area_limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

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
              Bits=8,          Filename='/home/gengguannan/result/bishe/area_map_by_totalpopu.ps', $
              /portrait,       /Inches,              $
              XSize=XSize,     YSize=YSize,          $
              XOffset=XOffset, YOffset=YOffset

filename1 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_annual_2006_NO2.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_annual_average_2006_05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'
filename4 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch'


;limit = [-1,1239,9650,89701,436085,9927500]
;limit = [-1,3487,11195,33866,123335,5094750]
limit = [-1,200000,500000,1000000,2000000,3000000,8500000]


ctm_get_data,datainfo_1,filename = filename1,tau0=nymd2tau(20061231),tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tau0=nymd2tau(20061231),tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tau0=nymd2tau(19850101),tracer=802
China_mask=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tau0=nymd2tau(20061231),tracer=802
popu=*(datainfo_4[0].data)


;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

map = fltarr(InGrid.IMX,InGrid.JMX)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if ( China_mask[I,J] eq 0 ) then map[I,J] = 0
    if ( (China_mask[I,J] eq 1) and (popu[I,J] gt limit[0]) and (popu[I,J] le limit[1]) ) then map[I,J] = 1
    if ( (China_mask[I,J] eq 1) and (popu[I,J] gt limit[1]) and (popu[I,J] le limit[2]) ) then map[I,J] = 2
    if ( (China_mask[I,J] eq 1) and (popu[I,J] gt limit[2]) and (popu[I,J] le limit[3]) ) then map[I,J] = 3
    if ( (China_mask[I,J] eq 1) and (popu[I,J] gt limit[3]) and (popu[I,J] le limit[4]) ) then map[I,J] = 4
    if ( (China_mask[I,J] eq 1) and (popu[I,J] gt limit[4]) and (popu[I,J] le limit[5]) ) then map[I,J] = 5
    if ( (China_mask[I,J] eq 1) and (popu[I,J] gt limit[5]) and (popu[I,J] le limit[6]) ) then map[I,J] = 6
  endfor
endfor

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor=1
mindata=0
maxdata=6

i1_index = where(xmid ge area_limit[1] and xmid le area_limit[3])
j1_index = where(ymid ge area_limit[0] and ymid le area_limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

map1 = map[I1:I2,J1:J2]

Myct,22

tvmap,map1,                          $
limit=area_limit,                    $
/nocbar,                             $
mindata = mindata,                   $
maxdata = maxdata,                   $
cbmin = mindata, cbmax =maxdata,     $
divisions = 7,                       $
cbposition=[0, 0.10, 1, 0.06 ],      $
cbformat='(f5)',                   $
/countries,/continents,/Coasts,      $
/CHINA,                              $
margin = margin,                     $
/Sample,                             $
title='Region Specification',        $
/Quiet,/Noprint,                     $
position=position1,                  $
/grid, skip=1,gcolor=gcolor

   Colorbar,                                                     $
      Position=[ 0.15, 0.10, 0.9, 0.12],                         $
      divisions = 7,                                             $
      c_colors=c_colors,C_levels=C_levels,                       $
      Min=0, Max=6, Unit='',format = '(f4.0)',charsize=0.8

   TopTitle = ''

      XYOutS, 0.6, 0.07, TopTitle,                              $
      /Normal,                       $ ; Use normal coordinates
      Color=!MYCT.BLACK,             $ ; Set text color to black
      CharSize=0.8,                  $ ; Set text size to twice normal size
      Align=0.5                        ; Center text

close_device

end
