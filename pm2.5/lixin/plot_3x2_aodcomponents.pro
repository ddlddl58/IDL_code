pro plot_3x2_aodcomponents

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

; Region set
limit=[15,85,53,136]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2


; Read file
avg_gc_OPSO4 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPBC = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPOC = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPSSa = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPSSc = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPD = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_AOD = fltarr(InGrid.IMX,InGrid.JMX)


Dir = '/home/gengguannan/work/pm2.5/pm2.5/gc_xin/'
filename = Dir + 'model_aod.200607.hdf'
print,filename

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(filename,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

OPSO4 = HDF_GETSD(fId,'OPSO4')
OPBC = HDF_GETSD(fId,'OPBC')
OPOC = HDF_GETSD(fId,'OPOC')
OPSSa = HDF_GETSD(fId,'OPSSa')
OPSSc = HDF_GETSD(fId,'OPSSc')
OPD = HDF_GETSD(fId,'OPD')
AOD = HDF_GETSD(fId,'AOD')

HDF_SD_END, FID

avg_gc_OPSO4[375:495,158:290] = OPSO4
avg_gc_OPBC[375:495,158:290] = OPBC
avg_gc_OPOC[375:495,158:290] = OPOC
avg_gc_OPSSa[375:495,158:290] = OPSSa
avg_gc_OPSSc[375:495,158:290] = OPSSc
avg_gc_OPD[375:495,158:290] = OPD
avg_gc_AOD[375:495,158:290] = AOD


data18 = avg_gc_OPSO4[I1:I2,J1:J2]
data28 = avg_gc_OPBC[I1:I2,J1:J2]
data38 = avg_gc_OPOC[I1:I2,J1:J2]
data48 = avg_gc_OPSSa[I1:I2,J1:J2]
data58 = avg_gc_OPSSc[I1:I2,J1:J2]
data68 = avg_gc_OPD[I1:I2,J1:J2]


; plot
!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 3, row = 2

;portrait
xmax = 20
ymax = 12

xsize= 15
ysize= 8

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/work/pm2.5/result/gc_aod_components.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 1

Myct, 22

tvmap,data18,                                           $   
limit=limit,					        $     
/nocbar,              			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I4)',                                        $
cbposition = [0.15 , 0.075, 1.8, 0.10 ],                $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $
margin = margin,				        $
/Sample,					        $
title='OPSO4',                                          $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor

tvmap,data28,                                           $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I4)',                                        $
cbposition=[0 , 0.03, 1.0, 0.06 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='OPBC',                                           $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data38,                                           $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I4)',                                        $
cbposition=[0 , 0.075, 1.0, 0.1 ],                      $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='OPOC',                                           $
/Quiet,/Noprint,                                        $
position=position3,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data48,                                           $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I4)',                                        $
cbposition=[0.0 , 0.075, 1.0, 0.1 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='OPSSa',                                          $
/Quiet,/Noprint,                                        $
position=position4,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data58,                                           $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I4)',                                        $
cbposition=[0.0 , 0.075, 1.0, 0.1 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='OPSSc',                                          $
/Quiet,/Noprint,                                        $
position=position5,                                     $
/grid, skip=1,gcolor=gcolor

tvmap,data68,                                           $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I4)',                                        $
cbposition=[0.0 , 0.075, 1.0, 0.1 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='OPD',                                            $
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


   Colorbar,					                 $
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      Position=[ 0.15, 0.05, 0.85, 0.07],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
      divisions = 11,                                             $
      c_colors=c_colors,C_levels=C_levels,			 $
      Min=mindata, Max=maxdata, Unit='',format = '(f6.1)',charsize=1
                   ;
   TopTitle = ''
                   
      XYOutS, 0.9, 0.03, TopTitle,       $
      /Normal,                           $ ; Use normal coordinates
      Color=!MYCT.BLACK,                 $ ; Set text color to black
      CharSize=1,                        $ ; Set text size to twice normal size
      Align= 0.5                           ; Center text

   TopTitle = '';'E+15 molec/cm2'

      XYOutS, 0.9, 0.53,TopTitle,	 $
      /Normal,                 		 $ ; Use normal coordinates
      Color=!MYCT.BLACK, 		 $ ; Set text color to black
      CharSize=0.8,  			 $ ; Set text size to twice normal size
      Align=0.5    			   ; Center text

close_device

end
