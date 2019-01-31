function [exCoeff]=MakeCalibrationCurve(h,concs,ODs)
    datamaxs=[0];
    datamins=[0];
    concs=[0 concs];
    for i=1:size(ODs,2)
        datamaxs=[datamaxs ODs{i}(1)];
        datamins=[datamins mean(ODs{i}(end-20:end))];
    end
    %calibration curve to get extinction coeefficient for NADPH and DHF in the presence of dhfr
    %activity
    % Theoretical Values of Extinction Coefficients at A340
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Edhf=7780 1/M;
    % Enadph=6200 1/M; 
    % Etotal=Edhf+Enadph;
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        range=1:length(concs);
        drange=datamaxs-datamins;% total OD340 change after the reaction is completed
        rangefits=robustfit(drange(range),concs(range));%fitting a line to get a calibration curve
        rangefitted=drange(range)*rangefits(2)+rangefits(1);
        
        plot(drange(range),concs(range),'ok')
        hold on
        plot(drange(range),rangefitted,'r');
        textbp(['[DHF] =' num2str(round(rangefits(2),2)) 'x OD_{340} +' num2str(round(rangefits(1),3)) ])
        ylabel('theoretical [DHF] \muM')
        xlabel('\DeltaOD_{340}')
        grid on
        title('Calibration curve for converting OD_{340} into DHF concentration')
        button1=uicontrol('Style', 'pushbutton', 'String', 'Use This Value',...
            'Position', [90 330 100 20],'Callback',@UseThisValue);
        button2=uicontrol('Style', 'pushbutton', 'String', 'Use Default Value',...
            'Position', [90 360 100 20],'Callback',@UseDefaultValue);
        uiwait()
    catch
        disp('No Calibration Curve!! CoEFF:115.58 \mu^{-1}cm^{-1}')
        exCoeff=[114.94 0];
    end
    
    function UseThisValue(hObject,callback)
        exCoeff=[rangefits(2),rangefits(1)];%unit=1/muM
        uiresume()
    end  
    function UseDefaultValue(hObject,callback)
        exCoeff=[114.94 0];
        uiresume()
    end
    try
        close(h)
    catch
    end
end