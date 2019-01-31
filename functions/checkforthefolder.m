function [replicanum]=checkforthefolder(data,FolderName,ProteinID)
    if isempty(fieldnames(data.(ProteinID)))
        replicanum=0;
    else
        for i=1:size(fieldnames(data.(ProteinID)))
            fldnames=fieldnames(data.(ProteinID));
            if strcmp(data.(ProteinID).(fldnames{i}).FolderName,FolderName)
                replicanum=i;
                break
            else
                replicanum=0;
            end
        end    
    end
end