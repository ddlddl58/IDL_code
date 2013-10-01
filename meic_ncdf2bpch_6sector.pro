pro meic_ncdf2bpch_6sector,year

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak

Intype = ctm_type( 'GEOS5', res = [2.d0/3d0, 1.d0/2.d0] )
Ingrid = ctm_grid(Intype)

close,/all


sector = ['industry','power','transportation','residential-bio','residential-fos','residential-noncom']
title = ['ind','pow','tra','dob','dof','dop']

for n = 5,5 do begin


year = year
Yr4 = string( year, format = '(i4.4)' )

flag = 1L
test = fltarr(InGrid.IMX,InGrid.JMX)

for month = 1,12 do begin
Mon = strtrim( month, 1)
Mon2 = string( month, format = '(i2.2)' )


; ALK4(5),ACET(9),MEK(10),ALD2(11),PRPE(18),C3H8(19),CH2O(20),C2H6(21)
old = ['ACET','ALK1','ALK2','ALK3','ALK4','ALK5','CCHO','HCHO','MEK','OLE1','OLE2']

saprc99 = fltarr(InGrid.IMX,InGrid.JMX,11)

for k = 0,10 do begin

Indir = '/home/gengguannan/indir/meic_s1/'+ Yr4 +'/'+ sector[n] +'_'+ Yr4 +'__'+ Mon +'/'
infile = Indir + Yr4 +'_'+ Mon2 +'__'+ sector[n] +'__SAPRC99_'+ old[k] +'.nc'

;read data
emis = fltarr(10800)

fid = ncdf_open(infile)
dataid = ncdf_varid(fid,'z')
ncdf_varget,fid,dataid,emis

remis=reform(emis,[120,90])
ind = where(remis lt 0.)
remis[ind] = 0.0

for I = 0L,120L-1L do begin
  for J = 0L,90L-1L do begin
    saprc99[I+375L,J+210L,k] = remis[I,89-J] * 6.02e23 * 1e6
  endfor
endfor

endfor

print,total(total(saprc99,3) / 6.02e23 / 1e6)
test = test + total(saprc99,3) / 6.02e23 / 1e6

ALK4 = ( saprc99[*,*,3] + saprc99[*,*,4] + saprc99[*,*,5] ) * 4
ACET = ( saprc99[*,*,0] ) * 3
MEK = saprc99[*,*,8] * 4
ALD2 = saprc99[*,*,6] * 2
PRPE = ( saprc99[*,*,9] + saprc99[*,*,10] ) * 3
C3H8 = saprc99[*,*,2] * 3
CH2O = saprc99[*,*,7] * 1
C2H6 = saprc99[*,*,1] * 2


Outdir = '/home/gengguannan/indir/meic_s1/'+ Yr4 +'/'

outfile1 = Outdir + 'meic_ALK4_'+ title[n] +'_'+ Yr4 +'.05x0666'
outfile2 = Outdir + 'meic_ACET_'+ title[n] +'_'+ Yr4 +'.05x0666'
outfile3 = Outdir + 'meic_MEK_'+ title[n] +'_'+ Yr4 +'.05x0666'
outfile4 = Outdir + 'meic_ALD2_'+ title[n] +'_'+ Yr4 +'.05x0666'
outfile5 = Outdir + 'meic_PRPE_'+ title[n] +'_'+ Yr4 +'.05x0666'
outfile6 = Outdir + 'meic_C3H8_'+ title[n] +'_'+ Yr4 +'.05x0666'
outfile7 = Outdir + 'meic_CH2O_'+ title[n] +'_'+ Yr4 +'.05x0666'
outfile8 = Outdir + 'meic_C2H6_'+ title[n] +'_'+ Yr4 +'.05x0666'

nymd = year * 10000L + month * 100L + 1L
tau0 = nymd2tau(nymd)

; outfile1
Success = CTM_Make_DataInfo( ALK4,                 $
                             ThisDataInfo1,        $
                             ThisFileInfo1,        $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=5,             $
                             Tau0=tau0,            $
                             Unit='atom C/month',  $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                       $
  then NewDataInfo1 = [ ThisDataInfo1 ]          $
  else NewDataInfo1 = [ NewDataInfo1, ThisDataInfo1 ]

If (flag )                                       $
  then NewFileInfo1 = [ ThisFileInfo1 ]          $
  else NewFileInfo1 = [ NewFileInfo1, ThisFileInfo1 ]

; outfile2
Success = CTM_Make_DataInfo( ACET,                 $
                             ThisDataInfo2,        $
                             ThisFileInfo2,        $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=9,             $
                             Tau0=tau0,            $
                             Unit='atom C/month',  $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                       $
  then NewDataInfo2 = [ ThisDataInfo2 ]          $
  else NewDataInfo2 = [ NewDataInfo2, ThisDataInfo2 ]

If (flag )                                       $
  then NewFileInfo2 = [ ThisFileInfo2 ]          $
  else NewFileInfo2 = [ NewFileInfo2, ThisFileInfo2 ]

; outfile3
Success = CTM_Make_DataInfo( MEK,                  $
                             ThisDataInfo3,        $
                             ThisFileInfo3,        $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=10,            $
                             Tau0=tau0,            $
                             Unit='atom C/month',  $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                       $
  then NewDataInfo3 = [ ThisDataInfo3 ]          $
  else NewDataInfo3 = [ NewDataInfo3, ThisDataInfo3 ]

If (flag )                                       $
  then NewFileInfo3 = [ ThisFileInfo3 ]          $
  else NewFileInfo3 = [ NewFileInfo3, ThisFileInfo3 ]

; outfile4
Success = CTM_Make_DataInfo( ALD2,                 $
                             ThisDataInfo4,        $
                             ThisFileInfo4,        $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=11,            $
                             Tau0=tau0,            $
                             Unit='atom C/month',  $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                     $
  then NewDataInfo4 = [ ThisDataInfo4]          $
  else NewDataInfo4 = [ NewDataInfo4, ThisDataInfo4 ]

If (flag )                                     $
  then NewFileInfo4 = [ ThisFileInfo4 ]          $
  else NewFileInfo4 = [ NewFileInfo4, ThisFileInfo4 ]

; outfile5
Success = CTM_Make_DataInfo( PRPE,                 $
                             ThisDataInfo5,        $
                             ThisFileInfo5,        $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=18,            $
                             Tau0=tau0,            $
                             Unit='atom C/month',  $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                       $
  then NewDataInfo5 = [ ThisDataInfo5 ]          $
  else NewDataInfo5 = [ NewDataInfo5, ThisDataInfo5 ]

If (flag )                                       $
  then NewFileInfo5 = [ ThisFileInfo5 ]          $
  else NewFileInfo5 = [ NewFileInfo5, ThisFileInfo5 ]

; outfile6
Success = CTM_Make_DataInfo( C3H8,                 $
                             ThisDataInfo6,        $
                             ThisFileInfo6,        $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=19,            $
                             Tau0=tau0,            $
                             Unit='atom C/month',  $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                       $
  then NewDataInfo6 = [ ThisDataInfo6 ]          $
  else NewDataInfo6 = [ NewDataInfo6, ThisDataInfo6 ]

If (flag )                                       $
  then NewFileInfo6 = [ ThisFileInfo6 ]          $
  else NewFileInfo6 = [ NewFileInfo6, ThisFileInfo6 ]

; outfile7
Success = CTM_Make_DataInfo( CH2O,                 $
                             ThisDataInfo7,        $
                             ThisFileInfo7,        $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=20,            $
                             Tau0=tau0,            $
                             Unit='atom C/month',  $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                       $
  then NewDataInfo7 = [ ThisDataInfo7 ]          $
  else NewDataInfo7 = [ NewDataInfo7, ThisDataInfo7 ]

If (flag )                                       $
  then NewFileInfo7 = [ ThisFileInfo7 ]          $
  else NewFileInfo7 = [ NewFileInfo7, ThisFileInfo7 ]

; outfile8
Success = CTM_Make_DataInfo( C2H6,                 $
                             ThisDataInfo8,        $
                             ThisFileInfo8,        $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=21,            $
                             Tau0=tau0,            $
                             Unit='atom C/month',  $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                       $
  then NewDataInfo8 = [ ThisDataInfo8 ]          $
  else NewDataInfo8 = [ NewDataInfo8, ThisDataInfo8 ]

If (flag )                                       $
  then NewFileInfo8 = [ ThisFileInfo8 ]          $
  else NewFileInfo8 = [ NewFileInfo8, ThisFileInfo8 ]

flag = 0L

endfor

CTM_WriteBpch, newDataInfo1, newFileInfo1, Filename=Outfile1
CTM_WriteBpch, newDataInfo2, newFileInfo2, Filename=Outfile2
CTM_WriteBpch, newDataInfo3, newFileInfo3, Filename=Outfile3
CTM_WriteBpch, newDataInfo4, newFileInfo4, Filename=Outfile4
CTM_WriteBpch, newDataInfo5, newFileInfo5, Filename=Outfile5
CTM_WriteBpch, newDataInfo6, newFileInfo6, Filename=Outfile6
CTM_WriteBpch, newDataInfo7, newFileInfo7, Filename=Outfile7
CTM_WriteBpch, newDataInfo8, newFileInfo8, Filename=Outfile8

ctm_cleanup

print,title[n],total(test)

endfor

end
