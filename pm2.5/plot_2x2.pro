pro plot_2x2

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

pm  = fltarr(InGrid.IMX,InGrid.JMX,4)
aod = fltarr(InGrid.IMX,InGrid.JMX,4)

for Year = 2004,2007 do begin
Yr4 = string(Year,format='(i4.4)')

Dir = '/home/gengguannan/work/pm2.5/'
filename = Dir + 'model_pm2.5_aod_10_12_yearly.'+ Yr4 +'.hdf'

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(filename ,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

data1 = HDF_GETSD(fId,'pm2.5')
help, data1

data2 = HDF_GETSD(fId,'aod')
help, data2

HDF_SD_END, FID

pm [375:495,158:290,Year-2004] = data1
aod[375:495,158:290,Year-2004] = data2

endfor


limit=[15,70,55,136]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

;data18 = pm[I1:I2,J1:J2,0]
;data28 = pm[I1:I2,J1:J2,1]
;data38 = pm[I1:I2,J1:J2,2]
;data48 = pm[I1:I2,J1:J2,3]

data18 = aod[I1:I2,J1:J2,0]
data28 = aod[I1:I2,J1:J2,1]
data38 = aod[I1:I2,J1:J2,2]
data48 = aod[I1:I2,J1:J2,3]


; plot
!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 2, row = 2

;portrait
xmax = 8
ymax = 12

xsize= 8
ysize= 8

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/work/pm2.5/result/trend_aod.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 2

Myct, 22

tvmap,data18,                                          $   
limit=limit,					        $     
/nocbar,              			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I4)',                                      $
cbposition = [0.15 , 0.075, 1.8, 0.10 ],                $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $
margin = margin,				        $
/Sample,					        $
title='AOD 2004',                      $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

tvmap,data28,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                          $
format = '(I4)',                                      $
cbposition=[0 , 0.03, 1.0, 0.06 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='AOD 2005',                     $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data38,                                          $
limit=limit,                                            $
/nocbar,                                                  $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                          $
format = '(I4)',                                      $
cbposition=[0 , 0.075, 1.0, 0.1 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='AOD 2006',                                       $
/Quiet,/Noprint,                                        $
position=position3,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data48,                                          $
limit=limit,                                            $
/nocbar,                                                  $
mindata = mindata,                                            $
maxdata = maxdata,                                          $
cbmin = mindata, cbmax = maxdata,                                 $
divisions = 11,                                          $
format = '(I4)',                                      $
cbposition=[0.0 , 0.075, 1.0, 0.1 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='AOD 2007',                                       $
/Quiet,/Noprint,                                        $
position=position4,                                     $
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



   Colorbar,					                 $
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      Position=[ 0.15, 0.05, 0.85, 0.07],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
      divisions = 11,                                             $
      c_colors=c_colors,C_levels=C_levels,			 $
      Min=mindata, Max=maxdata, Unit='',format = '(f6.1)',charsize=1
                   ;
   TopTitle = '';'ug/m3'
                   
      XYOutS, 0.9, 0.03, TopTitle,      $
      /Normal,                           $ ; Use normal coordinates
      Color=!MYCT.BLACK,                 $ ; Set text color to black
      CharSize=1,                      $ ; Set text size to twice normal size
      Align= 0.5                           ; Center text

   TopTitle = '';'E+15 molec/cm2'

      XYOutS, 0.9, 0.53,TopTitle,	 $
      /Normal,                 		 $ ; Use normal coordinates
      Color=!MYCT.BLACK, 		 $ ; Set text color to black
      CharSize=0.8,  			 $ ; Set text size to twice normal size
      Align=0.5    			   ; Center text

close_device

end
