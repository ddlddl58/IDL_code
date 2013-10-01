pro no2_ctm_average_from_month

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
;InType = CTM_Type('GENERIC', Res=[0.25d0,0.25d0],halfpolar=0,center180=0)
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid
close, /all

year = 2005

no2 = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

m = [12,1,2]

for k = 0,2 do begin

mon2 = string(m[k], format='(i2.2)')

nymd = year*10000L + (m[k])*100L + 1L
print,nymd
tau0 = nymd2tau(nymd)

infile = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_monthly_2005-2007_'+ mon2 +'_NO2.month.05x0666.power.plant.bpch'

CTM_Get_Data, datainfo, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile
data18 = *(datainfo[0].data)

;OMI_ARRAY = fltarr(InGrid.IMX,InGrid.JMX)
;restore,filename=infile
;data18 = OMI_ARRAY/1.0E+15


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (data18[I,J] gt 0) then begin
       no2[I,J] += data18[I,J] 
       nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor

print,max(nod,min=min),min,mean(nod)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  no2[I,J] /= nod[I,J]  $
        else  no2[I,J] = 0
  endfor
endfor

print,max(no2,min=min),min,mean(no2)

outfile = '/z3/gengguannan/GEOS_Chem/ur_emiss/ctm.vc_seasonal_2005-2007_DJF_NO2.month.05x0666.power.plant.bpch'


   success = CTM_Make_DataInfo( no2,       $
                                ThisDataInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN='IJ-AVG-$',       $
                                Tracer=1,               $
                                Tau0= nymd2tau(nymd),             $
                                Unit='E+15molec/cm2',              $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = OutFile

end
