pro plot_3x1_ratio

limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 3, row = 1

;portrait
xmax = 12
ymax = 4

xsize= 12
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/result/meic/2005.JJA.model.satellite.ratio.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

;filename1 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_MAM_05x0666.bpch'
;filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_JJA_05x0666.bpch'
;filename3 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_SON_05x0666.bpch'
;filename4 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_DJF_05x0666.bpch'
filename1 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic/ctm.vc_season_JJA_2005_NO2.bpch'
filename2 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.ubpower/ctm.vc_season_JJA_2005_NO2.bpch'
filename3 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.plus.ubpower/ctm.vc_season_JJA_2005_NO2.bpch'
filename4 = '/z3/gengguannan/satellite/no2/meic/omi_no2_seasonal_average_2005_JJA_05x0666.bpch'


ctm_get_data,datainfo_1,filename = filename1,tau0=nymd2tau(20050831),tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tau0=nymd2tau(20050831),tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tau0=nymd2tau(20050831),tracer=1
data38=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tau0=nymd2tau(20050831),tracer=1
data48=*(datainfo_4[0].data)


InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 1.5

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

p1=fltarr(InGrid.IMX,InGrid.JMX)
p2=fltarr(InGrid.IMX,InGrid.JMX)
p3=fltarr(InGrid.IMX,InGrid.JMX)

for I=I1,I2 do begin
  for J=J1,J2 do begin
    if (data48[I,J] gt 1)                 $
      then p1[I,J] = data18[I,J]/data48[I,J] $
      else p1[I,J] = -999
  endfor
endfor

for I=I1,I2 do begin
  for J=J1,J2 do begin
    if (data48[I,J] gt 1)                 $
      then p2[I,J] = data28[I,J]/data48[I,J] $
      else p2[I,J] = -999
  endfor
endfor

for I=I1,I2 do begin
  for J=J1,J2 do begin
    if (data48[I,J] gt 1)                 $
      then p3[I,J] = data38[I,J]/data48[I,J] $
      else p3[I,J] = -999
  endfor
endfor


data818 = p1[I1:I2,J1:J2]
data828 = p2[I1:I2,J1:J2]
data838 = p3[I1:I2,J1:J2]
print,max(data818),max(data828),max(data838)

Myct, 34

tvmap,data818,                                          $   
limit=limit,					        $     
/nocbar,            			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
title='Scenario1/OMI',  	                        $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

tvmap,data828,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition=[0.3 , 0.03, 1.7, 0.06 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='Scenario2/OMI',                                  $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data838,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition=[0.3 , 0.03, 1.7, 0.06 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='Scenario3/OMI',                                  $
/Quiet,/Noprint,                                        $
position=position3,                                     $
/grid, skip=1,gcolor=gcolor

   Colorbar,					                 $    
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      Position=[ 0.15, 0.05, 0.85, 0.07],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
      divisions = 6,                                            $
      c_colors=c_colors,C_levels=C_levels,			 $
      Min=mindata, Max=maxdata, Unit='',format = '(f6.1)',charsize=0.8
                   ;
   TopTitle = 'E+15 molec/cm2 '
                   
      XYOutS, 0.90, 0.05, TopTitle,                              $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=0.8,                                              $ ; Set text size to twice normal size
      Align= 0.5                                                    ; Center text

   TopTitle = ''

      XYOutS, 0.5, 1.05,TopTitle,				 $
      /Normal,                 				         $ ; Use normal coordinates
      Color=!MYCT.BLACK, 				         $ ; Set text color to black
      CharSize=1.4,  				                 $ ; Set text size to twice normal size
      Align=0.5    				                   ; Center text

close_device

end
