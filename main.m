clear all
close all
clc
%% Define Files and Locations

filename='Stats_Results.xlsx';
addpath('functions');
startingquestion=questdlg('What do you want to do?','Starting Question','Update Results','See Stored Results','');
if ispc
    slash='\';
else
    slash='/';
end

load('datatables.mat')
[ProteinID,folder]=askprotein();

ProteinID=strrep(ProteinID,'#','P');
%         ProteinID='P000000';
%         folder='data/Mut13-km-ki2-4-30-15';
datatable=AddFolder(folder,datatables);
% Define Variables
disp(['Mutant: ' ProteinID])
disp(['Folder Analyzed: ' folder ])
tmp=strsplit(folder,slash)
FolderName=tmp{end};
updateddata={};
mmlist={};
inhlist={};
tmpconcs=[];
dhfconcs=[];
protconcsmm=[];
protconcsinh=[];
dhfconcsmm=[];
dhfconcsinh=[];
excludelowdhf=0;
excludehighdhf=25;
numdatapts=20;
kifitstart=10;
kifitlen=10;
if ispc
    slash='\';
else
    slash='/';
end

% Read The Folder And Classify the Files
% For example; background file, files important for Km-Kcat measurements
% and also runs for Ki-IC50 measurements...

counter=1;
for i=1:size(datatable,1)
    if datatable{i,2}==1
        updateddata(counter,:)= datatable(i,:);
        counter=counter+1;
    end
end
datatable=updateddata;
for i=1:size(datatable,1)
    if datatable{i,4}==0
        bgfile={[folder ,slash, datatable{i,1}]};
        break
    else
        
    end
end
counter1=1;
counter2=1;
for j=1:size(datatable,1)
    dhfconcs=[dhfconcs datatable{j,4}];
    if datatable{j,4}~=0
        if datatable{j,5}==0
            name=[folder ,slash, datatable{j,1}];
            mmlist(counter2,1)={name};
            protconcsmm=[protconcsmm datatable{j,3}];
            dhfconcsmm=[dhfconcsmm datatable{j,4}];
            counter2=counter2+1;
        end
    end
end
try
    for j=1:size(datatable,1)
        if datatable{j,4}==mode(dhfconcs)
            name=[folder, slash, datatable{j,1}];
            inhlist(counter1,1)={name};
            tmpconcs=[tmpconcs datatable{j,5}];
            protconcsinh=[protconcsinh datatable{j,3}];
            dhfconcsinh=[dhfconcsinh datatable{j,4}];
            counter1=counter1+1;
        end
    end
    
catch
    disp('No Inhibition Assay Files Found.')
    disp('Restart the script and check TMP concentrations again')
end
if exist('bgfile')
    [ODs_MM]=Reader(mmlist,bgfile);
    [ODs_KI]=Reader(inhlist,bgfile);
else
    [ODs_MM]=Reader(mmlist);
    [ODs_KI]=Reader(inhlist);
end
% This cell calculates the Calibration Curve needed for
% calibration curve to get extinction coeefficient for NADPH and DHF in the
% presence of dhfractivity
% Theoretical Values of Extinction Coefficients at A340
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edhf=7780 1/M;
% Enadph=6200 1/M;
% Etotal=Edhf+Enadph;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1=figure;
exCoeff=MakeCalibrationCurve(h1,dhfconcs,ODs_MM); % exCoeff has two values in it. (y=bx+a) exCoeff includes "b", and "a" sequentially.
if exCoeff(1)~=114.94
    load('listexCoeff');
    listexCoeff(size(listexCoeff,1)+1,:)= {exCoeff , folder};
    save('listexCoeff','listexCoeff');
end
trODs=cell(size(ODs_MM));
for i=1:size(ODs_MM,2)
    trODs{i}=ODs_MM{i}(:)-median(ODs_MM{i}(end-20:end));
end
%save_figure(h1,['Graphs' slash  ProteinID slash FolderName], 'TransformedRawData')

% Extrapolate Initial Data Points to See Mixing Error
h2=figure;
ExtrapolateInitialDataPts(h2,trODs,dhfconcsmm,exCoeff);



% OD--> [DHF] conversion
h3=figure('Name','DHF concentration change over Time');
[DHF,fitDHF,fitPTs]=OD2DHFConverter(h3,trODs,exCoeff,excludelowdhf,excludehighdhf,numdatapts,dhfconcsmm);

% Function below shows inputs and outputs needed for OD conversion.
% [DHF,fitDHF,fitPTs]=OD2DHFConverter(trODs,exCoeff,excludelowdhf,excludehighdhf,numdatapts,dhf0)


%  The analysis for Km, Kcat, and Kcat/Km
% To make the analysis we are taking the linear fits over time on
% \Delta[DHF] vs V_0 curve. Then these linear fit values and their corresponding [DHF]
% become our data points in Michelis-Menten curve.
h4=figure;
[~,mmfitresults]=mmplotter(h4,DHF,fitDHF,fitPTs,protconcsmm);
h=gcf;
foldername=strsplit(folder,'-');
suptitle('[DHF] vs Velocity Plot');
Km2Use=questdlg('Which Km Value do you wanna use for Ki measurements? ','Ask for Km','One with Best Rsq', 'Mean Km','Use Given Value','');


switch Km2Use
    case 'One with Best Rsq'
        for i=1:size(mmfitresults,1)
            if i==1
                rsq=mmfitresults{i}.rsqr;
                UsedKm=mmfitresults{i}.Km;
            else
                if rsq<mmfitresults{i}.rsqr
                    UsedKm=mmfitresults{i}.Km;
                end
            end
        end
        
    case 'Mean Km'
        Kmlist=[];
        for i=1:size(mmfitresults,1)
            Kmlist=[Kmlist mmfitresults{i}.Km];
        end
        UsedKm=median(Kmlist);
    case 'Use Given Value'
        UsedKm=inputdlg('Write Down the Km','Ask for Km')
        UsedKm=str2num(cell2mat(UsedKm))
end




% Analysis for Ki Starts Here
% First we take the TMP concentrations for each sample and saved into data
% cell matrix.

DHF4Ki=zeros(300,length(inhlist));
dhfconc=mode(dhfconcsinh);
for i=1:size(inhlist,1)
    DHF4Ki(1:size(ODs_KI{i},1),i)=ODs_KI{i}(:)*exCoeff(1)+exCoeff(2);
    DHF4Ki(:,i)=max(DHF4Ki(:,i)+(dhfconc-DHF4Ki(1,i)),0);
end


h5=figure('Name','Ki Fits');
hold on
[sortedTMPconcs,indTMPconcs]=sort(tmpconcs);
sortedDHF4Ki=DHF4Ki(:, indTMPconcs);
for i=1:size(tmpconcs,2)
    x=0:60;
    y=sortedDHF4Ki(1:61,i);
    plot(x,y,'-ok','MarkerFaceColor',[1-(i/size(tmpconcs,2)),0,0]);
    hold on
    xlim([0 50])
    ylim([2 13])
    hold on
    xlabel('Time (sec)','FontSize',14)
    ylabel('[DHF] (\muM)','FontSize',14)
end




[Kifits]=kirobustfitter(h5,sortedDHF4Ki,kifitstart,kifitlen);

suptitle('Decrease in Initial DHFR Activity with Increasing [TMP]')

[a,~,c]=unique(sortedTMPconcs);
tmpconcfits=zeros(max(c),2);
for i=1:max(c)
    tmpconcfits(i,2)=abs(mean(Kifits(2,find(c==i))));
    tmpconcfits(i,1)=a(i);
end


range=logspace(-3,7,1000);
rrange=1:size(tmpconcfits,1);
[kifitresults]=mmfitterki(mode(dhfconcsinh),tmpconcfits(rrange,2)',tmpconcfits(rrange,1)',UsedKm);
kifitted=(kifitresults.Vmax*mode(dhfconcsinh))./...
    ((UsedKm*(1+(range./kifitresults.Ki))+mode(dhfconcsinh)));




h6=figure;
semilogx(tmpconcfits(rrange,1),tmpconcfits(rrange,2)*1000,'ok',range,kifitted*1000,'r','LineWidth',2)
hold on
xlabel('[TMP] (nM)')
ylabel('V_0(nM/sec)')
grid on
text(1e-2,60,...
    {['Vmax: ' num2str(round(1E3*kifitresults.Vmax,2)) ' nM/sec'];...
    ['K_i: ' num2str(round(kifitresults.Ki,2)) ' nM'];...
    %             ['K_m: ' num2str(round(kifitresults.Km,2)) ' \muM'];...
    ['R^2: ' num2str(round(kifitresults.rsqr,2))];...
    ['IC_{50}: ' num2str(round(kifitresults.IC50,2)) ' nM'];...
    ['[DHFR] : ' num2str(round(mode(protconcsinh),2)) ' nM'];...
    ['Normalized K_i : ' num2str(round((kifitresults.Ki/mode(protconcsinh)),2))];...
    ['Normalized IC_{50} : ' num2str(round((kifitresults.IC50/mode(protconcsinh)),2))]},'FontSize',15)
hold on
ic50point=semilogx(kifitresults.IC50,((kifitresults.Vmax*mode(dhfconcsinh))/...
    ((UsedKm*(1+kifitresults.IC50/kifitresults.Ki))+mode(dhfconcsinh)))*1000,'ok','MarkerFaceColor','r','MarkerSize',10);
kipoint=semilogx(kifitresults.Ki,((kifitresults.Vmax*mode(dhfconcsinh))/...
    ((UsedKm*(1+kifitresults.Ki/kifitresults.Ki))+mode(dhfconcsinh)))*1000,'ok','MarkerFaceColor','b','MarkerSize',10);
f=legend([ic50point,kipoint],'IC50','Ki');
set(f,'FontSize',16);
ylim([0 max(100,max(tmpconcfits(rrange,2)*1000))]);




savebttn=uicontrol('Style', 'pushbutton', 'String', 'Save Results',...
    'Position', [410 341 100 50],'Callback',@resumescript);
uiwait()

delete(savebttn)

% Save Graphs
saveresults=questdlg('Do you want to save figures?','Save Figures','Yes','No','');
switch saveresults
    case 'Yes'
        graphfolder=['Results' slash ProteinID slash FolderName slash 'Graphs'];%
        if exist(graphfolder,'file')==7
            disp(['Graphs folder exists in ' graphfolder])
        else
            mkdir(graphfolder)
        end
        save_figure(h2, graphfolder , '1_ExtrapolatedRawData')
        save_figure(h3, graphfolder , '2_ConvertedDataWithFits')
        save_figure(h4, graphfolder , '3_KcatKm' )
        save_figure(h5, graphfolder , '4_DHFvsTime_IncreasingTMP')
        save_figure(h6, graphfolder , '5_Ki')
        save_parameters(graphfolder,excludelowdhf,excludehighdhf,numdatapts,kifitstart,kifitlen)
    case 'No'
        warndlg('As you wish! :D')       
end
