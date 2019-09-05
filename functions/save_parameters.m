function save_parameters(foldername,excludelowdhf,excludehighdhf,numdatapts,kifitstart,kifitlen)
    if ispc; slash='\'; else; slash='/'; end
    filename=[foldername slash 'params.txt']
    fileID=fopen(filename,'a');
    fprintf(fileID,['[DHF]_{Lowest} Included in Km Calculation: ' num2str(excludelowdhf,2)]);
    fprintf(fileID,['\n[DHF]_{Highest} Included in Km Calculation: ' num2str(excludehighdhf,2)]);
    fprintf(fileID,['\nNumber of Data Points in Km Calculation: ' num2str(numdatapts)]);
    fprintf(fileID,['\nKi Fits starts from time point :' num2str(kifitstart)]);
    fprintf(fileID,['\nLength of Ki Fits: ' num2str(kifitlen)]);
    fclose(fileID);
end