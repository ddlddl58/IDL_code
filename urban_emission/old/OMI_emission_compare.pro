pro OMI_emission_compare

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

InType = CTM_Type( 'GENERIC', Res=[0.25d0,0.25d0], Halfpolar=0, Center180=0 )
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid


;get China mask
filename1 = '/home/gengguannan/indir/China_mask.geos5.v3.025x025'
ctm_get_data,datainfo_1,filename = filename1,tracer=802
China_mask=*(datainfo_1[0].data)

;get OMI data
filename2 = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2009_JJA_025x025.bpch'
ctm_get_data,datainfo_2,filename = filename2,tracer=1
no2=*(datainfo_2[0].data)

;get emission data
emis = fltarr(InGrid.IMX,InGrid.JMX)
nod = 0

Year = 2007
for Month = 6,8 do begin

Yr4 = string( Year, format = '(i4.4)')

nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

filename3 = '/z3/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/dom-'+ Yr4 +'-025x025.bpch'
filename4 = '/z3/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/ind-'+ Yr4 +'-025x025.bpch'
filename5 = '/z3/gengguannan/indir/China_NOx_Emissions_monthly_2005-2007_by_Sector/bpch/tra-'+ Yr4 +'-025x025.bpch'
filename6 = '/z3/gengguannan/indir/power_plant_emission/Power_Plant_NOx_emission_2007_month_all_size.025x025.bpch'

ctm_get_data,datainfo_3,filename = filename3,tau0=Tau0,tracer=1
dom=*(datainfo_3[0].data)

ctm_get_data,datainfo_4,filename = filename4,tau0=Tau0,tracer=1
ind=*(datainfo_4[0].data)

ctm_get_data,datainfo_5,filename = filename5,tau0=Tau0,tracer=1
tra=*(datainfo_5[0].data)

ctm_get_data,datainfo_6,filename = filename6,tau0=Tau0,tracer=1
pow=*(datainfo_6[0].data)

print,total(dom),total(ind),total(tra),total(pow)

sum = dom+ind+tra+pow
print,total(sum)

emis += sum
nod += 1

CTM_Cleanup

endfor

print,total(emis),nod

emis = emis / nod
print,total(emis)



;print data
x = make_array(1)
y = make_array(1)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if China_mask[I,J] gt 0 and no2[I,J] gt 0 then begin
        x = [x,no2[I,J]]
        y = [y,emis[I,J]]
    endif
  endfor
endfor

outfile = '/home/gengguannan/result/ur_emiss/OMI_emission.hdf'

IF (HDF_EXISTS() eq 0) then message, 'HDF not supported'

; Open the HDF file
FID = HDF_SD_Start(Outfile,/RDWR,/Create)

HDF_SETSD, FID, x, 'x',          $
           Longname='satellite', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SETSD, FID, y, 'y',          $
           Longname='inventory', $
           Unit='unitless',      $
           FILL=-999.0
HDF_SD_End, FID


end
