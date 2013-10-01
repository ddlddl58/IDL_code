pro get_China_columns_correlation_by_popu

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
year = 2005
for Month = 6,8 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd


;filename4 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch.bpch'
filename4 = '/home/gengguannan/indir/popu/urban_popu_2010_05x0666.bpch'

filename5 = '/home/wangsiwen/indir/GEOS_05x0666/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_ge_100MW.05x0666.bpch'
filename6 = '/home/wangsiwen/indir/GEOS_05x0666/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_lt_100MW.05x0666.bpch'
;filename5 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_power_2005.by.total.pop.05x0667.bpch'

;filename7 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_residential_2005.by.total.pop.05x0667.bpch'
filename7 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_residential_2005.by.urban.pop.05x0667.bpch'

;filename8 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_industry_2005.by.total.pop.05x0667.bpch'
filename8 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_industry_2005.by.urban.pop.05x0667.bpch'

;filename9 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_transportation_2005.by.total.pop.05x0667.bpch'
filename9 = '/home/wangsiwen/outdir/Qiang_allocation/F_NOx_transportation_2005.by.urban.pop.05x0667.bpch'


ctm_get_data,datainfo_4,filename = filename4,tracer=802
popu=*(datainfo_4[0].data)

;ctm_get_data,datainfo_5,filename = filename5,tau0=nymd2tau(20050101),tracer=1
;pow_year=*(datainfo_5[0].data)

ctm_get_data,datainfo_5,filename = filename5,tau0=Tau0,tracer=1
pow1=*(datainfo_5[0].data)

ctm_get_data,datainfo_6,filename = filename6,tau0=Tau0,tracer=1
pow2=*(datainfo_6[0].data)

ctm_get_data,datainfo_7,filename = filename7,tau0=nymd2tau(20050101),tracer=1
dom_year=*(datainfo_7[0].data)

ctm_get_data,datainfo_8,filename = filename8,tau0=nymd2tau(20050101),tracer=1
ind_year=*(datainfo_8[0].data)

ctm_get_data,datainfo_9,filename = filename9,tau0=nymd2tau(20050101),tracer=1
tra_year=*(datainfo_9[0].data)

pow1 += pow1
pow2 += pow2
;pow = pow_year * 0.2541
dom = dom_year * 0.1332
ind = ind_year * 0.2531
tra = tra_year * 0.2500

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
filename1 = '/z3/gengguannan/GEOS_Chem/v9-01-01.standard.geos5.05x0667.meic.plus.ubpower/ctm.vc_season_JJA_'+Yr4+'_NO2.bpch'
filename2 = '/z3/gengguannan/satellite/no2/meic/omi_no2_seasonal_average_2005_JJA_05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'

;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data2=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tau0=nymd2tau(19850101),tracer=802
China_mask=*(datainfo_3[0].data)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (pp[I,J] gt 0.5) then begin
      data18[I,J] = 0
      data28[I,J] = 0
    endif else begin
      data18[I,J] = data1[I,J]
      data28[I,J] = data2[I,J]
    endelse
  endfor
endfor


;regions divided by popu
limit = [-1,200000,500000,1000000,5000000]
name = ['1','2','3','4']
range = [10,10,10,15]

for l=0,3 do begin
;  l=0
  ind = WHERE( popu gt limit[l] and popu le limit[l+1], count )
  dims = SIZE(popu, /DIMENSIONS)
  p = ARRAY_INDICES(dims, ind, /DIMENSIONS)
  x = p[0,0:count-1]
  y = p[1,0:count-1]
  print,count

  m = make_array(1)
  s = make_array(1)

  for n = 0L,count-1 do begin
    if ((China_mask[x[n],y[n]] eq 1) and (data18[x[n],y[n]] gt 0) and (data28[x[n],y[n]] gt 0)) then begin
      m=[m,data18[x[n],y[n]]]
      s=[s,data28[x[n],y[n]]]
    endif
  endfor
  


  d = n_elements(m)
  print,'**********Correlation of model and satellite**********'
  print,'R =', CORRELATE(s[1:d-1], m[1:d-1])
  coeff = LINFIT(s[1:d-1], m[1:d-1])
  print,'sample number =', N_ELEMENTS(s[1:d-1])
  print,'A,B = ', coeff
  print,'s =', mean(s[1:d-1]),'m =', mean(m[1:d-1])

  YFIT = coeff[0] + coeff[1]*s[1:d-1]
  plot, s[1:d-1], m[1:d-1],psym=7,SYMSIZE=1,       $
  TITLE='Tropospheric NO2 columns',            $
  XTITLE='OMI-2006(E+15 molec/cm2)',           $
  YTITLE='GEOS_Chem(E+15 molec/cm2)',          $
  XRANGE = [0,range[l]],YRANGE = [0,range[l]]
  oplot, s[1:d-1], YFIT,linestyle=1

  SCREEN2JPG, 'myplot_'+name[l]+'.jpg'

endfor
end
