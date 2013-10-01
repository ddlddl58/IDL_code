pro BLStoSOM

Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

for Year = 2004,2004 do begin
Yr4 = string( Year, format = '(i4.4)')

for Month = 10,10 do begin
Mon2 = string( Month, format = '(i2.2)')

for Day = 22,Dayofmonth[Month-1] do begin
Day2 = string( Day, format = '(i2.2)')

ctm_cleanup


;Paths
;-----
dir_misr = '/z6/satellite/MISR/'+ Yr4 +'/'+ Yr4 +'.'+ Mon2 +'.'+ Day2 +'/'
dir_out = '/home/gengguannan/satellite/aod/MISR/SOM/'+ Yr4 +'/'
spawn,'ls '+dir_misr+'MISR_AM1_AS_AEROSOL_*.hdf',list_misr


;Check files
;-----------
vcheck = make_array(1)

for ifile = 0, n_elements(list_misr)-1 do begin
  if strcmp(strmid(list_misr[ifile],68,8),'F12_0022') then vcheck = [vcheck,ifile]
endfor

list_misr = list_misr[vcheck[1:(n_elements(vcheck)-1)]]


;Read files
;----------
for ifile = 0, n_elements(list_misr)-1 do begin

  orbit = strmid(list_misr[ifile],56,3)
  restore,filename='/home/gengguannan/satellite/aod/MISR/SOM/AGP/MISR-AM1-AGP-P'+ orbit

;  status = read_global_attr(list_misr[ifile],'coremetadata',temp)
;  temp = strmid(temp, strpos(temp,'EQUATORCROSSINGDATE'), strpos(temp,'EQUATORCROSSINGDATE',/REVERSE_SEARCH)-strpos(temp,'EQUATORCROSSINGDATE'))
;  temp = strmid(temp, strpos(temp,'VALUE'), strpos(temp,'END_OBJECT')-strpos(temp,'VALUE'))
;  temp = strmid(temp, strpos(temp,'"')+1, strpos(temp,'"',/REVERSE_SEARCH)-strpos(temp,'"')-1)
;  date = strsplit(temp, escape='-', /EXTRACT)
  date = Yr4+Mon2+Day2

  status = read_grid_field(list_misr[ifile],'RegParamsAer','RegBestEstimateSpectralOptDepth',AOD)
  status = read_grid_field(list_misr[ifile],'RegParamsAer','RegBestEstimateSpectralOptDepthFraction',AODfrac)
  status = read_grid_attr(list_misr[ifile],'RegParamsAer','Block_size.resolution_x',temp)
  resx = double(temp)
  status = read_grid_attr(list_misr[ifile],'RegParamsAer','Block_size.resolution_y',temp)
  resy = double(temp)
  status = read_grid_attr(list_misr[ifile],'RegParamsAer','Block_size.size_x',temp)
  size_x = double(temp)
  status = read_grid_attr(list_misr[ifile],'RegParamsAer','Block_size.size_y',temp)
  size_y = double(temp)
  status = read_grid_attr(list_misr[ifile],'RegParamsAer','_BLKSOM:RegParamsAer',temp)
  BLKSOM = double(temp)

  status = read_global_attr(list_misr[ifile],'Origin_block.ulc.x',temp)
  ulc_x = double(temp)
  status = read_global_attr(list_misr[ifile],'Origin_block.lrc.y',temp)
  ulc_y = double(temp)
  status = read_global_attr(list_misr[ifile],'Origin_block.lrc.x',temp)
  lrc_x = double(temp)
  status = read_global_attr(list_misr[ifile],'Origin_block.ulc.y',temp)
  lrc_y = double(temp)
  status = read_global_attr(list_misr[ifile],'Start_block',temp)
  startBlock = double(temp)
  status = read_global_attr(list_misr[ifile],'End block',temp)
  endBlock = double(temp)

  Sx = (lrc_x - ulc_x) / size_x
  Sy = (lrc_y - ulc_y) / size_y

  ulc_xc = ulc_x + Sx / 2
  ulc_yc = ulc_y + Sy / 2

  dim = size(AOD)
  SOMxdim = dim[3]
  SOMydim = dim[2]
  SOMzdim = dim[1]

  SOMaod = reform(AOD,SOMzdim,SOMydim,SOMxdim*dim[4])
  SOMaodfrac = reform(AODfrac,5,SOMzdim,SOMydim,SOMxdim*dim[4])

  SOMx = fltarr(SOMydim,SOMxdim*dim[4])
  SOMy = fltarr(SOMydim,SOMxdim*dim[4])

  flag = 1
  for i = 0,dim[4]-1 do begin

    temp1 = ulc_xc[0] + i * size_x[0] * Sx[0] + transpose(indgen(SOMxdim)) * Sx[0]

    while (size(temp1))[1] lt SOMydim do begin
      temp1 = [temp1,temp1]
    endwhile

    SOMx[*,i*SOMxdim:((i+1)*SOMxdim-1)] = temp1[0:(SOMydim-1),*]

    if flag gt 0 $
      then temp2 = ulc_yc[0] + indgen(SOMydim) * Sy[0] $
      else temp2 = ulc_yc[0] + (indgen(SOMydim) + total(BLKSOM[0:(i-1)])) * Sy[0]

    while (size(temp2))[2] lt SOMxdim do begin
      temp2 = [[temp2],[temp2]]
    endwhile

    SOMy[*,i*SOMxdim:((i+1)*SOMxdim-1)] = temp2[*,0:(SOMxdim-1)]

    flag = 0
    undefine,temp1,temp2

  endfor

  SOMlat = make_array((size(SOMx))[1], (size(SOMx))[2], /FLOAT, VALUE = -999)
  SOMlon = make_array((size(SOMx))[1], (size(SOMx))[2], /FLOAT, VALUE = -999)

  for i = 0,(size(SOMx))[1]-1 do begin
    for j = 0,(size(SOMx))[2]-1 do begin

      a = min(abs(SOM_x[0,*]-SOMx[i,j]),b)
      c = min(abs(SOM_y[*,b]-SOMy[i,j]),d)

      if (a^2 + c^2)^0.5 lt 800 then begin
        SOMlat[i,j] = SOM_lat[d,b]
        SOMlon[i,j] = SOM_lon[d,b]
      endif else begin
        print,'Locational Error: Distance Exceeds 800 m: i = ',i,', j = ',j
      endelse

    endfor
  endfor

  save,SOMaod,SOMaodfrac,SOMlat,SOMlon,date,filename=dir_out+'MISR-L2-AOD-'+Yr4+Mon2+Day2+'-P'+orbit

  print,list_misr[ifile],' Complete'

endfor


endfor
endfor
endfor

end
