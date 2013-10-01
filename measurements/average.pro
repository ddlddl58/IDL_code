pro average

year = 2013
for month = 1,6 do begin

  Mon2 = string( month, format = '(i2.2)')

  infile = '/home/gengguannan/indir/data/2013'+ Mon2 +'.csv'
  outfile = '/home/gengguannan/2013'+ Mon2 +'.hdf'


  OPENR, lun, infile, /GET_LUN

  headline = ''
  READF, lun, headline
  head = STRSPLIT(headline,',',/EXTRACT,COUNT=n_p)

  ind1 = where( head eq 'Area_code' )
  ind2 = where( head eq 'O3' )
  ind3 = where( head eq 'PM2_5' )

  print,ind1,ind2,ind3

  avg_o3 = make_array(74)
  avg_pm = make_array(74)
  nod_o3 = make_array(74)
  nod_pm = make_array(74)

  while ~EOF(lun) do begin

    line = ''
    READF, lun, line
    arr = STRSPLIT(line,',',/EXTRACT,COUNT=n)

    if n ne n_p then continue

    city = long(arr[ind1])

    if arr[ind2] ne 'NULL' and arr[ind2] ne '0' then begin
      avg_o3[city-1] += float(arr[ind2])
      nod_o3[city-1] += 1
    endif

    if arr[ind3] ne 'NULL' and arr[ind2] ne '0' then begin
      avg_pm[city-1] += float(arr[ind3])
      nod_pm[city-1] += 1
    endif

  endwhile

  CLOSE, lun
  FREE_LUN, lun

  avg_o3 = avg_o3 / nod_o3
  avg_pm = avg_pm / nod_pm



  ; Find out if HDF is supported on this platform
  IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

  ; Open the HDF file
  FID = HDF_SD_START(outfile,/RDWR,/Create)
  IF ( FID lt 0 ) then Message, 'Error opening file!'

  HDF_SETSD, FID, avg_o3, 'o3',            $
             Longname='O3',                $
             Unit='ug/m3',                 $
             FILL=-999.0
  HDF_SETSD, FID, avg_pm, 'pm2.5',         $
             Longname='PM2.5',             $
             Unit='ug/m3',                 $
             FILL=-999.0
  HDF_SD_End, FID

  CTM_CLEANUP

endfor

end
