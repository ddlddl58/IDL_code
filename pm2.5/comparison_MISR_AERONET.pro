pro comparison_MISR_AERONET

FORWARD_FUNCTION CTM_Grid, CTM_Type

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


;Read station names
filename = '/home/gengguannan/indir/locations.txt'

no = FILE_LINES(filename)
file_list = STRARR(no)

OPENR, lun, filename, /GET_LUN
READF, lun, file_list
CLOSE, lun
FREE_LUN, lun


for k = 0,no-1 do begin

  length = STRLEN(file_list(k))
  site = STRMID(file_list(k),14,length-20)

  print,'site '+ site +' is processed'

  aero_file = '/z6/satellite/AERONET/'+ file_list(k)

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


  misr = FLTARR(7)
  aero = FLTARR(7)
  sample = FLTARR(7)

  for year = 2004,2010 do begin
  Yr4  = String( year, format='(i4.4)')

  ; Read misr data
  misr_file = '/home/gengguannan/satellite/aod/MISR/MISR_0.66x0.50_yearly.'+ Yr4

  RESTORE,filename = misr_file

  m = where(( lat gt (xmid - 0.3333)) and ( lat le (xmid + 0.3333)))
  n = where(( lon gt (ymid - 0.25)) and ( lon le (ymid + 0.25)))

  cas = 1

  ;case 1
  if cas eq 1 then begin
  misr[year-2004] = avg_misr_aod[m,n]
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
    year_file = LONG(date(2))

    ; Time match
    if year_file eq year then begin
      julian_day = FLOAT(temp2(2))
      jd_part1 = FIX(julian_day)
      jd_part2 = julian_day - jd_part1

      if jd_part2 ge 0.375 and jd_part2 le 0.5 then begin

        wavelength = [1640,1020,870,675,667,555,551,532,531,500,490,443,440,412,380,340]
        AOT = temp2[3:18]

        AOT[where(STRMATCH(AOT,'N/A',/FOLD_CASE) eq 1)] = 0
        wave_ok = where(float(AOT) gt 0)

        wavelength = wavelength[wave_ok]
        AOT = AOT[wave_ok]

        ind1 = max(where(wavelength gt 550))
        ind2 = min(where(wavelength lt 550))
        print,wavelength[ind1],wavelength[ind2]

        aod1 = float(AOT[ind1])
        aod2 = float(AOT[ind2])

        aod_550 = EXP((ALOG(aod1) - ALOG(aod2)) / (ALOG(wavelength[ind1]) - ALOG(wavelength[ind2]))$
                  * (ALOG(wavelength[ind1]) - ALOG(wavelength[ind2])) + ALOG(aod2))

        avg = avg + aod_550
        nod = nod + 1

      endif

    endif

  endfor

  avg = avg / nod

  aero[year-2004] = avg
  sample[year-2004] = nod

  endfor

  CTM_ClEANUP

  outfile = '/home/gengguannan/work/pm2.5/result/misr_aeronet_'+ site +'.hdf'

  IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

  ; Open the HDF file

  FID = HDF_SD_Start(Outfile,/RDWR,/Create)

  HDF_SETSD, FID, misr, 'MISR',     $
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
