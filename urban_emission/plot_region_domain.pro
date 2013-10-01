pro plot_region_domain

limit=[15,70,55,136]

!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 1.0

multipanel, omargin=[0.05,0.02,0.02,0.05],col = 1, row = 1

;portrait
xmax = 8
ymax = 12

xsize= 4
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

year = 2005
month = 1
nymd0 = year*10000L + month*100L + 1L
tau0 = nymd2tau(nymd0)

Open_Device, /PS,             $
             /Color,               $
             Bits=8,          Filename='/home/gengguannan/result/ur_emiss/five_areas_domain.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

filename1 = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_annual_2005-2007_NO2.month.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_annual_average_2005-2007_05x0666.bpch'

ctm_get_data,datainfo1,filename = filename1,tracer=1
data18=*(datainfo1[0].data)

ctm_get_data,datainfo2,filename = filename2,tracer=1
data28=*(datainfo2[0].data)

;print,max(data18,min=min),min,mean(data18)

InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = 0L
maxdata = 10L

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

data818 = data28[I1:I2, J1:J2]
;data818 = data28[I1:I2, J1:J2]-data18[I1:I2,J1:J2]
;print,max(data818,min=min),min,mean(data818)

xxmid = xmid[I1:I2]
yymid = ymid[J1:J2]

Myct, 22

; Define (X,Y) coordinates of first tagged tracer region
 TrackX = [ 104, 114, 114, 104, 104 ]
 TrackY = [ 35, 35, 41, 41, 35 ]
 TrackD = [ 0, 0, 0, 0, 0 ]

CTM_OverLay,                               $
Data818, xxmid, yymid,                     $
TrackD,TrackX,TrackY,                      $
limit=limit,                               $
mindata=mindata,maxdata=maxdata,           $
/cbar,                                     $
cbmin =mindata, cbmax =maxdata,            $
divisions = 9,                             $
cbposition=[0.15 , 0.1, 0.9, 0.12 ],       $
cbformat = '(f4.1)',                       $
/Sample,                                   $
/Grid,                                     $
/Countries,/continents,/Coasts,            $
/China,                                    $
margin = margin,                           $
title='OMI 2005-2007',              $
T_Color=!MYCT.BLACK,                       $
T_Thick=4,                                 $
T_LineStyle=0

;multipanel, /noerase
;Map_limit = limit
; Plot grid lines on the map
;Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
;LatRange = [ Map_Limit[0], Map_Limit[2] ]
;LonRange = [ Map_Limit[1], Map_Limit[3] ]

;make_chinaboundary


   TopTitle = 'E+15molec/cm2'

      XYOutS, 0.54, 0.04, TopTitle,                             $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=0.9,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

   TopTitle = ' '

      XYOutS, 0.5, 1.05,TopTitle,                                $
      /Normal,                                                   $ ; Use normal coordinates
      Color=!MYCT.BLACK,                                         $ ; Set text color to black
      CharSize=1.4,                                              $ ; Set text size to twice normal size
      Align=0.5                                                    ; Center text

; Define (X,Y) coordinates of second tagged tracer region
 TrackX = [ 114, 114, 122, 122, 114 ]
 TrackY = [ 30, 45, 45, 30, 30 ]
 TrackD = [ 0,  0,  0,  0, 0 ]

CTM_OverLay,          $
Data818, xxmid, yymid,$
TrackD,TrackX,TrackY, $
limit=limit,          $
T_Color=!MYCT.BLACK,  $
T_Thick=4,            $
T_LineStyle=0,        $
/OverPlot

; Define (X,Y) coordinates of third tagged tracer region
 TrackX = [ 122, 122, 135, 135, 122 ]
 TrackY = [ 40, 50, 50, 40, 40 ]
 TrackD = [ 0,  0,  0,  0, 0 ]

CTM_OverLay,          $
Data818, xxmid, yymid,$
TrackD,TrackX,TrackY, $
limit=limit,          $
T_Color=!MYCT.BLACK,  $
T_Thick=4,            $
T_LineStyle=0,        $
/OverPlot


; Define (X,Y) coordinates of third tagged tracer region
 TrackX = [ 97, 97, 110, 110, 97 ]
 TrackY = [ 25, 33, 33, 25, 25 ]
 TrackD = [ 0,  0,  0,  0, 0 ]

CTM_OverLay,          $
Data818, xxmid, yymid,$
TrackD,TrackX,TrackY, $
limit=limit,          $
T_Color=!MYCT.BLACK,  $
T_Thick=4,            $
T_LineStyle=0,        $
/OverPlot

; Define (X,Y) coordinates of forth tagged tracer region
 TrackX = [ 110, 110, 123, 123, 110 ]
 TrackY = [ 20,  30, 30, 20, 20 ]
 TrackD = [ 0,  0,  0,  0, 0 ]

CTM_OverLay,          $
Data818, xxmid, yymid,$
TrackD,TrackX,TrackY, $
limit=limit,          $
T_Color=!MYCT.BLACK,  $
T_Thick=4,            $
T_LineStyle=0,        $
/OverPlot


close_device

end

