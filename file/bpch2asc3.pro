pro bpch2asc3,year

FORWARD_FUNCTION CTM_Grid, CTM_Type

year = year
Yr4 = string( Year, format='(i4.4)' )

limit = [15,70,55,136]


;infile = '/z3/gengguannan/satellite/no2/bishe/average/omi_no2_lok_annual_average_2006_05x05.bpch'
;infile = '/z3/gengguannan/GEOS_Chem/bishe/ctm.vc_annual_2006_NO2.05x05.power.plant.bpch' 
infile = '/home/gengguannan/result/trend_analysis_slope_1x1.bpch'

InType = CTM_Type('GENERIC', Res=[1d0,1d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid(InType)
xmid = InGrid.xmid
ymid = InGrid.ymid

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
print, 'I1:I2',I1,I2, 'J1:J2',J1,J2
print,xmid[I1],ymid[J1]

nymd = year*10000L + 1*100L + 1*1L
tau0 = nymd2tau(nymd)

CTM_Get_Data, datainfo, filename = infile
data18 = *(datainfo[0].data)

print,total(data18)

data818 = data18[I1:I2,J1:J2]
help,data818

xdata=I2-I1+1
ydata=J2-J1+1
print,xdata,ydata

;outfile = '/home/gengguannan/omi_no2_lok_annual_average_2006_05x05.asc'
;outfile = '/home/gengguannan/ctm.vc_annual_2006_NO2.05x05.power.plant.asc'
outfile = '/home/gengguannan/result/trend_analysis_slope_1x1.asc'

print,outfile

openw,lun,outfile,/GET_LUN

;printf, lun, 'ncols         160'
;printf, lun, 'nrows         90'
;printf, lun, 'xllcorner     70.25'
;printf, lun, 'yllcorner     10.25'
;printf, lun, 'cellsize      0.5000'
;printf, lun, 'nodata_value  -999.0000'
printf, lun, 'ncols         66'
printf, lun, 'nrows         40'
printf, lun, 'xllcorner     70.5'
printf, lun, 'yllcorner     15.5'
printf, lun, 'cellsize      1.000'
printf, lun, 'nodata_value  -999.0000'



;printf, lun, 'unit          1.0E+15 molec/cm2'

for pp = 0,ydata-1L do begin

printf, lun, format = '(640f10.4)',data818[*,ydata-1L-pp] 

endfor

close, lun
free_lun, lun

CTM_Cleanup

end


