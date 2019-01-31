function [hout,mmfitresult]=mmplotter(hincome,DHF,fitDHF,fitPTs,protconcsmm)
    for i=1:size(DHF,2)
        fitrange{i}=0:.01:max(DHF{i});
        substrate{i}=fitPTs{i};
        vo{i}=-fitDHF{i}(2,:);
        [mmfitresult{i}]=mmfitter(substrate{i},vo{i},protconcsmm(i));
        mmfit{i}=(mmfitresult{i}.Vmax.*fitrange{i})./(mmfitresult{i}.Km+fitrange{i});
        if i==1
            maxDHF=max(DHF{i});
            maxVo=max(vo{i});
        else
            if maxDHF<max(DHF{i})
                maxDHF=max(DHF{i});
            end
            if maxVo<abs(max(vo{i}))
                maxVo=abs(max(vo{i}));
            end
        end
        
    end
    hout=hincome;
    %h.Position=[400,100,1200,800];
    for i=1:size(DHF,2)
        if size(DHF,2)<=2
            subplot(1,size(DHF,2),i);
        else
            subplot(2,ceil(size(DHF,2)/2),i);
        end
        km_ind=find(round(fitrange{i},2)==round(mmfitresult{i}.Km,2));
        plot(substrate{i},vo{i},'ob',fitrange{i},mmfit{i},'r');
        hold on
%         plot(mmfitresult{i}.Km,mmfit{i}(km_ind),'ok','MarkerFaceColor','b','MarkerSize',10)
        grid on
        ylabel('V_0 (\muM/sec)');
        xlabel('[DHF] (\muM)');
        xlim([0 maxDHF]);
        ylim([0 maxVo]);
        bigplot=get(gca,'Position');
        axes('Position',[bigplot(1)+(1.9*bigplot(3)/2.9) bigplot(2)+(bigplot(4)*5/9) bigplot(3)/3 bigplot(4)/6])
        axis off
        text(0,0,... 
                {['Km= ' num2str(round(mmfitresult{i}.Km,2)) ' \muM'];...
                ['Vmax= ' num2str(round(mmfitresult{i}.Vmax*1000,1)) ' nM/sec'];...
                ['Kcat= ' num2str(round(mmfitresult{i}.Kcat,2)) ' sec^{-1}'];
                ['Kcat/Km=' num2str(round(mmfitresult{i}.KcatKm,1)) ' \muM^{-1}sec^{-1}'];...
                ['R^2=' num2str(round(mmfitresult{i}.rsqr,2))]},'FontSize',14);
        %text( ,{})
        
        axes('Position',[bigplot(1)+(1.9*bigplot(3)/2.9) bigplot(2)+(bigplot(4)/8) bigplot(3)/3 bigplot(4)/6])
        box on
        %plot(substrate{i},0,'-',substrate{i},mmfitresult{i}.Rnorm,'rp');
        ylabel('Error (%)');
        xlabel('[DHF] (\muM)');
        xlim([0 maxDHF]);
        ylim([-100 100]);

    end

end
