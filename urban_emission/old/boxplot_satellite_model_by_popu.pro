pro boxplot_satellite_model_by_popu

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
filename4 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch'

;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
China_mask=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=802
popu=*(datainfo_4[0].data)

category = fltarr(InGrid.IMX,InGrid.JMX)

limit = [0,1000,5000,10000,50000,100000,200000,500000,1000000,2000000,8400000]

for l = 0,10-1 do begin
for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (China_mask[I,J] eq 1) and (popu[I,J] ge limit[l]) and (popu[I,J] lt limit[l+1]) then begin
      category[I,J] = l+1
    endif
  endfor
endfor
endfor

print,min(category)

m = make_array(1)
s = make_array(1)
group = make_array(1)


flag = 1
for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (China_mask[I,J] eq 1) and (flag eq 1) then begin
      m = [data18[I,J]]
      s = [data28[I,J]]
      group = [category[I,J]]
    endif
    if (China_mask[I,J] eq 1) and (flag eq 0) then begin
      m = [m,data18[I,J]]
      s = [s,data28[I,J]]
      group = [group,category[I,J]]
    endif
    flag = 0
  endfor
endfor

print,min(m)

label = ['!C0 - 0.1','!C0.1 - 0.5','!C0.5 - 1','!C1 - 5','!C5 - 10','!C10 - 20','!C20 - 50','!C50 - 100','!C100 - 200','!C200 - 840']

BOXPLOT, m, GROUP=group, MINGROUP=1, LABEL=label, YRANGE=[0,8], BOXWIDTH=0.4,    $
         BOXPOSITION=-0.2, FILLCOLOR=15, XTITLE='Population (E+4)',              $
         YTITLE='NO2 Column (E+15 molec/cm2)', CHARSIZE=1.2
BOXPLOT, s, GROUP=group, MINGROUP=1, BOXWIDTH=0.4, BOXPOSITION=+0.2, /OVERPLOT

end
