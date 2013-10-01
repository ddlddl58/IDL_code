pro plot_3x1_3m

limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 3, row = 1

;portrait
xmax = 12
ymax = 3

xsize= 12
ysize= 3

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/work/ur_emiss/result/models.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

;filename1 = '/home/gengguannan/work/ur_emiss/gc/siwen/ctm.vc_seasonal_2006_JJA_NO2.power.plant.05x0666.bpch'
filename1 = '/home/gengguannan/work/ur_emiss/gc/scaled_intexb/ctm.vc_seasonal_2006_JJA_NO2.scaled.intexb.05x0666.bpch'
filename2 = '/home/gengguannan/work/ur_emiss/gc/meic/ctm.vc_seasonal_2006_JJA_NO2.meic.05x0666.bpch'
filename3 = '/home/gengguannan/work/ur_emiss/gc/meic_s1/ctm.vc_seasonal_2006_JJA_NO2.meic_s1.05x0666.bpch'
filename4 = '/home/gengguannan/work/ur_emiss/satellite/test.bpch'
;filename4 = '/home/gengguannan/work/ur_emiss/satellite/omi_v2_dpgc_no2_seasonal_average_2006_JJA_05x0666.bpch'


ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=1
data38=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=1
data48=*(datainfo_4[0].data)

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 10

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = data18[I1:I2,J1:J2]
data828 = data28[I1:I2,J1:J2]
data838 = data48[I1:I2,J1:J2]*1e15

title1 = '(a) GC_MEIC1'
title2 = '(b) GC_MEIC2'
title3 = '(c) OMI'

;data818 = data28[I1:I2,J1:J2] - data18[I1:I2,J1:J2]
;data828 = data48[I1:I2,J1:J2] - data18[I1:I2,J1:J2]
;data838 = data48[I1:I2,J1:J2] - data28[I1:I2,J1:J2]

;title1 = '(d) GC_MEIC2 - GC_MEIC1'
;title2 = '(e) OMI - GC_MEIC1'
;title3 = '(f) OMI - GC_MEIC2'

Myct, 22

tvmap,data818,                                          $   
limit=limit,					        $     
/cbar,              			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition = [0.7 , 0.075, 2.9, 0.10 ],                $
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

tvmap,data838,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 13,                                         $
format = '(f6.1)',                                      $
cbposition=[0 , 0.075, 1.0, 0.1 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title=title3,                                           $
/Quiet,/Noprint,                                        $
position=position3,                                     $
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

multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position3,color=13
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
   TopTitle = '10!U15!N molecules/cm!U2!N'
                   
      XYOutS, 0.85, 0.06, TopTitle,      $
      /Normal,                           $ ; Use normal coordinates
      Color=!MYCT.BLACK,                 $ ; Set text color to black
      CharSize=0.8,                      $ ; Set text size to twice normal size
      Align= 0.5                           ; Center text

close_device

end
