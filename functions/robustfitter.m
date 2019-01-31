function [fitvals]=robustfitter(x,y,flag)
    fitvals=robustfit(x,y);
    if flag==1
        fitted=x*fitvals(2)+fitvals(1);
        try
            plot(x,fitted,'Color',[1-abs(fitvals(2)/10),0,0],'LineWidth',2 );
        catch
            plot(x,fitted,'Color',[1-abs(fitvals(2)/50),0,0],'LineWidth',2 );
        end
    end
end
