pro GOCI_result_read

lonlat_file = 'C:\lonlat_GOCI.bin'

sz = lonarr(2)

openr, 1, lonlat_file
readu, 1, sz

lon = fltarr(sz)
lat = fltarr(sz)

readu, 1, lon, lat
close, 1

;for

GOCI_file = 'C:\AOP\AOP_2011040100.bin'

openr, 1, GOCI_file

AOD = fltarr(sz(0), sz(1))

readu, 1, AOD
close, 1

;endfor
stop

end