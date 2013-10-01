pro plot_point

FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data, CTM_Make_DataInfo, Nymd2Tau

CTM_CleanUp

InType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
InGrid = CTM_Grid( InType )

xmid = InGrid.xmid
ymid = InGrid.ymid

infile = '/home/gengguannan/indir/China_mask.geos5.v2.05x0666'

ctm_get_data,datainfo,filename = infile,tau0=nymd2tau(19850101),tracer=802
China_mask=*(datainfo[0].data)

limit = [15,105,40,125]

i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)

for J = J1,J2 do begin
  for I = I1,I2 do begin
    if (China_mask[I,J] eq 1 and China_mask[I+1,J] eq 0) then begin
      print,I,J
    endif
  endfor
endfor

end
