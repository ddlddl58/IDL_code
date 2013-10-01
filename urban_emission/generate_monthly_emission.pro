pro generate_monthly_emission

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Make_DataInfo, Nymd2Tau, StrBreak

Intype = ctm_type( 'GEOS5', res = [2.d0/3d0, 1.d0/2.d0] )
Ingrid = ctm_grid(Intype)

close,/all


sector = ['ind','res','tra']

for n = 0,2 do begin


;read meic monthly variation
meicfile = '/home/gengguannan/indir/meic_201207/2006/meic_NOx_'+ sector[n] +'_2006.05x0666'

meicemis = make_array(12)

for month = 1,12 do begin

nymd = 2006 * 10000L + month * 100L + 1L
tau0 = nymd2tau(nymd)

CTM_Get_Data, emis, 'ANTHSRCE', Tracer = 1, filename = meicfile, Tau0 = tau0
temp_emis = *(emis[0].data)

meicemis[month-1] = total(temp_emis)

endfor

factor = meicemis / total(meicemis)


;generate monthly file
Infile = '/home/gengguannan/indir/intexb_scaled/NOx_'+ sector[n] +'_2006.05x0666'
Outfile = '/home/gengguannan/indir/intexb_scaled/Scaled_NOx_'+ sector[n] +'_2006.05x0666'

CTM_Get_Data, emisannual, 'ANTHSRCE', Tracer = 1, filename = Infile
annual_emis = *(emisannual[0].data)

finalemis = make_array(12)

for month = 1,12 do begin

flag = 1

gemis = annual_emis * factor[month-1]

finalemis[month-1] = total(gemis)

nymd = 2006 * 10000L + month * 100L + 1L
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

print,meicemis,finalemis
print,total(meicemis),total(finalemis)

endfor

end
