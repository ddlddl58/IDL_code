pro get_China_columns_correlation_with_popu,year

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau, CTM_WriteBpch

CTM_CleanUp

year=year
Yr4 = String( Year, format = '(i4.4)' )

if year le 2002 $
  then filename1 = '/home/gengguannan/indir/gome_no2_v3-0_'+ Yr4 +'_annual_average.05x05.bpch' $
  else filename1 = '/home/gengguannan/indir/scia_no2_v1-5_'+ Yr4 +'_annual_average.05x05.bpch'
;if year le 2002 $
;  then filename1 = '/home/gengguannan/indir/gome_no2_v3-0_'+ Yr4 +'_JJA.05x05.bpch' $
;  else filename1 = '/home/gengguannan/indir/scia_no2_v1-5_'+ Yr4 +'_JJA.05x05.bpch'

filename2 = '/home/gengguannan/indir/popu/totalpopu_05x05.bpch'
filename3 = '/home/gengguannan/indir/China_mask.geos5.v3.05x05'
filename4 = '/home/gengguannan/indir/region_mask_05x05.bpch'
;filename4 = '/home/gengguannan/indir/scia_no2_v1-5_2010_JJA.05x05.bpch'

;Get data
ctm_get_data,datainfo_1,filename = filename1,tracer=1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2,tracer=802
popu=*(datainfo_2[0].data)

ctm_get_data,datainfo_3,filename = filename3,tracer=802
China_mask=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tracer=802
region=*(datainfo_4[0].data)


;InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
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


s = make_array(1)
p = make_array(1)
m = make_array(1)
x = make_array(1)
y = make_array(1)
n = 0

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
;for I = I1,I2 do begin
;  for J = J1,J2 do begin
    if (China_mask[I,J] eq 1) and (data18[I,J] gt 0) and (popu[I,J] gt 0) then begin
        s=[s,data18[I,J]]
        p=[p,popu[I,J]]
        m=[m,region[I,J]]
        x=[x,xmid(I)]
        y=[y,ymid(J)]
        n+=1
    endif
  endfor
endfor

print,n

@plot01
print,'**********Correlation of model and satellite**********'
print,'R =', CORRELATE(s[1:n], p[1:n])
coeff = LINFIT(s[1:n], p[1:n])  
print,'sample number =', N_ELEMENTS(s[1:n])
print,'A,B = ', coeff
print,'s =', median(s[1:n]),'m =', median(p[1:n])

YFIT = coeff[0] + coeff[1]*s[1:n]
plot, s[1:n], p[1:n],psym=7,SYMSIZE=1,       $
TITLE='Tropospheric NO2 columns',            $
XTITLE='OMI-2006(E+15 molec/cm2)',           $  
YTITLE='GEOS_Chem(E+15 molec/cm2)'  

oplot, s[1:n], YFIT,linestyle=1

outfile = '/home/gengguannan/result/'+Yr4+'.hdf'


IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, s, 's',  $
           Longname='satellite',$
           Unit='E+15molec/cm2',      $
           FILL=-999.0
HDF_SETSD, FID, p, 'popu',  $
           Longname='population',$
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, m, 'm',  $
           Longname='mask',$
           Unit='E+15molec/cm2',      $
           FILL=-999.0
HDF_SETSD, FID, x, 'x',  $
           Longname='mask',$
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, y, 'y',  $
           Longname='mask',$
           Unit='unitless',      $
           FILL=-999.0

HDF_SD_End, FID


end
