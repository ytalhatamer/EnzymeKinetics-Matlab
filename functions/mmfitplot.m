function [Vmax,Km,rsqrnonlin,Rnorm]=mmfitplot(fits,subs,flag)
    [a,b]=unique(subs);
    substrate=zeros(1,size(b,1));
    vo=zeros(1,size(b,1));
    Rnorm=zeros(1,size(b,1));
    bb=[b', size(subs,2)+1];
    % Plot Variables
    if mod(size(b,1),2)==1
        halfb=(size(b,1)+1)/2;
    else
        halfb=size(b,1)/2;
    end
    if mod(halfb,2)==1
        quartb=(halfb+1)/2;
    else
        quartb=halfb/2;
    end
    mmplot=[];
    resplot=[];
    for i=2*halfb+1:4*halfb
        if mod(i-1,halfb)>quartb
            resplot=[resplot i];
        else
            mmplot=[mmplot i];
        end
    end
    % Assign the data vectors
    for m=2:size(bb,2)
        vo(m-1)=abs(mean(fits(bb(m-1):bb(m)-1)));
        vostd(m-1)=std(fits(bb(m-1):bb(m)-1));
    end
    substrate=a;
    
    % Plot the raw data to get a look at the shape
%     plot(substrate,vo,'o')
%     xlabel('Substrate Concentration (mM)','FontSize',14)
%     ylabel('Initial rate (mM/s)','FontSize',14)
%     title('Initial Rate vs. Concentration','FontSize',16)
%     %print -depsc rawdataplot

    % Calculate unknown coefficients in the model using nlinfit
    model=@(b,x) b(1).*substrate./(b(2)+substrate);
    initialguess=[1 1];
    [beta,R,J,CovB,MSE] = nlinfit(substrate,vo,model, initialguess);
    % 95% CI of coefficients
    betaci = nlparci(beta,R,J);
    if flag==1
        % Plot the nonlinear fit with the raw data

        subplot(4,halfb,mmplot)
        plot(substrate,vo,'o')
        hold on
        x=substrate;
        f=beta(1).*x./(beta(2)+x);
        plot(x,f,'-')
        xlabel('Substrate Concentration (\muM)','FontSize',14)
        ylabel('Initial rate (nM/s)','FontSize',14)
        title('Initial Rate vs. Concentration','FontSize',16)
        %legend('Data Points','Nonlinear Fit','Location','SouthEast')
        xlim([0 max(subs)])
        
        print -depsc rawdatawithfit
        for i=1:size(b,1)
            Rnorm(i)=R(i)/f(i);
        end
        Rnorm,R,f
    % Make a residual plot
        hold on
        subplot(4,halfb,resplot)
        plot(x,0,'-',substrate,Rnorm*100,'rp')
        xlabel('Substrate Concentration (\muM)','FontSize',14)
        ylabel('Residuals','FontSize',14)
        title('Residual Plot','FontSize',16)
        %print -depsc nonlinresiduals
    end
    % Compute the r^2 value
  
    ssresnonlin=nansum(R.^2);
    sstotnonlin=nansum((vo-nanmean(vo)).^2);
    rsqrnonlin=1-(ssresnonlin/sstotnonlin);
    hold on
    if flag==1
        subplot(4,halfb,mmplot)
        textbp({['Km= ' num2str(beta(2))];['Vmax= ' num2str(beta(1))];['Rsq=' num2str(rsqrnonlin)]});
    end
    Vmax=beta(1);
    Km=beta(2);
end