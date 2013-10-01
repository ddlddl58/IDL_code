; This reads the individual file of OMI Near-Real-Time product and outputs 
; some important quantities. 

; Lok Lamsal, 6 Mar 2008

;@omipixelcorners

PRO get_omdomino_nrtp_data, fle_n, mtime, spx, sza, vzen, azi, vazi, $
                            latcorner, loncorner, g_lat, g_lon, $
                            slntcolno2, slntcolno2std, ass_str_slntcolno2, $
                            geoamf, amf, trpamf, no2cl, no2clstd, $
                            trp_flg, no2trp, no2trpstd, gvc, cfr, cldpre, $
                            spre, sht, crd, salb

fle=fle_n
data = H5_PARSE(fle, /READ_DATA)

;READ GEOLOCATION INFORMATION
g_lat     = data.hdfeos.swaths.DOMINONO2.geolocation_fields.latitude._data
help,g_lat
g_lon     = data.hdfeos.swaths.DOMINONO2.geolocation_fields.longitude._data
latCorner = data.hdfeos.swaths.DOMINONO2.geolocation_fields.latitudecornerpoints._data
lonCorner = data.hdfeos.swaths.DOMINONO2.geolocation_fields.longitudecornerpoints._data

sza    = data.hdfeos.swaths.DOMINONO2.geolocation_fields.solarzenithangle._data
azi    = data.hdfeos.swaths.DOMINONO2.geolocation_fields.solarazimuthangle._data
vzen   = data.hdfeos.swaths.DOMINONO2.geolocation_fields.viewingzenithangle._data
vazi   = data.hdfeos.swaths.DOMINONO2.geolocation_fields.viewingazimuthangle._data
mtime  = data.hdfeos.swaths.DOMINONO2.geolocation_fields.time._data

dim = SIZE(g_lat)
ntrack = dim[1]
ntimes = dim[2]

ntr_vec = 1 + INDGEN(ntrack)
spx = ntr_vec # replicate(1, ntimes)

amf    = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactor._data
geoamf = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactorgeometric._data
trpamf = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactortropospheric._data
ass_str_slntcolno2 = data.hdfeos.swaths.DOMINONO2.data_fields.assimilatedstratosphericslantcolumn._data

cfr    = data.hdfeos.swaths.DOMINONO2.data_fields.cloudfraction._data
cldpre = data.hdfeos.swaths.DOMINONO2.data_fields.cloudpressure._data
crd    = data.hdfeos.swaths.DOMINONO2.data_fields.cloudradiancefraction._data
gvc    = data.hdfeos.swaths.DOMINONO2.data_fields.ghostcolumn._data

slntcolno2    = data.hdfeos.swaths.DOMINONO2.data_fields.slantcolumnamountno2._data
slntcolno2std = data.hdfeos.swaths.DOMINONO2.data_fields.slantcolumnamountno2std._data

salb     = data.hdfeos.swaths.DOMINONO2.data_fields.surfacealbedo._data
sht      = data.hdfeos.swaths.DOMINONO2.data_fields.terrainheight._data
spre     = data.hdfeos.swaths.DOMINONO2.data_fields.tm4surfacepressure._data

no2cl    = data.hdfeos.swaths.DOMINONO2.data_fields.totalverticalcolumn._data
no2clstd = data.hdfeos.swaths.DOMINONO2.data_fields.totalverticalcolumnerror._data
trp_flg  = data.hdfeos.swaths.DOMINONO2.data_fields.troposphericcolumnflag._data
no2trp   = data.hdfeos.swaths.DOMINONO2.data_fields.troposphericverticalcolumn._data
no2trpstd= data.hdfeos.swaths.DOMINONO2.data_fields.troposphericverticalcolumnerror._data

END
