pro average

infile = '/home/gengguannan/indir/data/lat_lon.csv'
outfile = '/home/gengguannan/lat_lon.hdf'

OPENR, lun, infile, /GET_LUN

headline = ''
READF, lun, headline
head = STRSPLIT(headline,',',/EXTRACT,COUNT=n_p)

ind1 = where( head eq 'Area_code' )
ind2 = where( head eq 'Latitude' )
ind3 = where( head eq 'Longitude' )

print,ind1,ind2,ind3

avg_lat = make_array(74)
avg_lon = make_array(74)
nod = make_array(74)

while ~EOF(lun) do begin

  line = ''
  READF, lun, line
  arr = STRSPLIT(line,',',/EXTRACT,COUNT=n)

  if n ne n_p then continue

  city = long(arr[ind1])

  avg_lat[city-1] += float(arr[ind2])
  avg_lon[city-1] += float(arr[ind3])
  nod[city-1] += 1

endwhile

CLOSE, lun
FREE_LUN, lun

avg_lat = avg_lat / nod
avg_lon = avg_lon / nod


; Find out if HDF is supported on this platform
IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_START(outfile,/RDWR,/Create)
IF ( FID lt 0 ) then Message, 'Error opening file!'

HDF_SETSD, FID, avg_lat, 'lat',          $
           Longname='lat',               $
           Unit='',                      $
           FILL=-999.0
HDF_SETSD, FID, avg_lon, 'lon',          $
           Longname='lon',               $
           Unit='',                      $
           FILL=-999.0
HDF_SD_End, FID

end
