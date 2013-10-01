pro plot_3x2_3m_3d

limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 3, row = 2

;portrait
xmax = 12
ymax = 6

xsize= 12
ysize= 6

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/work/ur_emiss/result/emissions.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Year = 2006
Yr4 = string( Year, format = '(i4.4)')

sum1 = fltarr(InGrid.IMX,InGrid.JMX)
sum2 = fltarr(InGrid.IMX,InGrid.JMX)
pow2 = fltarr(InGrid.IMX,InGrid.JMX)

;intex-b
filename1 = '/home/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_ge_100MW.05x0666.bpch'
filename2 = '/home/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_lt_100MW.05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/dom-'+Yr4+'-05x0666.bpch'
filename4 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/ind-'+Yr4+'-05x0666.bpch'
filename5 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/tra-'+Yr4+'-05x0666.bpch'

;meic
filename6 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_pow_'+Yr4+'.05x0666'
filename7 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_res_'+Yr4+'.05x0666'
filename8 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_ind_'+Yr4+'.05x0666'
filename9 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_tra_'+Yr4+'.05x0666'

for Month = 1,12 do begin
Mon2 = string( Month, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

ctm_get_data,datainfo_1,filename = filename1,tau0=Tau0,tracer=1
pow1_temp1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tau0=Tau0,tracer=1
pow1_temp2=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tau0=Tau0,tracer=1
dom1_temp=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tau0=Tau0,tracer=1
ind1_temp=*(datainfo_4[0].data)

ctm_get_data,datainfo_5,filename = filename5,tau0=Tau0,tracer=1
tra1_temp=*(datainfo_5[0].data)

ctm_get_data,datainfo_6,filename = filename6,tau0=Tau0,tracer=1
pow2_temp=*(datainfo_6[0].data)

ctm_get_data,datainfo_7,filename = filename7,tau0=Tau0,tracer=1
dom2_temp=*(datainfo_7[0].data)

ctm_get_data,datainfo_8,filename = filename8,tau0=Tau0,tracer=1
ind2_temp=*(datainfo_8[0].data)

ctm_get_data,datainfo_9,filename = filename9,tau0=Tau0,tracer=1
tra2_temp=*(datainfo_9[0].data)

pow1_temp = pow1_temp1 + pow1_temp2
sum1_temp = pow1_temp + dom1_temp + ind1_temp + tra1_temp
sum2_temp = pow2_temp + dom2_temp + ind2_temp + tra2_temp

sum1 += sum1_temp
sum2 += sum2_temp
pow2 += pow2_temp

CTM_Cleanup

endfor

print,'intex-b',total(sum1)
print,'meic',total(sum2)

;scaled_intex-b
filename10 = '/home/gengguannan/indir/intexb_scaled/NOx_res_2006.05x0666'
filename11 = '/home/gengguannan/indir/intexb_scaled/NOx_ind_2006.05x0666'
filename12 = '/home/gengguannan/indir/intexb_scaled/NOx_tra_2006.05x0666'

ctm_get_data,datainfo_10,filename = filename10,tracer=1
dom3=*(datainfo_10[0].data)

ctm_get_data,datainfo_11,filename = filename11,tracer=1
ind3=*(datainfo_11[0].data)

ctm_get_data,datainfo_12,filename = filename12,tracer=1
tra3=*(datainfo_12[0].data)

pow3 = pow2
sum3 = pow3 + dom3 + ind3 + tra3

print,'scaled_intex-b',total(sum3)


;plot
Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata1 = 0
maxdata1 = 100
mindata2 = -50
maxdata2 = 50

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = sum1[I1:I2,J1:J2] / 1e6
data828 = sum3[I1:I2,J1:J2] / 1e6
data838 = sum2[I1:I2,J1:J2] / 1e6
data848 = (sum3[I1:I2,J1:J2] - sum1[I1:I2,J1:J2]) / 1e6
data858 = (sum2[I1:I2,J1:J2] - sum1[I1:I2,J1:J2]) / 1e6
data868 = (sum2[I1:I2,J1:J2] - sum3[I1:I2,J1:J2]) / 1e6
print,max(data818),max(data848)

title1 = 'INTEX-B'
title2 = 'SCALED_INTEX-B'
title3 = 'MEIC'
title4 = 'SCALED_INTEX-B - INTEX-B'
title5 = 'MEIC - INTEX-B'
title6 = 'MEIC - SCALED_INTEX-B'

Myct, 22

tvmap,data818,                                          $   
limit=limit,					        $     
/cbar,              			                $     
mindata = mindata1,                                     $
maxdata = maxdata1,                                     $
cbmin = mindata1, cbmax = maxdata1,                     $
divisions = 11,                                         $
format = '(I4)',                                      $
cbposition = [0.7 , 0.075, 2.9, 0.10 ],                 $
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
mindata = mindata1,                                     $
maxdata = maxdata1,                                     $
cbmin = mindata1, cbmax = maxdata1,                     $
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
mindata = mindata1,                                     $
maxdata = maxdata1,                                     $
cbmin = mindata1, cbmax = maxdata1,                     $
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

tvmap,data848,                                          $
limit=limit,                                            $
/cbar,                                                  $
mindata = mindata2,                                     $
maxdata = maxdata2,                                     $
cbmin = mindata2, cbmax = maxdata2,                     $
divisions = 11,                                         $
format = '(I4)',                                      $
cbposition = [0.7 , 0.075, 2.9, 0.10 ],                 $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title=title4,                                           $
/Quiet,/Noprint,                                        $
position=position4,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data858,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata2,                                     $
maxdata = maxdata2,                                     $
cbmin = mindata2, cbmax = maxdata2,                     $
divisions = 13,                                         $
format = '(f6.1)',                                      $
cbposition=[0 , 0.03, 1.0, 0.06 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title=title5,                                           $
/Quiet,/Noprint,                                        $
position=position5,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data868,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata2,                                     $
maxdata = maxdata2,                                     $
cbmin = mindata2, cbmax = maxdata2,                     $
divisions = 13,                                         $
format = '(f6.1)',                                      $
cbposition=[0 , 0.075, 1.0, 0.1 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title=title6,                                           $
/Quiet,/Noprint,                                        $
position=position6,                                     $
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

multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position4,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary

multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position5,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary

multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position6,color=13
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
   TopTitle = 'kiloton'
                   
      XYOutS, 0.85, 0.06, TopTitle,      $
      /Normal,                           $ ; Use normal coordinates
      Color=!MYCT.BLACK,                 $ ; Set text color to black
      CharSize=0.8,                      $ ; Set text size to twice normal size
      Align= 0.5                           ; Center text

close_device

end
