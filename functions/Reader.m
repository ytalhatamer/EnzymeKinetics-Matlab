% This function reads the measurement files and returns background
% substracted results.
function [datasubd]=Reader(namelist,bgname)
    % If statement below is to read background.
    if exist('bgname')
        data=cell(1,length(namelist));
        reader=csvread(bgname{1},2);
        background=mean(reader(:,2));
        disp(['Background Used: ' num2str(background)])
    else
        data=cell(1,length(namelist));
        background=0;
        disp(['Background Used: ' num2str(background)])
    end
    % For loop below read files in the folder indicated above.
    
    for i=1:length(namelist)
        reader=csvread(namelist{i},2);    
        data(i)={reader(:,2)-background};
        
    end
    datasubd=data;
end