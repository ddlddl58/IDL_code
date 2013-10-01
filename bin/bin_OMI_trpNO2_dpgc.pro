; NAME:
;        BIN_OMI_TRPNO2
;
; VERSION:
;        2.0
;
; AUTHOR:
;        N. Bousserez (October 21, 2009)
;
;        Atmospheric Composition Analysis Group,
;        Dalhousie University, Halifax, CA
;
; DESCRIPTION:
;        Performs daily tropospheric NO2 columns regriding from
;        OMI DOMINO NO2 product
;
; CATEGORY:
;        Satellite data regriding
;
; CALLING SEQUENCE:
;        BIN_OMI_TRPNO2
;
; OUTPUTS:
;        IDL format file(s) (.xdr) containing the new NO2 values array,
;        longitude and latitude coordinates of grid pixel centers
;
; SUBROUTINES USED:
;        polyfillaa (J.D. Smith's code, see http://tir.astro.utoledo.edu
;                    /jdsmith/code/idl.php for more information)
;
;        get_omdomino_nrtp_data
;
; NOTES:
;        Grid resolution has to be specified in section "3D-grid definition below
;        Path/files are defined in sections "Paths" and "List OMI files" below
;        Data filtering has to be adapted depending on your needs. See sections
;        "Filtering parameters" and "Filtering"
;        This routine applies to OMI NO2 DOMINO product, but could easily be
;        adapted for other type of measurements.
;        Please contact the author if you need help on that.
;
; Please report any bugs/improvements to: N.Bousserez@dal.ca
;
;##############################################################################
;
; LICENSE
;
;  Copyright (C) 2009-2010 N. Bousserez
;
;  This file is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published
;  by the Free Software Foundation; either version 2, or (at your
;  option) any later version.
;
;  This file is distributed in the hope that it will be useful, but
;  WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;  General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this file; see the file COPYING.  If not, write to the
;  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;  Boston, MA 02110-1301, USA.
;
;##############################################################################


@polyfillaa
@get_dpgc_data


PRO bin_OMI_trpNO2_dpgc

for dir_year = 2005,2006 do begin
Yr4 = string( dir_year, format = '(i4.4)')

for dir_month = 1,12 do begin
Mon2 = string( dir_month, format = '(i2.2)')

ctm_cleanup

;Paths
;-----
dir_omi = '/z6/satellite/OMI/no2/DOMINO_S_v2/'+ Yr4 +'/'+ Mon2 +'/'
dir_out = '/home/gengguannan/satellite/no2/OMI_KNMI_v2.0_DPGC/05x0666/'+ Yr4 +'/'
spawn,'ls '+dir_omi+'OMI-Aura_L2*_'+ Yr4 +'m'+ Mon2 +'*.he5',list_omi


;Filtering parameters
;-------------------
;1: remove large pixels; 0: take into account each pixel
large_pixels = 1
;lp represents the number of edge pixels you want to remove on each side
if large_pixels eq 1 then lp=10 else lp=0
missing=-999.


; Julian day reference
;---------------------
julday_ref = double(JULDAY(1,1,1993,0,0,0))


; Define arrays to read in the data
;----------------------------------
ARRSIZE    = 5500000L
lon_NO2_1   = DblArr( ARRSIZE         )
lat_NO2_1   = DblArr( ARRSIZE         )
lon_NO2_2   = DblArr( ARRSIZE         )
lat_NO2_2   = DblArr( ARRSIZE         )
lon_NO2_3   = DblArr( ARRSIZE         )
lat_NO2_3   = DblArr( ARRSIZE         )
lon_NO2_4   = DblArr( ARRSIZE         )
lat_NO2_4   = DblArr( ARRSIZE         )
time_NO2  = DblArr( ARRSIZE         )
value_NO2 = FltArr( ARRSIZE         )
crd_NO2 = LonArr( ARRSIZE         )
sza_NO2 = FltArr( ARRSIZE         )
flg_NO2 = FltArr( ARRSIZE         )
tramf_NO2 = FltArr( ARRSIZE         )
colerr_NO2 = FltArr( ARRSIZE         )
spix_NO2 = FltArr( ARRSIZE         )


;3D-grid definition
;------------------
GEOS_Type = CTM_Type( 'GEOS5', res = [2.d0/3d0, 1.d0/2.d0] )
;GEOS_Type = CTM_Type( 'GENERIC', res = [0.1d0, 0.1d0] )
GEOS_Grid = CTM_Grid( GEOS_Type )
grid_lon_mid = GEOS_Grid.Xmid
grid_lat_mid = GEOS_Grid.Ymid
grid_lon_edge = GEOS_Grid.XEDGE
grid_lat_edge = GEOS_Grid.YEDGE

dx = GEOS_Type.RESOLUTION[0]
dy = GEOS_Type.RESOLUTION[1]

nlon = n_elements(grid_lon_mid)
nlat = n_elements(grid_lat_mid)
;-------------------------------------


omi_array = fltarr(nlon,nlat)
count_array = fltarr(nlon,nlat)

n = 0
 
for k = 0, n_elements(list_omi)-1 do begin

PRINT,strtrim((k+1),2)+' file(s) over '+strtrim(n_elements(list_omi),2)+' files to be processed'

get_dpgc_data, list_omi(k), mtime, spx, sza, vzen, azi, vazi, $
  latcorner, loncorner, g_lat, g_lon, slntcolno2, slntcolno2std, $
  tm4slntcol, geoamf, amf, tramf, no2cl, no2clstd, trp_flg, $
  no2trp, no2trpstd, gvc, cfr, cldpre, spre, sht, crd, salb, errcol


jd = double(julday_ref + mtime(0)/(3600.D0*24.D0))
CALDAT, jd , MM, DD, YY, HH, MINUTES, SEC

;Apply the filter for row anomaly
IF yy EQ 2005 OR yy EQ 2006 THEN BEGIN 
    anomalies = 0   
ENDIF ELSE BEGIN
    anomalies = 1
ENDELSE

if k EQ 0 then CALDAT, jd , prev_MM, prev_DD, prev_YY, prev_HH, prev_MINUTES, prev_SEC

PRINT,'DATE: ',strtrim(MM,2),'/', strtrim(DD,2),'/', strtrim(YY,2),'/',strtrim(HH,2),':',strtrim(MINUTES,2),'UTC'

if DD NE prev_DD OR k EQ N_Elements(list_omi)-1 then begin

    if prev_MM LT 10 then month='0'+strtrim(prev_MM,2) else month=strtrim(prev_MM,2)
    if prev_DD LT 10 then day='0'+strtrim(prev_DD,2) else day=strtrim(prev_DD,2)
    SAVE,omi_array,grid_lon_mid,grid_lat_mid,filename=dir_out + 'OMI_'+ strmid(strtrim(dx,2),0,4) +'x'+ $
      strmid(strtrim(dy,2),0,4)+'_'+strtrim(prev_YY,2)+'_'+month+'_'+day

    omi_array(*,*) = 0.
    count_array(*,*) = 0.

endif
 
CALDAT, jd , prev_MM, prev_DD, prev_YY, prev_HH, prev_MINUTES, prev_SEC

;----
; Anomaly 1 (since June 25th 2007) ==> 53:54
; Anomaly 2 (since May, 11th 2008) ==> 37:42
; Anomaly 2 (since December, 3rd 2008) ==> 37:44 
; Anomaly 3 (since January, 24th 2009) ==> 27:44

IF (anomalies EQ 1) THEN BEGIN
    PRINT,'REMOVING OMI NO2 ANOMALIES...'
    IF ((yy EQ 2007) AND (MM GE 7)) THEN BEGIN
        no2trp(53:54,*) = missing   
    ENDIF ELSE IF ((yy EQ 2008) AND (MM LE 4)) THEN BEGIN
        no2trp(53:54,*) = missing   
    ENDIF ELSE IF ((yy EQ 2008) AND (MM GT 4 AND MM LT 12)) THEN BEGIN
        no2trp(53:54,*) = missing
        no2trp(37:42,*) = missing
    ENDIF ELSE IF ((yy EQ 2008) AND (MM EQ 12)) THEN BEGIN  
        no2trp(53:54,*) = missing
        no2trp(37:44,*) = missing
    ENDIF ELSE IF (yy EQ 2009) THEN BEGIN  
        no2trp(53:54,*) = missing
        no2trp(27:44,*) = missing
    ENDIF
ENDIF

npix = N_ELements(no2trp[*,0])
 
for m=0,n_elements(g_lon(0,*))-1 do begin

    lon_NO2_1(n:n+(npix-lp)-1)=loncorner(lp/2:npix-(lp/2+1),m,0)
    lat_NO2_1(n:n+(npix-lp)-1)=latcorner(lp/2:npix-(lp/2+1),m,0)
    lon_NO2_2(n:n+(npix-lp)-1)=loncorner(lp/2:npix-(lp/2+1),m,1)
    lat_NO2_2(n:n+(npix-lp)-1)=latcorner(lp/2:npix-(lp/2+1),m,1)
    lon_NO2_3(n:n+(npix-lp)-1)=loncorner(lp/2:npix-(lp/2+1),m,2)
    lat_NO2_3(n:n+(npix-lp)-1)=latcorner(lp/2:npix-(lp/2+1),m,2)
    lon_NO2_4(n:n+(npix-lp)-1)=loncorner(lp/2:npix-(lp/2+1),m,3)
    lat_NO2_4(n:n+(npix-lp)-1)=latcorner(lp/2:npix-(lp/2+1),m,3)
    time_NO2(n:n+(npix-lp)-1)=mtime(m)
    value_NO2(n:n+(npix-lp)-1) = no2trp(lp/2:npix-(lp/2+1),m)
    flg_NO2(n:n+(npix-lp)-1) = trp_flg(lp/2:npix-(lp/2+1),m)
    crd_NO2(n:n+(npix-lp)-1) = crd(lp/2:npix-(lp/2+1),m)
    sza_NO2(n:n+(npix-lp)-1) = sza(lp/2:npix-(lp/2+1),m)
    tramf_NO2(n:n+(npix-lp)-1) = tramf(lp/2:npix-(lp/2+1),m)
    colerr_NO2(n:n+(npix-lp)-1) = errcol(lp/2:npix-(lp/2+1),m)
    spix_NO2(n:n+(npix-lp)-1) = spx(lp/2:npix-(lp/2+1),m)

    n=n+(npix-lp)

endfor
   

;FILTERING (To customize)
;-----------------------
ind_ok = where((time_NO2 GT 0) AND                                        $
               (flg_NO2 EQ 0) AND                                         $
               (FINITE(value_NO2) EQ 1) AND                               $
               (sza_NO2 LE 70.) AND                                       $
               (crd_NO2/100. GE 0. AND crd_NO2/100. LE 30.) AND           $
               (tramf_NO2 GT 0.5) AND                                     $
               (lon_NO2_1 LT MAX(grid_lon_mid)) AND                       $
               (lon_NO2_2 LT MAX(grid_lon_mid)) AND                       $
               (lon_NO2_3 LT MAX(grid_lon_mid)) AND                       $
               (lon_NO2_4 LT MAX(grid_lon_mid)) AND                       $
               (lat_NO2_1 LT MAX(grid_lat_mid)) AND                       $
               (lat_NO2_2 LT MAX(grid_lat_mid)) AND                       $
               (lat_NO2_3 LT MAX(grid_lat_mid)) AND                       $
               (lat_NO2_4 LT MAX(grid_lat_mid)) AND                       $
               (lon_NO2_4 LT lon_NO2_2 AND lon_NO2_3 LT lon_NO2_1) AND    $
               (lat_NO2_4 LT lat_NO2_3 AND lat_NO2_2 LT lat_NO2_1))
  
if ind_ok(0) EQ -1 then goto, next_file

lon_NO2_1 = lon_NO2_1(ind_ok)
lat_NO2_1 = lat_NO2_1(ind_ok)
lon_NO2_2 = lon_NO2_2(ind_ok)
lat_NO2_2 = lat_NO2_2(ind_ok)
lon_NO2_3 = lon_NO2_3(ind_ok)
lat_NO2_3 = lat_NO2_3(ind_ok)
lon_NO2_4 = lon_NO2_4(ind_ok)
lat_NO2_4 = lat_NO2_4(ind_ok)
time_NO2 = time_NO2(ind_ok)
value_NO2 = value_NO2(ind_ok)


;binning
;-------
;SCALING OF THE COORDINATES TO GRID INDEXES
lon_NO2_1_unit = (lon_NO2_1-grid_lon_edge(0))/(grid_lon_edge(n_elements(grid_lon_edge)-1)-grid_lon_edge(0))*nlon
lat_NO2_1_unit = (lat_NO2_1-grid_lat_edge(0))/(grid_lat_edge(n_elements(grid_lat_edge)-1)-grid_lat_edge(0))*nlat
lon_NO2_2_unit = (lon_NO2_2-grid_lon_edge(0))/(grid_lon_edge(n_elements(grid_lon_edge)-1)-grid_lon_edge(0))*nlon
lat_NO2_2_unit = (lat_NO2_2-grid_lat_edge(0))/(grid_lat_edge(n_elements(grid_lat_edge)-1)-grid_lat_edge(0))*nlat
lon_NO2_3_unit = (lon_NO2_3-grid_lon_edge(0))/(grid_lon_edge(n_elements(grid_lon_edge)-1)-grid_lon_edge(0))*nlon
lat_NO2_3_unit = (lat_NO2_3-grid_lat_edge(0))/(grid_lat_edge(n_elements(grid_lat_edge)-1)-grid_lat_edge(0))*nlat
lon_NO2_4_unit = (lon_NO2_4-grid_lon_edge(0))/(grid_lon_edge(n_elements(grid_lon_edge)-1)-grid_lon_edge(0))*nlon
lat_NO2_4_unit = (lat_NO2_4-grid_lat_edge(0))/(grid_lat_edge(n_elements(grid_lat_edge)-1)-grid_lat_edge(0))*nlat
   
px = Dblarr(4*n_elements(lon_NO2_1_unit))
py = Dblarr(4*n_elements(lon_NO2_1_unit))
polygons_ind = lon64arr(n_elements(lon_NO2_1_unit)+1)
    
for nn=0L,n_elements(lon_NO2_1_unit)-1 do begin
    polygons_ind(nn) = 4*nn
    px(4*nn) = lon_NO2_4_unit(nn)
    px(4*nn+1) =  lon_NO2_3_unit(nn)
    px(4*nn+2) = lon_NO2_1_unit(nn)
    px(4*nn+3) = lon_NO2_2_unit(nn)
    py(4*nn) = lat_NO2_4_unit(nn)
    py(4*nn+1) =  lat_NO2_3_unit(nn)
    py(4*nn+2) = lat_NO2_1_unit(nn)
     py(4*nn+3) = lat_NO2_2_unit(nn)
endfor

polygons_ind(n_elements(lon_NO2_1_unit)) = 4*n_elements(lon_NO2_1_unit)
inds = polyfillaa(px,py,nlon,nlat,AREAS=areas,POLY_INDICES=polygons_ind) ;,/RECOMPILE)           
for pp=0L,n_elements(polygons_ind)-2L do begin
  ind_grid_x = inds(polygons_ind(pp):polygons_ind(pp+1)-1) mod nlon
  ind_grid_y = inds(polygons_ind(pp):polygons_ind(pp+1)-1)/fix(nlon)
  for ii=0L,n_elements(ind_grid_x)-1L do begin
    omi_array(ind_grid_x(ii),ind_grid_y(ii)) =  (omi_array(ind_grid_x(ii),ind_grid_y(ii))*count_array(ind_grid_x(ii),ind_grid_y(ii)) + areas(polygons_ind(pp)+ii)*value_NO2(pp))/(count_array(ind_grid_x(ii),ind_grid_y(ii))+areas(polygons_ind(pp)+ii))
    count_array(ind_grid_x(ii),ind_grid_y(ii)) = count_array(ind_grid_x(ii),ind_grid_y(ii)) + areas(polygons_ind(pp)+ii)
  endfor
endfor

;print,max(omi_array)

next_file :   
  
lon_NO2_1   = DblArr( ARRSIZE         )
lat_NO2_1   = DblArr( ARRSIZE         )
lon_NO2_2   = DblArr( ARRSIZE         )
lat_NO2_2   = DblArr( ARRSIZE         )
lon_NO2_3   = DblArr( ARRSIZE         )
lat_NO2_3   = DblArr( ARRSIZE         )
lon_NO2_4   = DblArr( ARRSIZE         )
lat_NO2_4   = DblArr( ARRSIZE         )
time_NO2  = FltArr( ARRSIZE         )
value_NO2 = FltArr( ARRSIZE         )
crd_NO2 = LonArr( ARRSIZE         )
sza_NO2 = FltArr( ARRSIZE         )
flg_NO2 = FltArr( ARRSIZE         )
ramf_NO2 = FltArr( ARRSIZE         )
colerr_NO2 = FltArr( ARRSIZE         )
spix_NO2 = FltArr( ARRSIZE         )  
 
n = 0      
endfor ; loop over files

fin :

endfor
endfor

END
