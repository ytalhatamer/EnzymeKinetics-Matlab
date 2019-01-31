function [proteinID,chosenfolder] = askprotein
    files=dir('Results');
    dirFlags=[files.isdir];
    cells=struct2cell(files(dirFlags));
    subfolders=cells(1,3:end);
    mutants=subfolders;
    proteinIDs=subfolders;

    if ispc
        slash='\';
    else
        slash='/';
    end
    h2=figure('Position',[600 400 460 350]);
    hold on
    axis off
    text(.51,.9,'Choose Data Folder','FontSize',15)
    hold on
    text(-.1,.9,'Mutations of Protein','FontSize',15)
    hold on
    hProtNames = uicontrol('Style','List', 'String',mutants);
    hProtNames.Position=[20 80 200 200];
    
    hListbox = uicontrol('Style','pushbutton', 'String','Choose Folder','Callback',@quitplot);
    hListbox.Position=[240 80 200 200];
    btn = uicontrol('Style', 'pushbutton', 'String', 'Start Analysis',...
                'Position', [180 5 100 50],'Callback',@quitplot);


    function quitplot(hObject,Callback)
        proteinID=proteinIDs{hProtNames.Value};
        chosenfolder=uigetdir(['Results' slash proteinID slash]);
        close(h2)
        return
        
    end
    uiwait(h2)

end