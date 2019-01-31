%%This function reads the files in the folder provided. Makes a data structure out of it ..
%%and if there is more than one no TMP file makes a calibration curve.
function [data]=AddFolderOld(folder)
    addpath(folder)
    listdir=dir([folder '\*_000_*Sample.csv'])
    bgfile=dir([folder '\*_bg.csv']);
    namelist={};
    reader=struct();
    data=struct();
    concs=[0];
    datamins=[0];
    datamaxs=[0];
   
    background=0;% if there is no experimental background correction data, it assumes it is zero.
    startdhf=4;% it ignores first few data points to avoid mixing artefacts
    excludelowdhf=.05; % To exclude the data points that have DHF concentration lower than this value 
    numdatapts=15;

    % If statement below is to read background.
    if exist(bgfile.name,'var')
        reader=csvread(bgfile.name,2);
        background=mean(reader(:,2));
    end
    % For loop below read files in the folder indicated above.
    for i=1:length(listdir)
        sample=strsplit(listdir(i).name,'_');
        if length(sample)==6
            namelist={namelist{:} [sample{1}, '_DHF', strrep(sample{3},'.','_'), 'uM_Prot', sample{2}, 'nM_Rep', sample{5}]};
            data.(namelist{i}).protconc=str2num(sample{2});
        else
            namelist={namelist{:} [sample{1}, '_DHF', strrep(sample{3},'.','_'), 'uM_Prot', sample{2}, 'nM']};
        end
        data.(namelist{i}).protconc=str2num(sample{2});
        data.(namelist{i}).dhf0=str2num(sample{3});
        concs=[concs data.(namelist{i}).dhf0];
        reader=csvread(listdir(i).name,2);    
        data.(namelist{i}).data=reader(:,2)-background;
        data.(namelist{i}).time=reader(:,1);
        datamaxs=[datamaxs data.(namelist{i}).data(1)];
        data.(namelist{i}).trdata=data.(namelist{i}).data-median(data.(namelist{i}).data(end-20:end));
        datamins=[datamins mean(data.(namelist{i}).data(end-20:end))];
    end
    if length(concs)>2
        exCoeff=MakeCalibrationCurve(concs,datamaxs,datamins)
    else
        exCoeff=115.58 % This value is calculated as average of many experiments.
    end
end