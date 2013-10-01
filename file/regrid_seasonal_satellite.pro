pro regrid_seasonal_satellite

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'generic', Res=[ 0.125d0, 0.125d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

OutType = CTM_Type( 'generic', Res=[ 1d0, 1d0], Halfpolar=0, Center180=0)
OutGrid = CTM_Grid( OutType )

outxmid = OutGrid.xmid
outymid = OutGrid.ymid

close, /all

for Year = 1997,2002 do begin
for k = 0,3 do begin

Yr4  = String( Year, format = '(i4.4)' )
nymd = Year * 10000L + 1 * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

season = ['MAM','JJA','SON','DJF']

no2 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod = fltarr(OutGrid.IMX,OutGrid.JMX)

if Year lt 2003 $
  then infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_'+ season[k] +'.0125x0125.bpch' $
  else infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_'+ season[k] +'.0125x0125.bpch'

CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, tau0 = tau0, filename = infile
data18 = *(datainfo1[0].data)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    x = where( (inxmid[I] gt (outxmid - 0.5)) and (inxmid[I] le (outxmid + 0.5)))
    y = where( (inymid[J] gt (outymid - 0.5)) and (inymid[J] le (outymid + 0.5)))
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
        else  no2[I,J] = -999.0
  endfor
endfor

if Year lt 2003 $
  then Outfile = '/z3/gengguannan/satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 +'_'+ season[k] +'.1x1.bpch' $
  else Outfile = '/z3/gengguannan/satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 +'_'+ season[k] +'.1x1.bpch'

   success = CTM_Make_DataInfo( no2,       $
                                ThisDataInfo,           $
                                ModelInfo=OutType,      $
                                GridInfo=OutGrid,       $
                                DiagN='IJ-AVG-$',       $
                                Tracer=1,               $
                                Tau0= tau0,             $
                                Unit='E+15molec/cm2',   $
                                Dim=[OutGrid.IMX,OutGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],     $
                                /No_vertical )

    CTM_WriteBpch, ThisDataInfo, FileName = OutFile
    CTM_Cleanup

endfor
endfor

end
