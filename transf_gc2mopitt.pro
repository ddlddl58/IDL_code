pro transf_gc2mopitt
;=============================================================
;resample pressure of gc output into mopitt structure and apply
;averaging kernel on it ,then regrid the processed data
;=============================================================
FORWARD_FUNCTION CTM_Grid,CTM_Type,CTM_Get_Data,CTM_Writebpch
;=============================================================
;Setup model parameters
;=============================================================

DiagN1  = 'IJ-AVG-$'
Tracer1 = 4 ; 4 for CO

DiagN2  = 'PEDGE-$'
Tracer2 = 7601 ;7601 for pedge

InType=CTM_Type( 'GEOS5', Resolution=[ 2d0/3d0,0.5d0 ])
InGrid=CTM_Grid( InType )


OutType=CTM_Type('generic',Resolution=[1d0,1d0])
OutGrid=CTM_Grid(OutType)

close,/all
;=================================================================
;Setup MOPITT Parameters
;================================================================
mo_dir='/home/zhengyixuan/MOPITT/'
mo_fileprefix='MOP03J-'
mo_filesuffix='-L3V3.1.3.hdf'
mo_grid_name='MOP03'
mo_co_name='Retrieved CO Total Column Day'
mo_srflevel_name='Surface Pressure Day'
mo_avrk_name='Retrieval Averaging Kernel Matrix Day'
mo_aprisrf_name='A Priori CO Surface Mixing Ratio Day'
mo_aprimxr_name='A Priori CO Mixing Ratio Profile Day'

mo_mixratio_name='Retrieved CO Mixing Ratio Profile Day'
mo_mixratiosrf_name='Retrieved CO Surface Mixing Ratio Day'

;get MOPITT vertical pressure information
mo_preslevi=100+findgen(9)*100
mo_preslev=reverse(mo_preslevi)
;========================================================

reportfile='/home/zhengyixuan/GC_ERROR_REPORT.txt'
openw,runit,reportfile,/GET_LUN

for year=2007,2010 do begin

  Yr4=string(year,format='(i4.4)')
  printf,runit,'========',Yr4,'==========='
  ;parameter of GEOS_Chem data
  gc_dir='/z1/gengguannan/meic_120918/'+Yr4+'/'
  gc_outdir='/home/zhengyixuan/code/result/MOPITT/resampled_2004_2010_gc_daily_1x1_hdf/'+Yr4+'/'
  gc_fileprefix='ts_10_12.'
  gc_tcoutfileprefix='gc_co_tc_10_12_1x1_eastasia_'
  gc_filesuffix='.bpch'
  gc_outfilesuffix='.hdf'
;  extent=[70,-11,150,55]
  ratio=[1.0/12,1.0/6,1.0/6,1.0/3,1.0/12,1.0/6];area based interpolation ratio
;  ratio=[1.0/6,1.0/12,1.0/3,1.0/6,1.0/6,1.0/12]
  for month=1,12 do begin
    Mon2=string(month,format='(i2.2)')
      for day=1,31 do begin
        Day2=string(day,format='(i2.2)')

        NYMD0=year*10000L+month*100L+day*1L
;        print,NYMD0
        TAU0=nymd2tau(NYMD0)
;        if day ne 1 then TAU0+=0.17
        
        mo_infile=mo_dir+mo_fileprefix+Yr4+Mon2+Day2+mo_filesuffix
        if (file_test(mo_infile)) eq 0 then continue
        gc_infile=gc_dir+gc_fileprefix+Yr4+Mon2+Day2+gc_filesuffix 
        
        ;===================================
        ;get gc data
        ;===================================
        undefine,datainfo_CO
        undefine,gc_inCO
        CTM_Get_Data, datainfo_CO,DiagN1 ,tracer=Tracer1,filename=gc_infile
        gc_inCO=*(datainfo_CO[0].data)
        
        undefine,datainfo_PEDGE
        undefine,gc_PG
        CTM_Get_Data, datainfo_PEDGE,DiagN2 ,tracer=Tracer2,filename=gc_infile
        gc_PG=*(datainfo_PEDGE[0].data)
        ;====================================
        ;get mopitt data
        ;====================================
        file_id=EOS_GD_OPEN(mo_infile)
        grid_id=EOS_GD_ATTACH(file_id,mo_grid_name)
        status=EOS_GD_READFIELD(grid_id,mo_co_name,mo_totalcol)

;        status=EOS_GD_READFIELD(grid_id,'Longitude',mo_lon)
;        status=EOS_GD_READFIELD(grid_id,'Latitude',mo_lat)
        status=EOS_GD_READFIELD(grid_id,mo_srflevel_name,mo_srflev)
        status=EOS_GD_READFIELD(grid_id,mo_avrk_name,mo_averk)
        status=EOS_GD_READFIELD(grid_id,mo_aprisrf_name,mo_aprisrf)
        status=EOS_GD_READFIELD(grid_id,mo_aprimxr_name,mo_aprimxr)


        status=EOS_GD_READFIELD(grid_id,mo_mixratio_name,mo_mixratio)
        status=EOS_GD_READFIELD(grid_id,mo_mixratiosrf_name,mo_mixrsrf)


        status=EOS_GD_DETACH(grid_id)
        status=EOS_GD_CLOSE(file_id)
        ;=============================================
;        gc_vmr=fltarr(80,66,10); define variable to store resampled&transformed&regrided gc volume mixing ratio
        gc_totalcol=fltarr(80,66); define variable to store resampled&transformed&regrided gc total column

;=========================================================
;        mo_tc_file=gc_outdir+'mo_tc_'+Yr4+Mon2+Day2+'.txt'
;        gc_tc_file=gc_outdir+'gc_tc_'+Yr4+Mon2+Day2+'.txt'
;        openw,mounit,mo_tc_file,/get_lun
;        openw,gcunit,gc_tc_file,/get_lun
;=========================================================
         for lat=0,65 do begin
          for lon=0,79 do begin
;            gc_vmr_grid=fltarr(10)
            if mo_totalcol[lon+250,lat+79] eq -9999.0 then begin
            ;  for l=0,9 do gc_vmr[lon-70,lat+11,l]=-9999.0
;              gc_vmr[lon,lat,0:9]=-9999.0
              gc_totalcol[lon,lat]=-9999.0
            endif else begin
             ;vallevidx store valid pressure levels indices
              vallevidx=where(mo_preslev lt mo_srflev[lon+250,lat+79],ct)
              novallevidx=where(mo_preslev gt mo_srflev[lon+250,lat+79],nct)
              ;vallev store valid pressure levels
              vallev=[mo_srflev[lon+250,lat+79],mo_preslev[vallevidx]]

              ;extract retrieved MOPITT mixing ratio profile start from surface
              mo_rtv=[mo_mixrsrf[lon+250,lat+79],mo_mixratio[vallevidx,lon+250,lat+79]]
;              help,mo_rtv
              ; new index with surface pressure 
              vallevidx_new=[nct,vallevidx+1]

              ;extract MOPITT a priori mixing ratio profile from surface
              ;from low altitude to high altitude
              ap1=[mo_aprisrf[lon+250,lat+79],mo_aprimxr[vallevidx,lon+250,lat+79]]            
              
;              if lon eq 6 and lat eq 43 then continue
;              help,ap1
              logap1=alog10(ap1)
;              if lon eq 6 and lat eq 43 then continue
              log_mortv=alog10(mo_rtv)
              ; if lon eq 6 and lat eq 43 then continue
;              ap1idx=where(ap1 eq 0,ap1ct)
;              print,ap1ct
;              rtvidx=where(mo_rtv eq 0,mo_rtvct)
;              print,mo_rtvct

              ak=fltarr(10,10)
;              if lon eq 6 and lat eq 43 then continue 
              ak=reform(mo_averk[0:9,0:9,lon+250,lat+79],10,10)
;              if lon eq 6 and lat eq 43 then continue

;===============================================
              akidx=where(ak eq -9999.0,akct)
              if akct eq 100 then begin
                gc_totalcol[lon,lat]=-9999.0
                printf,runit,NYMD0,lon+250,lat+79
                continue
              endif
;==============================================

;              if lon eq 6 and lat eq 43 then print,ak,ap1 
              ak1=reform(ak[nct:9,nct:9],ct+1,ct+1)
;              help,ak1
;              help,'=============================='
              ak1T=transpose(ak1)
              gctemp=fltarr(6,47)     ; store mixing ratio of 6 gc grids
              gc_prestemp=fltarr(6,47); store pedge
              gctctemp=fltarr(6)
              ;interpolate gc profile to MOPITT retrieval grid
              ;gc from low altitude to high altitude
              ;calculate total column of 6 gc grids which contribute to a mopitt grid respectively
;              if lon eq 6 and lat eq 43 then continue
              for i=0,1 do begin
                for j=0,2 do begin
                  gctemp[i+j*2,0:46]=gc_inCO[ceil(lon*3/2)+i,lat*2+j,0:46]
                  gc_prestemp[i+j*2,0:46]=gc_PG[ceil(lon*3/2)+i,lat*2+j,0:46]
                endfor;j
              endfor;i
                           
 
;              undefine,gc_vmrint,log_gcvmrint,logsimprof,simprof,deltap,t
              for g=0,5 do begin
               
                gc_vmrint=interpol(gctemp[g,0:46],gc_prestemp[g,0:46],vallev)
                
                vmrintidx=where(gc_vmrint lt 0,vmrintct)
                if vmrintct gt 0 then begin
                  printf,runit,NYMD0,lon+250,lat+79,'  g=',g,'  NaN'
                  
                  continue
                endif
                                

;=================================================================
;                if g eq 4 and lon eq 6 and lat eq 43 then begin
;                  print,'-----gc_vmrint----'
;                  print,gc_vmrint
;                  print,'--------gctemp-------'
;                  print,gctemp[g,0:46]
;                  print,'--------mo_mixing_ratio---------'
;                  print,mo_rtv
;                  print,'----------gc_press-------'   
;                  print,gc_prestemp[g,0:46]
;                  print,'-------vallev----------'
;                  print,vallev
;                endif       
;================================================================                
                log_gcvmrint=alog10(gc_vmrint)
              ;calculate simulated retrieval
                logsimprof=logap1+ak1T##transpose(log_gcvmrint-logap1)
                simprof=10.^(logsimprof)
;                a=where(simprof eq !values.f_NaN,aaacttt)
;                if aaacttt gt 0 then print,aaacttt,lon,lat

              ;calculate total column from simulated data
                deltap=fltarr(ct+1)
                deltap[0]=vallev[0]-vallev[1]
                deltap[1:ct-1]=100.0
                deltap[ct]=74.0
                t=2.120e+13*deltap
                gc_totcol_grid=t##transpose(simprof)
            
                gctctemp[g]=gc_totcol_grid
              endfor;6 gc grids
              gc_totcol_cal=ratio##transpose(gctctemp)
              if gc_totcol_cal eq 0 then begin
                gc_totalcol[lon,lat]=-9999.0
              endif else begin
                gc_totalcol[lon,lat]=gc_totcol_cal
              endelse
              
;=================================================================
;              if finite(gc_totcol_cal) eq 0 or gc_totcol_cal eq !values.f_Infinity then begin
;                gc_totalcol[lon,lat]=-9999.0
;                printf,runit,NYMD0,gc_totcol_cal,lon+250,lat+79
;              endif else gc_totalcol[lon,lat]=gc_totcol_cal
;==================================================================

;              if finite(gc_totalcol[lon,lat]) eq 0 then print,lon,lat
;==========================================================
;              printf,gcunit,gc_totalcol[lon,lat]
;              printf,mounit,mo_totalcol[lon+250,lat+79]
;==========================================================
            endelse
;=================================================================
 ;             if nct gt 0 then begin
 ;               gc_vmr_grid=[temp[novallevidx],10.^(logsimprof)]
 ;             endif else begin
 ;               gc_vmr_grid=simprof
 ;               ;  print,logap1
 ;             endelse
;                print,'============gc_simulate==========='
;                print,gc_totcol_grid;[lon-70,lat+11]
;                print,'=============mopitt==============='
;                print,total_col[lon+180,lat+90]

;              gc_vmr[lon-70,lat+11,*]=gc_vmr_grid
;              gc_vmrrf=reform(gc_vmr,66,80,10)
;              gc_totalcol[lon-70,lat+11]=gc_totcol_grid
;               endelse
;==================================================================
            ;undefine all array define in every loop
;            undefine,vallevidx,novallevidx,vallev,mo_rtv,$
;            gc_vmrint,vallevidx_new,ap1,log_gcvmrint,logap1,$
;            log_mortv,akidx,ak1,ak1T


          endfor;lon
        endfor;lat

;        close,mounit,gcunit

       ;     out_vmr_filename=gc_outdir+gc_vmroutfileprefix+Yr4+Mon2+Day2+gc_outfilesuffix
        out_tc_filename=gc_outdir+gc_tcoutfileprefix+Yr4+Mon2+Day2+gc_outfilesuffix
;        dataX=fltarr(6)
;        out_file_name=gc_outdir+'co_10_12_1x1_eastasia_'+Yr4+Mon2+Day2+'.bpch'
;       print,where(gc_totalcol eq !values.f_Infinity)
        
;===========================================================================
;        success = CTM_Make_DataInfo(gc_totalcol ,       $
;                                ThisDataInfo,           $
;                                ThisFileInfo,           $
;                                ModelInfo=OutType,      $
;                                GridInfo=OutGrid,       $
;                                DiagN=DiagN,            $
;                                Tracer=4,               $
;                                Tau0= TAU0,             $
;                                Unit='ppbv',            $
;                                Dim=[80,66,0,0],        $
;                                First=[1L, 1L, 1L],     $
;                                /No_global )

;        CTM_WriteBpch, ThisDataInfo,ThisFileInfo,FileName = out_tc_filename
        CTM_Cleanup
;============================================================================

;===========================================================================
;         mo_tc_file=gc_outdir+'mo_tc_'+Yr4+Mon2+Day2+'.txt';
;         gc_tc_file=gc_outdir+'gc_tc_'+Yr4+Mon2+Day2+'.txt'
;         openw,mounit,mo_tc_file,/get_lun
;         openw,gcunit,gc_tc_file,/get_lun
;         for j=0,65 do begin
;           for i=0,79 do begin
;             if(gc_totalcol[i,j] ne -9999.0) then begin
               
;             printf,gcunit,gc_totalcol[i,j] 
;             printf,mounit,mo_totalcol[i+250,j+79]
;             endif
;           endfor
;         endfor
;         close,mounit,gcunit
;         free_lun,mounit,gcunit

;===========================================================================

;======================================================================
         TCID=HDF_SD_Start(out_tc_filename,/RDWR,/Create)

         HDF_SETSD,TCID,gc_totalcol, 'CO', $
         Longname='CO Total Column from GEOS_Chem',$
         Unit='molecules/cm2',$
         FILL=-9999.0
         HDF_SD_End, TCID
;=====================================================================
;=====================================================================
;         eindx=where(gc_totalcol ne -9999.0,count)
;         moidx=where(mo_totalcol[250:329,79:144] ne -9999.0,moct)
;         print,count,moct 
;         if count gt 0 then print,a,count,'====',gc_totalcol[eindx]
;======================================================================
      print,NYMD0,' Done'
    endfor;day
  endfor;month
endfor;year


close,runit
free_lun,runit
end
