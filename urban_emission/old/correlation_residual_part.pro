pro correlation_residual_part

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, Nymd2Tau

CTM_CleanUp

for k = 0,8 do begin
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

limit = [35,104,41,114]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

for I = I1,I2 do begin
  for J = J1,J2 do begin
    data18[I,J] = 0
    data28[I,J] = 0
  endfor
endfor

s = make_array(1)
m = make_array(1)

flag = 1
for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
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

endfor

end
