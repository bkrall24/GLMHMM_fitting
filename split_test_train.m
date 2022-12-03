function [all_indices, session_length] = split_test_train(sessions, crossv)
    
    % Rebecca Krall 12/1/22
    
    % Function designed to generate test train splits for cross validation
    % techniques. Takes n trials split into sessions and samples from each
    % session without replacement. Results in (crossv)X(~n/crossv) matrix
    % containing indices for each cross validation test group in a row.
    % Should equally sample each session allowing for stratified test
    % groups reflective of changes across sessions. 
    
    % Inputs:
    %   sessions: n x 1 array of integers indicating the session id for
    %   each trial
    %   crossv: number of cross validation groups, will default to 5 if not
    %   passed
    
    % Outputs:
    %   all_indices: (crossv)X(~n/crossv) matrix of indices for each test
    %   group
    %   session_length: 1 x max(sessions) array of length of each split per
    %   session to allow for generation of a boolean indicating new session
    
    
    all_indices = [];
    for i = 1:length(unique(sessions))
        set = [];
        indices = [];
        session_indices = [find(sessions == i, 1, 'first'):find(sessions == i, 1, 'last')];
        
        set(1,:) = sort(randsample(length(session_indices), floor(length(session_indices) *1/crossv)));
        indices(1,:) = session_indices(set(1,:));
        train_s = setdiff(1:length(session_indices), set(1,:));
        
        for j = 2:crossv-1
            set(j,:) = sort(randsample(train_s, floor(length(session_indices) *0.2)))';
            indices(j,:) = session_indices(set(j,:));
            train_s = setdiff(train_s, set(j,:));
            
        end
        
        set(crossv,:) = train_s(1:size(set,2))';
        indices(crossv,:) = session_indices(set(crossv,:));
        session_length(i) = size(set,2);
        
        all_indices = cat(2, all_indices, indices);
        
        
    end

end