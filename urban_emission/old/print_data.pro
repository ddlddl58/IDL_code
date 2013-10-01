pro print_data

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid



filename1 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_seasonal_2006_JJA_NO2.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_seasonal_average_2006_JJA_05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'
;filename3 = '/home/gengguannan/indir/urban_mask_05x0666.bpch'
filename4 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch'
filename5 = '/home/gengguannan/indir/GDP_2006_05x0666.bpch'

;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data1=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data2=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
mask=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=802
data3=*(datainfo_4[0].data)

ctm_get_data,datainfo_5,filename = filename5,tracer=802
data4=*(datainfo_5[0].data)

GC_2006 = make_array(1)
OMI_2006 = make_array(1)
popu = make_array(1)
GDP = make_array(1)
I_index = make_array(1)
J_index = make_array(1)


area = [35,104,41,114]
;area = [30,114,41,123]
;area = [40,120,50,135]
;area = [25,97,33,110]
;area = [20,110,30,123]

i1_index = where(xmid ge area[1] and xmid le area[3])
j1_index = where(ymid ge area[0] and ymid le area[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)


flag = 1
;for I = 0,InGrid.IMX-1 do begin
;  for J = 0,InGrid.JMX-1 do begin
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (mask[I,J] gt 0) and (flag eq 1) then begin
      GC_2006 = [data1[I,J]]
      OMI_2006 = [data2[I,J]]
      popu = [data3[I,J]]
      GDP = [data4[I,J]]
    endif
    if (mask[I,J] gt 0) and (flag eq 0) then begin
      GC_2006 = [GC_2006,data1[I,J]]
      OMI_2006 = [OMI_2006,data2[I,J]]
      popu = [popu,data3[I,J]]
      GDP = [GDP,data4[I,J]]
    endif
    flag = 0
  endfor
endfor


print,GC_2006
;print,OMI_2006
;print,popu
;print,GDP
;print,I_index
;print,J_index


end

