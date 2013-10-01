pro area_average_so2

FORWARD_FUNCTION CTM_Get_Data

year = 2005
Yr4  = String( Year,format = '(i4.4)' )

nymd = year*10000L+12*100L+31*1L
print,nymd
tau0 = nymd2tau(nymd)



infile ='/z3/gengguannan/satellite/so2/average/omi_so2_'+ Yr4 +'_tropCS30_partial_scene.05x05.bpch'

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 26, tau0 = tau0, filename = infile
data18 = *(datainfo1[0].data)


so2 = 0
nod = 0


;for I = 568,578 do begin
;  for J = 232,244 do begin
for I = 580,606 do begin
  for J = 240,260 do begin

    if (data18[I,J] ge -10) then begin
       so2 += data18[I,J]
       nod += 1
    endif
  endfor
endfor

print,so2
print,nod

CTM_Cleanup

average = so2 / nod 
print,average

end
