pro area_average_no2

FORWARD_FUNCTION CTM_Get_Data

year = 2005
Yr4  = String( Year,format = '(i4.4)' )

nymd = year*10000L+12*100L+31*1L
print,nymd
tau0 = nymd2tau(nymd)



infile ='/z3/gengguannan/satellite/no2/average/omi_no2_'+ Yr4 +'_tropCS30_partial_scene.05x05.bpch'

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile
data18 = *(datainfo1[0].data)

no2 = 0
nod = 0

for I = 568,578 do begin
 for J = 232,244 do begin
;for I = 580,606 do begin
;  for J = 240,260 do begin

    if (data18[I,J] gt 0) then begin
       no2 += data18[I,J]
       nod += 1
    endif
  endfor
endfor

print,no2
print,nod

CTM_Cleanup

average = no2 / nod 
print,average

end
