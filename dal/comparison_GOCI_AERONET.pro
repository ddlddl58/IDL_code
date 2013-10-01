pro comparison_GOCI_AERONET

filename = '/data1/guannan/data/locations.txt'

no = FILE_LINES(filename)
file_list = STRARR(no)

OPENR, lun, filename, /GET_LUN
READF, lun, file_list
CLOSE, lun
FREE_LUN, lun

time = [0.010417,0.052083,0.093750,0.135417,0.177083,$
        0.218750,0.260417,0.302083,0.343750]

for k = 0,0 do begin

  length = STRLEN(file_list(k))
  site = STRMID(file_list(k),14,length-20)

  print,'file '+ file_list(k) +' is processed'

  aero_file = '/data4/kelaar/AERONET/AOT_20120412/LEV20/ALL_POINTS/'+ file_list(k)

  row = FILE_LINES(aero_file)
  line = ''
  siteinfo = ''
  data = STRARR(row-5)

  OPENR, lun, aero_file, /GET_LUN
  READF, lun, line
  READF, lun, line
  READF, lun, siteinfo
  READF, lun, line
  READF, lun, line
  READF, lun, data
  CLOSE, lun
  FREE_LUN, lun

  temp1 = STRSPLIT(siteinfo, ',', /EXTRACT)
  flelen1 = STRLEN(temp1(1))
  lat = FLOAT(STRMID(temp1(1),5,flelen1-5))
  flelen2 = STRLEN(temp1(2))
  lon = FLOAT(STRMID(temp1(2),4,flelen1-4))
  PRINT,'Location: ',lat,lon


  goci = FLTARR(8)
  aero = FLTARR(8)
  sample = FLTARR(8)

  for t = 0,7 do begin

  ; Read goci data
  tim2 = string( t, format = '(i2.2)')

  goci_file = '/data1/guannan/data/GOCI/AOD_goci_2011apr-may'+ tim2 +'_average.bpch'

  Undefine, DataInfo
  CTM_Get_Data, DataInfo, 'IJ-AVG-$', Tracer = 26, File = goci_file
  goci_aod = *( DataInfo[0].Data )

  OutType = CTM_Type( 'generic', Res=[ 0.1d0, 0.1d0], Halfpolar=0, Center180=0)
  OutGrid = CTM_Grid( OutType )

  outxmid = OutGrid.xmid
  outymid = OutGrid.ymid

  m = where(( lat gt (outxmid - 0.05)) and ( lat le (outxmid + 0.05)))
  n = where(( lon gt (outymid - 0.05)) and ( lon le (outymid + 0.05)))
  print,m,n

  cas = 3

  ;case 1
  if cas eq 1 then begin
  goci[t] = goci_aod[m,n]
  endif

  ;case 2
  if cas eq 2 then begin
  nod = 0
  for I = m[0]-5,m[0]+5 do begin
  for J = n[0]-5,n[0]+5 do begin
  if goci_aod[I,J] gt 0 then begin
  goci[t] = goci[t] + goci_aod[I,J]
  nod = nod+1
  endif
  endfor
  endfor
  print,nod
  goci[t] = goci[t]/nod
  endif

  ;case 3
  if cas eq 3 then begin
  ;maskfile = '/data1/guannan/data/landmask.asc'
  ;mask = fltarr(OutGrid.IMX,OutGrid.JMX)
  ;Open_File, maskfile, Ilun, /Get_LUN
  ;ReadF, Ilun, mask

  ;ind = where(mask[*,n] eq 0)
  ;print,ind
  ;x = where(ind gt 2963L)
  ;print,x[0],n

  nod = 0
  for I = 2998-5,2998+5 do begin
  for J = n[0]-5,n[0]+5 do begin
  if goci_aod[I,J] gt 0 then begin
  goci[t] = goci[t] + goci_aod[I,J]
  nod = nod+1
  endif
  endfor
  endfor
  print,nod
  goci[t] = goci[t]/nod
  endif

  ; Read aeronet data
  avg = 0
  nod = 0

  for r = 0L,row-6L do begin
    temp2 = STRSPLIT(data(r), ',', /EXTRACT)
    date = STRSPLIT(temp2(0), ':', /EXTRACT)
    year = LONG(date(2))

    if year eq 2011 then begin
      julian_day = FLOAT(temp2(2))
      jd_part1 = FIX(julian_day)
      jd_part2 = julian_day - jd_part1

      if jd_part1 ge 91 and jd_part1 le 151 then begin
        if jd_part2 ge time[t] and jd_part2 le time[t+1] then begin
          ;aod_675(6),aod_500(12),aod_440(15)
          aod1 = FLOAT(temp2(6))
          aod2 = FLOAT(temp2(15))
          ;print,aod1,aod2
          aod_550 = EXP((ALOG(aod1) - ALOG(aod2)) / (ALOG(675) - ALOG(440)) $
                    * (ALOG(550) - ALOG(440)) + ALOG(aod2))
          avg = avg + aod_550
          nod = nod + 1
        endif
      endif

    endif

  endfor

  avg = avg / nod

  aero[t] = avg
  sample[t] = nod

  endfor



  CTM_ClEANUP

  outfile = '/data1/guannan/result/goci_aeronet_'+ site +'.hdf'

  IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

  ; Open the HDF file

  FID = HDF_SD_Start(Outfile,/RDWR,/Create)

  HDF_SETSD, FID, goci, 'GOCI',     $
             Longname='satellite1', $
             Unit='unitless',       $
             FILL=-999.0
  HDF_SETSD, FID, aero, 'AERONET',  $
             Longname='monitor',    $
             Unit='unitless',       $
             FILL=-999.0
  HDF_SETSD, FID, sample, 'number', $
             Longname='monitor',    $
             Unit='unitless',       $
             FILL=-999.0
  HDF_SD_End, FID

endfor

end
