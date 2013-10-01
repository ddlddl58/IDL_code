pro plot_2x1

limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 2, row = 1

;portrait
xmax = 8
ymax = 12

xsize= 8
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/work/longterm/result/models.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

;make file
maskfile = '/home/gengguannan/indir/mask/China_mask.geos5.v3.05x05'

ctm_get_data,datainfo,filename = maskfile,tracer=802
mask=*(datainfo[0].data)


;input no2 file
;filename1 = '/home/gengguannan/work/longterm/no2/ctm.vc_yearly_2005_NO2.meic.05x0666.bpch'
;filename2 = '/home/gengguannan/work/longterm/no2/ctm.vc_yearly_2006_NO2.meic.05x0666.bpch'
;filename1 = '/home/gengguannan/work/longterm/no2/omi_v2_no2_yearly_average_2005.05x0666.bpch'
;filename2 = '/home/gengguannan/work/longterm/no2/omi_v2_no2_yearly_average_2006.05x0666.bpch'

;ctm_get_data,datainfo_1,filename = filename1,tracer=1
;data18=*(datainfo_1[0].data)

;ctm_get_data,datainfo_2,filename = filename2,tracer=1
;data28=*(datainfo_2[0].data)


;input so2 file
;filename1 = '/home/gengguannan/work/longterm/so2/ctm.vc_yearly_2005_SO2.meic.05x0666.bpch'
;filename2 = '/home/gengguannan/work/longterm/so2/ctm.vc_yearly_2006_SO2.meic.05x0666.bpch'
filename1 = '/home/gengguannan/work/longterm/so2/omi_annual_avg_so2_vcol_crd30_2005_with_new_cldpre_2x25profile.05x05.bpch'
filename2 = '/home/gengguannan/work/longterm/so2/omi_annual_avg_so2_vcol_crd30_2006_with_new_cldpre_2x25profile.05x05.bpch'

ctm_get_data,datainfo_1,filename = filename1,tracer=26
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=26
data28=*(datainfo_2[0].data)


;InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 2

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

;data18(where(mask le 0)) = 0
;data28(where(mask le 0)) = 0

data818 = data18[I1:I2,J1:J2]
data828 = data28[I1:I2,J1:J2]

title1 = 'OMI 2005'
title2 = 'OMI 2006'


Myct, 22

tvmap,data818,                                          $   
limit=limit,					        $     
/cbar,              			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 5,                                         $
format = '(f6.1)',                                      $
cbposition = [0.2 , 0.075, 2.0, 0.10 ],                $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $
margin = margin,				        $
/Sample,					        $
title=title1,                                           $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

tvmap,data828,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 13,                                         $
format = '(f6.1)',                                      $
cbposition=[0 , 0.03, 1.0, 0.06 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title=title2,                                           $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary

multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position2,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary


;   Colorbar,					                 $
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
;      Position=[ 0.15, 0.05, 0.85, 0.06],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
;      divisions = 7,                                             $
;      c_colors=c_colors,C_levels=C_levels,			 $
;      Min=mindata, Max=maxdata, Unit='',format = '(f6.1)',charsize=0.8
                   ;
;   TopTitle = '10!U15!N molecules/cm!U2!N'
   TopTitle = 'DU'
                   
      XYOutS, 0.55, 0.03, TopTitle,      $
      /Normal,                           $ ; Use normal coordinates
      Color=!MYCT.BLACK,                 $ ; Set text color to black
      CharSize=0.8,                      $ ; Set text size to twice normal size
      Align= 0.5                           ; Center text

close_device

end
