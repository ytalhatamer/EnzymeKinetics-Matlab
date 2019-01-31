function [result]= mmfitterki(substrate,vo,tmp,km)
      
    result=struct();
    
    model=@(c,x) (c(1)*substrate)./((km.*(1+tmp./c(2)))+substrate);
    initialguess=[.01 .01 ];
    [beta,R,~,~,~] = nlinfit(tmp,vo,model, initialguess); 
    % 95% CI of coefficients
    %betaci = nlparci(beta,R,J);
    
    % Compute the r^2 value

    ssresnonlin=nansum(R.^2);
    sstotnonlin=nansum((vo-nanmean(vo)).^2);
    rsqrnonlin=1-(ssresnonlin/sstotnonlin);
    
    % Send Results back to main script as result structure

    result.Vmax=beta(1);
    result.Ki=beta(2);
    result.IC50=beta(2)*(substrate/km-1);
    result.IC75=beta(2)*(3*substrate/km-1);
    result.rsqr=rsqrnonlin;
    
end