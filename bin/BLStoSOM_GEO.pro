pro BLStoSOM_GEO

for Path = 100,100 do begin
strPath = string( Path, format = '(i3.3)' )


Indir = '/z6/satellite/MISR/AGP/'
Infile = Indir +'MISR_AM1_AGP_P'+ strPath +'_F01_24.hdf'
Outdir = '/home/gengguannan/satellite/aod/MISR/SOM/AGP/'
Outfile = Outdir +'MISR-AM1-AGP-P'+ strPath

; Read files
status = read_grid_field(Infile,'Standard','GeoLatitude',lat)
status = read_grid_field(Infile,'Standard','GeoLongitude',lon)
status = read_grid_attr(Infile,'Standard','Block_size.resolution_x',temp)
resx = double(temp)
status = read_grid_attr(Infile,'Standard','Block_size.resolution_y',temp)
resy = double(temp)
status = read_grid_attr(Infile,'Standard','Block_size.size_x',temp)
size_x = double(temp)
status = read_grid_attr(Infile,'Standard','Block_size.size_y',temp)
size_y = double(temp)
status = read_grid_attr(Infile,'Standard','_BLKSOM:Standard',temp)
BLKSOM = double(temp)

status = read_global_attr(Infile,'Origin_block.ulc.x',temp)
ulc_x = double(temp)
status = read_global_attr(Infile,'Origin_block.lrc.y',temp)
ulc_y = double(temp)
status = read_global_attr(Infile,'Origin_block.lrc.x',temp)
lrc_x = double(temp)
status = read_global_attr(Infile,'Origin_block.ulc.y',temp)
lrc_y = double(temp)
status = read_global_attr(Infile,'Start_block',temp)
startBlock = double(temp)
status = read_global_attr(Infile,'End block',temp)
endBlock = double(temp)


; 
Sx = (lrc_x - ulc_x) / size_x
Sy = (lrc_y - ulc_y) / size_y

ulc_xc = ulc_x + Sx / 2
ulc_yc = ulc_y + Sy / 2


;
dim = size(lat)
SOMxdim = dim[2]
SOMydim = dim[1]


SOM_lat = reform(lat,SOMydim,SOMxdim*dim[3])
SOM_lon = reform(lon,SOMydim,SOMxdim*dim[3])

SOM_x = fltarr(SOMydim,SOMxdim*dim[3])
SOM_y = fltarr(SOMydim,SOMxdim*dim[3])

flag = 1
for i = 0,dim[3]-1 do begin

  temp1 = ulc_xc[0] + i * size_x[0] * Sx[0] + transpose(indgen(SOMxdim)) * Sx[0]

  while (size(temp1))[1] lt SOMydim do begin
    temp1 = [temp1,temp1]
  endwhile

  SOM_x[*,i*SOMxdim:((i+1)*SOMxdim-1)] = temp1(0:(SOMydim-1),*)

  if flag gt 0 $
    then temp2 = ulc_yc[0] + indgen(SOMydim) * Sy[0] $
    else temp2 = ulc_yc[0] + (indgen(SOMydim) + total(BLKSOM(0:(i-1)))) * Sy[0]

  while (size(temp2))[2] lt SOMxdim do begin
    temp2 = [[temp2],[temp2]]
  endwhile

  SOM_y[*,i*SOMxdim:((i+1)*SOMxdim-1)] = temp2(*,0:(SOMxdim-1))

  flag = 0

endfor

;help,SOM_lat,SOM_lon,SOM_x,SOM_y
print,max(SOM_lat),SOM_lat[343,8274]
print,max(SOM_x),SOM_x[395,3927]

; Save files
save,SOM_lat,SOM_lon,SOM_x,SOM_y,filename=Outfile

endfor

end

