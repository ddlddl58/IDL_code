pro OMI_GC

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau, CTM_WriteBpch

CTM_CleanUp

;filename1 = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.month.05x0666.power.plant.bpch'
;filename2 = '/z3/gengguannan/outdir/ur_emiss/ctm.vc_seasonal_2005-2007_JJA_NO2.new.05x0666.bpch'
;filename3 = '/z3/gengguannan/outdir/ur_emiss/inverse_seasonal_2005-2007_JJA_NO2.new1.05x0666.bpch'
;filename3 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x0666.bpch'
filename1 = '/z3/gengguannan/outdir/ur_emiss/intexb_2006_season_average_JJA_sample.05x0666.bpch'
filename2 = '/z3/gengguannan/outdir/ur_emiss/gc_no2_season_average_2006_JJA.sample.05x0666.bpch'
filename3 = '/z3/gengguannan/outdir/ur_emiss/inverse_2006_JJA_NO2.test.05x0666.bpch'
;filename3 = '/z3/gengguannan/outdir/ur_emiss/DPGC_OMI_GEOS5_05x06profile_2006_JJA_sza70_crd30_v2.05x0666.bpch'
filename4 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'


;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1
data28=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=1
data38=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=802
China_mask=*(datainfo_4[0].data)



InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

limit = [15,70,55,150]

;limit = [35,104,41,114]
;limit = [30,114,45,122]
;limit = [40,120,50,135]
;limit = [25,97,33,110]
;limit = [20,110,30,123]



i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2


m1 = make_array(1)
m2 = make_array(1)
s = make_array(1)
n = 0

;for I = 0,InGrid.IMX-1 do begin
;  for J = 0,InGrid.JMX-1 do begin
for I = I1,I2 do begin
  for J = J1,J2 do begin
   if ((China_mask[I,J] gt 0) and (data18[I,J] gt 1) and (data28[I,J] gt 1) and (data38[I,J] gt 1)) then begin
        m1=[m1,data18[I,J]]
        m2=[m2,data28[I,J]]
        s=[s,data38[I,J]]
        n+=1
    endif
  endfor
endfor

print,n

print,max(s)

outfile = '/home/gengguannan/result/ur_emiss/GC_OMI.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, m1, 'GC1',        $
           Longname='model',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, m2, 'GC2',        $
           Longname='model',     $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, s, 'OMI',      $
           Longname='satellite', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SD_End, FID


print,'**********Correlation of model and satellite**********'
print,'R =', CORRELATE(s[1:n], m1[1:n])
coeff = LINFIT(s[1:n], m1[1:n])  
print,'sample number =', N_ELEMENTS(s[1:n])
print,'A,B = ', coeff
print,'s =', median(s[1:n]),'m =', median(m1[1:n])

print,'**********Correlation of model and satellite**********'
print,'R =', CORRELATE(s[1:n], m2[1:n])
coeff = LINFIT(s[1:n], m2[1:n])
print,'sample number =', N_ELEMENTS(s[1:n])
print,'A,B = ', coeff
print,'s =', median(s[1:n]),'m =', median(m2[1:n])


end
