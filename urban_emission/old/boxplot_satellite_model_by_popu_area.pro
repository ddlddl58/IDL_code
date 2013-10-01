pro boxplot_satellite_model_by_popu_area

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


filename1 = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.month.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x0666.bpch'
filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'
;filename4 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch'
filename4 = '/home/gengguannan/indir/GDP_2005-2007_05x0666.bpch'


;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
China_mask=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4
popu=*(datainfo_4[0].data)


;area = [35,104,41,114]
;area = [30,114,45,122]
;area = [40,122,50,135]
;area = [25,97,33,110]
;area = [20,110,30,123]
area = [22,110,40,123]

title = '35-41N,104-114E'
;title = '30-45N,112-120E'
;title = '27-33N,102-108E'
;title = '40-45N,80-90E'
;title = '20-27N,100-120E'

i1_index = where(xmid ge area[1] and xmid le area[3])
j1_index = where(ymid ge area[0] and ymid le area[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

category = fltarr(InGrid.IMX,InGrid.JMX)

limit = [0,10,20,30,40,50,60,80,1000,150,200]

for l = 0,10-1 do begin
for I = I1,I2 do begin
  for J = J1,J2 do begin
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
for I = I1,I2 do begin
  for J = J1,J2 do begin
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

g = group(sort(group))
g = g(uniq(g))
g = g(sort(g))

print,g

outfile = '/home/gengguannan/result/ur_emiss/boxplot.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, m, 'm',          $
           Longname='model',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, s, 's',          $
           Longname='satellite', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, group, 'group',  $
           Longname='group',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SD_End, FID


;label = ['!C0 - 1','!C1 - 5','!C5 - 10','!C10 - 20','!C20 - 50','!C50 - 100','!C100 - 200','!C200 - 840']
label = ['!C0 - 1','!C1 - 5','!C5 - 10','!C10 - 20','!C20 - 50','!C50 - 100','!C100 - 200','!C200 - 840']


BOXPLOT, m, GROUP=group, MINGROUP=1, LABEL=label, YRANGE=[0,8],  $
         BOXWIDTH=0.4,BOXPOSITION=-0.2, FILLCOLOR=15,             $
         TITLE=title, CHARSIZE=1.2, MEANSYMBOL=1,                 $
;         XTITLE='Population (E+4)',                               $
         YTITLE='NO2 Column (E+15 molec/cm2)'
BOXPLOT, s, GROUP=group, MINGROUP=1, BOXWIDTH=0.4,                $
         BOXPOSITION=+0.2, MEANSYMBOL=1, /OVERPLOT

end
