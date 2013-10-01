pro average_gc_pm_components

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

for m = 1,1 do begin
mon2 = string( m, format='(i2.2)')

gc_SO4 = fltarr(InGrid.IMX,InGrid.JMX)
gc_NO3 = fltarr(InGrid.IMX,InGrid.JMX)
gc_NH4 = fltarr(InGrid.IMX,InGrid.JMX)
gc_OC = fltarr(InGrid.IMX,InGrid.JMX)
gc_BC = fltarr(InGrid.IMX,InGrid.JMX)
gc_Dust = fltarr(InGrid.IMX,InGrid.JMX)
gc_Salt = fltarr(InGrid.IMX,InGrid.JMX)
gc_SOA = fltarr(InGrid.IMX,InGrid.JMX)
gc_pm = fltarr(InGrid.IMX,InGrid.JMX)
gc_SO4RH50 = fltarr(InGrid.IMX,InGrid.JMX)
gc_NO3RH50 = fltarr(InGrid.IMX,InGrid.JMX)
gc_NH4RH50 = fltarr(InGrid.IMX,InGrid.JMX)
gc_OCRH50 = fltarr(InGrid.IMX,InGrid.JMX)
gc_BCRH50 = fltarr(InGrid.IMX,InGrid.JMX)
gc_pmRH50 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_SO4 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_NO3 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_NH4 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OC = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_BC = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_Dust = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_Salt = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_SOA = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_pm = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_SO4RH50 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_NO3RH50 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_NH4RH50 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_OCRH50 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_BCRH50 = fltarr(InGrid.IMX,InGrid.JMX)
avg_gc_pmRH50 = fltarr(InGrid.IMX,InGrid.JMX)
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
Indir = '/home/gengguannan/work/pm2.5/pm2.5/gc_xin/'
Infile = Indir + 'model_pm2.5_24h.'+ Yr4 + Mon2 + Day2 +'.hdf'
print,infile

IF ( EOS_EXISTS() eq 0 ) then Message, 'HDF not supported'

FID = HDF_SD_START(Infile,/Read)
if ( FID lt 0 ) then Message, 'Error opening file!'

SO4 = HDF_GETSD(fId,'SO4')
NO3 = HDF_GETSD(fId,'NO3')
NH4 = HDF_GETSD(fId,'NH4')
OC = HDF_GETSD(fId,'OC')
BC = HDF_GETSD(fId,'BC')
Dust = HDF_GETSD(fId,'Dust')
Salt = HDF_GETSD(fId,'Salt')
SOA = HDF_GETSD(fId,'SOA')
pm = HDF_GETSD(fId,'pm2.5')
SO4RH50 = HDF_GETSD(fId,'SO4RH50')
NO3RH50 = HDF_GETSD(fId,'NO3RH50')
NH4RH50 = HDF_GETSD(fId,'NH4RH50')
OCRH50 = HDF_GETSD(fId,'OCRH50')
BCRH50 = HDF_GETSD(fId,'BCRH50')
pmRH50 = HDF_GETSD(fId,'pm2.5RH50')

HDF_SD_END, FID

gc_SO4[375:495,213:290] = SO4
gc_NO3[375:495,213:290] = NO3
gc_NH4[375:495,213:290] = NH4
gc_OC[375:495,213:290] = OC
gc_BC[375:495,213:290] = BC
gc_Dust[375:495,213:290] = Dust
gc_Salt[375:495,213:290] = Salt
gc_SOA[375:495,213:290] = SOA
gc_pm[375:495,213:290] = pm
gc_SO4RH50[375:495,213:290] = SO4RH50
gc_NO3RH50[375:495,213:290] = NO3RH50
gc_NH4RH50[375:495,213:290] = NH4RH50
gc_OCRH50[375:495,213:290] = OCRH50
gc_BCRH50[375:495,213:290] = BCRH50
gc_pmRH50[375:495,213:290] = pmRH50


; Average
for I = I1,I2 do begin
  for J = J1,J2 do begin
    avg_gc_SO4[I,J] = avg_gc_SO4[I,J] + gc_SO4[I,J]
    avg_gc_NO3[I,J] = avg_gc_NO3[I,J] + gc_NO3[I,J]
    avg_gc_NH4[I,J] = avg_gc_NH4[I,J] + gc_NH4[I,J]
    avg_gc_OC[I,J] = avg_gc_OC[I,J] + gc_OC[I,J]
    avg_gc_BC[I,J] = avg_gc_BC[I,J] + gc_BC[I,J]
    avg_gc_Dust[I,J] = avg_gc_Dust[I,J] + gc_Dust[I,J]
    avg_gc_Salt[I,J] = avg_gc_Salt[I,J] + gc_Salt[I,J]
    avg_gc_SOA[I,J] = avg_gc_SOA[I,J] + gc_SOA[I,J]
    avg_gc_pm[I,J] = avg_gc_pm[I,J] + gc_pm[I,J]
    avg_gc_SO4RH50[I,J] = avg_gc_SO4RH50[I,J] + gc_SO4RH50[I,J]
    avg_gc_NO3RH50[I,J] = avg_gc_NO3RH50[I,J] + gc_NO3RH50[I,J]
    avg_gc_NH4RH50[I,J] = avg_gc_NH4RH50[I,J] + gc_NH4RH50[I,J]
    avg_gc_OCRH50[I,J] = avg_gc_OCRH50[I,J] + gc_OCRH50[I,J]
    avg_gc_BCRH50[I,J] = avg_gc_BCRH50[I,J] + gc_BCRH50[I,J]
    avg_gc_pmRH50[I,J] = avg_gc_pmRH50[I,J] + gc_pmRH50[I,J]
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
      avg_gc_SO4[I,J] = avg_gc_SO4[I,J] / nod[I,J]
      avg_gc_NO3[I,J] = avg_gc_NO3[I,J] / nod[I,J]
      avg_gc_NH4[I,J] = avg_gc_NH4[I,J] / nod[I,J]
      avg_gc_OC[I,J] = avg_gc_OC[I,J] / nod[I,J]
      avg_gc_BC[I,J] = avg_gc_BC[I,J] / nod[I,J]
      avg_gc_Dust[I,J] = avg_gc_Dust[I,J] / nod[I,J]
      avg_gc_Salt[I,J] = avg_gc_Salt[I,J] / nod[I,J]
      avg_gc_SOA[I,J] = avg_gc_SOA[I,J] / nod[I,J]
      avg_gc_pm[I,J] = avg_gc_pm[I,J] / nod[I,J]
      avg_gc_SO4RH50[I,J] = avg_gc_SO4RH50[I,J] / nod[I,J]
      avg_gc_NO3RH50[I,J] = avg_gc_NO3RH50[I,J] / nod[I,J]
      avg_gc_NH4RH50[I,J] = avg_gc_NH4RH50[I,J] / nod[I,J]
      avg_gc_OCRH50[I,J] = avg_gc_OCRH50[I,J] / nod[I,J]
      avg_gc_BCRH50[I,J] = avg_gc_BCRH50[I,J] / nod[I,J]
      avg_gc_pmRH50[I,J] = avg_gc_pmRH50[I,J] / nod[I,J]
    endif else begin
      avg_gc_SO4[I,J] = -999
      avg_gc_NO3[I,J] = -999
      avg_gc_NH4[I,J] = -999
      avg_gc_OC[I,J] = -999
      avg_gc_BC[I,J] = -999
      avg_gc_Dust[I,J] = -999
      avg_gc_Salt[I,J] = -999
      avg_gc_SOA[I,J] = -999
      avg_gc_pm[I,J] = -999
      avg_gc_SO4RH50[I,J] = -999
      avg_gc_NO3RH50[I,J] = -999
      avg_gc_NH4RH50[I,J] = -999
      avg_gc_OCRH50[I,J] = -999
      avg_gc_BCRH50[I,J] = -999
      avg_gc_pmRH50[I,J] = -999
    endelse
  endfor
endfor


; Write into file
Outdir = '/home/gengguannan/work/pm2.5/pm2.5/gc_xin/'
;Outfile = Outdir + 'model_pm_components_yearly.'+ Yr4
Outfile = Outdir + 'model_pm_components.'+ Yr4 + Mon2

SAVE,avg_gc_SO4,avg_gc_NO3,avg_gc_NH4,avg_gc_OC,avg_gc_BC,avg_gc_Dust,avg_gc_Salt,avg_gc_SOA,avg_gc_pm,avg_gc_SO4RH50,avg_gc_NO3RH50,avg_gc_NH4RH50,avg_gc_OCRH50,avg_gc_BCRH50,avg_gc_pmRH50,nod,filename=Outfile

endfor
endfor

end
