function [hh,data,protname]=enzyme_kinetics(folder)
    % Variables and Data import
    % Please Make Sure all the Samples are Alphabetically Ordered in order of 
    % increasing substrate concentration.
    % Sample Names should be PROTNAME_PROTEINCONC_SUBSTRATECONC_REPLICA#...
    % e.g. 'I94L_20_0_1'
    %close all
    reader=struct();
    %subsconc=[0 0 .7 .7 1 1 1.4 1.4 2 2 2.8 2.8 4 4 11.3 11.3 64 64];
    %folder='arranged_data\';

    addpath(folder);
    listdir=dir([folder '/*.csv']);
    numsample=size(listdir,1);
    learner=csvread(listdir(1).name,2);
    data=struct();
    tmeas=size(learner,1);
    time=0:tmeas;
    protname=cell(1,numsample);
    protconc=zeros(1,numsample);
    dhfconc=zeros(1,numsample);
    reps=zeros(1,numsample);
    bfitlen=10;
    numreplica=2;
    firstdpfit=3;
    lastdpfit=10;



    for i=1:numsample
        sample=strsplit(listdir(i).name,'_');
        protname(i)=sample(1);
        protconc(i)=str2num(sample{2});
        dhfconc(i)=str2num(sample{3});
        replica=strsplit(sample{4},'.csv');
        replica=strsplit(replica{1},'.');
        replica=str2num(replica{1});
        reps(i)=replica;
    end

    [protname, ind]=sort(protname);
    [a,b,c]=unique(protname);
    listdir=listdir(ind,:);
    h=struct();
    if size(b)==1
        datasize=0;
        for j=1:numsample
            reader(j).data=csvread(listdir(j).name,2);
            if size(reader(j).data,1)>datasize
                datasize=size(reader(j).data,1);
            end
        end
        tmeas=datasize;
        data(1).(a{1}).data=zeros(tmeas,numsample);
        data(1).(a{1}).subsconc=dhfconc;
        data(1).(a{1}).replica=reps;
        for j=1:numsample
            reader(j).data=csvread(listdir(j).name,2);
            data(1).(a{1}).data(1:size(reader(j).data,1),j)=reader(j).data(:,2)-reader(j).data(1,2);
%             if size(reader(j).data)==size(learner)
%                 data(1).(a{1}).data(:,j)=reader(j).data(:,2)-reader(j).data(1,2);
%             else
%                 data(1).(a{1}).data(:,j)=[reader(j).data(:,2)-reader(j).data(1,2);...
%                     zeros(size(learner,1)-size(reader(j).data,1),size(reader(j).data,2))];
%             end
        end

        for k=firstdpfit:lastdpfit
            [hh,vmax,km,rsqr,rnorm]=kineticsplotter(data(1).(a{1}).data,k,bfitlen,data(1).(a{1}).subsconc,(1:tmeas),a{1},0);
            close all
            data(1).(a{1}).rsqrlist(k-2)=rsqr;
            data(1).(a{1}).kmlist(k-2)=km;
            data(1).(a{1}).vmaxlist(k-2)=vmax;
            data(1).(a{1}).rnormlist(k-2,:)=rnorm;
        end
    else
        for i=1:size(b,1)-1
            
            data(1).(a{i}).subsconc=dhfconc(b(i):b(i+1)-1);
            data(1).(a{i}).replica=reps(b(i):b(i+1)-1);
            datasize=0;
            b
            for j=b(i):b(i+1)-1
                reader(j).data=csvread(listdir(j).name,2);
                if size(reader(j).data,1)>datasize
                    datasize=size(reader(j).data,1);
                end
            end
            datasize
            data(1).(a{i}).data=zeros(tmeas,(b(i+1)-b(i)));
            for j=b(i):b(i+1)-1
                reader(j).data=csvread(listdir(j).name,2);
                data(1).(a{1}).data(1:size(reader(j).data,1),j)=reader(j).data(:,2)-reader(j).data(1,2);
%                 if size(reader(j).data)==size(learner)
%                     data(1).(a{i}).data(:,j)=reader(j).data(:,2)-reader(j).data(1,2);
%                 elseif size(reader(j).data) > size(learner)
%                     data(1).(a{i}).data(:,j)=[reader(j).data(:,2)-reader(j).data(1,2);...
%                         zeros(size(learner,1)-size(reader(j).data,1),size(reader(j).data,2))];
%                 else
%                     difference=size(learner,1)-size(reader(j).data,1);
%                     numcols=size(reader(j).data,2);
%                     data(1).(a{i}).data=[data(1).(a{i}).data; zeros(difference,(b(i+1)-b(i)))];
%                     data(1).(a{i}).data(:,j)=reader(j).data(:,2)-reader(j).data(1,2);
%                 end
            end

            for k=firstdpfit:lastdpfit
                [hh,vmax,km,rsqr,rnorm]=kineticsplotter(data(1).(a{i}).data,k,bfitlen,data(1).(a{i}).subsconc,(1:tmeas),a{i},0);
                close all
                data(1).(a{i}).rsqrlist(k-2)=rsqr;
                data(1).(a{i}).kmlist(k-2)=km;
                data(1).(a{i}).vmaxlist(k-2)=vmax;
                data(1).(a{i}).rnormlist(k-2,:)=rnorm;
            end

        end
        data(1).(a{i+1}).data=zeros(tmeas,numsample-b(i+1));
        data(1).(a{i+1}).subsconc=dhfconc(b(i+1):numsample);
        data(1).(a{i+1}).replica=reps(b(i+1):numsample);
        count=1;
        for j=b(i+1):numsample
        reader(j).data=csvread(listdir(j).name,2);
            if size(reader(j).data)==size(learner)
                data(1).(a{i+1}).data(:,count)=reader(j).data(:,2)-reader(j).data(1,2);
            else
                data(1).(a{i+1}).data(:,count)=[reader(j).data(:,2)-reader(j).data(1,2);...
                    zeros(size(learner,1)-size(reader(j).data,1),size(reader(j).data,2))];
            end
        count=count+1;
        end

        for k=firstdpfit:lastdpfit
            [hh,vmax,km,rsqr,rnorm]=kineticsplotter(data(1).(a{i+1}).data,k,bfitlen,data(1).(a{i+1}).subsconc,(1:tmeas),a{i+1},0);
            close all
            data(1).(a{i+1}).rsqrlist(k-2)=rsqr;
            data(1).(a{i+1}).kmlist(k-2)=km;
            data(1).(a{i+1}).vmaxlist(k-2)=vmax;
            data(1).(a{i+1}).rnormlist(k-2,:)=rnorm;
        end
    end

    for i=1:size(b,1)
        [bb,best]=min(abs(data(1).(a{i}).rsqrlist-1));
        [hh,vmax,km,rsqr,rnorm]=kineticsplotter(data(1).(a{i}).data,best+2,bfitlen,data(1).(a{i}).subsconc,(1:tmeas),a{i},1);
        data(1).(a{i}).bestVmax=vmax;
        data(1).(a{i}).bestkm=km;
        data(1).(a{i}).bestrsqr=rsqr;
        data(1).(a{i}).bestrnorm=rnorm;
        data(1).(a{i}).kcat_km=vmax/(protconc(b(i))/1000)/km;
    end
    
    print(hh,protname{1},'-dpng')



    % Unnecessary Parts-1 (if two proteins analyzed in 1 folder)

    % elseif size(b,1)==2
    %     data(a(1)).data=zeros(tmeas,(b(2)-b(1)));
    %     data(a(1)).subsconc=dhfconc(1:b(2)-1);
    %     data(a(1)).replica=reps(1:b(2)-1);
    %     for j=1:b(2)-1
    %         reader(j).data=csvread(listdir(j).name,2);
    % 
    %         if size(reader(j).data)==size(learner)
    %             data(:,j)=reader(j).data(:,2)-reader(j).data(1,2);
    %         else
    %             data(:,j)=[reader(j).data(:,2)-reader(j).data(1,2);...
    %                 zeros(size(learner,1)-size(reader(j).data,1),size(reader(j).data,2))];
    %         end
    %     end
    %     data(a(2)).data=zeros(tmeas,numsample-b(2));
    %     data(a(2)).subsconc=dhfconc(b(2):numsample);
    %     data(a(2)).replica=reps(b(2):numsample);
    %     for i=b(2):numsample
    %         reader(i).data=csvread(listdir(i).name,2);
    %         if size(reader(i).data)==size(learner)
    %             data(:,i)=reader(i).data(:,2)-reader(i).data(1,2);
    %         else
    %             data(:,i)=[reader(i).data(:,2)-reader(i).data(1,2);...
    %                 zeros(size(learner,1)-size(reader(i).data,1),size(reader(i).data,2))];
    %         end
    %     end
end