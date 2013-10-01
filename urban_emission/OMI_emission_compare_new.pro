pro OMI_emission_compare_new

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GENERIC', Res=[0.25d0,0.25d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


;get China mask
filename1 = '/home/gengguannan/indir/mask/China_mask.geos5.v3.05x0666'
ctm_get_data,datainfo_1,filename = filename1,tracer=802
China_mask=*(datainfo_1[0].data)

;get population data
filename2 = '/home/gengguannan/indir/parameter/totalpopu_05x0666.bpch'
ctm_get_data,datainfo_2,filename = filename2,tracer=802
popu=*(datainfo_2[0].data)

;get OMI data
filename3 = '/home/gengguannan/work/ur_emiss/satellite/omi_v2_dpgc_no2_seasonal_average_2006_JJA_05x0666.bpch'
ctm_get_data,datainfo_3,filename = filename3,tracer=1
no2=*(datainfo_3[0].data)

;get emission data
pow = fltarr(InGrid.IMX,InGrid.JMX)
emis = fltarr(InGrid.IMX,InGrid.JMX)


Year = 2006
Yr4 = string( Year, format = '(i4.4)')

filename4 = '/home/gengguannan/indir/meic_201207/'+Yr4+'/meic_NOx_pow_'+Yr4+'.05x0666'
filename5 = '/home/gengguannan/indir/intexb_scaled/combine_NOx_res_2006.05x0666'
filename6 = '/home/gengguannan/indir/intexb_scaled/combine_NOx_ind_2006.05x0666'
filename7 = '/home/gengguannan/indir/intexb_scaled/combine_NOx_tra_2006.05x0666'

for Month = 6,8 do begin
Mon2 = string( Month, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

ctm_get_data,datainfo_4,filename = filename4,tau0=Tau0,tracer=1
pow_temp=*(datainfo_4[0].data)

pow += pow_temp

endfor

print,total(pow)

ctm_get_data,datainfo_5,filename = filename5,tracer=1
dom=*(datainfo_5[0].data)

ctm_get_data,datainfo_6,filename = filename6,tracer=1
ind=*(datainfo_6[0].data)

ctm_get_data,datainfo_7,filename = filename7,tracer=1
tra=*(datainfo_7[0].data)

;ind 0.0872+0.0815+0.0844=0.2531 0.2531*1.200=0.3037
;dom 0.0434+0.0449+0.0449=0.1332 
;tra 0.0833+0.0833+0.0833=0.2500 0.2500*1.179=0.2948

print,total(0.2531*ind),total(0.1332*dom),total(0.2500*tra)

emis=0.2531*ind+0.1332*dom+0.2500*tra+pow

print,total(emis)


;print data
OMI = make_array(1)
EM = make_array(1)
population = make_array(1)


limit=[15,100,55,136]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2


for I = I1,I2 do begin
  for J = J1,J2 do begin
    if China_mask[I,J] gt 0 and no2[I,J] gt 0 then begin
        OMI = [OMI,no2[I,J]]
        EM = [EM,emis[I,J]]
        population = [population,popu[I,J]]
    endif
  endfor
endfor

outfile = '/home/gengguannan/work/ur_emiss/result/OMI_emission_popu.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, OMI, 'OMI',          $
           Longname='satellite', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, EM, 'EM',          $
           Longname='inventory', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, population, 'population',          $
           Longname='population', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SD_End, FID


end
