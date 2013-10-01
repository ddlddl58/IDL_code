pro plot_mark_max_season,year

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InType = CTM_Type( 'GENERIC', Res=[0.125d0, 0.125d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

no2 = fltarr(InGrid.IMX,InGrid.JMX,4)
max = fltarr(InGrid.IMX,InGrid.JMX)

season = ['JJA','SON','DJF','MAM']

limit=[15,70,55,136]
;limit=[32,100,45,120]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)


year = year
for m = 0,3 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( m+1, format = '(i2.2)')

nymd = Year * 10000L + 1 * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

;filename = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_'+season[m] +'.0125x0125.bpch'
;filename = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen/scia_no2_v1-0_'+ Yr4 +'_'+season[m] +'.0125x0125.bpch'
filename = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_1997_to_2002_'+season[m]+'.0125x0125.bpch'
;filename = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen/scia_no2_v1-0_2003_to_2005_'+season[m]+'.0125x0125.bpch'
;filename = '/z3/gengguannan/satellite/no2/OMI/omi_no2_'+ Yr4 +'_'+ season[m] +'.01x01.bpch'

CTM_Get_Data, datainfo, tracer = 1, filename = filename
data18 = *(datainfo[0].data)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    no2[I,J,m] = data18[I,J]
  endfor
endfor

endfor


for I = I1,I2 do begin
  for J = J1,J2 do begin
     if min(no2[I,J,*]) gt 0 $
     then max[I,J] = where(no2[I,J,*] eq max(no2[I,J,*])) + 1 $
     else max[I,J] = 0
  endfor
endfor



;plot
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

Open_Device, /PS,             $
             /Color,          $
             Bits=8,          Filename='/home/gengguannan/result/max_season_1997-2002.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor=1
mindata = 0L
maxdata = 4L

map = max[I1:I2,J1:J2]

;Myct, 34,/REVERSE,ncolors=5
Myct,34,ncolors=5

tvmap,map,                                              $
limit=limit,                                            $
/cbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
;divisions = 6,                                          $
;cbformat='(f4.0)',                                      $
cbposition=[0.025, 0.03, 0.95, 0.06 ],                  $
cbunit='',                                              $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title= '1997 - 2002 GOME',     $
/Quiet,/Noprint,                                        $
position=position1,                                     $
/grid, skip=1,gcolor=gcolor


;Colorbar,                                                     $
    ;Position=[ 0.15, 0.1, 0.85, 0.12],$
;    Position=[ 0.15, 0.10, 0.95, 0.12],                       $
;    Divisions=6,                                              $
    ;c_colors=c_colors,C_levels=C_levels,                      $
;    Min=mindata, Max=maxdata, Unit='',format = '(f3.1)',charsize=1.0

    TopTitle = 'No Data      Summer        Autumn          Winter         Spring'
;    TopTitle = ''
      XYOutS, 0.525, 0.026, TopTitle,  $
      /Normal,                        $ ; Use normal coordinates
      Color=!MYCT.BLACK,              $ ; Set text color to black
      CharSize=0.9,                   $ ; Set size to twice normal size
      Align=0.5                         ; Cen    ter text

close_device

end
