pro primary_pollutant

year = 2013

if year eq 2004 or year eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

final = fltarr(74,7)

for month = 1,9 do begin

  Mon2 = string( month, format = '(i2.2)')

  infile = '/home/gengguannan/indir/data/2013'+ Mon2 +'.csv'
  outfile = '/home/gengguannan/2013'+ Mon2 +'.hdf'


  ; calculate concentration
  OPENR, lun, infile, /GET_LUN

  headline = ''
  READF, lun, headline
  head = STRSPLIT(headline,',',/EXTRACT,COUNT=n_p)

  pollutants = ['CO','NO2','SO2','PM10','PM2_5','O3','O3_8h']

  ind_area = where( head eq 'Area_code' )
  ind_time = where( head eq 'TimePoint' )
  ind_station = where( head eq 'StationCode' )

  avg = fltarr(74,Dayofmonth[month-1],24,7)
  nod = fltarr(74,Dayofmonth[month-1],24,7)
  flag = fltarr(564,Dayofmonth[month-1],24)
  conc = fltarr(74,Dayofmonth[month-1],7)

  while ~EOF(lun) do begin

    line = ''
    READF, lun, line
    arr = STRSPLIT(line,',',/EXTRACT,COUNT=n)

    if n ne n_p then continue

    city = long(arr[ind_area])
    time_temp = arr[ind_time]
    station_temp = arr[ind_station]
    time = STRSPLIT(time_temp,' ',/EXTRACT)
    day = (STRSPLIT(time[0],'/',/EXTRACT))[2]
    hour = (STRSPLIT(time[1],':',/EXTRACT))[0]
    station = long(STRMID(station_temp,0,4))

    if flag[station-1001,day-1,hour] eq 1 then continue
    flag[station-1001,day-1,hour] = 1

    for pp = 0,7-1 do begin

      ind = where( head eq pollutants[pp] )
  
      if arr[ind] ne 'NULL' and arr[ind] ne '0' then begin
        avg[city-1,day-1,hour,pp] += float(arr[ind])
        nod[city-1,day-1,hour,pp] += 1
      endif

    endfor

  endwhile

  CLOSE, lun
  FREE_LUN, lun

  for cc = 0,74-1 do begin
    for dd = 0,Dayofmonth[month-1]-1 do begin
      for hh = 0,24-1 do begin
        for pp = 0,7-1 do begin
          if nod[cc,dd,hh,pp] gt 0 then avg[cc,dd,hh,pp] = avg[cc,dd,hh,pp] / nod[cc,dd,hh,pp]
        endfor
      endfor
    endfor
  endfor


  for cc = 0,74-1 do begin
    for dd = 0,Dayofmonth[month-1]-1 do begin

      for pp = 0,4 do begin
        conc_temp = reform(avg[cc,dd,*,pp])
        valid_index = where(conc_temp ne 0)
        if valid_index[0] eq -1 $
          then conc[cc,dd,pp] = 0 $
          else conc[cc,dd,pp] = mean(conc_temp[valid_index])
      endfor

      for pp = 5,6 do begin
        conc[cc,dd,pp] = max(avg[cc,dd,*,pp])
      endfor

    endfor
  endfor

  ; calculate AQI
  eta = [ [0,2,4,14,24,36,48,60], $ 
          [0,40,80,180,280,565,750,940], $
          [0,50,150,475,800,1600,2100,2620], $
          [0,50,150,250,350,420,500,600], $
          [0,35,75,115,150,250,350,500], $
          [0,160,200,300,400,800,1000,1200] ]

  eta0 = [0,100,160,215,265,800]

  aqi = [0,50,100,150,200,300,400,500]
  iaqi = fltarr(74,Dayofmonth[month-1],7)

  primary_p = fltarr(74,Dayofmonth[month-1])

  for cc = 0,74-1 do begin
    for dd = 0,Dayofmonth[month-1]-1 do begin

      for pp = 0,5 do begin
        iaqi[cc,dd,pp] = INTERPOL( aqi, eta[*,pp], conc[cc,dd,pp] )
      endfor

      pp = 6
      if conc[cc,dd,pp] gt 800 $
        then iaqi[cc,dd,pp] = 0 $
        else iaqi[cc,dd,pp] = INTERPOL( aqi[0:5], eta0, conc[cc,dd,pp] )

      if total(iaqi[cc,dd,*]) eq 0 $
        then primary_p[cc,dd] = 0 $
        else primary_p[cc,dd] = (where(iaqi[cc,dd,*] eq max(iaqi[cc,dd,*])))[0] + 1

    endfor
  endfor

  totaldays = fltarr(74,7)

  for cc = 0,74-1 do begin
    for pp = 0,7-1 do begin
      valid_day = where(primary_p[cc,*] eq (pp+1))
      if valid_day[0] ne -1 then totaldays[cc,pp] = n_elements(valid_day)
    endfor
  endfor

print,totaldays[0,*]

  ; Find out if HDF is supported on this platform
  IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

  ; Open the HDF file
  FID = HDF_SD_START(outfile,/RDWR,/Create)
  IF ( FID lt 0 ) then Message, 'Error opening file!'

  HDF_SETSD, FID, iaqi, 'IAQI',       $
             Longname='IAQI',         $
             Unit='',                 $
             FILL=-999.0
  HDF_SETSD, FID, primary_p, 'primary_pollutants',         $
             Longname='',             $
             Unit='',                 $
             FILL=-999.0
  HDF_SETSD, FID, totaldays, 'days',  $
             Longname='',             $
             Unit='',                 $
             FILL=-999.0
  HDF_SD_End, FID

  CTM_CLEANUP

  final = final + totaldays

endfor

FID = HDF_SD_START('/home/gengguannan/test.hdf',/RDWR,/Create)
IF ( FID lt 0 ) then Message, 'Error opening file!'

HDF_SETSD, FID, final, 'days',  $
           Longname='',             $
           Unit='',                 $
           FILL=-999.0
HDF_SD_End, FID


end
