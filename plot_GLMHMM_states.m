function plot_GLMHMM_states(animal, gammas_fit)
  
    figure
    for state = 1:size(gammas_fit,1)
        subplot(1,size(gammas_fit,1), state)
        state_trials = gammas_fit(state,:) > 0.6;
        LED = animal.LED;
  
        try
            [xAxis, yData, errorbars] = generate_psych_data(animal.lick(:, state_trials & ~LED), animal.stimulus(state_trials & ~LED),  ~mode(animal.target(animal.stimulus == 32)));
            psy = fit_psychometric_curve(xAxis, yData, false, 'k');
            plot_single_psychometric_curve(psy, 'k', errorbars)

            [xAxis, yData, errorbars] = generate_psych_data(animal.lick(:, state_trials & LED), animal.stimulus(state_trials & LED),  ~mode(animal.target(animal.stimulus == 32)));
            psy = fit_psychometric_curve(xAxis, yData, false, 'b');
            plot_single_psychometric_curve(psy, 'b', errorbars)        
        catch
            warning(strcat("Could not generate psy curve for state: ",num2str(state)))
        end
        title(strcat("State ", num2str(state)))
    end
    
    % performance & bias with and without LED
    for state = 1:size(gammas_fit,1)
        state_trials = gammas_fit(state,:) > 0.6;
        LED = animal.LED;
        
        bias(state,1) = calculate_bias(animal.lick(:, state_trials & ~LED),  ~mode(animal.target(animal.stimulus == 32)),0, 'fdjskf');
        bias(state,2) = calculate_bias(animal.lick(:, state_trials & LED),  ~mode(animal.target(animal.stimulus == 32)), 0 , 'fjhdkslf');        
        
        perf(state,1) = calculate_percentages((animal.lick(:, state_trials & ~LED)), (animal.stimulus(state_trials & ~LED)), "fffe", 'Hits');        
        perf(state,2) = calculate_percentages((animal.lick(:, state_trials & LED)), (animal.stimulus(state_trials & LED)), "fefe", 'Hits');
        
    end
    
    figure
    bar(bias)
    xticks(1:size(gammas_fit,1))
    xlabel('States')
    title('Bias')
    legend({'LED off', 'LED on'}, 'Location', 'southwest')
    
    figure
    bar(perf)
    xticks(1:size(gammas_fit,1))
    xlabel('States')
    title('Accuracy')
    legend({'LED off', 'LED on'},  'Location', 'southwest')
    
     for state = 1:size(gammas_fit,1)
        for ses = (unique(animal.sessionNum))
            state_trials = (gammas_fit(state,:) > 0.6) & animal.sessionNum == ses;
            LED = animal.LED;
            led_on = animal.lick(:, state_trials & LED);
            led_off = animal.lick(:,state_trials & ~LED);
            high_side = ~mode(animal.target(animal.stimulus == 32));
            
            try
                bias_s(state,ses,1) = calculate_bias(led_off, high_side, 0, 'fjfdksj');
                
            catch
                bias_s(state,ses,1) = nan;
                
            end
            
            try
                bias_s(state,ses,2) = calculate_bias(led_on, high_side,0, 'fjfdksj');
               
            catch
                bias_s(state,ses,2) = nan;
               
            end
        end
     end
     
     figure
     plotDataPointsError(squeeze(bias_s(:,:,1))', 1:size(gammas_fit,1),[0 0 0], false, true)
     hold on
     plotDataPointsError(squeeze(bias_s(:,:,2))', 1.25:size(gammas_fit,1)+.25,[0 0 1], false, true)
     xticks(1:size(gammas_fit,1))
     xlabel('States')
     title('Bias by Session')
    
    % number of state transititions
    [confidence, state_id] = max(gammas_fit);
    transitions = [diff(state_id) ~= 0,0];
    
    transitions_sessions = splitapply(@(x) sum(x), transitions, findgroups(animal.sessionNum));
    confidence_session = splitapply(@(x) mean(x), confidence, findgroups(animal.sessionNum));
    figure
    subplot(1,2,1)
    plotDataPointsError(transitions_sessions')
    title('State Transititions Per Session')
    subplot(1,2,2)
    plotDataPointsError(confidence_session')
    title('Average Confidence Per Session')
    
    
    % % of time spent in each state
    figure
    subplot(1,2,1)
    time_state = (histcounts(state_id)./length(state_id))*100;
    bar(time_state)
    ylabel("Percent Trials")
    xlabel("States")
    xticks(1:size(gammas_fit,1))
    
    % confidence of each state (i.e. average p(state), when p(state) ==
    % max(states)
    try
    subplot(1,2,2)
    state_conf = splitapply(@(x) {[x]}, confidence, state_id);
    hold on
    
    cellfun(@(x) histogram(x, 0:0.05:1, 'Normalization','probability'), state_conf)
    legend(arrayfun(@num2str, 1:size(gammas_fit,1), 'UniformOutput', false), 'Location', 'southwest')
    ylabel("Percent Confidence")
    xlabel("States")
    xticks(1:size(gammas_fit,1));
    end
    
    % attempt to pull out each 'session' of a state
%     state_sessions = state_id(logical(transitions));
%     state_starts = find(transitions);
%     
%     st = 1;
%     for i = 1:length(state_starts)
%         choose = zeros(1, size(gammas_fit,2));
%         choose(st:state_starts(i)) = 1;
%         st = state_starts(i)+1;
%         try
%             [xAxis, yData, errorbars] = generate_psych_data(animal.lick(:, choose & ~LED), animal.stimulus(choose & ~LED),  ~mode(animal.target(animal.stimulus == 32)));
%             psy = fit_psychometric_curve(xAxis, yData, false, 'k');
%             subplot(1, size(gammas_fit,1), state_sessions(i))
%             
%             hold on
%             plot_single_psychometric_curve(psy, [0 0 0 0.5])
% 
%             [xAxis, yData, errorbars] = generate_psych_data(animal.lick(:, choose & LED), animal.stimulus(choose & LED),  ~mode(animal.target(animal.stimulus == 32)));
%             psy = fit_psychometric_curve(xAxis, yData, false, 'b');
%             subplot(1, size(gammas_fit,1), state_sessions(i))
%             hold on
%             plot_single_psychometric_curve(psy, [0 0 1 0.5])        
%         catch
%             warning(strcat("Could not generate psy curve for state: ",num2str(state)))
%         end
%         
%     end
    
    if any(contains(fieldnames(animal), 'pupil'))
%         m= splitapply(@mean, animal.pupil, state_id);
%         e = splitapply(@(x)sem(x'), animal.pupil, state_id);
        pupil = animal.pupil./max(animal.pupil);
        figure
        hold on
        splitapply(@(x) histogram(x,0:0.025:1,'Normalization','probability'), pupil, state_id)
        legend(arrayfun(@num2str, 1:size(gammas_fit,1), 'UniformOutput', false), 'Location', 'northwest')
        
    end
        
  
end
