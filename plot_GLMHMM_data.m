function plot_GLMHMM_data(m, model, gammas_fit, x_names)
    
%  %   
    %[x, x_names, y, sessions] = get_GLMHMM_regressors(animal, false, 1);
    [x, x_names, y, sessions, choose] = get_GLMHMM_regressors(m, false,[1,2,3,4,5,10,11]);

    
    session_change = diff(sessions);
    new_sess = logical([1; session_change(1:end)])';
    [gammas_fit,xis,ll,ll_norm] = runBaumWelch(y,x',model,new_sess);
%     
%     
    figure
    plot(model.w(1:end,:), '-o')
    xticks(1:length(x_names))
    xticklabels(x_names)
    yline(0, ':')
    xtickangle(30)
    title('GLM Weights')


    figure
    colors = colororder;
    colors = [colors; colors];
    m2 = select_trials(m,choose);
    %m2 = m;
    for state = 1:size(gammas_fit,1)
        state_trials = gammas_fit(state, :) > 0.5;
        try
            [xAxis, yData, errorbars] = generate_psych_data(m2.lick(:, state_trials), m2.stimulus(state_trials), ~mode(m2.target(m2.stimulus == 32)));
            psy = fit_psychometric_curve(xAxis, yData, false, colors(state,:));
            plot_single_psychometric_curve(psy, colors(state,:), errorbars)
        catch
            warning(strcat("Could not generate psy curve for state: ",num2str(state)))
        end

        %plotPsychometricGen(psy, colors(state,:), 'w', true)
    end
    title('Psychometric Fit')


    figure
    [~, st] = max(gammas_fit);
    for state = 1:size(gammas_fit,1)
        state_trials = st == state;
        try
            
            [xAxis, yData, errorbars] = generate_psych_data(m2.lick(:, state_trials), m2.stimulus(state_trials), ~mode(m2.target(m2.stimulus == 32)));
            psy = fit_psychometric_curve(xAxis, yData, false, colors(state,:));
            plot_single_psychometric_curve(psy, colors(state,:), errorbars)
        catch
            warning(strcat("Could not generate psy curve for state: ",num2str(state)))
        end
    end


    figure  
    for state = 1:size(gammas_fit,1)
        subplot(1,size(gammas_fit,1), state)
        state_trials = gammas_fit(state,:) > 0.6;
        LED = m2.LED ;
        %LED = LED(~isnan(m2.pupil));
        
        try
            [xAxis, yData, errorbars] = generate_psych_data(m2.lick(:, state_trials & ~LED), m2.stimulus(state_trials & ~LED),  ~mode(m2.target(m2.stimulus == 32)));
            psy = fit_psychometric_curve(xAxis, yData, false, colors(state,:));
            plot_single_psychometric_curve(psy, colors(state,:), errorbars)

            [xAxis, yData, errorbars] = generate_psych_data(m2.lick(:, state_trials & LED), m2.stimulus(state_trials & LED),  ~mode(m2.target(m2.stimulus == 32)));
            psy = fit_psychometric_curve(xAxis, yData, false, colors(state+4,:));
            plot_single_psychometric_curve(psy, colors(state+4,:), errorbars)        
        catch
            warning(strcat("Could not generate psy curve for state: ",num2str(state)))
        end
        
        



    end
    
    %% what do I actually want to plot for a given animal? 
    % What is the performance, bias, and effect of LED on both those
    % measures in each state
    %
    % 
    
 
    for state = 1:size(gammas_fit,1)
        state_trials = gammas_fit(state,:) > 0.6;
        LED = m2.LED;
        %LED = LED(~isnan(m2.pupil));

        bias_off(state) = calculate_bias(m2.lick(:, state_trials & ~LED),  ~mode(m2.target(m2.stimulus == 32)), 0, 'fjdksfj');
        bias_on(state) = calculate_bias(m2.lick(:, state_trials & LED),  ~mode(m2.target(m2.stimulus == 32)), 0, 'fjdksfj');
      
        
        perf_off(state,:) = calculate_percentages((m2.lick(:, state_trials & ~LED)), (m2.stimulus(state_trials & ~LED)), "fffe", 'Hits');
        try
            perf_on(state) = calculate_percentages((m2.lick(:, state_trials & LED)), (m2.stimulus(state_trials & LED)), "fefe", 'Hits');
        catch
            perf_on(state) = nan;
        end
    end
    
    
    figure
    plot(perf_on)
    hold on
    plot(perf_off)
    
    
    figure
    plot(bias_on)
    hold on
    plot(bias_off)
end


