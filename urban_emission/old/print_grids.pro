pro print_grids

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
filename5 = '/home/gengguannan/indir/power_plant_emission/bpch/Power_Plant_NOx_emission_2006_month_ge_100MW_05x0666.bpch'
filename6 = '/home/gengguannan/indir/power_plant_emission/bpch/Power_Plant_NOx_emission_2006_month_lt_100MW_05x0666.bpch'
filename7 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/dom-2006-05x0666.bpch'
filename8 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/ind-2006-05x0666.bpch'
filename9 = '/home/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/tra-2006-05x0666.bpch'


ctm_get_data,datainfo_4,filename = filename4,tau0=nymd2tau(20061231),tracer=802
popu=*(datainfo_4[0].data)

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

endfor

sum = pow1+pow2+dom+ind+tra

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (sum[I,J] gt 0)                            $
    then pp[I,J] = (pow1[I,J]+pow2[I,J])/sum[I,J] $
    else pp[I,J] = -999
  endfor
endfor


;filename1 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_annual_2006_NO2.05x0666.power.plant.bpch'
;filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_annual_average_2006_05x0666.bpch'
filename1 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_seasonal_2006_JJA_NO2.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_JJA_05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'

;Get data
ctm_get_data,datainfo_1,filename = filename1,tau0=nymd2tau(20060831),tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tau0=nymd2tau(20060831),tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tau0=nymd2tau(19850101),tracer=802
China_mask=*(datainfo_3[0].data)


;for I = 0,InGrid.IMX-1 do begin
;  for J = 0,InGrid.JMX-1 do begin
;    if (pp[I,J] gt 0.5) and (popu[I,J] lt 500000) then begin
;      data18[I,J] = 0
;      data28[I,J] = 0
;    endif else begin
;      data18[I,J] = data1[I,J]
;      data28[I,J] = data2[I,J]
;    endelse
;  endfor
;endfor

data818 = make_array(1)
data828 = make_array(1)
popu1 = make_array(1)
pp1 = make_array(1)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if ((China_mask[I,J] eq 1) and (data18[I,J] gt 0) and (data28[I,J] gt 0)) then begin
    data818 = [data818,data18[I,J]]
    data828 = [data828,data28[I,J]]
    popu1 = [popu1,popu[I,J]]
    pp1 = [pp1,pp[I,J]]
    endif
  endfor
endfor

;print,data818
;print,data828
print,popu1
;print,pp1

end
