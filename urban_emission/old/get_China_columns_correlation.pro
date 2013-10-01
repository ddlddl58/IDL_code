pro get_China_columns_correlation,p

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau, CTM_WriteBpch

CTM_CleanUp

;filename1 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_seasonal_2006_JJA_NO2.05x0666.power.plant.bpch'
filename1 = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.month.05x05.power.plant.bpch'
;filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_JJA_05x0666.bpch'
filename2 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x05.bpch'
;filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'
filename3 = '/home/gengguannan/indir/province_mask_05x05.bpch'
;filename4 = '/home/gengguannan/indir/urban_mask_05x0666_v2.bpch'


;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
China_mask=*(datainfo_3[0].data)

;ctm_get_data,datainfo_4,filename = filename4,tracer=802
;urban_mask=*(datainfo_4[0].data)


;InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

limit = [15,74,54,135]
;limit = [33,110,38,118]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

k = 10000L*p
m = make_array(1)
s = make_array(1)
n = 0

;for I = 0,InGrid.IMX-1 do begin
;  for J = 0,InGrid.JMX-1 do begin
for I = I1,I2 do begin
  for J = J1,J2 do begin
   if ((China_mask[I,J] eq k) and (data18[I,J] gt 0) and (data28[I,J] gt 0)) then begin
        m=[m,data18[I,J]]
        s=[s,data28[I,J]]
        n+=1
    endif
  endfor
endfor

print,n

@plot01
print,'**********Correlation of model and satellite**********'
print,'R =', CORRELATE(s[1:n], m[1:n])
coeff = LINFIT(s[1:n], m[1:n])  
print,'sample number =', N_ELEMENTS(s[1:n])
print,'A,B = ', coeff
print,'s =', median(s[1:n]),'m =', median(m[1:n])

YFIT = coeff[0] + coeff[1]*s[1:n]
plot, s[1:n], m[1:n],psym=7,SYMSIZE=1,       $
TITLE='Tropospheric NO2 columns',            $
XTITLE='OMI-2006(E+15 molec/cm2)',           $  
YTITLE='GEOS_Chem(E+15 molec/cm2)'  

oplot, s[1:n], YFIT,linestyle=1
end
