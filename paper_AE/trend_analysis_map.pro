;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;define the function of the form F(x)=a+b*x+c*sin(d*x+e)
;a and d is known                                       
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pro gfunct, X, A, F, pder

ax = sin( 0.5236 * X + A[2] )
bx = cos( 0.5236 * X + A[2] )
F = A[0] * X + A[1] * ax

;If the procedure is called with 4 parameters, calculate the partial derivatives
if n_params() ge 4 then $
  pder= [[X], [ax], [A[1] * bx]]

end



;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;Compute the fit to the function we have just defined
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pro trend_analysis_map

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

InType = CTM_Type( 'GENERIC', Resolution=[1d0,1d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

;limit=[20,80,50,130]
limit=[27,115,28,116]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
I0 = ( 115 + 180 ) / 1
J0 = ( 27 + 90 ) / 1
print,I1,I2,J1,J2


;prepare the data needed
filename1 = '/z3/gengguannan/satellite/no2/GOME_KNMI_v2.0/no2_199604_1x1.bpch'
;filename1 = '/z3/gengguannan/satellite/no2/SCIAMACHY_KNMI_v2.0/no2_200301_1x1.bpch'
;filename1 = '/z3/gengguannan/satellite/no2/OMI_KNMI_v2.0/no2_200501_1x1.bpch'

ctm_get_data,datainfo1,filename = filename1,tracer=1
intercept=*(datainfo1[0].data)


xx = I2 - I1 + 1
yy = J2 - J1 + 1
zz = (2004-1996+1)*12

no2 = fltarr(xx,yy,zz)
data = fltarr(xx,yy,zz)
B = fltarr(xx,yy)

for y = 1996,2004 do begin
for m = 1,12 do begin

Yr4  = String( y, format = '(i4.4)' )
Mon2 = String( m, format = '(i2.2)' )

nymd = y * 10000L + m * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd


if nymd eq 19960101 then continue
if nymd eq 19960201 then continue
if nymd eq 19960301 then continue

if y lt 2003 $
  then filename2 = '/z3/gengguannan/satellite/no2/GOME_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'_1x1.bpch'$
  else filename2 = '/z3/gengguannan/satellite/no2/SCIAMACHY_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'_1x1.bpch'
;filename2 = '/z3/gengguannan/satellite/no2/OMI_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'_1x1.bpch'


ctm_get_data,datainfo2,filename = filename2,tau0=nymd2tau(NYMD),tracer=1
data18=*(datainfo2[0].data)

k = m+(y-1996)*12-1

for I = I1,I2 do begin
  for J = J1,J2 do begin
    no2[I-I0,J-J0,k] = data18[I,J]
    data[I-I0,J-J0,k] = (data18[I,J]-intercept[I,J])
  endfor
endfor

CTM_CLEANUP

endfor
endfor


;fit
for I = 0,xx-1 do begin
  for J = 0,yy-1 do begin

    X0 = indgen(zz)+1
    X1 = make_array(1)
    Y1 = make_array(1)
    flag = 1

    for p = 0,zz-1 do begin

      if no2[I,J,p] gt 0 then begin
        if flag eq 1 then begin
          Y1 = [data[I,J,p]]
          X1 = [X0[p]]
        endif else begin
          Y1 = [Y1,data[I,J,p]]
          X1 = [X1,X0[p]]
        endelse
      flag = 0
      endif

    endfor

    print,'number of data',n_elements(X1)

    if n_elements(X1) lt 10 then continue

    weights = make_array(n_elements(X1),value=1.0)

    ; Provide an initial guess of the function's parameters
    A = [0.025,3,1.5708]

    ; Compute the parameters.
    yfit = CURVEFIT(X1, Y1, weights, A, SIGMA, FUNCTION_NAME='gfunct', ITMAX=50)

    ; Print the parameters returned in A.
    print, 'Function parameters: ', A

    ; validate
    res = A[0] * X1 + A[1] * sin( 0.5236 * X1 + A[2] ) - Y1
    lag = [1]
    cor = A_CORRELATE(res,lag,/DOUBLE)
    var = VARIANCE(res)
    n = zz
    sd = var / (n^(1.5)) * ((1+cor[0])/(1-cor[0]))^(0.5)
    confi = ABS(A[0]/sd)
    print,'confidence',confi

;    if confi gt 2 then B[I,J]= A[0]*12 else B[I,J]= -999
    B[I,J]= cor

    print,X1
    print,Y1
    print,res

    CTM_CLEANUP

  endfor
endfor

print,max(B),min(B)

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
             Bits=8,          Filename='/home/gengguannan/result/AE/all_trend_cor_1x1.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset


Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = -0.2
maxdata = 1


map_temp = fltarr(InGrid.IMX,InGrid.JMX)

for I = 0,xx-1 do begin
  for J = 0,yy-1 do begin
    map_temp[I+I0,J+J0] = B[I,J]
  endfor
endfor

map = map_temp[I1:I2,J1:J2]

Myct,34

tvmap,map,                                              $
limit=limit,                                            $
/nocbar,                                                $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 5,                                         $
format = '(f6.1)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $
margin = margin,                                        $
/Sample,                                                $
title='Trend',                              $
/Quiet,/Noprint,                                        $
position=position1,                                     $
/grid, skip=1,gcolor=gcolor

   Colorbar,                                                     $
      ;Position=[ 0.10, 0.20, 0.90, 0.22],$
      Position=[ 0.1, 0.10, 0.95, 0.12],                         $
      ;Divisions=Comlorbar_NDiv( Max=9 ),                        $
      divisions = 12,                                            $
      c_colors=c_colors,C_levels=C_levels,                       $
      Min=mindata, Max=maxdata, Unit='',format = '(f4.1)',charsize=0.8
                   ;
   TopTitle = 'E+15 molec/cm2/year'

      XYOutS, 0.55, 0.03, TopTitle, $
      /Normal,                      $ ; Use normal coordinates
      Color=!MYCT.BLACK,            $ ; Set text color to black
      CharSize=0.8,                 $ ; Set text to twice normal size
      Align= 0.5                      ; Center text

   TopTitle = ''

      XYOutS, 0.5, 1.05,TopTitle,   $
      /Normal,                      $ ; Use normal coordinates
      Color=!MYCT.BLACK,            $ ; Set text color to black
      CharSize=1.4,                 $ ; Set text to twice normal size
      Align=0.5                       ; Center text

close_device

end
