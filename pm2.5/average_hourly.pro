pro average_hourly

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch


; Time set
y = 2004
Yr4  = String( y, format='(i4.4)')

for m = 1,1 do begin
Mon2 = string( m, format='(i2.2)')

for t = 8,8 do begin
Tim2 = string( t, format='(i2.2)')

data1 = fltarr(121,133)
data2 = fltarr(121,133)
nod = fltarr(121,133)

for d = 1,31 do begin
Day2 = string( d, format='(i2.2)')


nymd = y*10000L + m*100L + d*1L
print,nymd
date = m*100L + d*1L
if (date eq 0229) then continue
if (date eq 0230) then continue
if (date eq 0231) then continue
if (date eq 0431) then continue
if (date eq 0631) then continue
if (date eq 0931) then continue
if (date eq 1131) then continue


; Infile info
Indir = '/home/gengguannan/work/pm2.5/hourly/'+ Yr4 +'/'
Infile = Indir + 'model_pm2.5_aod.'+ Yr4 + Mon2 + Day2 + Tim2 +'.hdf'



; Read data (hdf)
IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(Infile,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

pm = HDF_GETSD(fId,'PM2.5_35')
help, pm

aod = HDF_GETSD(fId,'PM2.5')
help, aod

HDF_SD_END, FID

print,max(pm),mean(pm)
print,max(aod),mean(aod)

; Read data (bpch)
;tau0 = nymd2tau(nymd)

;InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
;InType = CTM_Type( 'generic', res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
;InGrid = CTM_Grid( InType )

;xmid = InGrid.xmid
;ymid = InGrid.ymid

;close, /all

;CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 38, tau0 = tau0, filename = Infile
;pm = *(datainfo1[0].data)

;CTM_Get_Data, datainfo2, 'OD-MAP-$', tracer = 4, tau0 = tau0, filename = Infile
;aod = *(datainfo2[0].data)


; Average
for I = 0,121-1 do begin
  for J = 0,133-1 do begin
     data1[I,J] += pm[I,J]
     data2[I,J] += aod[I,J]
     nod[I,J] += 1
  endfor
endfor

CTM_Cleanup

endfor


print,max(nod,min=min),min,mean(nod)

for I = 0,121-1 do begin
  for J = 0,133-1 do begin
    if (nod[I,J] gt 0L) then begin
      data1[I,J] /= nod[I,J]
      data2[I,J] /= nod[I,J]
    endif
  endfor
endfor

print,max(data1,min=min),min,mean(data1)
print,max(data2,min=min),min,mean(data2)


; Write into file
Outdir = '/home/gengguannan/work/pm2.5/hourly/'
Outfile = Outdir + 'model_pm2.5_aod_monthly.'+ Yr4 + Mon2 + Tim2 +'.hdf'

; hdf format
IF ( HDF_EXISTS() eq 0 ) then MESSAGE, 'HDF not supported!'

FID = HDF_SD_START( Outfile, /Create )
IF ( FID lt 0 ) then Message, 'Error opening file!'

HDF_SETSD, FID, data1, 'pm2.5',        $
           LONGNAME='Surface pm2.5',   $
           UNIT='ug/m3',               $
           FILL=-999 
HDF_SETSD, FID, data2, 'aod',          $
           LONGNAME='aod column',      $
           UNIT='unitless',            $
           FILL=-999
HDF_SD_END, FID

; bpch format
;nymd0 = y*10000L + m*100L + 1*1L

;Success = CTM_Make_DataInfo( data1,                $
;                             ThisDataInfo1,        $
;                             ThisFileInfo1,        $
;                             ModelInfo=InType,     $
;                             GridInfo=InGrid,      $
;                             DiagN='IJ-AVG-$',     $
;                             Tracer=51,            $
;                             Tau0=nymd2tau(nymd0), $
;                             Unit='um/m3',         $
;                             Dim=[121,133,0,0],    $
;                             First=[376L, 159L, 1L],   $
;                             /No_vertical )


;NewDataInfo = [ ThisDataInfo1, ThisDataInfo2 ]
;NewFileInfo = [ ThisFileInfo1, ThisFileInfo2 ]

;CTM_WriteBpch, newDataInfo, newFileInfo, Filename=Outfile

endfor
endfor

end
