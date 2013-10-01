pro aod_CALIPSO

;22 : AOD_corrected
monthname = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

factorfile = '/home/gengguannan/indir/CALIPSO_factor/CALIPSO-ADJ-20120821LR'+ monthname[month-1] +'-CH.h5'

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

fId = H5F_OPEN(factorfile)

if ( fId lt 0 ) then Message, 'Error opening file!'

dataId = H5D_OPEN( fId, 'CALIPSOADJ' )
CAL_factor = H5D_READ(dataId)

OPAOD_corrected = fltarr(121,133,47)

for level = 0,47-1 do begin
  for I = 0,121-1 do begin
    for J = 0,133-1 do begin
      OPAOD_corrected[I,J,level] = OPAOD[I,J,level]*CAL_factor[I,J,level+40]
    endfor
  endfor
endfor

tracer[*,*,22] = total(OPAOD_corrected,3)

end
