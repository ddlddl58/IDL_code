

% MOIDS-TERRA-AQUA/MISR  Combine with filters 
clear all; clc; close all;
%--------------------------------------------------------------------------------------------------

MinFW = 0.2;

mlati = [-89.95 89.95];   
mloni = [-179.95 179.95];   
mlat = mlati(1):0.1:mlati(2);
mlon = mloni(1):0.1:mloni(2);

MaxAeroBias00 = 0.2;
MaxAeroBias = 0.1;
mLON = -179.95:0.1:179.95;
mLAT = -89.95:0.1:89.95;

load('LandMask-0.1.mat') 
MODISdir = '/data1/kelaar/work/PM25_Prediction/MODIS_v2/0.1/';
MISRdir = '/data1/kelaar/work/PM25_Prediction/MISR_v2/0.1/';


for Mn = 1:12
    
    % take monthly filters
    load(sprintf('AODzBIASao-%d.mat',Mn));
    load(sprintf('MeanSatelliteAOD-%d.mat',Mn),'meanMODISaod','meanMISRaod','meanMODISfw');
    modisfilter = double((abs(MODISbias./ meanMODISaod) <= MaxAeroBias00) | abs(MODISbias) <= MaxAeroBias);
    misrfilter = double((abs(MISRbias./ meanMISRaod) <= MaxAeroBias00) | abs(MISRbias) <= MaxAeroBias);
    latspot = [find(abs(mLAT-mlati(1))<0.0001) find(abs(mLAT-mlati(2))<0.0001)];
    lonspot = [find(abs(mLON-mloni(1))<0.0001) find(abs(mLON-mloni(2))<0.0001)];
    modistfilter = modisfilter(latspot(1):latspot(2),lonspot(1):lonspot(2));
    modisafilter = modisfilter(latspot(1):latspot(2),lonspot(1):lonspot(2));
    misrfilter = misrfilter(latspot(1):latspot(2),lonspot(1):lonspot(2));
            
    for Yr = 2004:2008      
        
        DateNeed = Juln2Grg(Grg2Juln((Yr*10000+Mn*100+1)):Grg2Juln(Yr*10000+(Mn+1)*100+1));   DateNeed = DateNeed(1:end-1);
        if Mn == 12
            DateNeed = DateNeed(1:end);
        end        
        
        for di = DateNeed(1:end)
            
            disp(di);
            d = num2str(di);  
            
    
            % find filters : MODIS-TERRA filter
            load(sprintf('%sMODIS-TERRA-0.1-%s.mat',MODISdir,d));
            latspot = [find(abs(MODIS.LatGrid(:,1)-mlati(1))<0.0001) find(abs(MODIS.LatGrid(:,1)-mlati(2))<0.0001)];
            lonspot = [find(abs(MODIS.LongGrid(1,:)-mloni(1))<0.0001) find(abs(MODIS.LongGrid(1,:)-mloni(2))<0.0001)];
            TerraAOD = MODIS.aod(latspot(1):latspot(2),lonspot(1):lonspot(2));
            TerraAOD(MODIS.aoda(latspot(1):latspot(2),lonspot(1):lonspot(2))==0) = NaN;
            TerraFW = MODIS.fw(latspot(1):latspot(2),lonspot(1):lonspot(2));
            TerraFW(MODIS.fwc(latspot(1):latspot(2),lonspot(1):lonspot(2))==0) = NaN;
            modistfilter(TerraFW<MinFW) = 0;            
            modistfilter(meanMODISfw<MinFW) = 0;            
           
            % MODIS-AQUA filter
            load(sprintf('%sMODIS-AQUA-0.1-%s.mat',MODISdir,d));
            latspot = [find(abs(MODIS.LatGrid(:,1)-mlati(1))<0.0001) find(abs(MODIS.LatGrid(:,1)-mlati(2))<0.0001)];
            lonspot = [find(abs(MODIS.LongGrid(1,:)-mloni(1))<0.0001) find(abs(MODIS.LongGrid(1,:)-mloni(2))<0.0001)];
            AquaAOD = MODIS.aod(latspot(1):latspot(2),lonspot(1):lonspot(2));
            AquaAOD(MODIS.aoda(latspot(1):latspot(2),lonspot(1):lonspot(2))==0) = NaN;
            AquaFW = MODIS.fw(latspot(1):latspot(2),lonspot(1):lonspot(2));
            AquaFW(MODIS.fwc(latspot(1):latspot(2),lonspot(1):lonspot(2))==0) = NaN;
            modisafilter(AquaFW<MinFW) = 0;           
            
            % MISR filter    
            load(sprintf('%sMISR-0.1-%s.mat',MISRdir,d));
            latspot = [find(abs(MISR.LatGrid(:,1)-mlati(1))<0.0001) find(abs(MISR.LatGrid(:,1)-mlati(2))<0.0001)];
            lonspot = [find(abs(MISR.LongGrid(1,:)-mloni(1))<0.0001) find(abs(MISR.LongGrid(1,:)-mloni(2))<0.0001)];
            MISRAOD = MISR.aod(latspot(1):latspot(2),lonspot(1):lonspot(2));
            MISRAOD(MISR.aodc(latspot(1):latspot(2),lonspot(1):lonspot(2))==0) = NaN;
            misrfilter((sum(MISRsize.data(latspot(1):latspot(2),lonspot(1):lonspot(2),1:2),3)./sum(MISRsize.data(latspot(1):latspot(2),lonspot(1):lonspot(2),:),3)<0.2) & MISR.aod(latspot(1):latspot(2),lonspot(1):lonspot(2)) > 0.2) = 0;
             

                
        
            % apply filter 
            TerraAOD(modistfilter==0) = nan;
            AquaAOD(modisafilter==0) = nan;
            MISRAOD(misrfilter==0) = nan;
            
            
            % remove over-water points
            TerraAOD(~Mask.land) = NaN;
            AquaAOD(~Mask.land) = NaN;
            MISRAOD(~Mask.land) = NaN;
            
            % average and save each sepeprately
            PM25d.aod = nan(length(mlat), length(mlon), 4);
            PM25d.aod(:,:,1) = TerraAOD;
            PM25d.aod(:,:,2) = AquaAOD;
            PM25d.aod(:,:,3) = MISRAOD;
            PM25d.aod(:,:,4) = nanmean(PM25d.aod(:,:,1:3),3);
            
            

            % saving MODIS-TerraAqua-MISRcombAOD
            Combdir = '/scratch2/sajeev/MODISterraMISRcombAOD/';
            fname = sprintf('%sPM25-%s-withAqua.mat',Combdir,d);
            save (fname,'PM25d');     


            clear PM25d TerraAOD MISRAOD
            

        end
    end
end
%--------------------------------------------------------------------------------------------------


