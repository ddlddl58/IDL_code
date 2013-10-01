pro correlation

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, Nymd2Tau

InType = CTM_Type( 'generic', Res=[ 0.1d0, 0.1d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'GEOS5', Res=[2.0d0/3.0d0, 0.5d0] )
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

OutType = CTM_Type( 'generic', Res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all


limit=[20,110,50,150]

i1_index = where(inxmid ge limit[1] and inxmid le limit[3])
j1_index = where(inymid ge limit[0] and inymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

i3_index = where(outxmid ge limit[1] and outxmid le limit[3])
j3_index = where(outymid ge limit[0] and outymid le limit[2])
I3 = min(i3_index, max = I4)
J3 = min(j3_index, max = J4)

CTM_CleanUp


filename1 = '/data1/guannan/data/GOCI/AOD_goci_2011apr-may01_average.bpch'
filename2 = '/data1/guannan/data/MODIS/AODterraMODIS_2011apr-may_average.bpch'
filename3 = '/data1/guannan/data/landmask.asc'

ctm_get_data,datainfo_1,filename = filename1
data18=*(datainfo_1[0].data)

ctm_get_data,datainfo_2,filename = filename2
data28=*(datainfo_2[0].data)

mask = fltarr(InGrid.IMX,InGrid.JMX)
Open_File, filename3, Ilun, /Get_LUN
ReadF, Ilun, mask

goci = fltarr(OutGrid.IMX,OutGrid.JMX)
nod1 = fltarr(OutGrid.IMX,OutGrid.JMX)
modis = fltarr(OutGrid.IMX,OutGrid.JMX)
nod2 = fltarr(OutGrid.IMX,OutGrid.JMX)
mask_new = fltarr(OutGrid.IMX,OutGrid.JMX)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    x = where( (inxmid[I] gt (outxmid - 0.125)) and (inxmid[I] le (outxmid + 0.125)))
    y = where( (inymid[J] gt (outymid - 0.125)) and (inymid[J] le (outymid + 0.125)))
    if (data18[I,J] gt 0) then begin
        goci[x,y] = goci[x,y] + data18[I,J]
        nod1[x,y] = nod1[x,y] + 1
    endif
    if (data28[I,J] gt 0) then begin
        modis[x,y] = modis[x,y] + data28[I,J]
        nod2[x,y] = nod2[x,y] + 1
    endif
    mask_new[x,y] = mask_new[x,y] + mask[I,J]
  endfor
endfor

print,max(nod1),max(nod2)

for I = I3,I4 do begin
  for J = J3,J4 do begin
    if (nod1[I,J] gt 0L)             $
        then  goci[I,J] = goci[I,J] / nod1[I,J]  $
        else  goci[I,J] = -999.0
    if (nod2[I,J] gt 0L)             $
        then  modis[I,J] = modis[I,J] / nod2[I,J]  $
        else  modis[I,J] = -999.0
  endfor
endfor

help,goci
help,modis
help,mask_new

ind_ok = where( goci gt 0 and modis gt 0 and mask_new eq 0)
;ind_ok = where( goci gt 0 and modis gt 0 )
s1 = goci(ind_ok)
s2 = modis(ind_ok)


print,'******Correlation of satellite data******'

print,'sample number =', N_ELEMENTS(s1)
print,'R =', CORRELATE(s1, s2)
coeff = LINFIT(s1, s2)
;print,'A = ',coeff[0]
print,'B = ',coeff[1]
print,'goci = ',mean(s1)
print,'modis = ',mean(s2)


outfile = '/data1/guannan/result/correlation.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, s1, 'GOCI',       $
           Longname='satellite1', $
           Unit='unitless',       $
           FILL=-999.0
HDF_SETSD, FID, s2, 'MODIS',      $
           Longname='satellite2', $
           Unit='unitless',       $
           FILL=-999.0
HDF_SD_End, FID


end
