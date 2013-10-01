pro get_China_columns_correlation_by_popu_2

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

year = 2006
Yr4  = String( Year, format = '(i4.4)' )

filename4 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch'
;filename4 = '/home/gengguannan/indir/popu/urban_popu_2010_05x0666.bpch'
;filename4 = '/home/gengguannan/indir/popu/urpopu_05x0666.bpch'


ctm_get_data,datainfo_4,filename = filename4,tracer=802
urpopu=*(datainfo_4[0].data)


;filename1 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic/ctm.vc_season_JJA_'+Yr4+'_NO2.bpch'
;filename1 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.ubpower/ctm.vc_season_JJA_'+Yr4+'_NO2.bpch'
;filename1 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.plus.ubpower/ctm.vc_season_JJA_'+Yr4+'_NO2.bpch'
;filename2 = '/z3/gengguannan/satellite/no2/meic/omi_no2_seasonal_average_2005_JJA_05x0666.bpch'
filename1 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_seasonal_2006_JJA_NO2.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_JJA_05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'

;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
China_mask=*(datainfo_3[0].data)

popu = make_array(1)

flag2 = 1
for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (China_mask[I,J] eq 1) and (urpopu[I,J] gt 0) and (flag2 eq 1) then begin
      popu = [urpopu[I,J]]
    endif
    if (China_mask[I,J] eq 1) and (urpopu[I,J] gt 0) and (flag2 eq 0) then begin
      popu = [popu,urpopu[I,J]]
    endif
    flag2 = 0
  endfor
endfor

print,n_elements(popu)

p = percentiles(popu,value=[0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1])
print,p


R = make_array(1)

flag1 = 1
for l = 0,20-1 do begin

  ind = WHERE( urpopu gt p[l] and urpopu le p[l+1], count )
  dims = SIZE(urpopu, /DIMENSIONS)
  p0 = ARRAY_INDICES(dims, ind, /DIMENSIONS)
  x = p0[0,0:count-1]
  y = p0[1,0:count-1]
  print,count

  m = make_array(1)
  s = make_array(1)

  flag3 = 1
  for n = 0L,count-1 do begin
    if ((China_mask[x[n],y[n]] eq 1) and (data18[x[n],y[n]] gt 0) and (data28[x[n],y[n]] gt 0)) and (flag3 eq 1) then begin
      m=[data18[x[n],y[n]]]
      s=[data28[x[n],y[n]]]
    endif
    if ((China_mask[x[n],y[n]] eq 1) and (data18[x[n],y[n]] gt 0) and (data28[x[n],y[n]] gt 0)) and (flag3 eq 0) then begin
      m=[m,data18[x[n],y[n]]]
      s=[s,data28[x[n],y[n]]]
    endif
    flag3 = 0
  endfor
 
;print,m,s
 
  d = n_elements(m)
  print,'**********Correlation of model and satellite**********'
  r = CORRELATE(s, m)
  print,r[0]
  coeff = LINFIT(s, m)
  if (flag1 eq 1) then begin
      R = [r[0]]
      B = [coeff[1]]
  endif
  if (flag1 eq 0) then begin
      R = [R,r[0]]            
      B = [B,coeff[1]]
  endif

  flag1 = 0

endfor
  
print, R, B

;v = [0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1]
  plot,/XLOG, p[1:20], B, psym=7, SYMSIZE=1,       $
;  plot, v[1:20], B, psym=7, SYMSIZE=1,       $
;  TITLE='Tropospheric NO2 columns',       $
  XTITLE='population',                    $
  YTITLE='Slope'
;  XRANGE = [0,range[l]],YRANGE = [0,range[l]]
;  oplot, popu, B, psym=5, SYMSIZE=1

;  SCREEN2JPG, 'myplot_'+name[l]+'.jpg'

end
