pro compare_emission

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Year = 2006
Yr4 = string( Year, format = '(i4.4)')

pow1 = fltarr(InGrid.IMX,InGrid.JMX)
dom1 = fltarr(InGrid.IMX,InGrid.JMX)
ind1 = fltarr(InGrid.IMX,InGrid.JMX)
tra1 = fltarr(InGrid.IMX,InGrid.JMX)
sum1 = fltarr(InGrid.IMX,InGrid.JMX)
pow2 = fltarr(InGrid.IMX,InGrid.JMX)
dom2 = fltarr(InGrid.IMX,InGrid.JMX)
ind2 = fltarr(InGrid.IMX,InGrid.JMX)
tra2 = fltarr(InGrid.IMX,InGrid.JMX)
sum2 = fltarr(InGrid.IMX,InGrid.JMX)


;intex-b
filename1 = '/home/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_ge_100MW.05x0666.bpch'
filename2 = '/home/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_lt_100MW.05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/dom-'+Yr4+'-05x0666.bpch'
filename4 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/ind-'+Yr4+'-05x0666.bpch'
filename5 = '/home/gengguannan/indir/China_NOx_Emissions/bpch/tra-'+Yr4+'-05x0666.bpch'

;meic
filename6 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_pow_'+Yr4+'.05x0666'
filename7 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_res_'+Yr4+'.05x0666'
filename8 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_ind_'+Yr4+'.05x0666'
filename9 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_tra_'+Yr4+'.05x0666'

for Month = 1,12 do begin
Mon2 = string( Month, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

ctm_get_data,datainfo_1,filename = filename1,tau0=Tau0,tracer=1
pow1_temp1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tau0=Tau0,tracer=1
pow1_temp2=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tau0=Tau0,tracer=1
dom1_temp=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tau0=Tau0,tracer=1
ind1_temp=*(datainfo_4[0].data)

ctm_get_data,datainfo_5,filename = filename5,tau0=Tau0,tracer=1
tra1_temp=*(datainfo_5[0].data)

ctm_get_data,datainfo_6,filename = filename6,tau0=Tau0,tracer=1
pow2_temp=*(datainfo_6[0].data)

ctm_get_data,datainfo_7,filename = filename7,tau0=Tau0,tracer=1
dom2_temp=*(datainfo_7[0].data)

ctm_get_data,datainfo_8,filename = filename8,tau0=Tau0,tracer=1
ind2_temp=*(datainfo_8[0].data)

ctm_get_data,datainfo_9,filename = filename9,tau0=Tau0,tracer=1
tra2_temp=*(datainfo_9[0].data)

pow1_temp = pow1_temp1 + pow1_temp2
sum1_temp = pow1_temp + dom1_temp + ind1_temp + tra1_temp
sum2_temp = pow2_temp + dom2_temp + ind2_temp + tra2_temp

pow1 += pow1_temp
dom1 += dom1_temp
ind1 += ind1_temp
tra1 += tra1_temp
sum1 += sum1_temp
pow2 += pow2_temp
dom2 += dom2_temp
ind2 += ind2_temp
tra2 += tra2_temp
sum2 += sum2_temp

CTM_Cleanup

endfor

print,'intex-b',total(sum1),total(pow1),total(dom1),total(ind1),total(tra1)
print,'meic',total(sum2),total(pow2),total(dom2),total(ind2),total(tra2)

;scaled_intex-b
filename10 = '/home/gengguannan/indir/intexb_scaled/NOx_res_2006.05x0666'
filename11 = '/home/gengguannan/indir/intexb_scaled/NOx_ind_2006.05x0666'
filename12 = '/home/gengguannan/indir/intexb_scaled/NOx_tra_2006.05x0666'

ctm_get_data,datainfo_10,filename = filename10,tracer=1
dom3=*(datainfo_10[0].data)

ctm_get_data,datainfo_11,filename = filename11,tracer=1
ind3=*(datainfo_11[0].data)

ctm_get_data,datainfo_12,filename = filename12,tracer=1
tra3=*(datainfo_12[0].data)

pow3 = pow2
sum3 = pow3 + dom3 + ind3 + tra3

print,'scaled_intex-b',total(sum3),total(pow3),total(dom3),total(ind3),total(tra3)


;mask file
;filename13 = '/home/gengguannan/indir/mask/China_mask.geos5.v3.05x0666'
filename13 = '/public/geos/GEOS_0.5x0.666_CH/Streets_200607/China_mask.geos5.05x0666'
filename14 = '/home/gengguannan/indir/mask/region_mask_05x0666.bpch'

ctm_get_data,datainfo_13,filename = filename13,tracer=802
China_mask=*(datainfo_13[0].data)

ctm_get_data,datainfo_14,filename = filename14,tracer=802
region=*(datainfo_14[0].data)


;other files
filename15 = '/home/gengguannan/indir/parameter/totalpopu_05x0666.bpch'
filename16 = '/home/gengguannan/indir/parameter/GDP_'+Yr4+'_05x0666.bpch'
filename17 = '/home/gengguannan/work/ur_emiss/satellite/omi_v2_dpgc_no2_seasonal_average_2006_JJA_05x0666.bpch'

ctm_get_data,datainfo_15,filename = filename15,tracer=802
popu=*(datainfo_15[0].data)

ctm_get_data,datainfo_16,filename = filename16,tracer=802
gdp=*(datainfo_16[0].data)

ctm_get_data,datainfo_17,filename = filename17,tracer=1
no2=*(datainfo_17[0].data)


;print data
pow_intex = make_array(1)
dom_intex = make_array(1)
ind_intex = make_array(1)
tra_intex = make_array(1)
sum_intex = make_array(1)
pow_meic = make_array(1)
dom_meic = make_array(1)
ind_meic = make_array(1)
tra_meic = make_array(1)
sum_meic = make_array(1)
pow_scaled_intex = make_array(1)
dom_scaled_intex = make_array(1)
ind_scaled_intex = make_array(1)
tra_scaled_intex = make_array(1)
sum_scaled_intex = make_array(1)
mask = make_array(1)
totalpopu = make_array(1)
gdpdata = make_array(1)
omi_no2 = make_array(1)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if China_mask[I,J] gt 0 then begin
      pow_intex = [pow_intex,pow1[I,J]]
      dom_intex = [dom_intex,dom1[I,J]]
      ind_intex = [ind_intex,ind1[I,J]]
      tra_intex = [tra_intex,tra1[I,J]]
      sum_intex = [sum_intex,sum1[I,J]]
      pow_meic = [pow_meic,pow2[I,J]]
      dom_meic = [dom_meic,dom2[I,J]]
      ind_meic = [ind_meic,ind2[I,J]]
      tra_meic = [tra_meic,tra2[I,J]]
      sum_meic = [sum_meic,sum2[I,J]]
      pow_scaled_intex = [pow_scaled_intex,pow3[I,J]]
      dom_scaled_intex = [dom_scaled_intex,dom3[I,J]]
      ind_scaled_intex = [ind_scaled_intex,ind3[I,J]]
      tra_scaled_intex = [tra_scaled_intex,tra3[I,J]]
      sum_scaled_intex = [sum_scaled_intex,sum3[I,J]]
      mask = [mask,region[I,J]]
      totalpopu = [totalpopu,popu[I,J]]
      gdpdata = [gdpdata,gdp[I,J]]
      omi_no2 = [omi_no2,no2[I,J]]
    endif
  endfor
endfor


outfile = '/home/gengguannan/work/ur_emiss/result/emissions.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, pow_intex, 'pow_intex',  $
           Longname='pow_intex',         $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, dom_intex, 'dom_intex',  $
           Longname='dom_intex',         $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, ind_intex, 'ind_intex',  $
           Longname='ind_intex',         $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, tra_intex, 'tra_intex',  $
           Longname='tra_intex',         $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, sum_intex, 'sum_intex',  $
           Longname='sum_intex',         $
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, pow_meic, 'pow_meic',  $
           Longname='pow_meic',        $
           Unit='unitless',            $ 
           FILL=-999.0
HDF_SETSD, FID, dom_meic, 'dom_meic',  $
           Longname='dm_meic',         $
           Unit='unitless',            $
           FILL=-999.0
HDF_SETSD, FID, ind_meic, 'ind_meic',  $
           Longname='ind_meic',        $
           Unit='unitless',            $
           FILL=-999.0
HDF_SETSD, FID, tra_meic, 'tra_meic',  $
           Longname='tra_meic',        $
           Unit='unitless',            $
           FILL=-999.0
HDF_SETSD, FID, sum_meic, 'sum_meic',  $
           Longname='sum_meic',        $
           Unit='unitless',            $
           FILL=-999.0
HDF_SETSD, FID, pow_scaled_intex, 'pow_scaled_intex',  $
           Longname='pow_scaled_intex',                $
           Unit='unitless',                            $
           FILL=-999.0
HDF_SETSD, FID, dom_scaled_intex, 'dom_scaled_intex',  $
           Longname='dom_scaled_intex',                $
           Unit='unitless',                            $
           FILL=-999.0
HDF_SETSD, FID, ind_scaled_intex, 'ind_scaled_intex',  $
           Longname='ind_scaled_intex',                $
           Unit='unitless',                            $
           FILL=-999.0
HDF_SETSD, FID, tra_scaled_intex, 'tra_scaled_intex',  $
           Longname='tra_scaled_intex',                $
           Unit='unitless',                            $
           FILL=-999.0
HDF_SETSD, FID, sum_scaled_intex, 'sum_scaled_intex',  $
           Longname='sum_scaled_intex',                $
           Unit='unitless',                            $
           FILL=-999.0
HDF_SETSD, FID, mask, 'mask',  $
           Longname='mask',    $
           Unit='unitless',    $
           FILL=-999.0
HDF_SETSD, FID, totalpopu, 'totalpopu',  $
           Longname='totalpopu',         $ 
           Unit='unitless',              $
           FILL=-999.0
HDF_SETSD, FID, gdpdata, 'gdpdata',  $
           Longname='gdpdata',       $
           Unit='unitless',          $
           FILL=-999.0
HDF_SETSD, FID, omi_no2, 'omi_no2',  $
           Longname='omi_no2',       $
           Unit='unitless',          $
           FILL=-999.0
HDF_SD_End, FID





end
