pro modify

FORWARD_FUNCTION CTM_Type,    CTM_Grid,   CTM_BoxSize, $
                 CTM_RegridH, CTM_NamExt, CTM_ResExt, TAU2YYMMDD

NewType = CTM_Type( 'GEOS5', Resolution=[2d0/3d0,0.5d0])
NewGrid = CTM_Grid( NewType)

xmid = NewGrid.xmid
ymid = NewGrid.ymid


infile = '/home/gengguannan/indir/mask/region_mask_05x0666.bpch'
outfile = '/home/gengguannan/indir/mask/region_mask_05x0666_rev.bpch'

ctm_get_data,datainfo,filename = infile,tracer=802
mask=*(datainfo[0].data)


limit = [43,85,47,92]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 5.5 then mask[I,J] = 11 else mask[I,J] = 0
  endfor
endfor

limit = [26,100,33.5,110]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 4.5 then mask[I,J] = 9 else mask[I,J] = 0
  endfor
endfor

limit = [40,121,45,125]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 4 then mask[I,J] = 8 else mask[I,J] = 0
  endfor
endfor

limit = [35.5,115.5,38,123]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 3.5 then mask[I,J] = 7 else mask[I,J] = 0
  endfor
endfor

limit = [29,112,33,116]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 3 then mask[I,J] = 6 else mask[I,J] = 0
  endfor
endfor

limit = [26,111,29,115]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 2 then mask[I,J] = 5 else mask[I,J] = 0
  endfor
endfor

limit = [33.5,105,37,110]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 1.5 then mask[I,J] = 3 else mask[I,J] = 0
  endfor
endfor

limit = [37.5,110,41,113]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 1 then mask[I,J] = 2 else mask[I,J] = 0
  endfor
endfor

limit = [20,110,25,115]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 0.5 then mask[I,J] = 1 else mask[I,J] = 0
  endfor
endfor


limit = [28.5,116,35.5,123]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 6 then mask[I,J] = 12 else mask[I,J] = 0
  endfor
endfor

limit = [24,115,28.5,120]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 6 then mask[I,J] = 12
    if mask[I,J] gt 2 and mask[I,J] lt 6 then mask[I,J] = 4
    if mask[I,J] lt 2 then mask[I,J] = 0
  endfor
endfor

limit = [36,113,43,120]
i1_index = where(xmid ge limit[1] and xmid le limit[3])
j1_index = where(ymid ge limit[0] and ymid le limit[2])
I1 = min(i1_index, max = I2)
J1 = min(j1_index, max = J2)
for I = I1,I2 do begin
  for J = J1,J2 do begin
    if mask[I,J] gt 5 and mask[I,J] ne 7 then mask[I,J] = 10
    if mask[I,J] lt 5 then mask[I,J] = 0
  endfor
endfor

D = 0
; Make a DATAINFO structure
Success = CTM_Make_DataInfo( mask,              $
                             ThisDataInfo,                  $
                             ModelInfo=NewType,             $
                             GridInfo=NewGrid,              $
                             DiagN=DataInfo[D].Category,    $
                             Tracer=DataInfo[D].Tracer,     $
                             Tau0=DataInfo[D].Tau0,         $
                             Tau1=DataInfo[D].Tau1,         $
                             Unit=DataInfo[D].Unit,         $
                             Dim= Dim,           $
                             First=DataInfo[D].First)

NewDataInfo =  ThisDataInfo

CTM_WriteBpch, NewDataInfo, FileName= Outfile


end
