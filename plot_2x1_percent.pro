pro plot_2x1_percent

limit=[14.5,72,52.5,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 10.0

multipanel, omargin=[0.05,0.02,0.02,0.05]

;portrait
xmax = 8 
ymax = 12

xsize= 6
ysize= 6

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Year = 2007
Month = 1
NYMD0 = Year * 10000L + Month * 100L + 1L

Yr4 = string(Year,format='(i4.4)')
Mon2 = String( Month, Format = '(i2.2)' )

Open_Device, /PS,             $
             /Color,          $     
             Bits=8,          Filename='/home/gengguannan/result/pictures/'+ Yr4 + Mon2 +'differences.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

filename1 =  '/home/gengguannan/result/power_plant/ctm.vc_monthly_'+ Yr4 + Mon2 +'_NO2.month.05x0666.power.plant.bpch'
filename2 =  '/home/gengguannan/satellite/NASA_OMI_NO2_L3_monthly_'+ Yr4 + Mon2 +'_TropCS30.05x0666.bpch'

ctm_get_data,datainfo_1,filename = filename1,tau0=nymd2tau(20070101),tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tau0=nymd2tau(20070101),tracer=1
data28=*(datainfo_2[0].data)


InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.25d0, 0.25d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = -0.03
maxdata = 0.03

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = data18[I1:I2,J1:J2]-data28[I1:I2,J1:J2]

print,max(data818),min(data818)
print,max(data18[I1:I2,J1:J2]),min(data18[I1:I2,J1:J2])

a=data818
b=data28[I1:I2,J1:J2]
percent=float(a)/b 
print,max(percent),min(percent)

tvmap,percent,                                         $   
limit=limit,					        $     
/cbar,         				        $     
mindata = mindata, $
maxdata = maxdata, $
cbmin = mindata, cbmax =maxdata, $
divisions = 11,                  $
cbposition=[0, 0.05, 1, 0.08 ],                 $
cbformat='(f6.3)',$
/countries,/continents,/Coasts,    		        $
/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
title='Differences between model and satellite '+Yr4+Mon2,	        $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor


   ;Colorbar,					                 $    
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      ;Position=[ 0.10, 0.10, 0.90, 0.12],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), $
      ;c_colors=c_colors,C_levels=C_levels,			 $
      ;Min=0, Max=20, Unit='',format = '(f3.1)',charsize=1.2
                   ;
   TopTitle = 'E+15 molec/cm2 '
                   
      XYOutS, 0.85, 0.035, TopTitle,                              $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.0,                                                $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle = ' '

      XYOutS, 0.5, 1.05,TopTitle,				 $
      /Normal,                 				         $ ; Use normal coordinates
      Color=!MYCT.BLACK, 				         $ ; Set text color to black
      CharSize=1.4,  				                 $ ; Set text size to twice normal size
      Align=0.5     				                   ; Center text

close_device

end
