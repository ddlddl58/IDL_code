pro average_GOCI_data

FORWARD_FUNCTION CTM_Grid, CTM_Type

InType = CTM_Type( 'generic', Res=[ 0.1d0, 0.1d0], Halfpolar=0, Center180=0)
;InType = CTM_Type( 'GEOS5', Resolution=[ 2d0/3d0,0.5d0 ] )
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

close, /all

for t = 0,7 do begin

avg = fltarr(InGrid.IMX, InGrid.JMX)
nod = fltarr(InGrid.IMX, InGrid.JMX)

for m = 4,5 do begin
for d = 1,31 do begin

Mon2 = string( m, format = '(i2.2)')
Day2 = string( d, format = '(i2.2)')
tim2 = string( t, format = '(i2.2)')

nymd = m*10000L + d*100L + t*1L
print,nymd

if nymd eq 043100 then continue
if nymd eq 043101 then continue
if nymd eq 043102 then continue
if nymd eq 043103 then continue
if nymd eq 043104 then continue
if nymd eq 043105 then continue
if nymd eq 043106 then continue
if nymd eq 043107 then continue
if nymd eq 052200 then continue
if nymd eq 052501 then continue
if nymd eq 052502 then continue
if nymd eq 052605 then continue
if nymd eq 051807 then continue


infile = '/data1/guannan/data/GOCI/goci_aop_2011'+ Mon2 + Day2 + tim2 +'.bpch'

Undefine, DataInfo
CTM_Get_Data, DataInfo, 'IJ-AVG-$', Tracer = 26, File = infile
AOD = *( DataInfo[0].Data )


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if AOD[I,J] gt 0 then begin
      avg[I,J] = avg[I,J] + AOD[I,J]
      nod[I,J] = nod[I,J] + 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor

print,max(nod)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0) $
      then avg[I,J] = avg[I,J] / nod[I,J] $
      else avg[I,J] = -999
  endfor
endfor
print,max(avg)


outfile = '/data1/guannan/data/GOCI/AOD_goci_2011apr-may'+ tim2 +'_average.bpch'
tau0 = nymd2tau(20110401)

  Success = CTM_Make_DataInfo( avg,                     $
                               ThisDataInfo,            $
                               ModelInfo=InType,        $
                               GridInfo=InGrid,         $
                               DiagN='IJ-AVG-$',        $
                               Tracer=26,               $
                               Tau0=Tau0,               $
                               Tau1=Tau0+24.0,          $
                               Unit='DU',               $
                               Dim=[InGrid.IMX,         $
                                    InGrid.JMX,         $
                                    0, 0],              $
                               First=[1L, 1L, 1L],      $
                               /No_vertical )

  Success = CTM_Make_DataInfo( nod,                     $
                               ThisDataInfo2,           $
                               ModelInfo=InType,        $
                               GridInfo=InGrid,         $
                               DiagN='IJ-AVG-$',        $
                               Tracer=88,               $
                               Tau0=Tau0,               $
                               Tau1=Tau0+24.0,          $
                               Unit='unitless',         $
                               Dim=[InGrid.IMX,         $
                                    InGrid.JMX,         $
                                    0, 0],              $
                               First=[1L, 1L, 1L],      $
                               /No_vertical )

  NewDataInfo = [Thisdatainfo,Thisdatainfo2]
  CTM_WriteBpch, NewDataInfo, Filename = outfile


endfor

end
