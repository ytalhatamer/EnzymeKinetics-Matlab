function [fits]=kirobustfitter(~,data,fitstart,kifitlen)
    fitstartpt=fitstart; 
%     stats=struct();
%     for i=4:10
%         count=1;
%         for j=5
%             tmpResids=zeros(1,size(data,2));
%             for k=1:size(data,2)
%                 [~,stt]=robustfit(i:i+j,data(i:i+j,k));
%                 tmpResids(k)=sum(abs(stt.resid));
%             end  
%             stats.sumresids(i-3,count)=sum(tmpResids(k));
%             count=count+1;
%         end
%     end
%     [~,ind]=min(stats.sumresids(:));
%     [Irow,Icol]=ind2sub(size(stats.sumresids),ind);
%     stats.range=Irow:(10+Irow+Icol);
%     fitstartpt=30%15;
    fitlen=kifitlen;
    
    for k=1:size(data,2)
        y=data(:,k);
        x=1:length(y);
%         subplot(2,ceil(size(data,2)/2),k)
        fits(:,k)=robustfit(x(fitstartpt:(fitstartpt+fitlen)),y(fitstartpt:(fitstartpt+fitlen)));
        fitted=fits(1,k)+fits(2,k)*x(fitstartpt:(fitstartpt+fitlen));
        plot(x(fitstartpt:(fitstartpt+fitlen)),fitted,'b','LineWidth',2);
        hold on
    end
    
%     legend()
end