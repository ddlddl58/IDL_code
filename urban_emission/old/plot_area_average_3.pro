pro plot_area_average_3

FORWARD_FUNCTION CTM_Get_Data

InType = CTM_Type('GENERIC',Res=[0.125d0, 0.125d0],Halfpolar=0,Center180=0)
;InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all

filename1 = '/home/gengguannan/indir/region_mask_0125x0125.bpch'

ctm_get_data,datainfo1,filename = filename1,tracer=802
mask=*(datainfo1[0].data)

no2 = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

for year = 2008,2010 do begin
Yr4 = string(year,format='(i4.4)')

nymd = Year*10000L + 1*100L + 1*1L
tau0 = nymd2tau(nymd)

if year le 2002 $
  then filename2 = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_JJA.0125x0125.bpch' $
  else filename2 = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_JJA.0125x0125.bpch'

ctm_get_data,datainfo2,filename = filename2,tracer=1
data18=*(datainfo2[0].data)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if data18[I,J] gt 0 then begin
       no2[I,J] += data18[I,J]
       nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor

print,max(nod,min=min),min

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if nod[I,J] gt 0 $
      then no2[I,J] /= nod[I,J] $
      else no2[I,J] = -999.0
  endfor
endfor


flag = 1

for k = 1,12 do begin

temp = 0
grids = 0

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if mask[I,J] eq k and no2[I,J] gt 0 then begin
      temp += no2[I,J]
      grids += 1
    endif
  endfor
endfor

average = temp/grids

if (flag) $
  then region = average $
  else region = [region,average]

flag = 0

endfor

print,region

end
