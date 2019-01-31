function [result]= mmfitter(substrate,vo,protconc)
        result=struct();
        model=@(c,x) c(1)*substrate./(c(2)+substrate);
        initialguess=[.1 .1];
        [beta,R,J,CovB,MSE] = nlinfit(substrate,vo,model, initialguess);%,opts);
        % 95% CI of coefficients
        betaci = nlparci(beta,R,J);
        x=substrate;
        f=beta(1).*x./(beta(2)+x);

        Rnorm=R./f';
        data2Include=[];
        stdRnorm=std(Rnorm);
        for i=1:size(Rnorm,1)
            if Rnorm(i)<3*stdRnorm
                data2Include=[data2Include i];
            end
        end

        % Compute the r^2 value
        ssresnonlin=nansum(R.^2);
        sstotnonlin=nansum((vo-nanmean(vo)).^2);
        rsqrnonlin=1-(ssresnonlin/sstotnonlin);

        result.Vmax=beta(1);
        result.Km=beta(2);
        result.Kcat=result.Vmax*1E3/protconc;
        result.KcatKm=result.Kcat/result.Km;
        result.rsqr=rsqrnonlin;
        result.Rnorm=Rnorm*100;

end