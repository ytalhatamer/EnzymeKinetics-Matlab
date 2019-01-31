function [DHF,fitDHF,fitPTs]=OD2DHFConverter(~,trODs,exCoeff,excludelowdhf,excludehighdhf,numdatapts,dhf0)
    warning off
    % Convert OD340 to [DHF] using exCoeff and Plot the change of DHF over time
    for i=1:size(trODs,2)
        % Line below is for conversion of OD340 --> [DHF]
        DHF{i}=trODs{i}(:)*exCoeff(1)+exCoeff(2);

        % For loop below is to find the position of the last fit.
        enddhf{i}=size(DHF{i},1);
        for m=1:size(DHF{i},1)
            if DHF{i}(m)<=excludelowdhf
                enddhf{i}=m;
                break
            end
        end
        startdhf{i}=1;
%         try
        [~,tmp]=min(abs(DHF{i}-excludehighdhf));
        startdhf{i}=tmp;
%         catch
%             disp('Highest starting DHF concentration is bigger than the concentration of the Sample')
%             disp([num2str(excludehighdhf) '>' num2str(dhf0{i})])
%         end
%         
        if i==1
            maxtime=size(trODs{i},1);
            maxDHF=max(DHF{i});
        else
            if size(trODs{i},1)>maxtime
                maxtime=size(trODs{i},1);
            end
            if max(DHF{i})>maxDHF
                maxDHF=max(DHF{i});
            end
        end
    end

    

    hold on

    % In the plot drawn from next couple of lines shows whole DHF change over
    % time in black. Effective data that is from starting conditions to the
    % [DHF]<Lower Limit is show as blue 
    % and Redline shows the linear fits for conversion of OD to DHF
    for i=1:size(trODs,2)
        if size(trODs,2)<2
        else
            subplot(2,ceil(0.5*size(trODs,2)),i);
        end
        plot(1:size(DHF{i},1),DHF{i},'-ok');
        hold on
        plot([startdhf{i}:enddhf{i}],DHF{i}(startdhf{i}:enddhf{i}),'-bp');
        xlim([0 maxtime]);
        ylim([0 maxDHF]);
        xlabel('Time (sec)');
        ylabel('[DHF] \muM');
        count=1;
        fitlen=max(4,ceil((enddhf{i}-startdhf{i})/numdatapts));
        disp(['Robust Fit Lengths for this Analysis: ' num2str(fitlen) 'sec']);
        hold on
        for j=startdhf{i}:fitlen:enddhf{i}-fitlen
            [fitDHF{i}(:,count)]=robustfitter((j:j+fitlen),DHF{i}(j:j+fitlen),1);
            fitPTs{i}(count)=DHF{i}(j+fix(fitlen/2));
            count=count+1;
        end
        
        title({'Change in [DHF] over Time',['[DHF]_0= ' num2str(dhf0(i)) '\muM']})
        
    end
    hold on
    grid on
    %suptitle('DHF Concentration changes over Time');
end
    