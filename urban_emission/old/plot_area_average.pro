pro plot_area_average

FORWARD_FUNCTION CTM_Get_Data

;InType = CTM_Type('GENERIC',Res=[0.5d0, 0.5d0],Halfpolar=0,Center180=0)
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

;limit = [35,112,42,120]
;limit = [28,117,35,123]
;limit = [22,111,25,117]
limit = [27,105,33,110]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

close, /all

flag = 1L

Year = 2006
for Month = 1,12 do begin

m = fltarr(InGrid.IMX,InGrid.JMX)
s = fltarr(InGrid.IMX,InGrid.JMX)
n_day = fltarr(InGrid.IMX,InGrid.JMX)

for Day = 1,31 do begin

Yr4  = String( Year,format = '(i4.4)' )
Mon2 = String( Month,format = '(i2.2)' )
Day2 = String( Day,format = '(i2.2)' )

nymd = Year*10000L + Month*100L + Day*1L
;print,nymd
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
filename2 = '/z3/wangsiwen/Satellite/DPGC_OMI_05x06_NegIncl_06prof/OMI_0.66x0.50_'+ Yr4 +'_'+ Mon2 +'_'+ Day2
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
    if ( (data18[I,J] gt 0) and (data28[I,J] gt 0) ) then begin
       m[I,J] += data18[I,J]
       s[I,J] += data28[I,J]
       n_day[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor

print,'%%%%%%%%%%%end of a month%%%%%%%%%%%'
print,max(n_day,min=min),min

for I = I1,I2 do begin
  for J = J1,J2 do begin
    if ( n_day[I,J] gt 0L ) then begin
       m[I,J] /= n_day[I,J]
       s[I,J] /= n_day[I,J]
    endif else begin
       m[I,J] = -999.0
       s[I,J] = -999.0
    endelse
  endfor
endfor

temp_m = 0
temp_s = 0
n_grid = 0

 for I = I1,I2 do begin
   for J = J1,J2 do begin
     if ( (m[I,J] gt 0) and (s[I,J] gt 0) ) then begin
       temp_m += m[I,J]
       temp_s += s[I,J]
       n_grid += 1
     endif
   endfor
 endfor

m_average = temp_m/n_grid
s_average = temp_s/n_grid

;print,m_average,s_average

if (flag) then begin
model = m_average
satellite = s_average
endif else begin
model = [model,m_average]
satellite = [satellite,s_average]
endelse

flag = 0L

endfor

print,model,satellite

;BARGRAPH, model, XSTYLE=1, BARWIDTH=0.4, BARLABELS=model, L_FORMAT='(F4.1)',YRANGE=[0,12],$
;          XLABELS=['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'],$
;          XTITLE='Month', YTITLE='Tropospheric NO2 columns'
;BARGRAPH, satellite, BARWIDTH=0.4, /OVERPLOT,$
;          BARCOLOR=2, BARLABELS=satellite, L_FORMAT='(F4.1)'

end
