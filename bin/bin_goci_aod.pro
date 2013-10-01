;PURPOSE: Perform GOCI AOD data regridding
;SUBROUTINES USED: -polyfillaa (J.D. Smith's code, see http://tir.astro.utoledo.edu/jdsmith/code/idl.php for more information)
;REMARKS: the FILTERING sections (see below) have to be adapted depending on your needs, as well as the grid resolution

@polyfillaa

pro bin_goci_aod

for year = 2011,2011 do begin
for month = 5,5 do begin
for day = 1,31 do begin

Yr4  = string( year, format = '(i4.4)')
Mon2 = string( month, format = '(i2.2)')
Day2 = string( day, format = '(i2.2)')

dir_in = '/data1/guannan/data/GOCI/'
spawn,'ls '+ dir_in +'AOP_'+ Yr4 + Mon2 + Day2 +'*.bin',list_goci

dir_out = '/data1/guannan/data/GOCI/'


; 3D-grid definition for regridding
GEOS_Type = CTM_Type( 'GENERIC', res = [0.1d0, 0.1d0] )
;GEOS_Type = CTM_Type( 'GEOS5', res = [2.d0/3d0, 1.d0/2.d0] )
GEOS_Grid = CTM_Grid( GEOS_Type )

grid_lon_mid = GEOS_Grid.Xmid
grid_lat_mid = GEOS_Grid.Ymid
grid_lon_edge = GEOS_Grid.XEDGE
grid_lat_edge = GEOS_Grid.YEDGE

;dx = GEOS_Type.RESOLUTION[0]
;dy = GEOS_Type.RESOLUTION[1]

nlon = n_elements(grid_lon_mid)
nlat = n_elements(grid_lat_mid)


aod_array = fltarr(nlon,nlat)
count_array = fltarr(nlon,nlat)


for k = 0,n_elements(list_goci)-1 do begin

print,'file: '+ list_goci(k)
print,'file '+ strtrim((k+1),2)+' over '+strtrim(n_elements(list_goci),2)+' files is processed'

flelen = strlen(list_goci(k))
infile = list_goci(k)
YY = fix(strmid(infile, flelen-14, 4))
MM = fix(strmid(infile, flelen-10, 2))
DD = fix(strmid(infile, flelen-8, 2))
TT = fix(strmid(infile, flelen-6, 2))

date_now = YY * 1000000L + MM * 10000L + DD * 100L + TT * 1L
print,date_now


; Read data
lonlat_file = '/data1/guannan/data/GOCI/lonlat_GOCI.bin'

sz = lonarr(2)
openr, 1, lonlat_file
readu, 1, sz
x = sz[0]-1
y = sz[1]-1

glon = fltarr(sz)
glat = fltarr(sz)
readu, 1, glon, glat
close, 1

nan = where( finite(glon) eq 0 )
glon[nan] = ( glon[nan-1] + glon[nan+1] ) / 2
glat[nan] = ( glat[nan-1] + glat[nan+1] ) / 2

lon_1 = fltarr(sz)
lon_2 = fltarr(sz)
lon_3 = fltarr(sz)
lon_4 = fltarr(sz)
lat_1 = fltarr(sz)
lat_2 = fltarr(sz)
lat_3 = fltarr(sz)
lat_4 = fltarr(sz)
pt = fltarr(x,y,2)

for i = 0,x-1 do begin
  for j = 0,y-1 do begin
    pt[i,j,*] = lint([glon[i,j],glat[i,j]],[glon[i+1,j+1],glat[i+1,j+1]], $
                     [glon[i+1,j],glat[i+1,j]],[glon[i,j+1],glat[i,j+1]])
  endfor
endfor

lon_1[1:x,0:(y-1)] = pt[*,*,0]
lon_1[0,0:(y-1)] = 2 * pt[0,*,0] - pt[1,*,0]
lon_1[*,y] = 2 * lon_1[*,y-1] - lon_1[*,y-2]
lon_2[0:(x-1),0:(y-1)] = pt[*,*,0]
lon_2[0:(x-1),y] = lon_1[1:x,y]
lon_2[x,*] = 2 * lon_2[x-1,*] - lon_2[x-2,*]
lon_3[0:(x-1),1:y] = pt[*,*,0]
lon_3[x,1:y] = lon_2[x,0:(y-1)]
lon_3[*,0] = 2 * lon_3[*,1] - lon_3[*,2]
lon_4[1:x,1:y] = pt[*,*,0]
lon_4[0,1:y] = lon_1[0,0:(y-1)]
lon_4[*,0] = 2 * lon_4[*,1] - lon_4[*,2]

lat_1[1:x,0:(y-1)] = pt[*,*,1]
lat_1[0,0:(y-1)] = 2 * pt[0,*,1] - pt[1,*,1]
lat_1[*,y] = 2 * lat_1[*,y-1] - lat_1[*,y-2]
lat_2[0:(x-1),0:(y-1)] = pt[*,*,1]
lat_2[0:(x-1),y] = lat_1[1:x,y]
lat_2[x,*] = 2 * lat_2[x-1,*] - lat_2[x-2,*]
lat_3[0:(x-1),1:y] = pt[*,*,1]
lat_3[x,1:y] = lat_2[x,0:(y-1)]
lat_3[*,0] = 2 * lat_3[*,1] - lat_3[*,2]
lat_4[1:x,1:y] = pt[*,*,1]
lat_4[0,1:y] = lat_1[0,0:(y-1)]
lat_4[*,0] = 2 * lat_4[*,1] - lat_4[*,2]


aod = fltarr(sz)
openr, 1, infile
readu, 1, aod
close, 1


; filtering
ind_ok = where((finite(aod) gt 0) and                      $
               (lon_1 lt max(grid_lon_mid)) and            $
               (lon_2 lt max(grid_lon_mid)) and            $
               (lon_3 lt max(grid_lon_mid)) and            $
               (lon_4 lt max(grid_lon_mid)) and            $
               (lat_1 lt max(grid_lat_mid)) and            $
               (lat_2 lt max(grid_lat_mid)) and            $
               (lat_3 lt max(grid_lat_mid)) and            $
               (lat_4 lt max(grid_lat_mid)) and            $
               (lon_4 lt lon_3 and lon_1 lt lon_2) and     $
               (lat_1 lt lat_4 and lat_2 lt lat_3))

if ind_ok(0) eq -1 then continue

lon_1 = lon_1(ind_ok)
lat_1 = lat_1(ind_ok)
lon_2 = lon_2(ind_ok)
lat_2 = lat_2(ind_ok)
lon_3 = lon_3(ind_ok)
lat_3 = lat_3(ind_ok)
lon_4 = lon_4(ind_ok)
lat_4 = lat_4(ind_ok)
aod = aod(ind_ok)

; binning
; SCALING OF THE COORDINATES TO GRID INDEXES
lon_1_unit = (lon_1-grid_lon_edge(0))/(grid_lon_edge(n_elements(grid_lon_edge)-1)-grid_lon_edge(0))*nlon
lat_1_unit = (lat_1-grid_lat_edge(0))/(grid_lat_edge(n_elements(grid_lat_edge)-1)-grid_lat_edge(0))*nlat
lon_2_unit = (lon_2-grid_lon_edge(0))/(grid_lon_edge(n_elements(grid_lon_edge)-1)-grid_lon_edge(0))*nlon
lat_2_unit = (lat_2-grid_lat_edge(0))/(grid_lat_edge(n_elements(grid_lat_edge)-1)-grid_lat_edge(0))*nlat
lon_3_unit = (lon_3-grid_lon_edge(0))/(grid_lon_edge(n_elements(grid_lon_edge)-1)-grid_lon_edge(0))*nlon
lat_3_unit = (lat_3-grid_lat_edge(0))/(grid_lat_edge(n_elements(grid_lat_edge)-1)-grid_lat_edge(0))*nlat
lon_4_unit = (lon_4-grid_lon_edge(0))/(grid_lon_edge(n_elements(grid_lon_edge)-1)-grid_lon_edge(0))*nlon
lat_4_unit = (lat_4-grid_lat_edge(0))/(grid_lat_edge(n_elements(grid_lat_edge)-1)-grid_lat_edge(0))*nlat

px = Dblarr(4*n_elements(lon_1_unit))
py = Dblarr(4*n_elements(lon_1_unit))
polygons_ind = lon64arr(n_elements(lon_1_unit)+1)

for nn=0L,n_elements(lon_1_unit)-1L do begin
  polygons_ind(nn) = 4*nn
  px(4*nn)   = lon_4_unit(nn)
  px(4*nn+1) = lon_3_unit(nn)
  px(4*nn+2) = lon_1_unit(nn)
  px(4*nn+3) = lon_2_unit(nn)
  py(4*nn)   = lat_4_unit(nn)
  py(4*nn+1) = lat_3_unit(nn)
  py(4*nn+2) = lat_1_unit(nn)
  py(4*nn+3) = lat_2_unit(nn)
endfor
polygons_ind(n_elements(lon_1_unit)) = 4*n_elements(lon_1_unit)

;inds = polyfillaa(px,py,nlon,nlat,AREAS=areas,POLY_INDICES=polygons_ind,/RECOMPILE)
inds = polyfillaa(px,py,nlon,nlat,AREAS=areas,POLY_INDICES=polygons_ind,/NO_COMPILED)

for pp=0L,n_elements(polygons_ind)-2L do begin
  ind_grid_x = inds(polygons_ind(pp):polygons_ind(pp+1)-1) mod nlon
  ind_grid_y = inds(polygons_ind(pp):polygons_ind(pp+1)-1)/fix(nlon)

  for ii=0L,n_elements(ind_grid_x)-1L do begin

    aod_array(ind_grid_x(ii),ind_grid_y(ii))=(aod_array(ind_grid_x(ii),ind_grid_y(ii))*count_array(ind_grid_x(ii),ind_grid_y(ii))+areas(polygons_ind(pp)+ii)*aod(pp))/(count_array(ind_grid_x(ii),ind_grid_y(ii))+areas(polygons_ind(pp)+ii))
    count_array(ind_grid_x(ii),ind_grid_y(ii))=count_array(ind_grid_x(ii),ind_grid_y(ii))+areas(polygons_ind(pp)+ii)

  endfor

endfor

aod_array(where(count_array eq 0)) = -999.0
print,max(aod_array)

date_file = YY * 10000L + MM * 100L + DD * 1L
tau0 = nymd2tau(date_file)
outfile1 = dir_out+'goci_aop_'+strtrim(string(date_now),2)+'.bpch'

  Success = CTM_Make_DataInfo( aod_array,             $
                               ThisDataInfo,            $
                               ModelInfo=GEOS_Type,     $
                               GridInfo=GEOS_Grid,      $
                               DiagN='IJ-AVG-$',        $
                               Tracer=26,               $
                               Tau0=Tau0,               $
                               Tau1=Tau0+24.0,          $
                               Unit='DU',               $
                               Dim=[GEOS_Grid.IMX,      $
                                    GEOS_Grid.JMX,      $
                                    0, 0],              $
                               First=[1L, 1L, 1L],      $
                               /No_vertical )

  Success = CTM_Make_DataInfo( count_array,             $
                               ThisDataInfo2,           $
                               ModelInfo=GEOS_Type,     $
                               GridInfo=GEOS_Grid,      $
                               DiagN='IJ-AVG-$',        $
                               Tracer=88,               $
                               Tau0=Tau0,               $
                               Tau1=Tau0+24.0,          $
                               Unit='unitless',         $
                               Dim=[GEOS_Grid.IMX,      $
                                    GEOS_Grid.JMX,      $
                                    0, 0],              $
                               First=[1L, 1L, 1L],      $
                               /No_vertical )

  NewDataInfo = [Thisdatainfo,Thisdatainfo2]
  CTM_WriteBpch, NewDataInfo, Filename = outfile1
  CTM_Cleanup

;outfile2 = dir_out+'goci_aop_'+strtrim(string(date_prev),2)+'.asc'
;openw,lun,outfile2,/GET_LUN

;printf, lun, 'ncols         720.0'
;printf, lun, 'nrows         360.0'
;printf, lun, 'xllcorner     -180.0'
;printf, lun, 'yllcorner     -90.0'
;printf, lun, 'cellsize      0.5'
;printf, lun, 'nodata_value  -999.0'

;for oo = 0L,n_elements(aod_array[0,*])-1L do begin
;  printf, lun, format = '(720f10.4)',aod_array[*,n_elements(aod_array[0,*])-1L-oo]
;endfor
;for oo = 0L,n_elements(aod_array[0,*])-1L do begin
;  printf, lun, format = '(720f10.4)',aod_array[*,n_elements(count_array[0,*])-1L-oo]
;endfor

;close, lun
;free_lun, lun

aod_array(*,*) = 0.
count_array(*,*) = 0.

endfor ; loop over files

fin :

endfor
endfor
endfor


end
