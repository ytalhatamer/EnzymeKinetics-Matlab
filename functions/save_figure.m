function save_figure(h,foldername,figurename)
    if ispc; slash='\'; else slash='/'; end
    sname='Trial1';
    s=hgexport('readstyle',sname);
    s.Format='png'
    s.Width=1600;
    s.Height=1000;
    cd(foldername)
    hgexport(h,figurename, s)
    cd ..
end