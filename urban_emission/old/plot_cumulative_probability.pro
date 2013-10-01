pro plot_cumulative_probability

FORWARD_FUNCTION CTM_Grid, CTM_Type, Nymd2Taui, CTM_Get_Data

;InType = CTM_Type( 'GENERIC', Res=[0.5d0,0.5d0], Halfpolar=0, Center180=0 )
InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType, /No_Vertical )

inxmid = InGrid.xmid
inymid = InGrid.ymid

close, /all

Year = 2005
Month = 1
Day = 1

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
Day2 = string( Day, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + Day * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

xmid = InGrid.xmid
ymid = InGrid.ymid

filename1 = '/home/gengguannan/indir/GDP_2005-2007_05x0666.bpch'
filename2 = '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'

CTM_Get_Data, datainfo1, filename = filename1
data18 = *(datainfo1[0].data)

CTM_Get_Data, datainfo2, tracer = 802, tau0 = nymd2tau(19850101), filename = filename2
China_mask = *(datainfo2[0].data)

GDP = make_array(1)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if ((China_mask[I,J] eq 1) and (data18[I,J] gt 0)) then begin
;    if (China_mask[I,J] eq 1) then begin
      GDP = [GDP,data18[I,J]]
    endif
  endfor
endfor

print,n_elements(GDP)-1

p = percentiles(GDP[1:(n_elements(GDP)-1)],value=[0.5,0.6,0.7,0.8,0.9])
print,p,max(GDP)

PLOT_CPD, GDP[1:(n_elements(GDP)-1)], COLOR=!MYCT.BLACK, $
YTITLE='GDP'

end
