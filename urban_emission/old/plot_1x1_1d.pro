pro plot_1x1_1d

limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

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
             Bits=8,          Filename='/home/gengguannan/work/ur_emiss/result/emis.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

filename1 = '/home/gengguannan/indir/meic_201207/2006/meic_NOx_tra_2006.05x0666'
filename2 = '/home/gengguannan/indir/meic_s1/2006/meic_NOx_tra_2006.05x0666'

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


data1 = fltarr(InGrid.IMX,InGrid.JMX)
data2 = fltarr(InGrid.IMX,InGrid.JMX)

for month = 1,12 do begin
nymd = 2006 * 10000L + month * 100L + 1L
tau0 = nymd2tau(nymd)

ctm_get_data,datainfo_1,filename = filename1,tracer=1,tau0 = tau0
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1,tau0 = tau0
data28=*(datainfo_2[0].data)

data1 = data1 + data18/1e6
data2 = data2 + data28/1e6

endfor


Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = -10
maxdata = 30

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = data1[I1:I2,J1:J2] - data2[I1:I2,J1:J2]

title = 'meic - meic_s1'

Myct, 22

tvmap,data818,                                          $   
limit=limit,					        $     
/cbar,              			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 9,                                         $
format = '(I4)',                                      $
cbposition = [0.05 , 0.075, 0.95, 0.10 ],                $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $
margin = margin,				        $
/Sample,					        $
title=title,                                           $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary

;   TopTitle = '10!U15!N molecules/cm!U2!N'
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
;      Position=[ 0.15, 0.05, 0.85, 0.06],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
;      divisions = 7,                                             $
;      c_colors=c_colors,C_levels=C_levels,			 $
;      Min=mindata, Max=maxdata, Unit='',format = '(f6.1)',charsize=0.8
                   ;
   TopTitle = 'Gg/year'
                   
      XYOutS, 1.05, 0.06, TopTitle,      $
      /Normal,                           $ ; Use normal coordinates
      Color=!MYCT.BLACK,                 $ ; Set text color to black
      CharSize=0.9,                      $ ; Set text size to twice normal size
      Align= 0.5                           ; Center text

close_device

end
