function save_figure(h,foldername,figurename)
    if ispc; slash='\'; else slash='/'; end
    saveas(h,[foldername slash figurename '.pdf'])
end