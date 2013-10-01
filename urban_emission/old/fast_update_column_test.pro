pro fast_update_column_test

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all

pow = fltarr(InGrid.IMX,InGrid.JMX)
Ea = fltarr(InGrid.IMX,InGrid.JMX)
no2_t = fltarr(InGrid.IMX,InGrid.JMX)
avg_no2 = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)


;Ea
filename1 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_2006_month_ge_100MW.05x0666.bpch'
filename2 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_2006_month_lt_100MW.05x0666.bpch'
filename3 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_res_2006.geos5.05x0666'
filename4 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_ind_2006.geos5.05x0666'
filename5 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_tra_2006.geos5.05x0666'

;Et
filename6 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_pow_2006.geos5.05x0666'
filename7 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_res_2006.geos5.05x0666'
filename8 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_ind_2006.geos5.05x0666'
filename9 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_tra_2006.geos5.05x0666'


for Month = 6,8 do begin
nymd = 2006 * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

ctm_get_data,datainfo_1,filename = filename1,tau0=Tau0,tracer=1
pow1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tau0=Tau0,tracer=1
pow2=*(datainfo_2[0].data)

pow_temp = pow1 + pow2
print,total(pow_temp)
pow += pow_temp

CTM_Cleanup
endfor

ctm_get_data,datainfo_3,filename = filename3,tracer=1
dom_a=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=1
ind_a=*(datainfo_4[0].data)

ctm_get_data,datainfo_5,filename = filename5,tracer=1
tra_a=*(datainfo_5[0].data)

print,total(dom_a),total(ind_a),total(tra_a)
Ea = pow + dom_a*0.1332 + ind_a*0.2531 + tra_a*0.2500



ctm_get_data,datainfo_6,filename = filename6,tracer=1
pow_t=*(datainfo_6[0].data)

ctm_get_data,datainfo_7,filename = filename7,tracer=1
dom_t=*(datainfo_7[0].data)

ctm_get_data,datainfo_8,filename = filename8,tracer=1
ind_t=*(datainfo_8[0].data)

ctm_get_data,datainfo_9,filename = filename9,tracer=1
tra_t=*(datainfo_9[0].data)

print,total(dom_t),total(ind_t),total(tra_t)
Et = pow_t*0.2541 + dom_t*0.1332 + ind_t*0.2531 + tra_t*0.2500

Ea = Ea/3
Et = Et/3
print,total(Ea),total(Et)

filename9 = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2006_JJA_NO2.month.05x0666.power.plant.bpch'

ctm_get_data,datainfo_9,filename = filename9,tracer=1
no2_a=*(datainfo_9[0].data)

print,max(no2_a,min=min),min,mean(no2_a)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if Ea[I,J] gt 0 $
      then no2_t[I,J] = (Et[I,J]/Ea[I,J])*no2_a[I,J] $
      else no2_t[I,J] = -999
  endfor
endfor

print,max(no2_t,min=min),min,mean(no2_t)

CTM_Cleanup

outfile = '/z3/gengguannan/outdir/ur_emiss/inverse_2006_JJA_NO2.test.05x0666.bpch'

   success = CTM_Make_DataInfo( no2_t,                 $
                                ThisDataInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='IJ-AVG-$',        $
                                Tracer=1,                $
                                Tau0= nymd2tau(20050101),$
                                Unit='E+15molec/cm2',    $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],      $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = outfile

end
