pro get_China_columns_correlation_with_ratio_popu

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau, CTM_WriteBpch

CTM_CleanUp


filename1 = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_annual_2005-2007_NO2.month.05x0666.power.plant.bpch'
filename2 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_annual_average_2005-2007_05x0666.bpch'
filename3 = '/home/gengguannan/indir/popu/totalpopu_05x0666.bpch'
filename4 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'
filename5 = '/home/gengguannan/indir/GDP_2005-2007_05x0666.bpch'


;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
popu=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=802
mask=*(datainfo_4[0].data)

ctm_get_data,datainfo_5,filename = filename5,tracer=802
GDP=*(datainfo_5[0].data)


InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

;limit = [38,113,42,120]
;limit = [33,110,38,118]

;i1_index = where(xmid ge limit[1] and xmid le limit[3])
;j1_index = where(ymid ge limit[0] and ymid le limit[2])
;I1 = min(i1_index, max = I2)
;J1 = min(j1_index, max = J2)
;print, 'I1:I2',I1,I2, 'J1:J2',J1,J2

ratio = fltarr(InGrid.IMX,InGrid.JMX)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (data18[I,J] gt 1) and (data28[I,J] gt 1)      $
    then ratio[I,J] = data28[I,J]/data18[I,J] $
    else ratio[I,J] = -999
  endfor
endfor


r = make_array(1)
p = make_array(1)
G = make_array(1)
n = 0

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (mask[I,J] eq 1) and (ratio[I,J] gt 0) and (popu[I,J] gt 0) then begin
        r=[r,ratio[I,J]]
        p=[p,popu[I,J]]
        G=[G,GDP[I,J]]
        n+=1
    endif
  endfor
endfor

print,n-1

@plot01
print,'**********Correlation of model and satellite**********'
print,'R =', CORRELATE(r[1:n], p[1:n])
coeff = LINFIT(r[1:n], p[1:n])  
print,'sample number =', N_ELEMENTS(r[1:n])
print,'A,B = ', coeff
print,'r =', median(r[1:n]),'p =', median(p[1:n])

YFIT = coeff[0] + coeff[1]*r[1:n]
plot, r[1:n], p[1:n],psym=7,SYMSIZE=1
oplot, r[1:n], YFIT,linestyle=1



outfile = '/home/gengguannan/result/ur_emiss/ratio_popu.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, r, 'r',  $
           Longname='ratio',$
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, p, 'popu',  $
           Longname='population',$
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, G, 'GDP',  $
           Longname='GDP',$
           Unit='unitless',      $
           FILL=-999.0

HDF_SD_End, FID


end
