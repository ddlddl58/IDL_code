pro test

OutType = CTM_Type( 'generic', Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all

Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31]

for Year = 2004,2004 do begin
Yr4 = string( Year, format = '(i4.4)')

for Month = 1,1 do begin
Mon2 = string( Month, format = '(i2.2)')


misr = fltarr(OutGrid.IMX,OutGrid.JMX)
nod = fltarr(OutGrid.IMX,OutGrid.JMX)

for Day = 1,15 do begin
Day2 = string( Day, format = '(i2.2)')

ctm_cleanup

dir_misr = '/home/gengguannan/satellite/aod/MISR/SOM/'+ Yr4 +'/'
spawn,'ls '+dir_misr+'MISR-L2-AOD-'+Yr4+Mon2+Day2+'*',list_misr

for ifile = 0, n_elements(list_misr)-1 do begin

restore,filename = list_misr[ifile]

aod = reform(SOMaod[1,*,*])

for I = 0,32-1 do begin
  for J = 0,1440-1 do begin
    x = where( (SOMlon[I,J] gt (outxmid - 0.25)) and (SOMlon[I,J] le (outxmid + 0.25)))
    y = where( (SOMlat[I,J] gt (outymid - 0.25)) and (SOMlat[I,J] le (outymid + 0.25)))
    if aod[I,J] gt -999 then begin
      misr[x,y] = misr[x,y] + aod[I,J]
      nod[x,y] = nod[x,y] + 1
    endif
  endfor
endfor

endfor
endfor

print,max(nod)

for I = 0,OutGrid.IMX-1 do begin
  for J = 0,OutGrid.JMX-1 do begin
    if (nod[I,J] gt 0L) $
        then  misr[I,J] = misr[I,J] / nod[I,J] $
        else  misr[I,J] = -999.0
  endfor
endfor


save,misr,nod,filename=Yr4+Mon2

endfor
endfor

end

;restore,filename='200401'
;tvmap,misr,cbar,maxdata=1,mindata=0,cbmax=1,cbmin=0
