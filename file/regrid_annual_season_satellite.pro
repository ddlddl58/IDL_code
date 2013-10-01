pro regrid_annual_season_satellite,year

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

;InType = CTM_Type( 'generic', Res=[ 0.125d0, 0.125d0], Halfpolar=0, Center180=0)
InType = CTM_Type( 'GEOS5', Res=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

OutType = CTM_Type( 'generic', Res=[ 0.5d0, 0.5d0], Halfpolar=0, Center180=0)
;OutType = CTM_Type( 'GEOS5', Res=[2d0/3d0,0.5d0] )
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all

year = year

no2 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod = fltarr(OutGrid.IMX,OutGrid.JMX)

nymd = year*10000L+1*100L+1*1L
print,nymd
tau0 = nymd2tau(nymd)

infile = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x0666.bpch'

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile
data18 = *(datainfo1[0].data)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    x = where( (inxmid[I] gt (outxmid - 0.25d0)) and (inxmid[I] le (outxmid + 0.25d0)))
    y = where( (inymid[J] gt (outymid - 0.25d0)) and (inymid[J] le (outymid + 0.25d0)))
    if (data18[I,J] gt 0) then begin
        no2 [x,y] += data18[I,J]
        nod [x,y] += 1
    endif
  endfor
endfor

for I = 0,OutGrid.IMX-1 do begin
  for J = 0,OutGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  no2[I,J] /= nod[I,J]  $
        else  no2[I,J] = -999
  endfor
endfor

OutFile = '/z3/gengguannan/satellite/no2/ur_emiss/omi_no2_seasonal_average_2005-2007_JJA_05x05.bpch'

   success = CTM_Make_DataInfo( no2,       $
                                ThisDataInfo,            $
                                ModelInfo=OutType,       $
                                GridInfo=OutGrid,        $
                                DiagN='IJ-AVG-$',        $
                                Tracer=1,                $
                                Tau0= tau0,              $
                                Unit='10E+15molec/cm2',  $
                                Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = OutFile

   CTM_Cleanup

end
