pro average_MODIS_data

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak, CTM_BoxSize, CTM_RegridH, CTM_NamExt, CTM_ResExt

CTM_CleanUp

InType = CTM_Type( 'generic', Res=[ 0.1d0, 0.1d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType )

inxmid = InGrid.xmid
inymid = InGrid.ymid

close, /all


avg = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)

year = 2011
for Month = 4,5 do begin
for Day = 1,31 do begin

Yr4  = String( Year, format = '(i4.4)' )
Mon2 = string( Month, format = '(i2.2)')
Day2 = string( Day, format = '(i2.2)')

nymd = Year * 10000L + Month * 100L + Day * 1L
print,nymd

if (nymd eq 20110431) then continue


;infile = '/data1/guannan/data/MODIS/AODterraMODIS'+Yr4+Mon2+Day2+'.asc'
infile = '/data1/guannan/data/MODIS/AODaquaMODIS'+Yr4+Mon2+Day2+'.asc'

aod  = fltarr(InGrid.IMX,InGrid.JMX)

Open_File, infile, Ilun, /Get_LUN
ReadF, Ilun, aod
help, aod

Close,    Ilun
Free_LUN, Ilun

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if aod[I,J] gt 0 then begin
      avg[I,J] = avg[I,J] + aod[I,J]
      nod[I,J] = nod[I,J] + 1
    endif
  endfor
endfor

endfor
endfor

print,max(nod)

for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0L)             $
        then  avg[I,J] = avg[I,J] / nod[I,J]  $
        else  avg[I,J] = -999.0
  endfor
endfor

print,max(avg)


;outfile = '/data1/guannan/data/MODIS/AODterraMODIS_2011apr-may_average.bpch'
outfile = '/data1/guannan/data/MODIS/AODaquaMODIS_2011apr-may_average.bpch'
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

end
