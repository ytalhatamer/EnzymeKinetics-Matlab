function updatevals(hObject,callbackdata)
    val = callbackdata.EditData;
    r = callbackdata.Indices(1);
    c = callbackdata.Indices(2);
    if c>2
        hObject.Data{r,c} = str2num(val);
    else
        hObject.Data{r,c} = val;
    end
end