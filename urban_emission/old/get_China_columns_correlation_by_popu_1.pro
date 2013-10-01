pro get_China_columns_correlation_by_popu_1

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

sum = fltarr(InGrid.IMX,InGrid.JMX)
pp = fltarr(InGrid.IMX,InGrid.JMX)
data18 = fltarr(InGrid.IMX,InGrid.JMX)
data28 = fltarr(InGrid.IMX,InGrid.JMX)

;remove grids (pp>60% & urban population<50w)
year = 2006
for Month = 6,8 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd


filename4 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch'
;filename4 = '/home/gengguannan/indir/popu/urban_popu_2010_05x0666.bpch'
;filename4 = '/home/gengguannan/indir/popu/urpopu_05x0666.bpch'

filename5 = '/home/wangsiwen/indir/GEOS_05x0666/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_ge_100MW.05x0666.bpch'
filename6 = '/home/wangsiwen/indir/GEOS_05x0666/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_lt_100MW.05x0666.bpch'
;filename5 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_power_2005.by.total.pop.05x0667.bpch'

;filename7 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_residential_2005.by.total.pop.05x0667.bpch'
;filename7 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_residential_2005.by.urban.pop.05x0667.bpch'
filename7 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/dom-2006-05x0666.bpch'

;filename8 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_industry_2005.by.total.pop.05x0667.bpch'
;filename8 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_industry_2005.by.urban.pop.05x0667.bpch'
filename8 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/ind-2006-05x0666.bpch'

;filename9 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_transportation_2005.by.total.pop.05x0667.bpch'
;filename9 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_transportation_2005.by.urban.pop.05x0667.bpch'
filename9 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/tra-2006-05x0666.bpch'



ctm_get_data,datainfo_4,filename = filename4,tracer=802
urpopu=*(datainfo_4[0].data)

;ctm_get_data,datainfo_5,filename = filename5,tau0=nymd2tau(20050101),tracer=1
;pow_year=*(datainfo_5[0].data)

ctm_get_data,datainfo_5,filename = filename5,tau0=Tau0,tracer=1
pow1=*(datainfo_5[0].data)

ctm_get_data,datainfo_6,filename = filename6,tau0=Tau0,tracer=1
pow2=*(datainfo_6[0].data)

ctm_get_data,datainfo_7,filename = filename7,tau0=Tau0,tracer=1
dom=*(datainfo_7[0].data)

ctm_get_data,datainfo_8,filename = filename8,tau0=Tau0,tracer=1
ind=*(datainfo_8[0].data)

ctm_get_data,datainfo_9,filename = filename9,tau0=Tau0,tracer=1
tra=*(datainfo_9[0].data)

pow1 += pow1
pow2 += pow2
dom += dom
ind += ind
tra += tra
;pow = pow_year * 0.2541
;dom = dom_year * 0.1332
;ind = ind_year * 0.2531
;tra = tra_year * 0.2500

endfor

;sum = pow+dom+ind+tra
sum = pow1+pow2+dom+ind+tra

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (sum[I,J] gt 0)                            $
;    then pp[I,J] = (pow[I,J])/sum[I,J] $
    then pp[I,J] = (pow1[I,J]+pow2[I,J])/sum[I,J] $
    else pp[I,J] = -999
  endfor
endfor


;filename1 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic/ctm.vc_season_JJA_'+Yr4+'_NO2.bpch'
;filename1 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.ubpower/ctm.vc_season_JJA_'+Yr4+'_NO2.bpch'
;filename1 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.plus.ubpower/ctm.vc_season_JJA_'+Yr4+'_NO2.bpch'
;filename2 = '/z3/gengguannan/satellite/no2/meic/omi_no2_seasonal_average_2005_JJA_05x0666.bpch'
filename1 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_seasonal_2006_JJA_NO2.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_JJA_05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'

;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data2=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
China_mask=*(datainfo_3[0].data)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (pp[I,J] gt 0.5) and (urpopu[I,J] lt 500000) then begin
      data18[I,J] = 0
      data28[I,J] = 0
    endif else begin
      data18[I,J] = data1[I,J]
      data28[I,J] = data2[I,J]
    endelse
  endfor
endfor

popu = make_array(1)

flag2 = 1
for I = 1,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
;    if ((China_mask[I,J] eq 1) and (data18[I,J] gt 0)) then begin
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
