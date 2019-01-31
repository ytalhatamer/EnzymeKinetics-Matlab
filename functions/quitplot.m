function quitplot(hObject,Callback)
    data=t.Data;

    hObject.ButtonDownFcn=set(t,'Enable','off');
    flag=0;
    close(h)
    return
    %hObject.ButtonDownFcn=close(h);


    uiwait(h)

end