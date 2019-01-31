function []=plotthemall(results)
    
    for i=1:size(fieldnames(results),1)
        fields=fieldnames(results);

        h1=figure;
        OD2DHFConverter(h1,results.(fields{i}).trODs,results.(fields{i}).exCoeff,...
                        results.(fields{i}).excludelowdhf,results.(fields{i}).excludehighdhf,...
                        results.(fields{i}).numdatapts,results.(fields{i}).dhfconcsmm);
        

        h2=figure;
        mmplotter(h2,results.(fields{i}).DHF,results.(fields{i}).fitDHF,...
                    results.(fields{i}).fitPTs,results.(fields{i}).protconcsmm);
        hold on
        suptitle('[DHF] vs Velocity Plot');



        h3=figure('Name','Ki Fits');
       
        disp(['Fit Range for inhibition fits: '...
            num2str(results.(fields{i}).stts.range(1)) ':' num2str(results.(fields{i}).stts.range(end))]);
        hold on
        [sortedTMPconcs,indTMPconcs]=sort(results.(fields{i}).tmpconcs);
        for k=1:size(results.(fields{i}).tmpconcs,2)
            x=0:60;
            y=results.(fields{i}).DHF4Ki(:,k);
            plot(x,y,'-ok','MarkerFaceColor',[1-(find(results.(fields{i}).tmpconcs(i)==sortedTMPconcs,1,'first')/size(results.(fields{i}).tmpconcs,2)),0,0]);
            hold on

        end
                
        kirobustfitter(h3,results.(fields{i}).DHF4Ki);
        hold on
        xlabel('Time (sec)','FontSize',14)
        ylabel('[DHF] (\muM)','FontSize',14)
        grid on
        title('Decrease in Initial DHFR Activity with Increasing [TMP]')

        
        range=0:.01:(size(results.(fields{i}).kifitted,2)-1)/100;
        h4=figure;
        title('Inhibition of DHFR with increasing [TMP]');
        hold on
        plot(results.(fields{i}).tmpconcfits(:,1),results.(fields{i}).tmpconcfits(:,2)*1000,'ok',...
            range,results.(fields{i}).kifitted*1000,'r');
        hold on
        xlabel('[TMP] (nM)')
        ylabel('V_0(nM/sec)')
        set(gca,'XScale','log')
        grid on
         textbp({['Vmax: ' num2str(round(1E3*results.(fields{i}).kifitresults.Vmax,2)) ' nM/sec'];...
            ['K_i: ' num2str(round(results.(fields{i}).kifitresults.Ki,2)) ' nM'];...
            ['K_m: ' num2str(round(results.(fields{i}).UsedKm,2)) ' \muM'];...
            ['R^2: ' num2str(round(results.(fields{i}).kifitresults.rsqr,2))];...
            ['IC_{50}: ' num2str(round(results.(fields{i}).kifitresults.IC50,2)) ' nM'];...
            ['[DHFR] : ' num2str(round(mode(results.(fields{i}).protconcsmm(1)),2)) ' nM'];...
            ['Normalized K_i : ' num2str(round((mode(results.(fields{i}).protconcsmm(1))/results.(fields{i}).kifitresults.Ki),2))];...
            ['Normalized IC_{50} : ' num2str(round((mode(results.(fields{i}).protconcsmm(1))/results.(fields{i}).kifitresults.IC50),2))]},'FontSize',15)
        hold on
        plot(results.(fields{i}).kifitresults.IC50,((results.(fields{i}).kifitresults.Vmax*mode(results.(fields{i}).dhfconcsinh))/...
            ((results.(fields{i}).UsedKm*(1+results.(fields{i}).kifitresults.IC50/results.(fields{i}).kifitresults.Ki))...
            +mode(results.(fields{i}).dhfconcsinh)))*1000,'ok','MarkerFaceColor','r');
        
        
    end
    
end