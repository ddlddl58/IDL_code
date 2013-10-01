pro NH3_China_regrid

Intype = ctm_type('generic',res=[0.5d0,0.5d0], Halfpolar=0, Center180=0)
Ingrid = ctm_grid(Intype)

xmid = Ingrid.xmid
ymid = Ingrid.ymid

;--------------------------
; Inverse Projection Here!
;--------------------------
XIN = 1000
YIN = 1000
XMX = 5060L
YMX = 4240L
XST = -3059693.056928
YST = -1999997.320268
XYN = XMX*YMX

XX = LonArr( XMX )
YY = LonArr( YMX )
XY = LonArr( 2, XYN )
Lon = fltarr(XYN)
Lat = fltarr(XYN)
Locate_lon = Lonarr(XMX, YMX)
Locate_lat = Lonarr(XMX,YMX)

;help, XY
;print, XYN,XMX,YMX,XMX*YMX

for j = 0L, YMX-1 do begin
  YY[j] = YST+YIN*j
  for i = 0L, XMX-1 do begin
    ijloop = j*XMX+i
    XX[i] = XST+XIN*i

    XY[0L,ijloop] = XX[i]
    XY[1L,ijloop] = YY[j]
  endfor
endfor

; Initializes a mapping projection
mapStruct = MAP_PROJ_INIT( 'Lambert Conformal Conic', $
                           STANDARD_PAR1=25, STANDARD_PAR2=47, $
                           CENTER_LONGITUDE=108.916667, CENTER_LATITUDE=34.533333, $
                           DATUM='GRS 1980/WGS 84' )

; Transforms from Cartesian (X, Y) coordinates to longitude/latitude
LL = MAP_PROJ_INVERSE( XY, MAP_STRUCTURE = mapStruct )

help,LL

HalfDegree = 0.25d0

for j = 0L, YMX-1 do begin
  for i = 0L, XMX-1 do begin

    ijloop = j*XMX+i
    Lon[ijloop] = LL[0L,ijloop]
    Lat[ijloop] = LL[1L,ijloop]

    lon_ind = where(xmid le HalfDegree+Lon[ijloop] and (xmid ge Lon[ijloop]-HalfDegree ))
    lat_ind = where(ymid le HalfDegree+Lat[ijloop] and (ymid ge Lat[ijloop]-HalfDegree ))
    lon_ind = max(lon_ind)
    lat_ind = max(lat_ind)
    Locate_lon[i,j] = lon_ind
    Locate_lat[i,j] = lat_ind
    
  endfor
endfor


;-----------------------
; regrid emissions here
;-----------------------
Source = ['agri','indu','resi','tran']
Indir = '/home/gengguannan/indir/NH3_Huang/'
Outdir = '/home/gengguannan/indir/NH3_Huang/'

In  = fltarr(XMX, YMX)
Out =  fltarr(XMX, YMX)
Final = fltarr(Ingrid.imx, Ingrid.jmx)
Line = ''


; Agriculture
s = 0

for month = 1,12 do begin
Mon2 = string( month,format='(i2.2)')

Infile = Outdir + 'E__NH3_'+ Source[s] +'_'+ Mon2 +'.txt'
Outfile = Outdir + 'NH3_'+ Source[s] +'_'+ Mon2 +'.txt'

Final[*,*] = 0.0
TotalIn = 0d0

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

for j = 0L, YMX-1 do begin
  for i = 0L, XMX-1 do begin

    TotalIN += IN[i,j]

    if(In[i,j] ne -9999) then begin
      lon_index = Locate_lon[i,j]
      lat_index = Locate_lat[i,j]
      Final[lon_index,lat_index] += In[i,j]
    endif

  endfor
endfor

Final = reverse(Final,2)

print,Source[s],' ',Mon2,' ',total(Final),' ','kg/month'
print, 'TotalIn',Totalin
print,'final',total(Final)

openw, ilun, Outfile,/GET_LUN
printf, ilun, 'ncols 3600'
printf, ilun, 'nrows 1800'
printf, ilun, 'xllcorner -180.0'
printf, ilun, 'yllcorner -90.0'
printf, ilun, 'cellsize 0.1'
printf, ilun, 'NODATA_Value -9999'
printf, ilun, Final
close, ilun
free_lun,ilun

endfor


; Other sectors
for s = 1, n_elements(Source)-1 do begin

month = 1
Mon2 = string(month,format='(i2.2)')

Final[*,*] = 0.0
TotalIn = 0d0

Infile = Indir +'E__NH3_'+Source[s]+'_'+ Mon2 +'.txt'

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

for j = 0L, YMX-1 do begin
    for i = 0L, XMX-1 do begin

    TotalIn += In[i,j]

    if(In[i,j] ne -9999) then begin
      lon_index = Locate_lon[i,j]
      lat_index = Locate_lat[i,j]
      Final[lon_index,lat_index] += In[i,j]
    endif

  endfor
endfor

Final = reverse(Final,2)

print,Source[s],' ',Mon2,' ',total(Final),' ','kg/month'
print,'In',total(In)
print,'totalin',TotalIn
print, 'Final',min(Final),max(Final),total(Final), Source[s]

Outfile = Outdir +'NH3_'+ Source[s] +'_01.txt'

openw, ilun, outfile_out,/GET_LUN
printf, ilun, 'ncols 3600'
printf, ilun, 'nrows 1800'
printf, ilun, 'xllcorner -180.0'
printf, ilun, 'yllcorner -90.0'
printf, ilun, 'cellsize 0.1'
printf, ilun, 'NODATA_Value -9999'
printf, ilun, Final
close, ilun
free_lun,ilun

endfor

end

