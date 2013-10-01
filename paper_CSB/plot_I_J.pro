pro plot_I_J,choose,year

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InType = CTM_Type( 'GENERIC', Resolution=[0.125d0,0.125d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

choose = choose
Year = year
Yr4  = String( Year, format = '(i4.4)' )

nymd = Year * 10000L + 1 * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)


if year le 2002 $
then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_JJA.0125x0125.bpch' $
else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_JJA.0125x0125.bpch'

ctm_get_data,datainfo,filename = infile,tau0=nymd2tau(NYMD),tracer=1
data18=*(datainfo[0].data)


;limit= [27.5,103,28.5,123]
;limit= [40,-80,41,-70]
;limit= [48,-5,49,5]
limit= [33.5,-123,34.5,-113]

;limit = [36,114,42,115]


i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)


no2=make_array(1)
x=make_array(1)
flag = 1

if choose eq 1 then begin

for I = I1,I2 do begin

  no2_temp=0
  nod=0

  for J = J1,J2 do begin
    if data18[I,J] gt 0 then begin
      no2_temp +=data18[I,J]
      nod +=1
    endif
  endfor
  
  if nod gt 0  $
    then no2_temp /= nod $
    else no2_temp = -999

  if no2_temp gt 0 then begin
    if flag eq 1 then begin
      no2 = no2_temp
      x = (I*0.125-180)
    endif else begin
      no2 = [no2,no2_temp]
      x = [x,(I*0.125-180)]
    endelse
  endif

  flag = 0

endfor

endif else begin

for J = J1,J2 do begin

  no2_temp=0
  nod=0

  for I = I1,I2 do begin
    if data18[I,J] gt 0 then begin
      no2_temp +=data18[I,J]
      nod +=1
    endif
  endfor

  if nod gt 0  $
    then no2_temp /= nod $
    else no2_temp = -999

  if no2_temp gt 0 then begin
    if flag eq 1 then begin
      no2 = no2_temp
      x = (J*0.125-90)
    endif else begin
      no2 = [no2,no2_temp]
      x = [x,(J*0.125-90)]
    endelse
  endif

  flag = 0

endfor

endelse

print,n_elements(no2)
print,max(no2)

;plot,x,no2,yrange=[0,50]
plot,x,no2

outfile = '/home/gengguannan/result/'+Yr4+'.hdf'


IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, x, 'x',  $
           Longname='GRID',$
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, no2, 'NO2',  $
           Longname='NO2',$
           Unit='unitless',      $
           FILL=-999.0
HDF_SD_End, FID


end
