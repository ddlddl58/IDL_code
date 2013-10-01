pro fast_update_column

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

pow_fac = [0.8991,1,1.062]
ind_fac = [0.7593,1,1.200]
tra_fac = [0.8547,1,1.179]

for Year = 2005,2007 do begin

Yr4 = string( Year, format = '(i4.4)')


;Ea
filename1 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_ge_100MW.05x0666.bpch'
filename2 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_'+Yr4+'_month_lt_100MW.05x0666.bpch'
filename3 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_res_2006.geos5.05x0666'
filename4 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_ind_2006.geos5.05x0666'
filename5 = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200812/Streets_NOx_tra_2006.geos5.05x0666'

;Et
;%%%%%base scenario%%%%%
;filename6 = '/z3/gengguannan/indir/ur_emission/pow_total_05x0666.bpch'
;filename7 = '/z3/gengguannan/indir/ur_emission/dom_total_05x0666.bpch'
;filename8 = '/z3/gengguannan/indir/ur_emission/ind_total_05x0666.bpch'
;filename9 = '/z3/gengguannan/indir/ur_emission/tra_total_05x0666.bpch'

;%%%%%scenario1%%%%%
filename7 = '/z3/gengguannan/indir/ur_emission/dom_total_05x0666.bpch'
filename8 = '/z3/gengguannan/indir/ur_emission/ind_urban_05x0666.bpch'
filename9 = '/z3/gengguannan/indir/ur_emission/tra_total_05x0666.bpch'

;%%%%%scenario2%%%%%
;filename6 = '/z3/gengguannan/indir/ur_emission/pow_total_05x0666.bpch'
;filename7 = '/z3/gengguannan/indir/ur_emission/dom_total_05x0666.bpch'
;filename8 = '/z3/gengguannan/indir/ur_emission/ind_urban_05x0666.bpch'
;filename9 = '/z3/gengguannan/indir/ur_emission/tra_total_05x0666.bpch'

;%%%%%scenario3%%%%%
;filename6 = '/z3/gengguannan/indir/ur_emission/pow_total_05x0666.bpch'
;filename7 = '/z3/gengguannan/indir/ur_emission/dom_total_05x0666.bpch'
;filename8 = '/z3/gengguannan/indir/ur_emission/ind_iGDP_05x0666.bpch'
;filename9 = '/z3/gengguannan/indir/ur_emission/tra_total_05x0666.bpch'

;%%%%%scenario4%%%%%
;filename6 = '/z3/gengguannan/indir/ur_emission/pow_total_05x0666.bpch'
;filename7 = '/z3/gengguannan/indir/ur_emission/dom_total_05x0666.bpch'
;filename8 = '/z3/gengguannan/indir/ur_emission/ind_total_05x0666.bpch'
;filename9 = '/z3/gengguannan/indir/ur_emission/tra_road_05x0666.bpch'

;%%%%%scenario5%%%%%
;filename6 = '/z3/gengguannan/indir/ur_emission/pow_total_05x0666.bpch'
;filename7 = '/z3/gengguannan/indir/ur_emission/dom_total_05x0666.bpch'
;filename8 = '/z3/gengguannan/indir/ur_emission/ind_total_05x0666.bpch'
;filename9 = '/z3/gengguannan/indir/ur_emission/tra_roadxpopu_05x0666.bpch'

;%%%%%scenario6%%%%%
;filename6 = '/z3/gengguannan/indir/ur_emission/pow_total_05x0666.bpch'
;filename7 = '/z3/gengguannan/indir/ur_emission/dom_urban_05x0666.bpch'
;filename8 = '/z3/gengguannan/indir/ur_emission/ind_total_05x0666.bpch'
;filename9 = '/z3/gengguannan/indir/ur_emission/tra_total_05x0666.bpch'

;%%%%%scenario7%%%%%
;filename6 = '/z3/gengguannan/indir/ur_emission/pow_total_05x0666.bpch'
;filename7 = '/z3/gengguannan/indir/ur_emission/dom_rural_05x0666.bpch'
;filename8 = '/z3/gengguannan/indir/ur_emission/ind_total_05x0666.bpch'
;filename9 = '/z3/gengguannan/indir/ur_emission/tra_total_05x0666.bpch'


for Month = 6,8 do begin
nymd = Year * 10000L + Month * 100L + 1 * 1L
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
Ea = pow + dom_a*0.1332 + ind_a*0.2531*ind_fac[year-2005] + tra_a*0.2500*tra_fac[year-2005]


;ctm_get_data,datainfo_6,filename = filename6,tracer=1
;pow_t=*(datainfo_6[0].data)

ctm_get_data,datainfo_7,filename = filename7,tracer=1
dom_t=*(datainfo_7[0].data)

ctm_get_data,datainfo_8,filename = filename8,tracer=1
ind_t=*(datainfo_8[0].data)

ctm_get_data,datainfo_9,filename = filename9,tracer=1
tra_t=*(datainfo_9[0].data)

print,total(dom_t),total(ind_t),total(tra_t)
;Et = pow_t*0.2541*pow_fac[year-2005] + dom_t*0.1332 + ind_t*0.2531*ind_fac[year-2005] + tra_t*0.2500*tra_fac[year-2005]
Et = pow + dom_t*0.1332 + ind_t*0.2531*ind_fac[year-2005] + tra_t*0.2500*tra_fac[year-2005]

Ea = Ea/3
Et = Et/3
print,total(Ea),total(Et)

filename9 = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_'+Yr4+'_JJA_NO2.month.05x0666.power.plant.bpch'

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

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if no2_t[I,J] ge 0 then begin
      avg_no2[I,J] += no2_t[I,J]
      nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor

print,max(nod,min=min),min,mean(nod)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
      then avg_no2[I,J] /= nod[I,J]  $
      else avg_no2[I,J] = 0
  endfor
endfor

print,max(avg_no2,min=min),min,mean(avg_no2)


outfile = '/z3/gengguannan/outdir/ur_emiss/inverse_2005-2007_JJA_NO2.scenario1.05x0666.bpch'

   success = CTM_Make_DataInfo( avg_no2,                 $
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
