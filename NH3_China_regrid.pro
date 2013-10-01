pro NH3_China_regrid

Source = ['agri','indu','resi','tran']
SourceOut = ['AGRICULTURE','INDUSTRY','RESIDENTIAL','TRANSPORT']
Basedir = '/home/limeng/r6/MICS/GRID_20121224/GRID/CHN_NH3_SY/'
Outdir = '/home/limeng/r6/MICS/GRID_20121224/GRID/CHN_NH3_SY/'
Intype = ctm_type('generic',res=[1d0/4d0,1d0/4d0], Halfpolar=0, Center180=0)
Ingrid = ctm_grid(Intype)

xmid = Ingrid.xmid
ymid = Ingrid.ymid

; Inverse Projection Here!

   XIN = 1000
   YIN = 1000
   XMX = 5060L
   YMX = 4240L
   XST = -3059693.056928
   YST = -1999997.320268
   XYN = XMX*YMX

In  = fltarr(XMX, YMX)
Out =  fltarr(XMX, YMX)
Locate_lon = Lonarr(XMX, YMX)
Locate_lat = Lonarr(XMX,YMX)
Final = fltarr(Ingrid.imx, Ingrid.jmx)
Line = ''

;-----------------------------------
; Get the location array!
;-----------------------------------
   XX = LonArr( XMX )
   YY = LonArr( YMX )
   XY = LonArr( 2, XYN )
   Lon = fltarr(XYN)
   Lat = fltarr(XYN)

   help, XY
   print, XYN,XMX,YMX,XMX*YMX
   for j = 1L, YMX do begin
     YY[j-1L] = YST+YIN*(j-1L)
   for i = 1L, XMX do begin
     ijloop = (j-1L)*XMX+i
     XX[i-1L] = XST+XIN*(i-1L)

     XY[0L,ijloop-1L] = XX[i-1L]
     XY[1L,ijloop-1L] = YY[j-1L]
   endfor
   endfor

; Initializes a mapping projection
   mapStruct = MAP_PROJ_INIT( 'Lambert Conformal Conic', $
                              STANDARD_PAR1=25, STANDARD_PAR2=47, $
                              CENTER_LONGITUDE=108.916667, CENTER_LATITUDE=34.533333, $
                              DATUM='GRS 1980/WGS 84' )

; Transforms from Cartesian (X, Y) coordinates to longitude/latitude
   LL = MAP_PROJ_INVERSE( XY, MAP_STRUCTURE = mapStruct )
;-----------------------------------
   TotalIN = 0d0
   HalfDegree = 0.125d0
   for j = 1L, YMX do begin
   for i = 1L, XMX do begin

     ijloop = (j-1L)*XMX+i
     Lon[ijloop-1L] = LL[0L,ijloop-1L]
     Lat[ijloop-1L] = LL[1L,ijloop-1L]

     lon_ind = where(xmid le HalfDegree+Lon[ijloop-1L] and (xmid ge Lon[ijloop-1L]-HalfDegree ),count1)
     lat_ind = where(ymid le HalfDegree+Lat[ijloop-1L] and (ymid ge Lat[ijloop-1L]-HalfDegree ),count2)
     lon_ind = max(lon_ind)
     lat_ind = max(lat_ind)
     Locate_lon[i-1L,j-1L] = lon_ind
     Locate_lat[i-1L,j-1L] = lat_ind
    
   endfor
   endfor

;-----------------------------------------------
;for s = 0L,n_elements(Source)-1L do begin
FILE_MKDIR, Outdir
outfile_check = '/home/limeng/r6/MICS/Check/NH3_China_fromSY.txt'
openw, ilun_fc, outfile_check,/GET_LUN
s = 0 ; agriculture!

for m = 1, 12 do begin 
Final[*,*] = 0.0
TotalIn = 0d0
m2 = string(m,format='(i2.2)')
Infile = Basedir+Source[s]+'/'+'E__NH3_'+Source[s]+'_'+m2+'.txt'
openr, ilun, Infile,/GET_LUN
readf, ilun, Line
readf, ilun, Line
readf, ilun, Line
readf, ilun, Line
readf, ilun, Line
readf, ilun, Line
readf, ilun, In
close, ilun
free_lun, ilun

index = where(IN ne -9999)
print,'In', min(In),max(In), total(In[index])
In= reverse(In,2)

for j = 1L, YMX do begin
   for i = 1L, XMX do begin
    TotalIN += IN[i-1L,j-1L]
    if(In[i-1L,j-1L] ne -9999) then begin
    lon_index = Locate_lon[i-1L,j-1L]
    lat_index = Locate_lat[i-1L,j-1L]
    Final[lon_index,lat_index] += In[i-1L,j-1L]
    endif
   endfor
endfor
 Final = reverse(Final,2)
 Final[*,*] = Final[*,*] / 1000.0 ; change unit to t/month
printf,ilun_fc,SourceOut[s],' ',m2,' ',total(Final),' ','t/month'
print, 'TotalIn',Totalin
print,'final',total(Final)
 outfile_out = Outdir +'China_NH3_'+SourceOut[s]+'_2008_'+m2+'_0.25x0.25'+'.asc'
 openw, ilun, outfile_out,/GET_LUN
 printf, ilun, 'ncols 1440'
 printf, ilun, 'nrows 720'
 printf, ilun, 'xllcorner -180.0'
 printf, ilun, 'yllcorner -90.0'
 printf, ilun, 'cellsize 0.25'
 printf, ilun, 'NODATA_Value -9999'
 printf, ilun, Final
 close, ilun
 free_lun,ilun

 outfile_out = Outdir +'China_NH3_'+SourceOut[s]+'_2010_'+m2+'_0.25x0.25'+'.asc'
 openw, ilun, outfile_out,/GET_LUN
 printf, ilun, 'ncols 1440'
 printf, ilun, 'nrows 720'
 printf, ilun, 'xllcorner -180.0'
 printf, ilun, 'yllcorner -90.0'
 printf, ilun, 'cellsize 0.25'
 printf, ilun, 'NODATA_Value -9999'
 printf, ilun, Final
 close, ilun
 free_lun,ilun

endfor
;----------------------------------------
for s = 1, n_elements(Source)-1 do begin
m = 1
Final[*,*] = 0.0
TotalIn = 0d0

m2 = string(m,format='(i2.2)')
if( Source[s] eq 'tran' ) then Infile = Basedir+Source[s]+'/'+'E__NH3_'+Source[s]+'_'+m2+'.txt' $
else Infile = Basedir+Source[s]+'/'+'E_NH3_'+Source[s]+'_'+m2+'.txt'

openr, ilun, Infile,/GET_LUN
readf, ilun, Line
readf, ilun, Line
readf, ilun, Line
readf, ilun, Line
readf, ilun, Line
readf, ilun, Line
readf, ilun, In
close, ilun
free_lun, ilun

index = where(IN ne -9999)
print,'In', min(In),max(In), total(In[index])
In= reverse(In,2)

for j = 1L, YMX do begin
   for i = 1L, XMX do begin
    TotalIn += In[i-1L,j-1L]
    if(In[i-1L,j-1L] ne -9999) then begin
    lon_index = Locate_lon[i-1L,j-1L]
    lat_index = Locate_lat[i-1L,j-1L]
    Final[lon_index,lat_index] += In[i-1L,j-1L]
    endif
   endfor
endfor
 Final = reverse(Final,2)
 Final = Final/1000.0 ; change unit to t/month
printf,ilun_fc,SourceOut[s],' ',m2,' ',total(Final),' ','t/month'
 print,'In',total(In)
 print,'totalin',TotalIn
 print, 'Final',min(Final),max(Final),total(Final), Source[s], m2
for m = 1,12 do begin
    m2 = string(m,format='(i2.2)')
 outfile_out = Outdir +'China_NH3_'+SourceOut[s]+'_2008_'+m2+'_0.25x0.25'+'.asc'
 openw, ilun, outfile_out,/GET_LUN
 printf, ilun, 'ncols 1440'
 printf, ilun, 'nrows 720'
 printf, ilun, 'xllcorner -180.0'
 printf, ilun, 'yllcorner -90.0'
 printf, ilun, 'cellsize 0.25'
 printf, ilun, 'NODATA_Value -9999'
 printf, ilun, Final
 close, ilun
 free_lun,ilun

 outfile_out = Outdir +'China_NH3_'+SourceOut[s]+'_2010_'+m2+'_0.25x0.25'+'.asc'
 openw, ilun, outfile_out,/GET_LUN
 printf, ilun, 'ncols 1440'
 printf, ilun, 'nrows 720'
 printf, ilun, 'xllcorner -180.0'
 printf, ilun, 'yllcorner -90.0'
 printf, ilun, 'cellsize 0.25'
 printf, ilun, 'NODATA_Value -9999'
 printf, ilun, Final
 close, ilun
 free_lun,ilun
endfor
endfor
close,ilun_fc
free_lun,ilun_fc
end


