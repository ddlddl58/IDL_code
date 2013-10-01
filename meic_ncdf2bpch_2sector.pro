pro meic_ncdf2bpch_2sector,year

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak

Intype = ctm_type( 'GEOS5', res = [2.d0/3d0, 1.d0/2.d0] )
Ingrid = ctm_grid(Intype)

close,/all


year = year
Yr4 = string( year, format = '(i4.4)' )


flag = 1L
test1 = fltarr(121,133)
test2 = fltarr(121,133)


for month = 1,12 do begin
Mon = strtrim( month, 1)
Mon2 = string( month, format = '(i2.2)' )


sector = ['industry','power','transportation','residential-bio','residential-fos','residential-noncom']

old_sec1 = fltarr(121,133,6)
old_sec2 = fltarr(121,133,6)

for m = 0,5 do begin


Indir = '/home/gengguannan/indir/meic/'+ Yr4 +'/'+ sector[m] +'_'+ Yr4 +'__'+ Mon +'/'
infile1 = Indir + Yr4 +'_'+ Mon2 +'__'+ sector[m] +'__BC.nc'
infile2 = Indir + Yr4 +'_'+ Mon2 +'__'+ sector[m] +'__OC.nc'

;read data
emis1 = fltarr(10800)
emis2 = fltarr(10800)

fid1 = ncdf_open(infile1)
dataid1 = ncdf_varid(fid1,'z')
ncdf_varget,fid1,dataid1,emis1

remis1=reform(emis1,[120,90])
ind1 = where(remis1 lt 0.)
remis1[ind1] = 0.0

fid2 = ncdf_open(infile2)
dataid2 = ncdf_varid(fid2,'z')
ncdf_varget,fid2,dataid2,emis2

remis2=reform(emis2,[120,90])
ind2 = where(remis2 lt 0.)
remis2[ind2] = 0.0


for I = 0L,120L-1L do begin
  for J = 0L,80L-1L do begin
    old_sec1[I,J+52L,m] = remis1[I,89-J] * 1000
    old_sec2[I,J+52L,m] = remis2[I,89-J] * 1000
  endfor
endfor

endfor

fossil1 = ( old_sec1[*,*,0] + old_sec1[*,*,1] + old_sec1[*,*,2] + old_sec1[*,*,4] + old_sec1[*,*,5] )
fossil2 = ( old_sec2[*,*,0] + old_sec2[*,*,1] + old_sec2[*,*,2] + old_sec2[*,*,4] + old_sec2[*,*,5] )

biofuel1 = old_sec1[*,*,3]
biofuel2 = old_sec2[*,*,3]
;print,total(fossil1)

test1 = test1 + fossil1/1000 + biofuel1/1000
test2 = test2 + fossil2/1000 + biofuel2/1000


maskfile = '/public/geos/GEOS_0.5x0.666_CH/Streets_200607/China_mask.geos5.05x0666'
tami_fos = '/public/geos/GEOS_0.5x0.666_CH/carbon_200909/BCOC_TBond_fossil.2000.geos.05x0666'
tami_bio = '/public/geos/GEOS_0.5x0.666_CH/carbon_200909/BCOC_TBond_biofuel.2000.geos.05x0666'

nymd1 = 2000 * 10000L + month * 100L + 1L
tau1 = nymd2tau(nymd1)


CTM_Get_Data, mask, 'LANDMAP', Tracer = 2, filename = maskfile, Tau0 = Nymd2Tau(19850101)
mask_file = *(mask[0].data)
China_mask = mask_file[375:495,158:290]

CTM_Get_Data, emis_11, 'ANTHSRCE', Tracer = 34, filename = tami_fos, Tau0 = tau1
tami_fos1 = *(emis_11[0].data)

CTM_Get_Data, emis_12, 'ANTHSRCE', Tracer = 35, filename = tami_fos, Tau0 = tau1
tami_fos2 = *(emis_12[0].data)

CTM_Get_Data, emis_21, 'BIOFSRCE', Tracer = 34, filename = tami_bio, Tau0 = tau1
tami_bio1 = *(emis_21[0].data)

CTM_Get_Data, emis_22, 'BIOFSRCE', Tracer = 35, filename = tami_bio, Tau0 = tau1
tami_bio2 = *(emis_22[0].data)

print,total(tami_fos1),total(tami_fos2),total(tami_bio1),total(tami_bio2)

fossil1(where(China_mask eq 0)) = tami_fos1(where(China_mask eq 0))
fossil2(where(China_mask eq 0)) = tami_fos2(where(China_mask eq 0))
biofuel1(where(China_mask eq 0)) = tami_bio1(where(China_mask eq 0))
biofuel2(where(China_mask eq 0)) = tami_bio2(where(China_mask eq 0))
print,total(fossil1),total(fossil2),total(biofuel1),total(biofuel2)


Outdir = '/home/gengguannan/indir/meic_201207/'+ Yr4 +'/'

outfile1 = Outdir + 'BCOC_meic_fossil.'+ Yr4 +'.05x0666'
outfile2 = Outdir + 'BCOC_meic_biofuel.'+ Yr4 +'.05x0666'

nymd = year * 10000L + month * 100L + 1L
tau0 = nymd2tau(nymd)


; outfile1
Success = CTM_Make_DataInfo( fossil1,              $
                             ThisDataInfo11,       $
                             ThisFileInfo11,       $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=34,            $
                             Tau0=tau0,            $
                             Unit='kgEC',          $
                             Dim=[121,133,0,0],    $
                             First=[376L, 159L, 1L],   $
                             /No_vertical )

Success = CTM_Make_DataInfo( fossil2,              $
                             ThisDataInfo12,       $
                             ThisFileInfo12,       $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=35,            $
                             Tau0=tau0,            $
                             Unit='kgOC',          $
                             Dim=[121,133,0,0],    $
                             First=[376L, 159L, 1L],   $
                             /No_vertical )

If (flag )  $
  then NewDataInfo1 = [ ThisDataInfo11, ThisDataInfo12 ]  $
  else NewDataInfo1 = [ NewDataInfo1, ThisDataInfo11, ThisDataInfo12 ]

If (flag )  $
  then NewFileInfo1 = [ ThisFileInfo11, ThisFileInfo12 ]  $
  else NewFileInfo1 = [ NewFileInfo1, ThisFileInfo11, ThisFileInfo12 ]

; outfile2
Success = CTM_Make_DataInfo( biofuel1,             $
                             ThisDataInfo21,       $
                             ThisFileInfo21,       $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='BIOFSRCE',     $
                             Tracer=34,            $
                             Tau0=tau0,            $
                             Unit='kgEC',          $
                             Dim=[121,133,0,0],    $
                             First=[376L, 159L, 1L],   $
                             /No_vertical )

Success = CTM_Make_DataInfo( biofuel2,             $
                             ThisDataInfo22,       $
                             ThisFileInfo22,       $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='BIOFSRCE',     $
                             Tracer=35,            $
                             Tau0=tau0,            $
                             Unit='kgOC',          $
                             Dim=[121,133,0,0],    $
                             First=[376L, 159L, 1L],   $
                             /No_vertical )

If (flag )  $
  then NewDataInfo2 = [ ThisDataInfo21, ThisDataInfo22 ]  $
  else NewDataInfo2 = [ NewDataInfo2, ThisDataInfo21, ThisDataInfo22 ]

If (flag )  $
  then NewFileInfo2 = [ ThisFileInfo21, ThisFileInfo22 ]  $
  else NewFileInfo2 = [ NewFileInfo2, ThisFileInfo21, ThisFileInfo22 ]

flag = 0L

endfor

print,total(test1),total(test2)


CTM_WriteBpch, newDataInfo1, newFileInfo1, Filename=Outfile1
CTM_WriteBpch, newDataInfo2, newFileInfo2, Filename=Outfile2

ctm_cleanup


end
