pro correlation_scenario_filter

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, Nymd2Tau

CTM_CleanUp

InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


powfile1 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_2006_month_ge_100MW.05x0666.bpch'
powfile2 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_2006_month_lt_100MW.05x0666.bpch'

pow = fltarr(InGrid.IMX,InGrid.JMX)

for m = 6,8 do begin
nymd = 2006 * 10000L + M * 100L + 1L
tau0 = nymd2tau(nymd)

ctm_get_data,datainfo1,filename = powfile1,tracer=1,tau0 = tau0
pow1=*(datainfo1[0].data)

ctm_get_data,datainfo2,filename = powfile2,tracer=1,tau0 = tau0
pow2=*(datainfo2[0].data)

temp = pow1 + pow2
pow =+ temp

endfor

pow_temp = pow[where(pow gt 0)]
r = percentiles( pow_temp,value = 0.95)
print,r

for k = 0,8 do begin
k1 = String( k, format='(i1.1)')

filename0 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'
filename1 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2006_JJA_05x0666.bpch'
filename2 = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2006_JJA_NO2.s'+ k1 +'.05x0666.bpch'
;filename2 = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.month.05x0666.power.plant.bpch'

ctm_get_data,datainfo_0,filename = filename0,tracer=802
mask=*(datainfo_0[0].data)

ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)


;limit = [35,104,41,114]
;limit = [30,114,45,122]
;limit = [40,120,50,135]
;limit = [25,97,33,110]
;limit = [20,110,30,123]

limit = [15,70,55,150]


ind_i = where(xmid lt limit[1] or xmid gt limit[3])
ind_j = where(ymid lt limit[0] or ymid gt limit[2])

data18[ind_i,*] = -999
data28[*,ind_j] = -999


s = make_array(1)
m = make_array(1)

ind_ok = where( data18 gt -999 and data28 gt -999 and mask gt 0 and pow le r)
s = data18(ind_ok)
m = data28(ind_ok)


print,'******Correlation of model and satellite******'

print,'sample number =', N_ELEMENTS(s)
print,'R =', CORRELATE(s, m)
coeff = LINFIT(s, m)
;print,'A = ',coeff[0]
print,'B = ',coeff[1]
print,'s = ',mean(s)
print,'m = ',mean(m)

;plot,s,m,psym=7,SYMSIZE=1

outfile = '/home/gengguannan/result/ur_emiss/scenario'+ k1 +'.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, s, 'OMI',         $
           Longname='satellite',  $
           Unit='unitless',       $
           FILL=-999.0
HDF_SETSD, FID, m, 'GC',          $
           Longname='model',      $
           Unit='unitless',       $
           FILL=-999.0
HDF_SD_End, FID

endfor

end
