pro plot_2x2_hotspot

;limit=[15,70,55,136]
;limit=[42,85,47,93]
;limit=[32,107,42,120]
limit=[22,100,46,132]
;limit=[27,115,35,125]

;InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InType = CTM_Type( 'GENERIC', Res=[0.125d0, 0.125d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2


;1st
no21 = fltarr(InGrid.IMX,InGrid.JMX)
nod1 = fltarr(InGrid.IMX,InGrid.JMX)

for year=1996,1998 do begin

  Yr4 = string(Year,format='(i4.4)')

  if year le 2002 $
;    then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_annual_average.0125x0125.bpch' $
;    else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_annual_average.0125x0125.bpch'
    then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_JJA.0125x0125.bpch' $
    else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_JJA.0125x0125.bpch'


  ctm_get_data,datainfo,filename = infile,tracer=1
  data18=*(datainfo[0].data)

  for I = I1,I2 do begin
    for J = J1,J2 do begin
      if (data18[I,J] gt 0) then begin
        no21[I,J] += data18[I,J]
        nod1[I,J] += 1
      endif
    endfor
  endfor

endfor

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod1[I,J] gt 0L)           $
      then  no21[I,J] /= nod1[I,J]  $
      else  no21[I,J] = -999.0
  endfor
endfor

data818 = no21[I1:I2,J1:J2]

;2nd
no22 = fltarr(InGrid.IMX,InGrid.JMX)
nod2 = fltarr(InGrid.IMX,InGrid.JMX)

for year=2003,2005 do begin

  Yr4 = string(Year,format='(i4.4)')

  if year le 2002 $
;    then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_annual_average.0125x0125.bpch' $
;    else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_annual_average.0125x0125.bpch'
    then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_JJA.0125x0125.bpch' $
    else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_JJA.0125x0125.bpch'

  ctm_get_data,datainfo,filename = infile,tracer=1
  data28=*(datainfo[0].data)

  for I = I1,I2 do begin
    for J = J1,J2 do begin
      if (data28[I,J] gt 0) then begin
        no22[I,J] += data28[I,J]
        nod2[I,J] += 1
      endif
    endfor
  endfor

endfor

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod2[I,J] gt 0L)           $
      then  no22[I,J] /= nod2[I,J]  $
      else  no22[I,J] = -999.0
  endfor
endfor

data828 = no22[I1:I2,J1:J2]

;3rd
no23 = fltarr(InGrid.IMX,InGrid.JMX)
nod3 = fltarr(InGrid.IMX,InGrid.JMX)

for year=2008,2010 do begin

  Yr4 = string(Year,format='(i4.4)')

  if year le 2002 $
;    then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_annual_average.0125x0125.bpch' $
;    else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_annual_average.0125x0125.bpch'
    then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_JJA.0125x0125.bpch' $
    else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_JJA.0125x0125.bpch'

  ctm_get_data,datainfo,filename = infile,tracer=1
  data38=*(datainfo[0].data)

  for I = I1,I2 do begin
    for J = J1,J2 do begin
      if (data38[I,J] gt 0) then begin
        no23[I,J] += data38[I,J]
        nod3[I,J] += 1
      endif
    endfor
  endfor

endfor

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod3[I,J] gt 0L)           $
      then  no23[I,J] /= nod3[I,J]  $
      else  no23[I,J] = -999.0
  endfor
endfor

data838 = no23[I1:I2,J1:J2]

;4th
filename = '/home/gengguannan/indir/China_mask.geos5.v3.025x025'

ctm_get_data,datainfo,filename = filename,tracer=802
mask=*(datainfo[0].data)


OutType = CTM_Type( 'generic', Res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

no241 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod41 = fltarr(OutGrid.IMX,OutGrid.JMX)
no242 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod42 = fltarr(OutGrid.IMX,OutGrid.JMX)
data48 = fltarr(OutGrid.IMX,OutGrid.JMX)

;for year=2008,2010 do begin

;  Yr4 = string(Year,format='(i4.4)')

;  if year le 2002 $
;    then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_annual_average.0125x0125.bpch' $
;    else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_annual_average.0125x0125.bpch'
;    then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_JJA.0125x0125.bpch' $
;    else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_JJA.0125x0125.bpch'

;  ctm_get_data,datainfo,filename = infile,tracer=1
;  data48=*(datainfo[0].data)

inxmid = InGrid.xmid
inymid = InGrid.ymid

  for I = I1,I2 do begin
    for J = J1,J2 do begin
    x = where( (inxmid[I] gt (outxmid - 0.125)) and (inxmid[I] le (outxmid + 0.125)))
    y = where( (inymid[J] gt (outymid - 0.125)) and (inymid[J] le (outymid + 0.125)))
    if (no22[I,J] gt 0) then begin
        no241 [x,y] += no22[I,J]
        nod41 [x,y] += 1
    endif
    if (no23[I,J] gt 0) then begin
        no242 [x,y] += no23[I,J]
        nod42 [x,y] += 1
    endif
    endfor
  endfor

i1_index = where(Outxmid ge limit[1] and Outxmid le limit[3])
j1_index = where(Outymid ge limit[0] and Outymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2


for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod41[I,J] gt 0L)           $
        then  no241[I,J] /= nod41[I,J]  $
        else  no241[I,J] = -999.0
    if (nod42[I,J] gt 0L)           $
        then  no242[I,J] /= nod42[I,J]  $
        else  no242[I,J] = -999.0
  endfor
endfor

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (mask[I,J] gt 0) and (no241[I,J] gt 1) and (no242[I,J] gt 1)            $
        then data48[I,J] = no242[I,J] / no241[I,J]   $
        else data48[I,J] = -999.0
  endfor
endfor

data848 = data48[I1:I2,J1:J2]
print,max(data848),min(data848)


CTM_CLEANUP


;now plot
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
             Bits=8,          Filename='/home/gengguannan/result/hotspot_change_part1.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset



Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 10

print,max(data818),max(data828),max(data838),max(data848)

Myct, 22

tvmap,data818,                                          $   
limit=limit,					        $     
/nocbar,            			                $     
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I12)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,    		        $
/CHINA,						        $         
margin = margin,				        $  
/Sample,					        $         
title='1996-1998 (GOME)',  	                $
/Quiet,/Noprint,				        $
position=position1,			         	$       
/grid, skip=1,gcolor=gcolor,$
;CSFAC=1.5,$
TCSFAC=2


tvmap,data828,                                          $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I12)',                                      $
cbposition=[0.3 , 0.03, 1.7, 0.06 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='2003-2005 (SCIAMACHY)',                                  $
/Quiet,/Noprint,                                        $
position=position2,                                     $
/grid, skip=1,gcolor=gcolor,$
TCSFAC=2

tvmap,data838,                                          $
limit=limit,                                            $
/cbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 11,                                         $
format = '(I12)',                                      $
cbposition=[0.0 , 0.025, 1, 0.05 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='2008-2010 (SCIAMACHY)',                          $
/Quiet,/Noprint,                                        $
position=position3,                                     $
/grid, skip=1,gcolor=gcolor,$
TCSFAC=2

tvmap,data848,                                          $
limit=limit,                                            $
/cbar,                                                $
mindata = mindata,                                      $
maxdata = 1.8,                                        $
cbmin = mindata, cbmax = 1.8,                         $
divisions = 7,                                          $
format = '(I12)', $
cbformat = '(f6.1)',                                      $
cbposition=[0.0 , 0.025, 1, 0.05 ],                     $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='2008-2010/2003-2005',                            $
/Quiet,/Noprint,                                        $
position=position4,                                     $
/grid, skip=1,gcolor=gcolor,$
TCSFAC=2



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



;   Colorbar,					                 $    
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
;      Position=[ 0.1, 0.05, 0.5, 0.06],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
;      divisions = 11,                                            $
;      c_colors=c_colors,C_levels=C_levels,			 $
;      Min=mindata, Max=maxdata, Unit='',format = '(f6.0)',charsize=0.8
                   ;
   TopTitle = '10!U15!N molecules/cm!U2!N'
                   
      XYOutS, 0.3, 0.02, TopTitle,                              $
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

CTM_CLEANUP


end
