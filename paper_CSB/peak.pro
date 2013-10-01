pro peak,year

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

;InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InType = CTM_Type( 'GENERIC', Resolution=[0.125d0,0.125d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

Year = year
Yr4  = String( Year, format = '(i4.4)' )

nymd = Year * 10000L + 1 * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)


if year le 2002 $
then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_annual_average.0125x0125.bpch' $
else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen/scia_no2_v1-0_'+ Yr4 +'_annual_average.0125x0125.bpch'

ctm_get_data,datainfo,filename = infile,tau0=nymd2tau(NYMD),tracer=1
data18=*(datainfo[0].data)



limit=[36,110,37,120]


i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)


no2=make_array(1)
x=make_array(1)
flag = 1

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

print,no2

max=0
min=0

for i = 1,n_elements(x)-2 do begin
  if no2[i] gt no2[i-1] and no2[i] gt no2[i+1] then max +=1
  if no2[i] lt no2[i-1] and no2[i] lt no2[i+1] then min +=1
endfor

print,max,min

end
