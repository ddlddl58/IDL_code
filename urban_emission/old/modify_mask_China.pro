pro modify_mask_China

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

;infile = '/z2/geos/GEOS_0.5x0.666_CH/Streets_200607/China_mask.geos5.05x0666'
infile = '/home/gengguannan/indir/China_mask.geos5.v2.05x0666'
outfile= '/home/gengguannan/indir/China_mask.geos5.v3.05x0666'

ctm_get_data,datainfo,filename = infile,tau0=nymd2tau(19850101),tracer=802
China_mask=*(datainfo[0].data)

limit = [15,105,40,130]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

for I = I1,I2 do begin
  for J = J1,J2 do begin
;for I = 1,InGrid.IMX-2 do begin
;  for J = 1,InGrid.JMX-2 do begin
;    if (China_mask[I,J] eq 0) then begin
;      China_mask[I-1,J] = 0
;      China_mask[I,J-1] = 0
;      China_mask[I-1,J-1] = 0
    if I eq 436 and J eq 219 then China_mask[I,J]=0
    if I eq 436 and J eq 222 then China_mask[I,J]=0
    if I eq 441 and J eq 223 then China_mask[I,J]=0
    if I eq 440 and J eq 223 then China_mask[I,J]=0
    if I eq 439 and J eq 223 then China_mask[I,J]=0
    if I eq 441 and J eq 224 then China_mask[I,J]=0
    if I eq 444 and J eq 225 then China_mask[I,J]=0
    if I eq 445 and J eq 226 then China_mask[I,J]=0
    if I eq 447 and J eq 228 then China_mask[I,J]=0
    if I eq 448 and J eq 229 then China_mask[I,J]=0
    if I eq 449 and J eq 230 then China_mask[I,J]=0
    if I eq 449 and J eq 231 then China_mask[I,J]=0
    if I eq 449 and J eq 232 then China_mask[I,J]=0
    if I eq 451 and J eq 235 then China_mask[I,J]=0
    if I eq 452 and J eq 236 then China_mask[I,J]=0
    if I eq 452 and J eq 237 then China_mask[I,J]=0
    if I eq 453 and J eq 238 then China_mask[I,J]=0
    if I eq 453 and J eq 239 then China_mask[I,J]=0
    if I eq 453 and J eq 240 then China_mask[I,J]=0
    if I eq 452 and J eq 240 then China_mask[I,J]=0
    if I eq 453 and J eq 241 then China_mask[I,J]=0
    if I eq 452 and J eq 244 then China_mask[I,J]=0
    if I eq 449 and J eq 249 then China_mask[I,J]=0
    if I eq 449 and J eq 250 then China_mask[I,J]=0
    if I eq 450 and J eq 251 then China_mask[I,J]=0
    if I eq 453 and J eq 253 then China_mask[I,J]=0
    if I eq 452 and J eq 253 then China_mask[I,J]=0
    if I eq 451 and J eq 253 then China_mask[I,J]=0
    if I eq 453 and J eq 254 then China_mask[I,J]=0
    if I eq 453 and J eq 255 then China_mask[I,J]=0
    if I eq 452 and J eq 255 then China_mask[I,J]=0
    if I eq 450 and J eq 255 then China_mask[I,J]=0
    if I eq 449 and J eq 255 then China_mask[I,J]=0
    if I eq 448 and J eq 255 then China_mask[I,J]=0
    if I eq 452 and J eq 256 then China_mask[I,J]=0
    if I eq 451 and J eq 256 then China_mask[I,J]=0
    if I eq 450 and J eq 256 then China_mask[I,J]=0
    if I eq 449 and J eq 256 then China_mask[I,J]=0
    if I eq 448 and J eq 256 then China_mask[I,J]=0
    if I eq 447 and J eq 256 then China_mask[I,J]=0
    if I eq 452 and J eq 257 then China_mask[I,J]=0
    if I eq 451 and J eq 257 then China_mask[I,J]=0
    if I eq 450 and J eq 257 then China_mask[I,J]=0
    if I eq 449 and J eq 257 then China_mask[I,J]=0
    if I eq 448 and J eq 257 then China_mask[I,J]=0
    if I eq 447 and J eq 257 then China_mask[I,J]=0
    if I eq 454 and J eq 258 then China_mask[I,J]=0
    if I eq 453 and J eq 258 then China_mask[I,J]=0
    if I eq 451 and J eq 258 then China_mask[I,J]=0
    if I eq 450 and J eq 258 then China_mask[I,J]=0
    if I eq 449 and J eq 258 then China_mask[I,J]=0
    if I eq 448 and J eq 258 then China_mask[I,J]=0
    if I eq 456 and J eq 259 then China_mask[I,J]=0
    if I eq 455 and J eq 259 then China_mask[I,J]=0
    if I eq 454 and J eq 259 then China_mask[I,J]=0
    if I eq 451 and J eq 259 then China_mask[I,J]=0
    if I eq 450 and J eq 259 then China_mask[I,J]=0
    if I eq 449 and J eq 259 then China_mask[I,J]=0
    if I eq 457 and J eq 260 then China_mask[I,J]=0
    if I eq 451 and J eq 260 then China_mask[I,J]=0
    if I eq 450 and J eq 260 then China_mask[I,J]=0
    if I eq 459 and J eq 261 then China_mask[I,J]=0
    if I eq 452 and J eq 261 then China_mask[I,J]=0
    if I eq 451 and J eq 261 then China_mask[I,J]=0
;    endif
  endfor
endfor

success = CTM_Make_DataInfo( China_mask,             $
                             ThisDataInfo,           $
                             ModelInfo=InType,       $
                             GridInfo=InGrid,        $
                             DiagN='LANDMAP',        $
                             Tracer=802,             $
                             Tau0=nymd2tau(19850101),$
                             Unit='',                $
                             Dim=[InGrid.IMX,InGrid.JMX,0,0],$
                             First=[1L, 1L, 1L],     $
                             /No_vertical )

NewDataInfo = ThisDataInfo
CTM_WriteBpch, NewDataInfo, FileName = OutFile

end
