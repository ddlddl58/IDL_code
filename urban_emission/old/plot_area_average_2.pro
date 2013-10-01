pro plot_area_average_2

FORWARD_FUNCTION CTM_Get_Data

;InType = CTM_Type('GENERIC',Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0)
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

;limit = [20,110,50,120]
limit = [25,100,32,120]


i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

print,I1,I2,J1,J2

close, /all


filename0 = '/home/gengguannan/indir/popu/urpopu_05x0666.bpch'

CTM_Get_Data, datainfo0, tracer = 802,  filename = filename0
urpopu = *(datainfo0[0].data)


flag = 1L

Year = 2006
for Month = 1,12 do begin


m = fltarr(InGrid.IMX,InGrid.JMX)
s = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)


for Day = 1,31 do begin

Yr4  = String( Year,format = '(i4.4)' )
Mon2 = String( Month,format = '(i2.2)' )
Day2 = String( Day,format = '(i2.2)' )

nymd = Year*10000L + Month*100L + Day*1L
print,nymd
tau0 = nymd2tau(nymd)

if (nymd eq 20060101) then continue
if (nymd eq 20060228) then continue
if (nymd eq 20060229) then continue
if (nymd eq 20060230) then continue
if (nymd eq 20060231) then continue
if (nymd eq 20060301) then continue
if (nymd eq 20060302) then continue
if (nymd eq 20060425) then continue
if (nymd eq 20060431) then continue
if (nymd eq 20060517) then continue
if (nymd eq 20060631) then continue
if (nymd eq 20060931) then continue
if (nymd eq 20061004) then continue
if (nymd eq 20061131) then continue


filename1 = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_daily_2006'+ Mon2 +'_NO2.month.05x0666.power.plant.bpch'
filename2 = '/z3/wangsiwen/Satellite/no2/DPGC_OMI_GEOS5_05x06profile_05x06_crd30/OMI_0.66x0.50_'+ Yr4 +'_'+ Mon2 +'_'+ Day2 +'_sza70_crd30_v2'
;filename2 = '/z3/gengguannan/satellite/no2/bishe/CF_0.2/'+ Mon2 +'/omi_no2_'+ Yr4 + Mon2 + Day2 +'_v003_tropCS020_05x05.bpch'

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = filename1
data18 = *(datainfo1[0].data)

;CTM_Get_Data, datainfo2, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = filename2
;data28 = *(datainfo2[0].data)
OMI_ARRAY = fltarr(InGrid.IMX,InGrid.JMX)
restore,filename=filename2
data28 = OMI_ARRAY/1.0E+15


for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (data18[I,J] gt 0) and (data28[I,J] gt 0) then begin
      m[I,J] += data18[I,J]
      s[I,J] += data28[I,J]
      nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor

print,'%%%%%%%%%%%end of a month%%%%%%%%%%%'
print,max(nod,min=min),min

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if nod[I,J] gt 0L then begin
       m[I,J] /= nod[I,J]
       s[I,J] /= nod[I,J]
    endif else begin
       m[I,J] = -999.0
       s[I,J] = -999.0
    endelse
  endfor
endfor


temp_m1 = 0
temp_m2 = 0
temp_s1 = 0
temp_s2 = 0
n_grid1 = 0
n_grid2 = 0


for I = I1,I2 do begin
  for J = J1,J2 do begin
    if (m[I,J] gt 0) and (s[I,J] gt 0) then begin
      if urpopu[I,J] ge 1000000 then begin
        temp_m1 += m[I,J]
        temp_s1 += s[I,J]
        n_grid1 += 1
      endif else begin
        temp_m2 += m[I,J]
        temp_s2 += s[I,J]
        n_grid2 += 1
      endelse
    endif
  endfor
endfor

m_average1 = temp_m1/n_grid1
s_average1 = temp_s1/n_grid1
m_average2 = temp_m2/n_grid2
s_average2 = temp_s2/n_grid2

;print,m_average,s_average

if (flag) then begin
  model1 = m_average1
  satellite1 = s_average1
  model2 = m_average2
  satellite2 = s_average2
endif else begin
  model1 = [model1,m_average1]
  satellite1 = [satellite1,s_average1]
  model2 = [model2,m_average2]
  satellite2 = [satellite2,s_average2]
endelse

flag = 0L

endfor

print,model1,satellite1
print,model2,satellite2

end
