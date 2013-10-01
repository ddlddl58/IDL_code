pro regrid_monthly_satellite

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

for Year = 2005,2011 do begin
for Month = 1,12 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
nymd = Year * 10000L + Month * 100L + 1 * 1L
Tau0 = nymd2tau(NYMD)
print,nymd

if nymd eq 19960101 then continue
if nymd eq 19960201 then continue
if nymd eq 19960301 then continue


no2 = fltarr(OutGrid.IMX,OutGrid.JMX)
nod = fltarr(OutGrid.IMX,OutGrid.JMX)

;infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 + Mon2 +'.bpch'
;infile = '/z3/wangsiwen/Satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 + Mon2 +'.bpch'

;infile = '/z3/wangsiwen/Satellite/no2/GOME_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'.bpch'
;infile = '/z3/wangsiwen/Satellite/no2/SCIAMACHY_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'.bpch'
infile = '/z3/wangsiwen/Satellite/no2/KNMI_L3/v2.0/no2_'+ Yr4 + Mon2 +'.bpch'


CTM_Get_Data, datainfo1, 'IJ-AVG-$', tracer = 1, filename = infile
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

;Outfile = '/z3/gengguannan/satellite/no2/SCIAMACHY_Bremen_v1.5/scia_no2_v1-5_'+ Yr4 + Mon2 +'_1x1.bpch'
;Outfile = '/z3/gengguannan/satellite/no2/GOME_Bremen/gome_no2_v3-0_'+ Yr4 + Mon2 +'_0.5x0.5.bpch'

;Outfile = '/z3/gengguannan/satellite/no2/GOME_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'_1x1.bpch'
;Outfile = '/z3/gengguannan/satellite/no2/SCIAMACHY_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'_1x1.bpch'
Outfile = '/z3/gengguannan/satellite/no2/OMI_KNMI_v2.0/no2_'+ Yr4 + Mon2 +'_1x1.bpch'

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
