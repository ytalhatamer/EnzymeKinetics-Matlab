function [proteinID]=askmutantresults
    muts=load('Mutations_IDs');
    mutants=muts.mutants;
    proteinIDs=muts.proteinIDs;
    if ispc
        slash='\';
    else
        slash='/';
    end
    h3=figure('Position',[600 400 240 320]);
    hold on
    axis off
    text(.45,1,{'Which Mutant';'Do You Wanna See?'},'FontSize',15,'HorizontalAlignment','Center')
    hold on
    hProtNames = uicontrol('Style','List', 'String',mutants);
    hProtNames.Position=[20 60 200 200];
    btn = uicontrol('Style', 'pushbutton', 'String', 'See Results',...
                'Position', [85 20 80 30],'Callback',@quitplot);
    function quitplot(hObject,Callback)
        proteinID=proteinIDs{hProtNames.Value};
        proteinID=strrep(proteinID,'#','P');
        close(h3)
        return
        
    end
    uiwait(h3)
end