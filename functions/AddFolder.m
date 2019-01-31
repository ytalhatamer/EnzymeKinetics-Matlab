function [data]=AddFolder(folder,datatables)
    if ispc
        slash='\';
    else
        slash='/';
    end
    addpath(folder)
    listdir=dir([folder slash '*.csv']);
    features=cell(length(listdir),5);
    fname=strsplit(folder,slash);
    fname=strrep(fname,'-','_');
    formattedfoldername=[fname{end-1} '_' fname{end}];
    
    if isfield(datatables,formattedfoldername)
        features=datatables.(formattedfoldername);
    else
        for i=1:length(listdir)
            features(i,:)={listdir(i).name,true,20,12.5,0};
        end
        datatables.(formattedfoldername)=features;
    end
    
    
    h=figure('Position',[600 400 600 400]);
    t=uitable('Parent',h,'Data',features);
    t.ColumnEditable=[false true true true true true];
    t.ColumnName={'File Name','Include File','[Protein]','[DHF]','[TMP]'};
    t.ColumnFormat={'char','logical','Numeric','Numeric','Numeric'};
    t.Position=[30 60 532 300];
    t.ColumnWidth={200,100,50,50,50};
    t.CellEditCallback=@updatevals;
    t.Enable='on';
    btn = uicontrol('Style', 'pushbutton', 'String', 'DONE',...
                'Position', [250 5 100 50],'Callback',@quitplot);
    function updatevals(hObject,callbackdata)
        val = callbackdata.EditData;
        r = callbackdata.Indices(1);
        c = callbackdata.Indices(2);
        if c>2
            hObject.Data{r,c} = str2num(val);
        else
            hObject.Data{r,c} = val;
        end
        %data=hObject.Data;
        %hObject.updatedfeatures{r,c}=val;
    end

    
       
    
    function quitplot(hObject,Callback)
        data=t.Data;
        datatables.(formattedfoldername)=t.Data;
        %hObject.ButtonDownFcn=set(t,'Enable','off');
        flag=0;
        for m=1:size(data,1)
            if data{m,5}==0
                flag=1;
            else
                continue
            end
        end
        if flag==1
            close(h)
        else
            warndlg('No background file is indicated','Annoying Error')
        end
        return
        %hObject.ButtonDownFcn=close(h);
        
    end
    uiwait(h)
    save('datatables.mat','datatables');
end