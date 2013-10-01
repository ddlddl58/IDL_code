MODISdir = sprintf('MODIS_v2/0.1/');
MISRdir = sprintf('MISR_v2/0.1/');        
for Mni = 1:2
    meanMODISaod = zeros(1800,3600);
    meanMODISfw = meanMODISaod;
    meanMISRaod = meanMODISaod;
    meanMISRfw = meanMODISaod;
    MODISc = meanMODISaod;
    MODISfwc = meanMODISaod;
    MISRc = meanMODISaod;
    MISRfwc = meanMODISaod;
    for y = 2001:2006
        if Mni < 12
            dr = Grg2Juln(y*10000+Mni*100+1):(Grg2Juln(y*10000+(Mni+1)*100+1)-1);
        else
            dr = Grg2Juln(y*10000+Mni*100+1):Grg2Juln(y*10000+1231);
        end
        for d = dr
            load(sprintf('%sMODIS-TERRA-0.1-%d.mat',MODISdir,Juln2Grg(d)));
            load(sprintf('%sMISR-0.1-%d.mat',MISRdir,Juln2Grg(d)));
            meanMODISaod = meanMODISaod + MODIS.aod;
            MODISc = MODISc + double(MODIS.aodc>0);
            meanMODISfw = meanMODISfw + MODIS.fw;
            MODISfwc = MODISfwc + double(MODIS.fwc>0);
            meanMISRaod = meanMISRaod + MISR.aod;
            MISRc = MISRc + double(MISR.aodc>0);
            
            temp = sum(MISRsize.data(:,:,1:2),3); %./sum(MISRsize.data,3);
            
            % remove points with AOD < 0.2
            MISRsize.count(MISR.aod<0.2) = 0;
            
            temp(MISRsize.count==0) = 0;
            meanMISRfw = meanMISRfw + temp;
            MISRfwc = MISRfwc + double(MISRsize.count>0);
            disp(sprintf('%d Complete',Juln2Grg(d)));
        end
    end
    meanMODISaod = meanMODISaod ./ MODISc;
    meanMISRaod = meanMISRaod ./ MISRc;
    meanMODISfw = meanMODISfw ./ MODISfwc;
    meanMISRfw = meanMISRfw ./ MISRfwc;

    save(sprintf('MeanSatelliteAOD-%d.mat',Mni),'meanMODISaod','meanMISRaod','meanMODISfw','meanMISRfw');
end
