pro average_no2

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Writebpch

InType = CTM_Type( 'geos5',res=[2d0/3d0,0.5d0])
;InType = CTM_Type( 'generic', res=[ 0.25d0, 0.25d0], Halfpolar=0, Center180=0)
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

close, /all


for y = 2006,2006 do begin
Yr4  = String( y, format='(i4.4)')

if y eq 2004 or y eq 2008 $
  then Dayofmonth = [31,29,31,30,31,30,31,31,30,31,30,31] $
  else Dayofmonth = [31,28,31,30,31,30,31,31,30,31,30,31]

no2_omi = fltarr(InGrid.IMX,InGrid.JMX)
no2_gc = fltarr(InGrid.IMX,InGrid.JMX)
nod = fltarr(InGrid.IMX,InGrid.JMX)


for m = 1,12 do begin
Mon2 = string( m, format='(i2.2)')

for d = 1,Dayofmonth[m-1] do begin
Day2 = string( d, format='(i2.2)')


nymd = y*10000L + m*100L + d*1L
print,nymd
tau0 = nymd2tau(nymd)

if (nymd eq 20060228) then continue
if (nymd eq 20060301) then continue
if (nymd eq 20060302) then continue
if (nymd eq 20080927) then continue
if (nymd eq 20080928) then continue
if (nymd eq 20080929) then continue


infile1 = '/home/gengguannan/satellite/no2/OMI_KNMI_v2.0/05x0666/'+ Yr4 +'/OMI_0.66x0.50_'+ Yr4 +'_'+ Mon2 +'_'+ Day2

OMI_ARRAY = fltarr(InGrid.IMX,InGrid.JMX)
restore,filename=infile1
data18 = OMI_ARRAY

print,max(data18)


infile2 = '/home/gengguannan/work/longterm/no2/ctm.vc_daily_'+ Yr4 + Mon2 +'_NO2.meic.05x0666.bpch'

CTM_Get_Data, datainfo, tracer = 1, tau0 = tau0, filename = infile2
data28 = *(datainfo[0].data)

print,max(data28)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (data18[I,J] gt 0) then begin
       no2_omi[I,J] += data18[I,J]
       no2_gc[I,J] += data28[I,J]
       nod[I,J] += 1
    endif
  endfor
endfor

CTM_Cleanup

endfor
endfor

print,max(nod,min=min),min,mean(nod)


for I = 0,InGrid.IMX-1 do begin
  for J = 0,InGrid.JMX-1 do begin
    if (nod[I,J] gt 0) then begin
      no2_omi[I,J] /= nod[I,J]
      no2_gc[I,J]  /= nod[I,J]
    endif else begin
      no2_omi[I,J] = -999
      no2_gc[I,J]  = -999
    endelse
  endfor
endfor

print,max(no2_omi,min=min),min,mean(no2_omi)
print,max(no2_gc, min=min),min,mean(no2_gc)

;OMI
outfile1 = '/home/gengguannan/work/longterm/no2/omi_v2_no2_yearly_average_'+ Yr4 +'.05x0666.bpch'
outfile2 = '/home/gengguannan/work/longterm/no2/ctm.vc_yearly_'+ Yr4 +'_NO2.meic.05x0666.bpch'

nymd0 = y * 10000L + 1 * 100L + 1 * 1L

   success = CTM_Make_DataInfo( no2_omi,                 $
                                ThisDataInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='IJ-AVG-$',        $
                                Tracer=1,                $
                                Tau0= nymd2tau(nymd0),   $
                                Unit='E+15molec/cm2',    $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],      $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = outfile1

   success = CTM_Make_DataInfo( no2_gc,                  $
                                ThisDataInfo,            $
                                ModelInfo=InType,        $
                                GridInfo=InGrid,         $
                                DiagN='IJ-AVG-$',        $
                                Tracer=1,                $
                                Tau0= nymd2tau(nymd0),   $
                                Unit='E+15molec/cm2',    $
                                Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                                First=[1L, 1L, 1L],      $
                                /No_vertical )

   CTM_WriteBpch, ThisDataInfo, FileName = outfile2

endfor

end
