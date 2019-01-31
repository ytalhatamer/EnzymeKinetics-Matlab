function [hh,vmax,km,rsqr,rnorm]=kineticsplotter(data,fitstart,fitlen,subsconc,time,protname,flag)
    warning off
    fitend=fitstart+fitlen;
    numsample=size(data,2);
    hh=figure('Name',protname)
    
    count=1;
    [a,b,c]=unique(subsconc);
    basicfits=zeros(2,numsample);
    
    for j=1:numsample
        if flag==1
            if mod(size(b,1),2)==1
                subplot(4,(size(b,1)+1)/2,c(j))
            else
                subplot(4,size(b,1)/2,c(j))
            end
            
            plot(time,data(:,j),'-ok');
            ylim([-Inf 0])
            hold on
        end
        basicfits(:,j)=robustfit(time(fitstart:fitend),data(fitstart:fitend,j));
        fitted=time(fitstart:fitend)*basicfits(2,j)+basicfits(1,j);
        if flag==1
            plot(time(fitstart:fitend),fitted,'r')
            title(['DHF: ' num2str(a(c(j)))])
            text(20,-.002,['Slope: ' num2str(round(basicfits(2,j)*1000,3))]);
            xlabel('Time(sec)')
            ylabel('A340')
            xlim([0 60])
            %ylim([-.1 0])  
        end
    end
    [vmax,km,rsqr,rnorm]=mmfitplot(basicfits(2,:),subsconc,flag);
    
end