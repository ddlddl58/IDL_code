;PURPOSE: Perform MODIS AOD data regridding
;SUBROUTINES USED: -polyfillaa

@polyfillaa
@get_modis_data


pro bin_modis_aod

;Time set
;---------
for year = 2004,2004 do begin
Yr4  = string( year, format = '(i4.4)')

for day = 1,1 do begin
Day3 = string( day, format = '(i3.3)')

ctm_cleanup


;File path
;---------
dir_in = '/z6/satellite/MODIS/Aqua/'+ Yr4 +'/'+ Day3 +'/'
dir_out = '/home/gengguannan/satellite/aod/MODIS/'+ Yr4 +'/'
spawn,'ls '+ dir_in +'MYD04_L2.A'+ Yr4 + Day3 +'*',list_modis


;3D-grid definition for regridding
;---------------------------------
GEOS_Type = CTM_Type( 'GEOS5', res = [2.d0/3d0, 1.d0/2.d0] )
GEOS_Grid = CTM_Grid( GEOS_Type )

grid_lon_mid = GEOS_Grid.Xmid
grid_lat_mid = GEOS_Grid.Ymid
grid_lon_edge = GEOS_Grid.XEDGE
grid_lat_edge = GEOS_Grid.YEDGE

nlon = n_elements(grid_lon_mid)
nlat = n_elements(grid_lat_mid)

dx = GEOS_Type.RESOLUTION[0]
dy = GEOS_Type.RESOLUTION[1]


; Define arrays to read in the data
;----------------------------------
ARRSIZE    = 5500000L
lon_1   = DblArr( ARRSIZE         )
lat_1   = DblArr( ARRSIZE         )
lon_2   = DblArr( ARRSIZE         )
lat_2   = DblArr( ARRSIZE         )
lon_3   = DblArr( ARRSIZE         )
lat_3   = DblArr( ARRSIZE         )
lon_4   = DblArr( ARRSIZE         )
lat_4   = DblArr( ARRSIZE         )
value_aod  = FltArr( ARRSIZE         )


;============================
; Regridding starts from here
;============================
modis_array = fltarr(nlon,nlat)
count_array = fltarr(nlon,nlat)

n = 0

for k = 0, n_elements(list_modis)-1 do begin

  print,strtrim((k+1),2)+' file over '+strtrim(n_elements(list_modis),2)+' files to be processed'

  get_modis_data, list_modis[k], AOD, date, latcorner, loncorner

  print,'DATE: '+ date


  npix = n_elements(AOD[*,0])

  for m = 0,n_elements(AOD[0,*])-1 do begin
    lon_1(n:n+npix-1)=loncorner(0:npix-1,m,0)
    lat_1(n:n+npix-1)=latcorner(0:npix-1,m,0)
    lon_2(n:n+npix-1)=loncorner(0:npix-1,m,1)
    lat_2(n:n+npix-1)=latcorner(0:npix-1,m,1)
    lon_3(n:n+npix-1)=loncorner(0:npix-1,m,2)
    lat_3(n:n+npix-1)=latcorner(0:npix-1,m,2)
    lon_4(n:n+npix-1)=loncorner(0:npix-1,m,3)
    lat_4(n:n+npix-1)=latcorner(0:npix-1,m,3)
    value_aod(n:n+npix-1) = AOD(0:npix-1,m)

    n = n+npix
  endfor

  ; Filter (To customize)  
  ind_ok = where((value_aod gt 0) and                        $
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

  print,n_elements(ind_ok)
  if ind_ok[0] eq -1 then goto, next_file

  lon_1 = lon_1(ind_ok)
  lat_1 = lat_1(ind_ok)
  lon_2 = lon_2(ind_ok)
  lat_2 = lat_2(ind_ok)
  lon_3 = lon_3(ind_ok)
  lat_3 = lat_3(ind_ok)
  lon_4 = lon_4(ind_ok)
  lat_4 = lat_4(ind_ok)
  value_aod = value_aod(ind_ok)


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

  inds = polyfillaa(px,py,nlon,nlat,AREAS=areas,POLY_INDICES=polygons_ind,/NO_COMPILED)

  for pp=0L,n_elements(polygons_ind)-2L do begin
    ind_grid_x = inds(polygons_ind(pp):polygons_ind(pp+1)-1) mod nlon
    ind_grid_y = inds(polygons_ind(pp):polygons_ind(pp+1)-1)/fix(nlon)

    for ii=0L,n_elements(ind_grid_x)-1L do begin

      modis_array(ind_grid_x(ii),ind_grid_y(ii))=(modis_array(ind_grid_x(ii),ind_grid_y(ii))*count_array(ind_grid_x(ii),ind_grid_y(ii))+areas(polygons_ind(pp)+ii)*value_aod(pp))/(count_array(ind_grid_x(ii),ind_grid_y(ii))+areas(polygons_ind(pp)+ii))
      count_array(ind_grid_x(ii),ind_grid_y(ii))=count_array(ind_grid_x(ii),ind_grid_y(ii))+areas(polygons_ind(pp)+ii)

    endfor

  endfor

  next_file :

  lon_1   = DblArr( ARRSIZE         )
  lat_1   = DblArr( ARRSIZE         )
  lon_2   = DblArr( ARRSIZE         )
  lat_2   = DblArr( ARRSIZE         )
  lon_3   = DblArr( ARRSIZE         )
  lat_3   = DblArr( ARRSIZE         )
  lon_4   = DblArr( ARRSIZE         )
  lat_4   = DblArr( ARRSIZE         )
  value_aod  = FltArr( ARRSIZE         )

  n = 0

  if k eq N_Elements(list_modis)-1 then begin

    SAVE,modis_array,count_array,grid_lon_mid,grid_lat_mid,filename=dir_out + 'MODIS_'+ strmid(strtrim(dx,2),0,4) +'x'+ strmid(strtrim(dy,2),0,4)+'_'+ date
    print,max(modis_array)

    modis_array(*,*) = 0.
    count_array(*,*) = 0.

  endif


endfor ; loop over files

fin :

endfor
endfor

end
