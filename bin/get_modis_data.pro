; This reads the individual file of MODIS product and outputs

pro get_modis_data, fle_n, AOD, date, latcorner, loncorner

fle=fle_n


; Read information
sd_id = HDF_SD_Start(fle,/read)

sds_index1 = HDF_SD_NAMETOINDEX(sd_id,'Optical_Depth_Land_And_Ocean')
sds_id1 = HDF_SD_SELECT(sd_id,sds_index1)
HDF_SD_GETDATA,sds_id1,AOD

sds_index2 = HDF_SD_NAMETOINDEX(sd_id,'Longitude')
sds_id2 = HDF_SD_SELECT(sd_id,sds_index2)
HDF_SD_GETDATA,sds_id2,lon

sds_index3 = HDF_SD_NAMETOINDEX(sd_id,'Latitude')
sds_id3 = HDF_SD_SELECT(sd_id,sds_index3)
HDF_SD_GETDATA,sds_id3,lat

HDF_SD_END, sd_id


; Time
year = fix(strmid(fle,44,4))
dayofyear = fix(strmid(fle,48,3))
caldat, julday(1, dayofyear, year), month, day
date = strtrim(year * 10000L + month * 100L + day * 1L)


; Calculate corner points
sz1 = (size(lat))[1] ;135
sz2 = (size(lat))[2] ;203
x = sz1-1
y = sz2-1

;---Step 1---
for col = 0,sz1-1 do begin
  minvalue = min(lon[col,*])
  peak = (where(lon[col,*] eq minvalue))[0]
  if peak lt 134 then begin
    if peak+1 lt sz2-peak-1 $
      then lon[col,0:peak] = lon[col,0:peak] + 360 $
      else lon[col,peak+1:sz2-1] = lon[col,peak+1:sz2-1] -360
  endif
endfor

;---Step 2---
pt = fltarr(x,y,2)
latcorner = fltarr(sz1,sz2,4)
loncorner = fltarr(sz1,sz2,4)

for i = 0,x-1 do begin
  for j = 0,y-1 do begin
    pt[i,j,*] = lint([lon[i,j],lat[i,j]],[lon[i+1,j+1],lat[i+1,j+1]], $
                     [lon[i+1,j],lat[i+1,j]],[lon[i,j+1],lat[i,j+1]])
  endfor
endfor

loncorner[1:x,0:(y-1),0] = pt[*,*,0]
loncorner[0,0:(y-1),0] = 2 * pt[0,*,0] - pt[1,*,0]
loncorner[*,y,0] = 2 * loncorner[*,y-1,0] - loncorner[*,y-2,0]
loncorner[0:(x-1),0:(y-1),1] = pt[*,*,0]
loncorner[0:(x-1),y,1] = loncorner[1:x,y,0]
loncorner[x,*,1] = 2 * loncorner[x-1,*,1] - loncorner[x-2,*,1]
loncorner[0:(x-1),1:y,2] = pt[*,*,0]
loncorner[x,1:y,2] = loncorner[x,0:(y-1),1]
loncorner[*,0,2] = 2 * loncorner[*,1,2] - loncorner[*,2,2]
loncorner[1:x,1:y,3] = pt[*,*,0]
loncorner[0,1:y,3] = loncorner[0,0:(y-1),0]
loncorner[*,0,3] = 2 * loncorner[*,1,3] - loncorner[*,2,3]

latcorner[1:x,0:(y-1),0] = pt[*,*,1]
latcorner[0,0:(y-1),0] = 2 * pt[0,*,1] - pt[1,*,1]
latcorner[*,y,0] = 2 * latcorner[*,y-1,0] - latcorner[*,y-2,0]
latcorner[0:(x-1),0:(y-1),1] = pt[*,*,1]
latcorner[0:(x-1),y,1] = latcorner[1:x,y,0]
latcorner[x,*,1] = 2 * latcorner[x-1,*,1] - latcorner[x-2,*,1]
latcorner[0:(x-1),1:y,2] = pt[*,*,1]
latcorner[x,1:y,2] = latcorner[x,0:(y-1),1]
latcorner[*,0,2] = 2 * latcorner[*,1,2] - latcorner[*,2,2]
latcorner[1:x,1:y,3] = pt[*,*,1]
latcorner[0,1:y,3] = latcorner[0,0:(y-1),0]
latcorner[*,0,3] = 2 * latcorner[*,1,3] - latcorner[*,2,3]

;---Step 3---
bias1 = where(loncorner lt -180)
if bias1[0] ne -1 then loncorner[bias1] = loncorner[bias1] + 360
bias2 = where(loncorner gt 180)
if bias2[0] ne -1 then loncorner[bias2] = loncorner[bias2] - 360


end
