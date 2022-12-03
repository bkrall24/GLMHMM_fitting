function [x, x_names, y, sessions, choose] = get_GLMHMM_regressors(m, stim_type, regressor_choice)

    % PROBLEM, I have to account for the fact that some animals lick left
    % for high and some lick left for low. Easiest place would be to do
    % that here. 

    % Determine the choice of the animal, we'll choose 1 to represent a
    % lick towards the 'high' side. We'll also pull out 1 previous choice
    
    if mode(m.target(m.stimulus == 32))
        high_choice = (m.lick(1,:) |  m.lick(4,:));
    else
        high_choice = (m.lick(2,:) |  m.lick(3,:));
    end
    
    previous_choice = [0, high_choice(1:end-1)];
    previous_choice_2 = [0, previous_choice(1:end-1)];
    previous_choice_3 = [0, previous_choice_2(1:end-1)];
    
    % Pull out the LED 
    led = m.LED;
    previous_led = [0 led(1:end-1)];
    
    % Pull out if the previous trial was correct
    correct = (m.lick(1,:) | m.lick(2,:));
    previous_correct = [0 correct(1:end-1)];
    
    % Pull out the reaction time
    rxn = m.rxnTime;
    rxn(rxn == -1) = nan;
    rxn = rescale(rxn);
 
    % Pull out the no go trials
    nogo = m.lick(5,:);
    previous_nogo = [0, nogo(1:end-1)];
    
    % any historical regressors should be not done on the first trial of a
    % new session so set the first day of each session to 0
    sessions = m.sessionNum;
    session_change = diff(sessions);
    new_sess = logical([1 session_change(1:end)]);
    
    previous_choice(new_sess) = 0;
    previous_correct(new_sess) = 0;
    previous_led(new_sess) = 0;
    previous_nogo(new_sess) = 0;
    
    if any(contains(fieldnames(m), 'earlyRxn'))
        er = m.earlyRxn/1000;
        
    else
        er = (m.rxnTime-500)/1000;
        
    end
    ch = er > 0;
    
    
    
    bias = ones(1, length(led));
    go_trials = (m.lick(1,:) | m.lick(2,:) | m.lick(3,:) | m.lick(4,:));
    
    if any(contains(fieldnames(m), 'pupil'))
        pupil = rescale(m.pupil);
        pupil_trials = ~isnan(pupil);
        choose = go_trials & pupil_trials & ch;
        
        x_names = {'Bias', 'LED', 'Previous Choice', 'Previous Correct', ...
            'Previous LED', 'Previous No Go', 'Pupil', 'Reaction Time' ...
            'Previous Choice 2', 'Previous Choice 3','Latency'};
        
        x = [bias(choose)', led(choose)', previous_choice(choose)', ...
            previous_correct(choose)', previous_led(choose)'...
            previous_nogo(choose)', pupil(choose)', rxn(choose)'...
            previous_choice_2(choose)', previous_choice_3(choose)', er(choose)'];
    else
        choose = go_trials & ch;
        x_names = {'Bias', 'LED', 'Previous Choice', 'Previous Correct', ...
            'Previous LED', 'Previous No Go', 'Reaction Time'...
            'Previous Choice 2', 'Previous Choice 3', 'Latency'};
        
        x = [bias(choose)', led(choose)', previous_choice(choose)', ...
            previous_correct(choose)', previous_led(choose)'...
            previous_nogo(choose)', rxn(choose)'...
            previous_choice_2(choose)', previous_choice_3(choose)', er(choose)'];
        
    end
    

    
    if stim_type
        
        % Parameterize the stimulus between -1 and 1: negative values are low
        % frequency modulation and positive values are high 
        stimulus = log2(m.stimulus/8)/2;
        stimulus(isinf(stimulus)) = 0;
        
        high = stimulus;
        high(high < 0) = 0;
        low = stimulus;
        low(low > 0) = 0;
        low = abs(low);
        
        x_names = [x_names, {'Low', 'High'}];
        x = [x, low(choose)', high(choose)'];
        
        
    else
        
        % Alternatively we can parameterize the stimulus as two regressors, one
        % with a positive or negative indicating direction and the other the
        % absolute value of the stimulus indicating the distance from the
        % category boundary
        stimulus = log2(m.stimulus/8)/2;
        stimulus(isinf(stimulus)) = 0;
        %stimulus_direction = double(stimulus > 0) - double(stimulus < 0);
        %stimulus_magnitude = abs(stimulus);
        
        %category_boundary = m.stimulus == 8;
        
        x_names = [x_names, {'Stimulus'}];%, 'Boundary'}];
        x = [x, stimulus(choose)'];%, category_boundary(choose)'];
   
    end
    
    if length(regressor_choice) > 1
        x_names = x_names(regressor_choice);
        x = x(:, regressor_choice);
    elseif regressor_choice
        [indx,~] = listdlg('ListString',x_names);
        x_names = x_names(indx);
        x = x(:, indx);
    end
      
   
    y = high_choice(choose);
    sessions = sessions(choose)';
    
end