; This reads the individual file of OMI Near-Real-Time product and outputs 
; some important quantities. 
; Please do not distribute this code without Author's consent
; Lok Lamsal, 23 Sept 2010
; This code now reads nested-grid GEOS-Chem output for Asia
; Siwen Wang, 6 April 2011

PRO get_dpgc_data, fle_n, mtime, spx, sza, vzen, azi, vazi, $
                            latcorner, loncorner, g_lat, g_lon, $
                            slntcolno2, slntcolno2std, tm4slntcol, $
                            geoamf, amf, trpamf, no2cl, no2clstd, $
                            trp_flg, no2tropkernel, no2trpstd, gvc, cfr, cldpre, $
                            spre, sht, crd, salb, colerr
;datadir = '/z2/satellite/OMI/no2/DOMINO_S/collection3/2005/'
;fle_n = datadir+'OMI-Aura_L2-OMDOMINO_2005m0601t0039-o04671_v003-2008m0505t052643.he5'
;fle = FILEPATH(fle_n, ROOT_DIR = '/home/wangsiwen/z0/satellite/KNMI_OMI_NO2_Swath/collection3/2005/')
fle=fle_n

data = H5_PARSE(fle, /READ_DATA)

;READ GEOLOCATION INFORMATION
g_lat  = data.hdfeos.swaths.DOMINONO2.geolocation_fields.latitude._data
g_lon  = data.hdfeos.swaths.DOMINONO2.geolocation_fields.longitude._data
latCorner = data.hdfeos.swaths.DOMINONO2.geolocation_fields.latitudecornerpoints._data
lonCorner = data.hdfeos.swaths.DOMINONO2.geolocation_fields.longitudecornerpoints._data
sza    = data.hdfeos.swaths.DOMINONO2.geolocation_fields.solarzenithangle._data
azi    = data.hdfeos.swaths.DOMINONO2.geolocation_fields.solarazimuthangle._data
vzen   = data.hdfeos.swaths.DOMINONO2.geolocation_fields.viewingzenithangle._data
vazi   = data.hdfeos.swaths.DOMINONO2.geolocation_fields.viewingazimuthangle._data
mtime  = data.hdfeos.swaths.DOMINONO2.geolocation_fields.time._data

;DATA INFORMATION
amf = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactor._data
geoamf = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactorgeometric._data
trpamf = data.hdfeos.swaths.DOMINONO2.data_fields.airmassfactortropospheric._data
;ass_str_slntcolno2 = data.hdfeos.swaths.DOMINONO2.data_fields.$
;assimilatedstratosphericslantcolumn._data

cfr      = data.hdfeos.swaths.DOMINONO2.data_fields.cloudfraction._data
cldpre   = data.hdfeos.swaths.DOMINONO2.data_fields.cloudpressure._data
crd      = data.hdfeos.swaths.DOMINONO2.data_fields.cloudradiancefraction._data
gvc      = data.hdfeos.swaths.DOMINONO2.data_fields.ghostcolumn._data

slntcolno2 = data.hdfeos.swaths.DOMINONO2.data_fields.slantcolumnamountno2._data
slntcolno2std = data.hdfeos.swaths.DOMINONO2.data_fields.slantcolumnamountno2std._data

salb     = data.hdfeos.swaths.DOMINONO2.data_fields.surfacealbedo._data
sht      = data.hdfeos.swaths.DOMINONO2.data_fields.terrainheight._data
spre     = data.hdfeos.swaths.DOMINONO2.data_fields.tm4surfacepressure._data

no2cl    = data.hdfeos.swaths.DOMINONO2.data_fields.totalverticalcolumn._data
no2clstd = data.hdfeos.swaths.DOMINONO2.data_fields.totalverticalcolumnerror._data
trp_flg  = data.hdfeos.swaths.DOMINONO2.data_fields.troposphericcolumnflag._data
no2trp   = data.hdfeos.swaths.DOMINONO2.data_fields.troposphericverticalcolumn._data
no2trpstd= data.hdfeos.swaths.DOMINONO2.data_fields.troposphericverticalcolumnerror._data

colerr = 100. * no2trpstd/no2trp

dim = SIZE(g_lat)
ntrack = dim[1]
ntimes = dim[2]
ntr_vec = 1 + INDGEN(ntrack)
tgt_spix = ntr_vec
spx = ntr_vec # replicate(1, ntimes)


;lat_sec = WHERE(g_lat LE 5. AND g_lat GE -30. AND $
;                slntcolno2 GT 0. AND geoamf GT 0., n_lat_sec)
;sec_spix = spx[lat_sec]
;sec_orislnt = slntcolno2[lat_sec]
;sec_amfs = geoamf[lat_sec]

;mn_spix  = LONARR(60)
;mn_slcol = FLTARR(60)
;mn_amf   = FLTARR(60)

;FOR k = 0, 59 DO BEGIN
;    pck = WHERE (sec_spix EQ tgt_spix[k], npck)
;    if npck gt 0 then begin
;        mn_spix[k] = MEAN(sec_spix[pck])
;    
;        s_sec_orislnt = sec_orislnt[pck]
;                                ; calculate the mean of slant column
;                                ; with data of 95% conf. for each subpixels
;        conf_min = percntle(s_sec_orislnt, 5)
;        conf_max = percntle(s_sec_orislnt, 95)
;        conf = WHERE(s_sec_orislnt GT conf_min and $
;                     s_sec_orislnt LT conf_max, ncnf)
;        mn_slcol[k] = MEAN(s_sec_orislnt[conf])            
;                                ; calculate amf similar way
;        s_sec_amfs    = sec_amfs[pck]
;        conf_mina  = percntle(s_sec_amfs, 5)
;        conf_maxa  = percntle(s_sec_amfs, 95)
;        confa = WHERE(s_sec_amfs GT conf_mina and $
;                      s_sec_amfs LT conf_maxa, ncnf)
;        mn_amf[k] = MEAN(s_sec_amfs[confa])
;    endif
;ENDFOR

;delta_dal = mn_slcol - mn_amf * (mean(mn_slcol)/mean(mn_amf))
;cor_slntcolno2 = slntcolno2  - delta_dal # replicate(1, ntimes)


; calculate tropospheric slant column
tm4slntcol  = data.hdfeos.swaths.DOMINONO2.data_fields.ASSIMILATEDSTRATOSPHERICSLANTCOLUMN._data
;tropslntcol = cor_slntcolno2 - tm4slntcol
tropslntcol = slntcolno2 - tm4slntcol
tm4trppause = data.hdfeos.swaths.DOMINONO2.data_fields.TM4TROPOPAUSELEVEL._data
aks         = data.hdfeos.swaths.DOMINONO2.data_fields.AVERAGINGKERNEL._data * 0.001
pleva       = data.hdfeos.swaths.DOMINONO2.data_fields.TM4PRESSURELEVELA._data
plevb       = data.hdfeos.swaths.DOMINONO2.data_fields.TM4PRESSURELEVELB._data

nlev = (size(aks))[3]
preslev = fltarr(ntrack, ntimes, nlev)
scatwts = fltarr(ntrack, ntimes, nlev)

for y = 0, nlev - 1 do begin
    ;following documentation for temis product
    akstrop          = aks[*, *, y] * amf/trpamf
    scatwts[*, *, y] = akstrop * trpamf
    preslev[*, *, y] =  pleva[y] * 0.01 + spre * plevb[y] 
endfor    

;find gc no2 profiles at the location of omi measurements
flelen = strlen(fle_n)
my_year  = strmid(fle_n, flelen-47, 4)
my_month = strmid(fle_n, flelen-42, 2)
my_day   = strmid(fle_n, flelen-40, 2)
my_tt    = strmid(fle_n, flelen-37, 4)

ymd = my_year + my_month + my_day 

gc_file = '/z1/gengguannan/meic_130828/'+ my_year +'/ts_13_15.'+ ymd +'.bpch'
print,gc_file

ctm_cleanup

FORWARD_FUNCTION CTM_Grid, CTM_Type, NYMD2Tau 

GEOS_Type = CTM_Type( 'GEOS5', res = [2d0/3d0,1d0/2d0] )
GEOS_Grid = CTM_Grid(GEOS_Type)
xmid = GEOS_Grid.xmid
ymid = GEOS_Grid.ymid
zmid = GEOS_Grid.zmid

tra   = 25; NO2 
NYMD0 = LONG(ymd)
Tau0  = NYMD2Tau( NYMD0, NHMS )
limit =  [-90, -180, 90, 180]

ctm_get_data, datainfo1, 'TIME-SER', Tracer = tra, FileName = gc_file
no2_asia = *(datainfo1[0].data)
help,no2_asia


lev   = 35 ;wsw for GEOS4 set lev=18
Zmid  = Zmid[0:(lev - 1)]
Zmid0 = Zmid[0]
Zmid1 = Zmid[1]
LL = N_ELEMENTS(Zmid)

ctm_get_data, datainfo2, 'PEDGE-$', Tracer = 7601, FileName = gc_file
Psurf_asia = *(datainfo2[0].data)
help,Psurf_asia


no2 = fltarr(GEOS_Grid.IMX,GEOS_Grid.JMX,47)
Psurf = fltarr(GEOS_Grid.IMX,GEOS_Grid.JMX)

for III = 0L, 121-1L do begin
    for JJJ = 0L, 133-1L do begin
        for ZZZ = 0, 47-1L do begin
            no2[III+375,JJJ+158,ZZZ] = no2_asia[III,JJJ,ZZZ]
        endfor
        Psurf[III+375,JJJ+158] = Psurf_asia[III,JJJ]
    endfor
endfor

amf_gc = fltarr(ntrack, ntimes)
;amf_tm4 = fltarr(ntrack, ntimes)

FOR j = 0, ntrack - 1 do begin
    for i = 0, ntimes - 1L do begin
        ;print, g_lat[j, i], ' ', g_lon[j, i] 
        ctm_index, geos_type, ilon, ilat, center = [g_lat[j, i], g_lon[j, i]], $
          /non_interactive
        ilon = ilon - 1
        ilat = ilat - 1
        ;print, ymid[ilat], ' ', xmid[ilon]
        ;print, ' '
        if (ilon lt 375 or ilon gt 495 or ilat lt 158 or ilat gt 290) then begin
                                ;Use tropospheric amf from satellite data file for pixels outside nested domain
           amf_gc[j,i] = trpamf[j,i]
           continue
        endif
        mixrat = TRANSPOSE(no2(ilon, ilat, 0:(lev - 1)) * 1d-9) 
                                ;Get grid information for that location
        GEOS_Grid = CTM_Grid( GEOS_Type, Psurf = Psurf(ilon, ilat))
        pres      = GEOS_Grid.pmid[0:(lev - 1)]
        heights   = GEOS_GRID.ZEDGE * 100000.
                                ;Calculate the sigma level and layer thickness 
        Ind0 = IndGen(lev)
        Ind1 = Ind0 + 1
        DSig = GEOS_Grid.ETAEDGE[Ind0] - GEOS_Grid.ETAEDGE[Ind1]
                                ;Compute Ad in Kg
        Ad = FltArr(LL)
        G0_100 = 100.0 / 9.81
        FOR L = 0, LL -  1 DO BEGIN
            Ad[L] = Psurf[ilon, ilat] * DSig[L] * G0_100 / 1d4  
        ENDFOR
        molec_kg = (6.022d23 / 28.97d-3)
        Ad = Ad * molec_kg
                                ;Calculate layer total (number density
                                ;in molec/cm2) 
        l_tconc = DblArr( LL )
        FOR L = 0, LL - 1 DO BEGIN
            l_tconc[L] = mixrat[L] * Ad[L] 
        ENDFOR
        l_tconc_tm4 = interpol(l_tconc, alog10(pres), (alog10(preslev[j, i, *]))[0:30])
        nume = 0.0
        deno = 0.0

        QQ = tm4trppause[j, i]
        if QQ ne 255 THEN BEGIN
            FOR KK = 0, QQ - 1 DO BEGIN
                nume = nume + scatwts[j, i, KK] * l_tconc_tm4[KK]
                deno = deno + l_tconc_tm4[KK]
            ENDFOR
            amf_gc_0 = nume / deno
            amf_gc[j, i] = nume / deno
        endif
    endfor
endfor

no2tropkernel = tropslntcol/amf_gc * 1d15

RR = where(finite(no2tropkernel) eq 0, nRR)
IF nRR gt 0 THEN BEGIN
    no2tropkernel[RR] = !values.f_nan
ENDIF
SS = where(slntcolno2 lt 0, nss)
IF nss gt 0 THEN BEGIN
    no2tropkernel[SS] = !values.f_nan
ENDIF

END
