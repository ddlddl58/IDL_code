% This script calculates regionally valid RF ranges for use with
% CalcPM25_globalr.m (surface PM25 calculations)

GetAeroData = 0;
GetSatData = 0;

GetAllRF = 0;

GetRFzData = 0;
GetPM25Data = 0;
LoadData = 1;
SaveData = 0;
MakeFilters = 0;

MakeBiasPlot = 0;
PostExamination = 0;
PlotFilter = 0;
RalphPlot = 0;
SaveFigure = 0;
MakeRandallPlot = 1;

UseAngstrom = 1; % correct Aeronet to 550 nm

glat = [-89.95:0.1:89.95];
glon = [-179.95:0.1:179.95];

if GetAeroData == 1;
    
    Aero = [];
    Aero.dir = '/data1/kelaar/Aeronet/AOT/LEV20/ALL_POINTS/';
    Aero.files = dir(sprintf('%s*.lev20',Aero.dir));
    Aero.dates = [Juln2Grg(2000001:2000366)'; Juln2Grg(2001001:2001365)'; Juln2Grg(2002001:2002365)'; Juln2Grg(2003001:2003365)'; Juln2Grg(2004001:2004366)'; Juln2Grg(2005001:2005365)'; Juln2Grg(2006001:2006365)'];
    
    % [24h AOD, 24h time, 24h c, 9-12 AOD, 9-12 time, 9-12 c]
    Aero.data = zeros(size(Aero.files,1),size(Aero.dates,1),6);
    Aero.coord = zeros(size(Aero.data,1),2);
    Aero.coordspot = zeros(size(Aero.data,1),2);
    Aero.station = cell(size(Aero.data,1),1);
    
    for i = 1:size(Aero.files,1)
        
        fid = fopen(sprintf('%s%s',Aero.dir,Aero.files(i).name));
        fgetl(fid); fgetl(fid);
        fline = fgetl(fid);
        spot = findstr(fline,',');
        lon = str2num(fline(findstr(fline,'long=')+5:spot(2)-1));
        lat = str2num(fline(findstr(fline,'lat=')+4:spot(3)-1));
        location = fline(findstr(fline,'Location=')+9:spot(1)-1);
        utc2loc = floor(lon/15)/24;
        fgetl(fid);
        fline = fgetl(fid);
        spot = findstr(fline,',');
        aodspot = findstr(fline,'AOT_500');
        aodspot = max(find(aodspot>spot));
        
        if UseAngstrom == 1
            aod675spot = findstr(fline,'AOT_675');
            aod675spot = max(find(aod675spot>spot));
        end
        
        Aero.station{i} = location;
        Aero.coord(i,1) = lat;
        Aero.coord(i,2) = lon;
        [a Aero.coordspot(i,2)] = min(abs(lon - glon));
        [a Aero.coordspot(i,1)] = min(abs(lat - glat));
        
        while(~feof(fid))
            fline = fgetl(fid);
            
            % check that observation is during overpass (9 - 12) and Year
            % is between 2000-2006
            year = str2double(fline(7:10));
            jdate = str2double(fline(21:30)) + utc2loc;
            
            if jdate < 0
                year = year - 1;
                jdate = mod(Grg2Juln(year*10000+1231),1000)+jdate;
            elseif jdate > mod(Grg2Juln(year*10000+1231),1000)
                year = year + 1;
                jdate = mod(jdate,1);
            end
            
            if year >= 2000 && year <= 2006
                
                spot = findstr(fline,',');
                if ~strcmp(fline(spot(aodspot)+1:spot(aodspot+1)-1),'N/A')
                    
                    aspot = find(Juln2Grg(year*1000+floor(jdate)) == Aero.dates);
                    if UseAngstrom == 0
                        Aero.data(i,aspot,1) = Aero.data(i,aspot,1) + str2double(fline(spot(aodspot)+1:spot(aodspot+1)-1));
                    else
                        t500 = str2double(fline(spot(aodspot)+1:spot(aodspot+1)-1));
                        t675 = str2double(fline(spot(aod675spot)+1:spot(aod675spot+1)-1));
                        angstrom = -log(t500/t675) / log(500/675);
                        Aero.data(i,aspot,1) = Aero.data(i,aspot,1) + t500*(550/500)^-angstrom;
                    end
                    Aero.data(i,aspot,2) = Aero.data(i,aspot,2) + mod(jdate,1);
                    Aero.data(i,aspot,3) = Aero.data(i,aspot,3) + 1;
                    
                    
                    if mod(jdate,1) > 0.37 && mod(jdate,1) < 0.51

                        if UseAngstrom == 0
                            Aero.data(i,aspot,4) = Aero.data(i,aspot,4) + str2double(fline(spot(aodspot)+1:spot(aodspot+1)-1));
                        else
                            Aero.data(i,aspot,4) = Aero.data(i,aspot,4) + t500*(550/500)^-angstrom;                            
                        end
                        Aero.data(i,aspot,5) = Aero.data(i,aspot,5) + mod(jdate,1);
                        Aero.data(i,aspot,6) = Aero.data(i,aspot,6) + 1;

                    end
                end
            end
            
        end
        
        disp(sprintf('AERONET: file %d of %d acquired.',i,size(Aero.files,1)));
    end
    Aero.data(:,:,1) = Aero.data(:,:,1) ./ Aero.data(:,:,3);
    Aero.data(:,:,2) = Aero.data(:,:,2) ./ Aero.data(:,:,3);
    Aero.data(:,:,4) = Aero.data(:,:,4) ./ Aero.data(:,:,6);
    Aero.data(:,:,5) = Aero.data(:,:,5) ./ Aero.data(:,:,6);
    
    if SaveData == 1
        if UseAngstrom == 0
            save('AeronetComparisonZ.mat','Aero');
        else
            save('AeronetComparisonZa.mat','Aero');            
        end
    end
elseif LoadData == 1
    if UseAngstrom == 0
        load('AeronetComparisonZ.mat','Aero');    
    else
        load('AeronetComparisonZa.mat','Aero');    
    end
end

if GetSatData == 1
    GetGCdata = 0;
    
    %Satidir = '/data1/kelaar/work/PM25_Prediction/PM25-0.1-v2/SmoothGC-bMfw-0.10-AODi-MISR-SRs-0.80-24h/';
    MODISdir = '/data1/kelaar/work/PM25_Prediction/MODIS_v2/0.1/';
    MISRdir = '/data1/kelaar/work/PM25_Prediction/MISR_v2/0.1/';
    %Satodir = '/data1/kelaar/work/PM25_Prediction/PM25-0.1-v2/SmoothGC-bMfw-0.10-AODo-MISR-SRs-0.80-24h/';
    GCdir = '/data1/kelaar/work/PM25_Prediction/GC_v2/0.1/';

    % [TERRA MODIS AOD, TERRA MISR AOD, TERRA MORNING AOD,TERRA MODIS PM25, TERRA MISR PM25, TERRA MORNING PM25, MODIS AODi?, MISR AODi? MORNING AODIi?]
    Aero.Satdata = NaN.*zeros(size(Aero.data,1),size(Aero.data,2),9);
    
    if GetGCdata == 1
        % [GCs 24h AOD, GC 10-12 AOD, GCs 24h PM25, GC 24h AOD, GC 10-12 AOD, GC 24h PM25];
        Aero.GCdata = NaN.*zeros(size(Aero.data,1),size(Aero.data,2),6);
    end
    
    for y = 2000:2000 %2006
        if y == 2000
            Mni = 5;
        else
            Mni = 1;
        end
        for d = Grg2Juln(y*10000+Mni*100+1):Grg2Juln(y*10000+1231)
            %load(sprintf('%sPM25-%d.mat',Satidir,Juln2Grg(d)));
            %PM25di = PM25d;
            %load(sprintf('%sPM25-%d.mat',Satodir,Juln2Grg(d)));
            load(sprintf('%sMODIS-TERRA-0.1-%d.mat',MODISdir,Juln2Grg(d)));
            MODIS.aod(MODIS.aodc==0) = NaN;
            load(sprintf('%sMISR-0.1-%d.mat',MISRdir,Juln2Grg(d)));
            MISR.aod(MISR.aodc==0) = NaN;
            
            if GetGCdata == 1
                load(sprintf('%sGCPM-%d.mat',GCdir,Juln2Grg(d)),'GC10t12','GCs10t12','GC00t23','GCs00t23');
            end
            spot = find(Aero.dates == Juln2Grg(d));
            for i = 1:size(Aero.data,1)
                
                %Aero.Satdata(i,spot,1) = PM25di.aod(Aero.coordspot(i,1),Aero.coordspot(i,2),1);
                %Aero.Satdata(i,spot,2) = PM25di.aod(Aero.coordspot(i,1),Aero.coordspot(i,2),3);
                %Aero.Satdata(i,spot,3) = PM25di.aod(Aero.coordspot(i,1),Aero.coordspot(i,2),4);
                %Aero.Satdata(i,spot,4) = PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),1);
                %Aero.Satdata(i,spot,5) = PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),3);
                %Aero.Satdata(i,spot,6) = PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),4);
                %Aero.Satdata(i,spot,7) = double(PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),1) ~= PM25d.data(Aero.coordspot(i,1),Aero.coordspot(i,2),1)) * ~isnan(PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),1));
                %Aero.Satdata(i,spot,8) = double(PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),3) ~= PM25d.data(Aero.coordspot(i,1),Aero.coordspot(i,2),3)) * ~isnan(PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),3));
                %Aero.Satdata(i,spot,9) = double(PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),4) ~= PM25d.data(Aero.coordspot(i,1),Aero.coordspot(i,2),4)) * ~isnan(PM25di.data(Aero.coordspot(i,1),Aero.coordspot(i,2),4));
                
                Aero.Satdata(i,spot,1) = MODIS.aod(Aero.coordspot(i,1),Aero.coordspot(i,2));
                Aero.Satdata(i,spot,2) = MISR.aod(Aero.coordspot(i,1),Aero.coordspot(i,2));
                Aero.Satdata(i,spot,3) = nanmean([Aero.Satdata(i,spot,1) Aero.Satdata(i,spot,2)]);
                
                if GetGCdata == 1
                    Aero.GCdata(i,spot,1) = GCs00t23.AOD(Aero.coordspot(i,1),Aero.coordspot(i,2));
                    Aero.GCdata(i,spot,2) = GCs10t12.AOD(Aero.coordspot(i,1),Aero.coordspot(i,2));
                    Aero.GCdata(i,spot,3) = GCs00t23.PM25(Aero.coordspot(i,1),Aero.coordspot(i,2));
                    Aero.GCdata(i,spot,4) = GC00t23.AOD(Aero.coordspot(i,1),Aero.coordspot(i,2));
                    Aero.GCdata(i,spot,5) = GC10t12.AOD(Aero.coordspot(i,1),Aero.coordspot(i,2));
                    Aero.GCdata(i,spot,6) = GC00t23.PM25(Aero.coordspot(i,1),Aero.coordspot(i,2));
                end
                
            end
            
            disp(sprintf('%d read in',Juln2Grg(d)))
            
        end
    end
    if SaveData == 1
        if UseAngstrom == 0
            save('AeronetComparisonZo.mat','Aero');
        else
            save('AeronetComparisonZao.mat','Aero');            
        end
    end
elseif LoadData == 1
    if UseAngstrom == 0
        load('AeronetComparisonZo.mat','Aero');
    else
        load('AeronetComparisonZao.mat','Aero');            
    end
end

if GetAllRF == 1
    Aero.RF = zeros(size(Aero.data,1),size(Aero.data,2),3);
    tlat = -89.9:0.2:89.9;
    tlon = -179.9:0.2:179.9;
    tspot = zeros(size(Aero.data,1),2);
    for i = 1:size(Aero.data,1)
        [a b] = min(abs(Aero.coord(i,1)-tlat));
        [c d] = min(abs(Aero.coord(i,2)-tlon));
        tspot(i,:) = [b(1) d(1)];
    end
    for Mni = 1:12
        dspot = find(mod(floor(Aero.dates/100),100)==Mni);
        load(sprintf('RFzones-%d.mat',Mni),'t');
        r1 = [];
        for i = 1:size(Aero.data,1)
            if t(tspot(i,1),tspot(i,2),3) > 0.2
                disp(sprintf('%d',i))
                r1 = [r1; i];
            end
            for j = 1:3
                Aero.RF(i,dspot,j) = t(tspot(i,1),tspot(i,2),j);
            end
        end
        disp(sprintf('Mni: %d',Mni));
    end
    if SaveData == 1
        if UseAngstrom == 0
            save('AeronetComparisonZo.mat','Aero');
        else
            save('AeronetComparisonZao.mat','Aero');            
        end
    end
elseif LoadData == 1
    if UseAngstrom == 0
        load('AeronetComparisonZo.mat','Aero');
    else
        load('AeronetComparisonZao.mat','Aero');            
    end
end

if GetRFzData == 1
    
    Aero.RFdata = zeros(size(Aero.coord,1),12);
    RF = [];
    RF.lat = [-89.95:0.1:89.95];
    RF.lon = [-179.95:0.1:179.95];
    [RF.LongGrid RF.LatGrid] = meshgrid(RF.lon,RF.lat);
    RF.data = zeros(length(RF.lat),length(RF.lon),12);
    RFdir = '';
    
    for Mn = 1:12
        load(sprintf('%s%s',RFdir,sprintf('RFzones-%d.mat',Mn)),'RFZ');
        RF.data(:,:,Mn) = RFZ.data;
        
        for i = 1:size(Aero.data,1)
            Aero.RFdata(i,Mn) = RF.data(Aero.coordspot(i,1),Aero.coordspot(i,2),Mn);
        end
    end
    if SaveData == 1
        if UseAngstrom == 0
            save('AeronetComparisonZo.mat','Aero','RF');
        else
            save('AeronetComparisonZao.mat','Aero','RF');            
        end
    end
elseif LoadData == 1
    if UseAngstrom == 0
        load('AeronetComparisonZo.mat','Aero','RF');
    else
        load('AeronetComparisonZao.mat','Aero','RF');            
    end
end

if GetPM25Data == 1
    GCdir = '/data1/kelaar/work/PM25_Prediction/GC_v2/0.1/';
    c = 0;
    meanaod = zeros(91,144);
    meanPM25 = meanaod;
    for Mni = 1:12
        for y = 2001:2006
            if Mni < 12
                dr = Grg2Juln(y*10000+Mni*100+1):(Grg2Juln(y*10000+(Mni+1)*100+1)-1);
            else
                dr = Grg2Juln(y*10000+Mni*100+1):Grg2Juln(y*10000+1231);
            end
            for d = dr
                load(sprintf('%sGCPM-%d.mat',GCdir,Juln2Grg(d)),'GC10t12','GC00t23');
                meanaod = meanaod + GC10t12.AODSO4 + GC10t12.AODOC + GC10t12.AODBC + GC10t12.AODSSa + GC10t12.AODSSc + GC10t12.AODD;
                meanPM25 = meanPM25 + GC00t23.SO4 + GC00t23.NH4 + GC00t23.NIT + GC00t23.OC + GC00t23.BC + GC00t23.DST + GC00t23.SAL + GC00t23.SOA;
                c = c + 1;
                disp(sprintf('%d Complete',Juln2Grg(d)));
            end
        end
        meanaod = meanaod ./ c;
        meanPM25 = meanPM25 ./ c;
        [oLongGrid, oLatGrid] = meshgrid(GC00t23.olon,GC00t23.olat);
        [LongGrid,LatGrid] = meshgrid(GC00t23.lon,GC00t23.lat);
        factor = griddata(oLatGrid,oLongGrid,meanPM25./meanaod,LatGrid,LongGrid,'linear');
        
        save(sprintf('AODfactor-%d.mat',Mni),'factor');
        
    end
    
    MODISdir = sprintf('MODIS_v2/0.1/');
    MISRdir = sprintf('MISR_v2/0.1/');        
    meanMODISaod = zeros(1800,3600);
    meanMISRAOD = meanMODISaod;
    MODISc = meanMODISaod;
    MISRc = meanMODISaod;
    for Mni = 1:12
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
                MODISc = MODISc + MODIS.aodc;
                meanMISRaod = meanMISRaod + MISR.aod;
                MISRaodc = MISRc + MISR.aodc;
                disp(sprintf('%d Complete',Juln2Grg(d)));
            end
        end
        meanMODISaod = meanMODISaod ./ MODISc;
        meanMISRaod = meanMISRaod ./ MISRc;
        
        % not used any longer (use MakeAODmean.m)
        %save(sprintf('MeanSatelliteAOD-%d.mat',Mni),'meanMODISaod','meanMISRaod');
        
    end
end

if MakeBiasPlot == 1
    
    SaveBias = 1;
    JustSaveBias = 1;
    SaveBiasPlot = 0;
    
    Mns = [1:12];
    
    for JDi = Mns
        
        % Aeronet Overpass AOD, MODIS AOD, MISR AOD, MORNING AOD
        tplot = zeros(size(Aero.data,1),size(Aero.data,2),4);
        tplot(:,:,1) = Aero.data(:,:,4);
        tplot(:,:,2:4) = Aero.Satdata(:,:,1:3);

        tcoord = Aero.coord;
        tRF = Aero.RFdata;
        tRF = nanmean(tRF(:,JDi),2);

        RFplot = nanmean(RF.data(:,:,JDi),3);
        RFlat = RF.LatGrid(:,:);
        RFlon = RF.LongGrid(:,:);

        Mn = mod(floor(Aero.dates/100),100);
        spot = find(Mn == JDi);
        tplot = tplot(:,spot,:);
            
        c = ['k-'; 'b+'; 'gx'; 'ro'];
        modistcoord = tcoord;
        misrtcoord = tcoord;
        modistcoord(sum(~isnan(tplot(:,:,1) + tplot(:,:,2)),2)==0,:) = [];
        misrtcoord(sum(~isnan(tplot(:,:,1) + tplot(:,:,3)),2)==0,:) = [];
           
        stat = [];

        % find regions of agreement
        clear opt
        for j = 1:2
            opt(:,:,j) = tplot(:,:,1) + tplot(:,:,j+1) - tplot(:,:,j+1);
        end
        for j = 3:4
            opt(:,:,j) = tplot(:,:,j-1) + tplot(:,:,1) - tplot(:,:,1);
        end
        opt = [squeeze(nanmean(opt,2)) tRF];
        RFp = [[0:9]' zeros(10,4)];
        MODISbias = zeros(size(RFlat));
        MISRbias = zeros(size(RFlat));
            
        % calculate AERONET coarse-grid distances
        crslat = -90:90;
        crslon = -180:180;
            
        for j = 1:size(RFp,1)
            for k = 3:4
                spot = find(opt(:,end) == RFp(j,1));
                %spot = find(opt(:,end) > -1);
                spot(isnan(opt(spot,k))) = [];
                value = zeros(length(crslat),length(crslon));
                weight = value;

                if ~isempty(spot)

                    [crsLon, crsLat] = meshgrid(deg2rad(crslon),deg2rad(crslat));
                    for n = 1:size(spot,1)
                            
                        d = 6371.*acos(sin(deg2rad(tcoord(spot(n),1))).*sin(crsLat)+cos(deg2rad(tcoord(spot(n),1))).*cos(crsLat).*cos(crsLon-deg2rad(tcoord(spot(n),2))));
                        d = d.^3; %increase weighting
                        value = value + (opt(spot(n),k-2)-opt(spot(n),k))./d;
                        weight = weight + 1./d;

                    end
                    value = value ./ weight;

                    [crsLon, crsLat] = meshgrid(crslon,crslat);

                    t = griddata(crsLat,crsLon,value,RFlat,RFlon,'linear');

                    if k == 3
                        MODISbias(RFplot==RFp(j,1)) = t(RFplot==RFp(j,1));
                    elseif k == 4
                        MISRbias(RFplot==RFp(j,1)) = t(RFplot==RFp(j,1));
                    end
                else
                    if k == 3
                        MODISbias(RFplot==RFp(j,1)) = NaN;
                    elseif k == 4
                        MISRbias(RFplot==RFp(j,1)) = NaN;
                    end                                               
                end

            end
        end
        
        % convert AOD bias to PM25 bias
        for Mni = Mns
            load(sprintf('AODfactor-%d.mat',Mni),'factor');
            MODISbiasPM25 = MODISbias .* factor;
            MISRbiasPM25 = MISRbias .* factor;            
        end
        
        if JustSaveBias ~= 1
            h = NaN.*zeros(4,1);
            figure
            for i = 1:2
                h(i) = subplot(2,2,i);
                worldmap('world')
                setm(gca,'MapProjection','miller'); %,'meridianlabel','off','parallellabel','off');
                tightmap
                load coast
                plotm(lat,long,'k-');
                colorbar
                if i == 2
                    surfm(RFlat-0.05,RFlon-0.05,MISRbiasPM25);
                    plotm(misrtcoord(:,1),misrtcoord(:,2),'w.')
                    title(['MISR - Months: ' num2str(JDi)])
                elseif i == 1
                    surfm(RFlat-0.05,RFlon-0.05,MODISbiasPM25);                        
                    plotm(modistcoord(:,1),modistcoord(:,2),'w.')
                    title(['MODIS - Months: ' num2str(JDi)])
                end
                set(gca,'clim',[-10 10]);
            end

            stat = [];
            for i = 2:3

                temp = tplot(:,:,[1 i 1]);

                temp(:,:,1) = temp(:,:,1) + temp(:,:,2) - temp(:,:,2);
                temp(:,:,2) = temp(:,:,2) + temp(:,:,1) - temp(:,:,1);
                temp(:,:,3) = NaN;

                for j = 1:size(tcoord,1)
                    [a b] = min(abs(tcoord(j,1) - RFlat(:,1)));
                    [a c] = min(abs(tcoord(j,2) - RFlon(1,:)));
                    if i == 2
                        temp(j,:,3) = MODISbias(b,c);
                    elseif i == 3
                        temp(j,:,3) = MISRbias(b,c);
                   end
                end

                Gnd = temp(:,:,1);
                Gnd = nanmean(Gnd,2);

                Sat = temp(:,:,2);
                BiasSat = temp(:,:,3) + temp(:,:,2) - temp(:,:,2);
                Sat = nanmean(Sat,2);
                BiasSat = nanmean(BiasSat,2);
                t = Gnd+BiasSat+BiasSat;
                Gnd(isnan(t)) = [];
                BiasSat(isnan(t)) = [];
                Sat(isnan(t)) = [];

                if numel(Gnd) > 1
                    r = corrcoef(Gnd,Sat);
                    rb = corrcoef(Gnd,Sat + BiasSat);

                    [m b] = organic_regress(Sat,Gnd);
                    [mb bb] = organic_regress(Sat + BiasSat,Gnd);
                else
                    r = [1 1; 1 1];
                    m = 1;
                    b = 0;
                    rb = [1 1; 1 1];
                    mb = 1;
                    bb = 0;
                end

                subplot(2,2,i+1);
                plot(Gnd,Sat + BiasSat,'r.',Gnd,Sat,'b.',[-100 100],[-100*mb+bb 100*mb+bb],'r-',[-100 100],[-100*m+b 100*m+b],'b-',[-100 100],[-100 100],'k-');

                stat = [stat; [r(1,2) m b nanmax(nanmax([Gnd Sat])) nanmin(nanmin([Gnd Sat])) length(Sat)]];
                stat = [stat; [rb(1,2) mb bb nanmax(nanmax([Gnd Sat + BiasSat])) nanmin(nanmin([Gnd Sat + BiasSat])) length(Sat)]];

                limits = [nanmin(stat(end-1:end,5)) nanmax(stat(end-1:end,4))];
                xlim(limits);
                ylim(limits);

                text(limits(1)+(limits(2)-limits(1))*0.05, limits(2)-(limits(2)-limits(1))*0.15, sprintf('Estimated: y = %.2fx + %.2f\nr = %.2f, n = %d',stat(end-1,2),stat(end-1,3),stat(end-1,1),stat(end-1,6)),'Color','blue');
                text(limits(1)+(limits(2)-limits(1))*0.05, limits(2)-(limits(2)-limits(1))*0.3, sprintf('Estimated: y = %.2fx + %.2f\nr = %.2f, n = %d',stat(end,2),stat(end,3),stat(end,1),stat(end,6)),'Color','red');

            end
        end

        if SaveBias == 1
            if UseAngstrom == 0
                save(sprintf('AODzBIASo-%d.mat',JDi),'MODISbias','MISRbias','MODISbiasPM25','MISRbiasPM25');
            else
                save(sprintf('AODzBIASao-%d.mat',JDi),'MODISbias','MISRbias','MODISbiasPM25','MISRbiasPM25');                
            end
        end
        
        if SaveBiasPlot == 1 & JustSaveBias ~= 1
            print('-r300','-djpeg',sprintf('AODzBIASo-%d.jpg',JDi))
            close
        end
        
        disp(sprintf('%d Complete',JDi));
    end
    
end

if PlotFilter == 1
    
    load('LandMask-0.1.mat');
    Mask.land = double(Mask.land);
    Mask.land(Mask.land == 0) = NaN;
    
    [LongGrid, LatGrid] = meshgrid(RF.lon,RF.lat);
    
    figure
    load coast
    
    for i = 1:2
        subplot(2,1,i)
        h(i) = worldmap([-60 80],[-180 180]);
        setm(gca,'meridianlabel','off','parallellabel','off');
        plotm(lat,long,'k-')
        if i == 1
            surfm(RF.LatGrid,RF.LongGrid,sum(double(RF.filter==1 | RF.filter == 3),3).*Mask.land)
            ylabel('MODIS','visible','on')
        elseif i == 2
            surfm(RF.LatGrid,RF.LongGrid,sum(double(RF.filter==2 | RF.filter == 3),3).*Mask.land)           
            ylabel('MISR','visible','on')
        end
        plotm(Aero.coord(:,1),Aero.coord(:,2),'k.')
        r = 1;
        for j = 1:size(RF.alat,1)
            %for k = RF.alat(j,1):r:RF.alat(j,2)-1
            %    plotm([k k+r],[RF.alon(j,1) RF.alon(j,1)],'k-');
            %    plotm([k k+r],[RF.alon(j,2) RF.alon(j,2)],'k-');
            %end
            %for k = 1:2
            %    plotm([RF.alat(j,k) RF.alat(j,k)],[RF.alon(j,1) RF.alon(j,2)],'k-');
            %end
            plotm([RF.alat(j,1) RF.alat(j,2) RF.alat(j,2) RF.alat(j,1) RF.alat(j,1)],[RF.alon(j,1) RF.alon(j,1) RF.alon(j,2) RF.alon(j,2) RF.alon(j,1)],'k-')
            z = textm(mean(RF.alat(j,:)),mean(RF.alon(j,:)), RF.aname{j},'color','black','HorizontalAlignment','center');
        end
    end
    cb = colorbar;
    
    set(h(1),'Position',[0.1 0.51 0.7 0.48]);
    set(h(2),'Position',[0.1 0.01 0.7 0.48]);
    set(cb,'Position',[0.83 0.2 0.03 0.6]);
    axes(cb)
    ylabel('Useable Months');
    
    if SaveFigure == 1
        print('-djpeg','-r200','RFfilter.jpg');
    end
end

if PostExamination == 1
    
    MPROI = 'NA'; % NA, ENA, WNA, HC, EU, NE, World
    
    % North America
    if strcmp(MPROI,'NA')
        Region = [[25 60];[-130 -50]];
    elseif strcmp(MPROI,'ENA')
        Region = [[25 55];[-100 -50]];
    elseif strcmp(MPROI,'WNA')
        %Region = [[25 55];[-150 -100]];
        Region = [[25 55];[-125 -100]];
    elseif strcmp(MPROI,'HC')
        Region = [[41 47];[-85 -75]];
    elseif strcmp(MPROI,'EU')
        Region = [[35 60];[-10 30]];
    elseif strcmp(MPROI,'NE')
        Region = [[40 60];[-10 15]];
        %Region = [[40 60];[10 25]];
    elseif strcmp(MPROI,'World')
        Region = [[-50 60];[-165 170]];
    elseif strcmp(MPROI,'Asia')
        Region = [[5 60];[60 180]];
    end
    
    [a latspot(1)] = min(abs(Region(1,1)-glat));
    [a latspot(2)] = min(abs(Region(1,2)-glat));
    [a longspot(1)] = min(abs(Region(2,1)-glon));
    [a longspot(2)] = min(abs(Region(2,2)-glon));

    [LongGrid, LatGrid] = meshgrid(glon(longspot(1):longspot(2)),glat(latspot(1):latspot(2)));
    
    MODIS  = zeros(size(LatGrid));
    MISR = MODIS;
    c = 0;
    for Mni = 1:12
        load(sprintf('AODzBIAS-%d.mat',Mni),'MODISbiasPM25','MISRbiasPM25');
        MODIS = MODIS + MODISbiasPM25(latspot(1):latspot(2),longspot(1):longspot(2));
        MISR = MISR + MISRbiasPM25(latspot(1):latspot(2),longspot(1):longspot(2));
        c=c+1;
    end
    MODIS = MODIS ./ c;
    MISR = MISR ./ c;
    
    figure
    worldmap(Region(1,:),Region(2,:))
    setm(gca,'MapProjection','miller','meridianlabel','off','parallellabel','off');
    tightmap
    load coast
    plotm(lat,long,'k-');
    surfm(LatGrid,LongGrid,MODIS);
    set(gca,'clim',[-5 5])
    colorbar('horiz');
end

if RalphPlot == 1
    
    MODISfilter = zeros(1800,3600,12);
    MISRfilter = zeros(1800,3600,12);
    
    MaxAeroBias00 = 0.20;
    MaxAeroBias = 0.1;
    
    for Mni = 1:12
        load(sprintf('AODzBIASao-%d.mat',Mni),'MODISbias','MISRbias')
        load(sprintf('MeanSatelliteAOD-%d.mat',Mni),'meanMODISaod','meanMISRaod');
        
        MODISfilter(:,:,Mni) = (abs(MODISbias./ meanMODISaod) <= MaxAeroBias00) | abs(MODISbias) <= MaxAeroBias;
        MISRfilter(:,:,Mni) = (abs(MISRbias./ meanMISRaod) <= MaxAeroBias00) | abs(MISRbias) <= MaxAeroBias;

    end
    
    tdata = [];
    for RFi = 0:9
        
        for Mni = 1:12
            RFspot = find(Aero.RFdata(:,Mni) == RFi);
            Mnspot = find(mod(floor(Aero.dates/100),100)==Mni);

            tCoord = Aero.coordspot(RFspot,:);
            tMODISf = zeros(size(RFspot,1),1);
            tMISRf = zeros(size(RFspot,1),1);
            for i = 1:size(tCoord,1);
                tMODISf(i) = MODISfilter(tCoord(i,1),tCoord(i,2),Mni);
                tMISRf(i) = MISRfilter(tCoord(i,1),tCoord(i,2),Mni);
            end
            
            tAero = Aero.data(RFspot,Mnspot,4); % AERONET overpass AOD
            tMODIS = Aero.Satdata(RFspot,Mnspot,1);
            tMISR = Aero.Satdata(RFspot,Mnspot,2);
            
            spot = isnan(tAero+tMODIS+tMISR);
            tAero(spot) = NaN;
            tMODIS(spot) = NaN;
            tMISR(spot) = NaN;
            
            tAero = nanmean(tAero,2);
            tMODIS = nanmean(tMODIS,2);
            tMISR = nanmean(tMISR,2); 
            
            tdata = [tdata; [RFi.*ones(size(tAero)) Mni.*ones(size(tAero)) Aero.coord(RFspot,:) tAero tMODIS tMISR tMODISf tMISRf]];
            tdata(isnan(sum(tdata(:,5:7),2)),:) = [];
            
        end
        
    end
    spot = tdata(:,8) == 1;
    tdata(spot,8) = tdata(spot,6);
    tdata(~spot,8) = NaN;
    spot = tdata(:,9) == 1;
    tdata(spot,9) = tdata(spot,7);
    tdata(~spot,9) = NaN;
    
    tdatafull = tdata;
    save('Aeronettdata.mat','tdatafull','-v6');
    
    RFzones = zeros(1800,3600,12);
    for Mni = 1:12
        load(sprintf('RFzones-%d.mat',Mni),'RFZ');
        RFdata = RFZ.data;
        save(sprintf('RFdata-%d.mat',Mni),'RFdata','glat','glon','-v6');
        RFzones(:,:,Mni) = RFZ.data;
    end
    
    Mn=7;
    tdata = tdatafull;
    tdata = tdata(tdata(:,2)==Mn,:);
    figure
    %load(sprintf('RFzones-%d.mat',Mn),'RFZ','t');
    worldmap([-49.95 59.95],[-164.95 169.95]);
    setm(gca,'MapProjection','miller','meridianlabel','off','parallellabel','off');
    tightmap
    load coast
    plotm(lat,long,'k-');
    surfm(glat,glon,RFzones(:,:,Mn))

    for i = 1:4
        if i == 1
            spot = find(~isnan(tdata(:,8)) == 1);
            s = '+';
        elseif i == 2
            spot = find(~isnan(tdata(:,9)) == 1);
            s = 'x';
        elseif i == 3
            spot = find(~isnan(tdata(:,8)) == 0 & ~isnan(tdata(:,9)) == 0);
            s = 'o';
        end
        plotm(tdata(spot,3),tdata(spot,4),['k' s]);
    end
    
end

disp('fin.');
