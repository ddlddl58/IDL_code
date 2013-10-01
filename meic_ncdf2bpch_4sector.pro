pro meic_ncdf2bpch_4sector,year

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak

Intype = ctm_type( 'GEOS5', res = [2.d0/3d0, 1.d0/2.d0] )
Ingrid = ctm_grid(Intype)

close,/all



; NOx(1), SO2(26), CO(4)
species = 'CO'

year = year
Yr4 = string( year, format = '(i4.4)' )


sector = ['industry','power','residential','transportation']
title = ['ind','pow','res','tra']

for n = 0,3 do begin


flag = 1L
test = fltarr(InGrid.IMX,InGrid.JMX)

for month = 1,12 do begin
Mon = strtrim( month, 1)
Mon2 = string( month, format = '(i2.2)' )

Indir = '/home/gengguannan/indir/meic_s1/'+ Yr4 +'/'+ sector[n] +'_'+ Yr4 +'__'+ Mon +'/'
Outdir = '/home/gengguannan/indir/meic_s1/'+ Yr4 +'/'

infile = Indir + Yr4 +'_'+ Mon2 +'__'+ sector[n] +'__'+ species +'.nc'
outfile = Outdir + 'meic_'+ species +'_'+ title[n] +'_'+ Yr4 +'.05x0666'



;read data
gemis = fltarr(InGrid.IMX,InGrid.JMX)
emis = fltarr(10800)

fid = ncdf_open(infile)
dataid = ncdf_varid(fid,'z')
ncdf_varget,fid,dataid,emis

remis=reform(emis,[120,90])
ind = where(remis lt 0.)
remis[ind] = 0.0
;print,total(remis)
;print,max(remis,min=min),min

for I = 0L,120L-1L do begin
  for J = 0L,90L-1L do begin
    gemis[I+375L,J+210L] = remis[I,89-J]*1000L ;convert from t to kg
  endfor
endfor

;print,Mon2,total(gemis)
test = test + gemis/1000

nymd = year * 10000L + month * 100L + 1L
tau0 = nymd2tau(nymd)

; Make a DATAINFO structure for this NEWDATA
Success = CTM_Make_DataInfo( gemis,                $
                             ThisDataInfo,         $
                             ThisFileInfo,         $
                             ModelInfo=InType,     $
                             GridInfo=InGrid,      $
                             DiagN='ANTHSRCE',     $
                             Tracer=4,            $
                             Tau0=tau0,            $
                             Unit='kg/month',      $
                             Dim=[InGrid.IMX,      $
                                  InGrid.JMX,      $
                                  0, 0],           $
                             First=[1L, 1L, 1L],   $
                             /No_vertical )

If (flag )                                     $
  then NewDataInfo = [ ThisDataInfo ]          $
  else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

If (flag )                                     $
  then NewFileInfo = [ ThisFileInfo ]          $
  else NewFileInfo = [ NewFileInfo, ThisFileInfo ]

flag = 0L

endfor

CTM_WriteBpch, newDataInfo, newFileInfo, Filename=Outfile
print,total(test)

endfor

ctm_cleanup

end
