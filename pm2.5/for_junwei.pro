pro for_junwei

FORWARD_FUNCTION CTM_Grid, CTM_Type

InType = CTM_Type( 'GEOS5', Res=[2d0/3d0, 0.5d0] )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


; Region set
limit=[15,70,55,136]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

avg_ratio = fltarr(InGrid.IMX,InGrid.JMX)
avg_ratio_dry = fltarr(InGrid.IMX,InGrid.JMX)
nod1 = fltarr(InGrid.IMX,InGrid.JMX)
nod2 = fltarr(InGrid.IMX,InGrid.JMX)


; Time set
for y = 2004,2010 do begin
Yr4  = String( y, format='(i4.4)')

if y eq 2004 or y eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

for m = 1,1 do begin
mon2 = string( m, format='(i2.2)')

for d = 1,Dayofmonth[m-1] do begin
day2 = string( d, format='(i2.2)')


nymd = y*10000L + m*100L + d*1L
if nymd eq 20081001 then continue
if nymd eq 20081002 then continue
if nymd eq 20081003 then continue
if nymd eq 20081004 then continue
if nymd eq 20081005 then continue
if nymd eq 20081006 then continue
if nymd eq 20081007 then continue
if nymd eq 20081008 then continue
if nymd eq 20081009 then continue
if nymd eq 20081010 then continue
if nymd eq 20081011 then continue
if nymd eq 20081012 then continue
if nymd eq 20081013 then continue
if nymd eq 20081014 then continue
if nymd eq 20081015 then continue
if nymd eq 20081220 then continue
if nymd eq 20081221 then continue
if nymd eq 20081222 then continue


; Infile info
Indir = '/home/gengguannan/work/pm2.5/pm2.5/sate_based/daily/'+ Yr4 +'/'
Infile = Indir + 'MISR_pm2.5_0.66x0.50_'+ Yr4 + Mon2 + Day2

RESTORE,filename = Infile


; Average
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if ratio[I,J] gt 0 then begin
      avg_ratio[I,J] = avg_ratio[I,J] + ratio[I,J]
      nod1[I,J] = nod1[I,J] + 1
    endif
    if ratio_dry[I,J] gt 0 then begin
      avg_ratio_dry[I,J] = avg_ratio_dry[I,J] + ratio_dry[I,J]
      nod2[I,J] = nod2[I,J] + 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor
endfor


print,max(nod1),max(nod2)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod1[I,J] gt 0L) $
      then avg_ratio[I,J] = avg_ratio[I,J] / nod1[I,J] $
      else avg_ratio[I,J] = -999
    if (nod2[I,J] gt 0L) $
      then avg_ratio_dry[I,J] = avg_ratio_dry[I,J] / nod2[I,J] $
      else avg_ratio_dry[I,J] = -999
  endfor
endfor

print,max(avg_ratio),max(avg_ratio_dry)

; Write into file
Outdir = '/home/gengguannan/work/'
Outfile = Outdir + 'ratio_0.66x0.50_JAN_2004-2010'

; Find out if HDF is supported on this platform
IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_START(Outfile,/RDWR,/Create)
IF ( FID lt 0 ) then Message, 'Error opening file!'

HDF_SETSD, FID, avg_ratio, 'ratio', $
           Longname='pm2.5/AOD',    $
           Unit='ug/m3',            $
           FILL=-999.0
HDF_SETSD, FID, nod1, 'sample_number', $
           Longname='sample_number',   $
           Unit='unitless',            $
           FILL=-999.0
HDF_SD_End, FID


end
