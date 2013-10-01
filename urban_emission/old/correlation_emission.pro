pro correlation_emission

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, Nymd2Tau

CTM_CleanUp

InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


filename0 = '/public/geos/GEOS_0.5x0.666_CH/Streets_200607/China_mask.geos5.05x0666' 
filename1 = '/home/gengguannan/indir/meic_201207/2006/meic_NOx_tra_2006.05x0666'
filename2 = '/home/gengguannan/indir/meic_s1/2006/meic_NOx_tra_2006.05x0666'

data1 = fltarr(InGrid.IMX,InGrid.JMX)
data2 = fltarr(InGrid.IMX,InGrid.JMX)

for month = 1,12 do begin
nymd = 2006 * 10000L + month * 100L + 1L
tau0 = nymd2tau(nymd)

ctm_get_data,datainfo_0,filename = filename0,tracer=802
mask=*(datainfo_0[0].data)

ctm_get_data,datainfo_1,filename = filename1,tracer=1,tau0 = tau0
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=1,tau0 = tau0
data28=*(datainfo_2[0].data)

data1 = data1 + data18
data2 = data2 + data28

endfor


;limit = [35,104,41,114]
;limit = [30,114,45,122]
;limit = [40,120,50,135]
;limit = [25,97,33,110]
;limit = [20,110,30,123]

limit = [15,70,55,150]

ind_i = where(xmid lt limit[1] or xmid gt limit[3])
ind_j = where(ymid lt limit[0] or ymid gt limit[2])

data1[ind_i,*] = -999
data2[*,ind_j] = -999

s = make_array(1)
m = make_array(1)

ind_ok = where( data1 gt -999 and data2 gt -999 and mask gt 0)
s = data1(ind_ok)
m = data2(ind_ok)


print,'******Correlation of model and satellite******'

print,'sample number =', N_ELEMENTS(s)
print,'R =', CORRELATE(s, m)
coeff = LINFIT(s, m)
;print,'A = ',coeff[0]
print,'B = ',coeff[1]
print,'s = ',mean(s)
print,'m = ',mean(m)

;plot,s,m,psym=7,SYMSIZE=1

;outfile = '/home/gengguannan/work/result/scenario'+ k1 +'.hdf'
outfile = '/home/gengguannan/work/ur_emiss/result/emis.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, s, 'E1',         $
           Longname='satellite',  $
           Unit='unitless',       $
           FILL=-999.0
HDF_SETSD, FID, m, 'E2',          $
           Longname='model',      $
           Unit='unitless',       $
           FILL=-999.0
HDF_SD_End, FID

end
