function [range]=ExtrapolateInitialDataPts(~,trODs,dhf0,exCoeff)
    % Data extrapolated for first values to avoid mixing errors
    
    legd={};
    for i=1:size(trODs,2)
        fit0{i}=robustfit(5:20,trODs{i}(5:20));
        fitted{i}=fit0{i}(2)*[0:20]+fit0{i}(1);

        plot([1:size(trODs{i})],trODs{i},'o');
        hold on
        plot(0:20,fitted{i},'-r');
        xlabel('time (sec)');
        ylabel('\DeltaOD_{340}');
        grid on
        title('OD vs time');
        range{i}=fitted{i}(1);  %this is extrapolated initial OD reading  
        hold on
        legd={legd{:} ['DHF: ' num2str(dhf0(i))] ['Extrapolation Fit DHF: ' num2str(fitted{i}(1)*exCoeff(1)+exCoeff(2))]};
    end
    hold on
    colormap jet
    legend(legd);
end