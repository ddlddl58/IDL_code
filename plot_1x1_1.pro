pro plot_1x1_1,year,month

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

;get data
InType = CTM_Type( 'GENERIC', Res=[0.25d0, 0.25d0],Halfpolar=0,Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

limit=[27,117,35,123]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2


Year = year
Month = month

AOD = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

for Day = 1,31 do begin

NYMD0 = Year * 10000L + Month * 100L + Day * 1L
tau0 = nymd2tau(NYMD0)

if NYMD0 eq 20090631 then continue
if NYMD0 eq 20090931 then continue
if NYMD0 eq 20100631 then continue
if NYMD0 eq 20100931 then continue
;if NYMD0 eq 20100430 then continue

Yr4 = string(Year,format='(i4.4)')
Mon2 = String( Month, Format = '(i2.2)' )
Day2 = String( Day, Format = '(i2.2)' )

filename = '/z3/gengguannan/satellite/AOD/omi_AOD_'+ Yr4 + Mon2 + Day2 +'_025x025.bpch'

ctm_get_data,datainfo,filename = filename,tau0=tau0
data18=*(datainfo[0].data)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (data18[I,J] gt 0) then begin
       AOD[I,J] += data18[I,J]
       nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor

print,max(nod,min=min),min,mean(nod)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod[I,J] gt 0L)           $
      then  AOD[I,J] /= nod[I,J]  $
      else  AOD[I,J] = -999.0
  endfor
endfor

print,max(AOD,min=min),min,mean(AOD)

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
             Bits=8,          Filename='/home/gengguannan/result/AOD_'+Yr4+Mon2+'.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset 

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = 0
maxdata = 2


data828=AOD[I1:I2,J1:J2]

xxmid = xmid[I1:I2]
yymid = ymid[J1:J2]

Myct,22

; Define (X,Y) coordinates of first tagged tracer region
 TrackX = [ 120, 122, 122, 120, 120 ]
 TrackY = [ 30, 30, 33, 33, 30 ]
 TrackD = [ 0, 0, 0, 0, 0 ]

CTM_OverLay,                               $
Data828, xxmid, yymid,                     $
TrackD,TrackX,TrackY,                      $
limit=limit,				   $     
/nocbar,            			   $     
mindata = mindata,                         $
maxdata = maxdata,                         $
cbmin = mindata, cbmax = maxdata,          $
divisions = 11,                            $
format = '(f6.1)',                         $
cbposition = [0 , 0.03, 1.0, 0.06 ],       $
/countries,/continents,/Coasts,    	   $
/CHINA,					   $         
margin = margin,			   $  
/Sample,				   $         
title=Yr4+Mon2,  	                   $
/Quiet,/Noprint,                           $
position=position1,			   $       
/grid, skip=1,gcolor=gcolor,               $
T_Color=!MYCT.BLACK,                       $
T_Thick=10,                                 $
T_LineStyle=0




;multipanel, /noerase
;Map_limit = limit
; Plot grid lines on the map
;Map_Set, 0, 0, 0, /NoErase, Limit = map_limit, position=position4,color=13
;LatRange = [ Map_Limit[0], Map_Limit[2] ]
;LonRange = [ Map_Limit[1], Map_Limit[3] ]

;make_chinaboundary


   Colorbar,					                 $    
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      Position=[ 0.1, 0.10, 0.95, 0.12],			 $
      ;Divisions=Comlorbar_NDiv( Max=9 ), 			 $
      divisions = 6,                                            $
      c_colors=c_colors,C_levels=C_levels,			 $
      Min=mindata, Max=maxdata, Unit='',format = '(f4.1)',charsize=0.8
                   ;
   TopTitle = ''
                   
      XYOutS, 0.55, 0.03, TopTitle, $
      /Normal,                      $ ; Use normal coordinates
      Color=!MYCT.BLACK,            $ ; Set text color to black
      CharSize=0.8,                 $ ; Set text to twice normal size
      Align= 0.5                      ; Center text

   TopTitle = ''

      XYOutS, 0.5, 1.05,TopTitle,   $
      /Normal,                 	    $ ; Use normal coordinates
      Color=!MYCT.BLACK, 	    $ ; Set text color to black
      CharSize=1.4,  		    $ ; Set text to twice normal size
      Align=0.5    		      ; Center text

close_device

end
