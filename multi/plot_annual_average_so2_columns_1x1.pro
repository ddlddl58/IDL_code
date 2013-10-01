pro plot_annual_average_so2_columns_1x1

limit=[15,70,55,145]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 1.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 1, row = 1

;portrait
xmax = 9 
ymax = 9

xsize= 7
ysize= 7

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

year = 2006
Yr4 = string(year,format='(i4.4)')
nymd0 = year*10000L + 12*100L + 31L
tau0 = nymd2tau(nymd0)

Open_Device, /PS,             $
             /Color,               $
             Bits=8,          Filename='/z3/gengguannan/satellite/pictures/omi_so2_annual_average_'+Yr4+'_tropCS30_partial_scene.05x05.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

filename1 = '/z3/gengguannan/satellite/so2/average/omi_so2_'+ Yr4 +'_tropCS30_partial_scene.05x05.bpch'

ctm_get_data,datainfo1,filename = filename1,tau0=tau0,tracer=26
data18=*(datainfo1[0].data)
print,max(data18,min=min),min,mean(data18)

GetModelAndGridInfo, dataInfo1[0], InType, InGrid

;InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = -2L
maxdata = 2L

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = data18[I1:I2, J1:J2]
print,max(data818,min=min),min,mean(data818)

Myct, 22

tvmap,data818,                                          $   
limit=limit,					        $     
/cbar,         	               			        $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
cbformat='(f4.1)',                                      $
cbposition=[0.1 , 0.03, 0.9, 0.06 ],                    $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
title='Annual average SO2 columns: '+Yr4+' (4-25 scenes)',  $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor


   TopTitle = '[DU]'
                   
      XYOutS, 0.93, 0.036, TopTitle,                             $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=0.9,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle = ' '

      XYOutS, 0.5, 1.05,TopTitle,				 $
      /Normal,                 				         $ ; Use normal coordinates
      Color=!MYCT.BLACK, 				         $ ; Set text color to black
      CharSize=1.4,  				                 $ ; Set text size to twice normal size
      Align=0.5     				                   ; Center text

close_device

end
