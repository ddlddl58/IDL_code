pro average_gc_aod_components

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


; Time set
for y = 2006,2006 do begin
Yr4  = String( y, format='(i4.4)')

if y eq 2004 or y eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

for m = 7,7 do begin
mon2 = string( m, format='(i2.2)')

gc_OPSO4 = fltarr(InGrid.IMX,InGrid.JMX)
gc_OPBC = fltarr(InGrid.IMX,InGrid.JMX)
gc_OPOC = fltarr(InGrid.IMX,InGrid.JMX)
gc_OPSSa = fltarr(InGrid.IMX,InGrid.JMX)
gc_OPSSc = fltarr(InGrid.IMX,InGrid.JMX)
gc_OPD = fltarr(InGrid.IMX,InGrid.JMX)
gc_AOD = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPSO4 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPBC = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPOC = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPSSa = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPSSc = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OPD = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_AOD = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

;for m = 1,12 do begin
;mon2 = string( m, format='(i2.2)')

for d = 1,Dayofmonth[m-1] do begin
day2 = string( d, format='(i2.2)')

;nymd = y*10000L + m*100L + d*1L
;if nymd eq 20081001 then continue
;if nymd eq 20081002 then continue
;if nymd eq 20081003 then continue
;if nymd eq 20081004 then continue
;if nymd eq 20081005 then continue
;if nymd eq 20081006 then continue
;if nymd eq 20081007 then continue
;if nymd eq 20081008 then continue
;if nymd eq 20081009 then continue
;if nymd eq 20081010 then continue
;if nymd eq 20081011 then continue
;if nymd eq 20081012 then continue
;if nymd eq 20081013 then continue
;if nymd eq 20081014 then continue
;if nymd eq 20081015 then continue
;if nymd eq 20081220 then continue
;if nymd eq 20081221 then continue
;if nymd eq 20081222 then continue


; Infile info
Indir = '/home/gengguannan/work/pm2.5/pm2.5/gc/daily/'+ Yr4 +'/'
Infile = Indir + 'model_pm2.5_aod_10_12.'+ Yr4 + Mon2 + Day2 +'.hdf'

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(Infile,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

OPSO4 = HDF_GETSD(fId,'OPSO4')
OPBC = HDF_GETSD(fId,'OPBC')
OPOC = HDF_GETSD(fId,'OPOC')
OPSSa = HDF_GETSD(fId,'OPSSa')
OPSSc = HDF_GETSD(fId,'OPSSc')
OPD = HDF_GETSD(fId,'OPD')
AOD = HDF_GETSD(fId,'AOD')

HDF_SD_END, FID

gc_OPSO4[375:495,158:290] = OPSO4
gc_OPBC[375:495,158:290] = OPBC
gc_OPOC[375:495,158:290] = OPOC
gc_OPSSa[375:495,158:290] = OPSSa
gc_OPSSc[375:495,158:290] = OPSSc
gc_OPD[375:495,158:290] = OPD
gc_AOD[375:495,158:290] = AOD

; Average
for I = I1,I2 do begin
  for J = J1,J2 do begin
    avg_gc_OPSO4[I,J] = avg_gc_OPSO4[I,J] + gc_OPSO4[I,J]
    avg_gc_OPBC[I,J]  = avg_gc_OPBC[I,J]  + gc_OPBC[I,J]
    avg_gc_OPOC[I,J]  = avg_gc_OPOC[I,J]  + gc_OPOC[I,J]
    avg_gc_OPSSa[I,J] = avg_gc_OPSSa[I,J] + gc_OPSSa[I,J]
    avg_gc_OPSSc[I,J] = avg_gc_OPSSc[I,J] + gc_OPSSc[I,J]
    avg_gc_OPD[I,J]   = avg_gc_OPD[I,J]   + gc_OPD[I,J]
    avg_gc_AOD[I,J]   = avg_gc_AOD[I,J]   + gc_AOD[I,J]
    nod[I,J] = nod[I,J] + 1
  endfor
endfor

CTM_Cleanup

;endfor
endfor

print,max(nod)

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (nod[I,J] gt 0L) then begin
      avg_gc_OPSO4[I,J] = avg_gc_OPSO4[I,J] / nod[I,J]
      avg_gc_OPBC[I,J]  = avg_gc_OPBC[I,J]  / nod[I,J]
      avg_gc_OPOC[I,J]  = avg_gc_OPOC[I,J]  / nod[I,J]
      avg_gc_OPSSa[I,J] = avg_gc_OPSSa[I,J] / nod[I,J]
      avg_gc_OPSSc[I,J] = avg_gc_OPSSc[I,J] / nod[I,J]
      avg_gc_OPD[I,J]   = avg_gc_OPD[I,J]   / nod[I,J]
      avg_gc_AOD[I,J]   = avg_gc_AOD[I,J]   / nod[I,J]
    endif else begin
      avg_gc_OPSO4[I,J] = -999
      avg_gc_OPBC[I,J]  = -999
      avg_gc_OPOC[I,J]  = -999
      avg_gc_OPSSa[I,J] = -999
      avg_gc_OPSSc[I,J] = -999
      avg_gc_OPD[I,J]   = -999
      avg_gc_AOD[I,J]   = -999
    endelse
  endfor
endfor

print,max(avg_gc_aod)

; Write into file
Outdir = '/home/gengguannan/work/pm2.5/pm2.5/gc/'
;Outfile = Outdir + 'model_aod_components_yearly.'+ Yr4
Outfile = Outdir + 'model_aod_components.'+ Yr4 + Mon2

SAVE,avg_gc_OPSO4,avg_gc_OPBC,avg_gc_OPOC,avg_gc_OPSSa,avg_gc_OPSSc,avg_gc_OPD,avg_gc_AOD,nod,filename=Outfile

endfor
endfor

end
