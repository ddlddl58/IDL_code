pro print_industry_data

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

filename1 = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.month.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x0666.bpch'
filename3 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch'
filename4 = '/home/gengguannan/indir/GDP_2005-2007_05x0666.bpch'

;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data2=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
data3=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=802
data4=*(datainfo_4[0].data)


sum = fltarr(InGrid.IMX,InGrid.JMX)
pp = fltarr(InGrid.IMX,InGrid.JMX)


;remove grids (pp>60% & urban population<50w)
for Year = 2005,2007 do begin

Yr4 = string( Year, format = '(i4.4)')

filename5 = '/home/wangsiwen/indir/GEOS_05x0666/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_ge_100MW.05x0666.bpch'
filename6 = '/home/wangsiwen/indir/GEOS_05x0666/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_lt_100MW.05x0666.bpch'
filename7 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/dom-'+Yr4+'-05x0666.bpch'
filename8 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/ind-'+Yr4+'-05x0666.bpch'
filename9 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/tra-'+Yr4+'-05x0666.bpch'
filename10 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'


for Month = 6,8 do begin

Mon2 = string( Month, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd


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

ctm_get_data,datainfo_10,filename = filename10,tracer=802
mask=*(datainfo_10[0].data)

pow1 += pow1
pow2 += pow2
dom += dom
ind += ind
tra += tra

endfor
endfor

sum = pow1+pow2+dom+ind+tra

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (sum[I,J] gt 0)                            $
    then pp[I,J] = ind[I,J]/sum[I,J] $
    else pp[I,J] = -999
  endfor
endfor



GC_2006 = make_array(1)
OMI_2006 = make_array(1)
popu = make_array(1)
GDP = make_array(1)
I_index = make_array(1)
J_index = make_array(1)


flag = 1
for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (mask[I,J] gt 0) and (pp[I,J] gt 0.5) and (flag eq 1) then begin
      GC_2006 = [data1[I,J]]
      OMI_2006 = [data2[I,J]]
      popu = [data3[I,J]]
      GDP = [data4[I,J]]
    endif
    if (mask[I,J] gt 0) and (pp[I,J] gt 0.5) and (flag eq 0) then begin
      GC_2006 = [GC_2006,data1[I,J]]
      OMI_2006 = [OMI_2006,data2[I,J]]
      popu = [popu,data3[I,J]]
      GDP = [GDP,data4[I,J]]
    endif
    flag = 0
  endfor
endfor


outfile = '/home/gengguannan/result/ur_emiss/ind.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, GC_2006, 'GC_2006',          $
           Longname='model',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, OMI_2006, 'OMI_2006',          $
           Longname='satellite', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, popu, 'popu',  $
           Longname='popu',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, GDP, 'GDP',  $
           Longname='GDP',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SD_End, FID

end
