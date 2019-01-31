function [Vmax,Km,rsqrnonlin,Rnorm,Kcat,KcatKm,dataInc]=mmfitplotnew(fits,subs,protconc,dhf0,flag,gca1,gca2 ,gcat)
%    set(gca1,'XTick',[])
%    set(gca2,'XTick',[])
%    set(gcat,'XTick',[])
    %[a,b]=unique(subs);
    substrate=subs;
    %vo=zeros(1,size(b,1));
    %Rnorm=zeros(1,size(subs,1));
    Rnorm=zeros(1,size(subs,1));
   % bb=[b', size(subs,2)+1];
   protconc
    % Assign the data vectors
    vo=fits;
    %substrate;
    
    % Plot the raw data to get a look at the shape
%     plot(substrate,vo,'o')
%     xlabel('Substrate Concentration (mM)','FontSize',14)
%     ylabel('Initial rate (mM/s)','FontSize',14)
%     title('Initial Rate vs. Concentration','FontSize',16)
%     %print -depsc rawdataplot

    % Calculate unknown coefficients in the model using nlinfit
%     model=@(b,x1,x2) vmax.*substrate./(b(1)+substrate);
%     initialguess=[.5];
% %     opts = statset('nlinfit');
% %     opts.RobustWgtFun = 'andrews';
%     [beta,R,J,CovB,MSE] = nlinfit([substrate,vmax],vo,model, initialguess);%,opts);
%     % 95% CI of coefficients
%     betaci = nlparci(beta,R,J);
%     
    model=@(c,x) c(1)*substrate./(c(2)+substrate);
    initialguess=[.1 .1];
    [beta,R,J,CovB,MSE] = nlinfit(substrate,vo,model, initialguess);%,opts);
    % 95% CI of coefficients
    betaci = nlparci(beta,R,J);
    x=substrate;
    %f=vmax.*x./(beta(1)+x);
    f=beta(1).*x./(beta(2)+x);
   
   % Rnorm=R./f';
    Rnorm=R./f';
    %end
    dataInc=[];
%     stdRnorm=std(Rnorm);
    stdRnorm=std(Rnorm);
    for i=1:size(Rnorm,1)
        if Rnorm(i)<3*stdRnorm
            dataInc=[dataInc i];
        end
    end
    
    % Compute the r^2 value

%     ssresnonlin=nansum(R.^2);
%     sstotnonlin=nansum((vo-nanmean(vo)).^2);
%     rsqrnonlin=1-(ssresnonlin/sstotnonlin);
    
    ssresnonlin=nansum(R.^2);
    sstotnonlin=nansum((vo-nanmean(vo)).^2);
    rsqrnonlin=1-(ssresnonlin/sstotnonlin);
    
    Vmax=beta(1);
    Km=beta(2);
    Kcat=Vmax*1E3/protconc;
    KcatKm=Kcat/Km;

    if flag==1
        % Plot the nonlinear fit with the raw data
        subplot(gca1)
        %subplot(4,halfb,mmplot)
        plot(substrate,vo,'ok')
        hold on
        plot(x,f,'-b')
        xlabel('[DHF] (\muM)','FontSize',14)
        ylabel('V_{initial} (nM/s)','FontSize',14)
       %title({'Initial Rate vs. Concentration';['DHF: ' num2str(dhf0) '\muM']},'FontSize',14)
        title({['DHF_0: ' num2str(dhf0) '\muM']},'FontSize',14)
        %legend('Data Points','Nonlinear Fit','Location','SouthEast')
        xlim([0 15])
        ylim([0 max(max(vo),.2)])
        
        %print -depsc rawdatawithfit
        %for i=1:size(subs,1)
        
        %Rnorm,R,f
    % Make a residual plot
        hold on
        %subplot(4,halfb,resplot)
        subplot(gca2)
        plot(x,0,'-',substrate,Rnorm.*100,'rp')
        hold on
        plot(x,0,'-',substrate,Rnorm.*100,'bp')
        xlabel('[DHF] (\muM)','FontSize',14)
        ylabel('Residuals(%)','FontSize',14)
        title('Residual Plot','FontSize',16)
        %print -depsc nonlinresiduals
        ylim([-100 100])

        subplot(gcat)
        axis off
        text(-.50,.50,{['KmBlue= ' num2str(round(beta(2),3))];['VmaxBlue= ' num2str(round(beta(1),3))];...
            ['Rsq2Blue=' num2str(round(rsqrnonlin,3))];...
            ['KcatKm=' num2str(round(KcatKm,3))]},'FontSize',18);
 
   end
end