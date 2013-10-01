pro average1

FORWARD_FUNCTION CTM_Grid, CTM_Type

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


; Time set
for y = 2004,2004 do begin
Yr4  = String( y, format='(i4.4)')

if y eq 2004 or y eq 2008 $
  then Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

;for m = 1,12 do begin
;mon2 = string( m, format='(i2.2)')

data1 = fltarr(121,133)
data2 = fltarr(121,133)
data3 = fltarr(121,133)
data4 = fltarr(121,133)
nod = fltarr(121,133)
avg_pm = fltarr(InGrid.IMX,InGrid.JMX)
avg_aod = fltarr(InGrid.IMX,InGrid.JMX)
avg_sna = fltarr(InGrid.IMX,InGrid.JMX)
avg_carbon = fltarr(InGrid.IMX,InGrid.JMX)

for m = 1,5 do begin
mon2 = string( m, format='(i2.2)')

for d = 1,Dayofmonth[m-1] do begin
day2 = string( d, format='(i2.2)')

nymd = y*10000L + m*100L + d*1L
print,nymd

; Infile info
Indir = '/home/gengguannan/work/pm2.5/pm2.5/gc/daily/'+ Yr4 +'/'
Infile = Indir + 'model_pm2.5_aod_10_12.'+ Yr4 + Mon2 + Day2 +'.hdf'

; Read data (hdf)
IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(Infile,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

pm = HDF_GETSD(fId,'pm2.5')

aod = HDF_GETSD(fId,'AOD')

HDF_SD_END, FID


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
endfor

print,max(nod)

for I = 0,121-1 do begin
  for J = 0,133-1 do begin
    if (nod[I,J] gt 0L) then begin
      data1[I,J] /= nod[I,J]
      data2[I,J] /= nod[I,J]
    endif
  endfor
endfor


avg_pm[375:495,158:290] = data1
avg_aod[375:495,158:290] = data2

; Write into file
;Outdir = '/home/gengguannan/work/pm2.5/monthly/'
;Outfile = Outdir + 'model_pm2.5_aod_10_12_monthly.'+ Yr4 + Mon2 +'.hdf'
Outdir = '/home/gengguannan/work/pm2.5/pm2.5/gc/'
Outfile = Outdir + 'model_pm2.5_aod_10_12_5m.'+ Yr4

SAVE,avg_pm,avg_aod,filename=Outfile

endfor

end
