pro average_multiyear_plot

FORWARD_FUNCTION CTM_Grid, CTM_Type

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


avg_value = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)


; Time set
for y = 2004,2010 do begin
Yr4  = String( y, format='(i4.4)')

if y eq 2004 or y eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

for m = 1,12 do begin
mon2 = string( m, format='(i2.2)')

for d = 1,Dayofmonth[m-1] do begin
day2 = string( d, format='(i2.2)')

nymd = y*10000L + m*100L + d*1L
if nymd eq 20081001 then continue
if nymd eq 20081002 then continue
if nymd eq 20081003 then continue
if nymd eq 20081004 then continue
if nymd eq 20081005 then continue
if nymd eq 20081006 then continue
if nymd eq 20081007 then continue
if nymd eq 20081008 then continue
if nymd eq 20081009 then continue
if nymd eq 20081010 then continue
if nymd eq 20081011 then continue
if nymd eq 20081012 then continue
if nymd eq 20081013 then continue
if nymd eq 20081014 then continue
if nymd eq 20081015 then continue
if nymd eq 20081220 then continue
if nymd eq 20081221 then continue
if nymd eq 20081222 then continue


; Infile info
;Infile1 = '/home/gengguannan/satellite/aod/MISR/'+Yr4+'/MISR_0.66x0.50_'+Yr4+Mon2+Day2
Infile1 = '/home/gengguannan/work/pm2.5/pm2.5/sate_based/daily/'+Yr4+'/MISR_pm2.5_0.66x0.50_'+Yr4+Mon2+Day2

RESTORE,filename = Infile1

value = misr_pm

;value = fltarr(InGrid.IMX,InGrid.JMX)

;Infile2 = '/home/gengguannan/work/pm2.5/pm2.5/gc/daily/'+Yr4+'/model_pm2.5_aod_10_12.'+Yr4+Mon2+Day2+'.hdf'

;IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

;FID = HDF_SD_START(Infile2,/Read)
;if ( FID lt 0 ) then Message, 'Error opening file!'

;data = HDF_GETSD(fId,'pm2.5')

;HDF_SD_END, FID

;value[375:495,158:290] = data


; Average
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if value[I,J] gt 0 then begin
      avg_value[I,J] = avg_value[I,J] + value[I,J]
      nod[I,J] = nod[I,J] + 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor
endfor


print,max(nod)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod[I,J] gt 0L) $
      then avg_value[I,J] = avg_value[I,J] / nod[I,J] $
      else avg_value[I,J] = -999
  endfor
endfor

print,max(avg_value),mean(avg_value)


;plot
!x.thick = 3
!y.thick = 3
!p.color = 1
!p.charsize = 1.0
!p.font = 4.0

multipanel, omargin=[0.05,0.02,0.02,0.05]

;portrait
xmax = 8
ymax = 12

xsize= 4
ysize= 4

XOffset = ( XMax - XSize ) / 2.0
YOffset = ( YMax - YSize ) / 2.0

Open_Device, /PS,             $
             /Color,          $
             Bits=8,          Filename='/home/gengguannan/work/pm2.5/result/misr_pm_7year.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 90

data18=avg_value[I1:I2,J1:J2]


tvmap,data18,                                           $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(f6.1)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='2004-2010',                          $
/Quiet,/Noprint,                                        $
position=position1,                                     $
/grid, skip=1,gcolor=gcolor


multipanel, /noerase
Map_limit = limit
; Plot grid lines on the map
Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position1,color=13
LatRange = [ Map_Limit[0], Map_Limit[2] ]
LonRange = [ Map_Limit[1], Map_Limit[3] ]

make_chinaboundary


   Colorbar,                                                     $
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      Position=[ 0.1, 0.10, 0.95, 0.12],                         $
      ;Divisions=Comlorbar_NDiv( Max=9 ),                        $
      divisions = 10,                                            $
      c_colors=c_colors,C_levels=C_levels,                       $
      Min=mindata, Max=maxdata, Unit='',format = '(I4)',charsize=0.8
                   ;
   TopTitle = 'ug/m!U3!N'

      XYOutS, 0.55, 0.03, TopTitle, $
      /Normal,                      $ ; Use normal coordinates
      Color=!MYCT.BLACK,            $ ; Set text color to black
      CharSize=0.8,                 $ ; Set text to twice normal size
      Align= 0.5                      ; Center text

close_device

end
