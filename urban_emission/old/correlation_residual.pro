pro correlation_residual

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, Nymd2Tau

CTM_CleanUp

for k = 0,7 do begin
k1 = String( k, format='(i1.1)')

filename0 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'
filename1 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x0666.bpch'
filename2 = '/z3/gengguannan/outdir/ur_emiss/inverse_2005-2007_JJA_NO2.scenario'+ k1 +'.05x0666.bpch'
;filename2 = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.month.05x0666.power.plant.bpch'

ctm_get_data,datainfo_0,filename = filename0,tracer=802
mask=*(datainfo_0[0].data)

ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)


InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


;limit = [35,104,41,114]
;limit = [30,114,45,122]
;limit = [40,120,50,135]
;limit = [25,97,33,110]
;limit = [20,110,30,123]
limit = [15,70,55,150]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2


s = make_array(1)
m = make_array(1)

flag = 1
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (data18[I,J] gt 1) and (data28[I,J] gt 1) and (mask[I,J] gt 0) then begin
      if flag eq 1 then begin
        s = [data18[I,J]]
        m = [data28[I,J]]
      endif else begin
        s = [s,data18[I,J]]
        m = [m,data28[I,J]]
      endelse
    endif
    flag = 0
  endfor
endfor



print,'******Correlation of model and satellite******'

print,'sample number =', N_ELEMENTS(s)
print,'R =', CORRELATE(s, m)
coeff = LINFIT(s, m)
;print,'A = ',coeff[0]
print,'B = ',coeff[1]
print,'s = ',mean(s)
print,'m = ',mean(m)

plot,s,m

yfit = coeff[0] + coeff[1]*s
res = m - yfit

yfit_ = fltarr(InGrid.IMX,InGrid.JMX)
res_ = fltarr(InGrid.IMX,InGrid.JMX)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (data18[I,J] gt 1) and (data28[I,J] gt 1) and (mask[I,J] gt 0) then begin
      yfit_[I,J] = coeff[0] + coeff[1]*data18[I,J]
      res_[I,J] = data28[I,J] - yfit_[I,J]
    endif
  endfor
endfor

sum_square = 0
for n = 0,n_elements(res)-1 do begin
  sum_square = sum_square + res[n]^2
endfor

std_res = (sum_square / (n_elements(res)-1))^0.5

print,'sum_square = ',sum_square
print,'std_res = ',std_res

endfor


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
             Bits=8,          Filename='/home/gengguannan/result/ur_emiss/residual.ps', $
             /portrait,       /Inches,              $
             XSize=XSize,     YSize=YSize,          $
             XOffset=XOffset, YOffset=YOffset

Margin=[ 0.06, 0.02, 0.02, 0.02 ]
gcolor= 1
mindata = -2.2
maxdata = 2.2

Myct,22

data818 = res_[I1:I2,J1:J2]

tvmap,data818,                                          $
limit=limit,                                            $
/cbar,                                                  $
mindata = mindata,                                      $
maxdata = maxdata,                                      $
cbmin = mindata, cbmax = maxdata,                       $
divisions = 12,                                          $
format = '(f6.1)',                                      $
cbposition = [0 , 0.03, 1.0, 0.06 ],                    $
/countries,/continents,/Coasts,                         $
/CHINA,                                                 $   
margin = margin,                                        $
/Sample,                                                $   
title='residual',                                       $
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

close_device

end
