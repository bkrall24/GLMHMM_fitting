function [lbps, ll_test, ll_train, pa] = optimize_state_hyperparameter(all_indices, session_length, x, y, max_states)
    

    ll_train = nan(size(all_indices,1), max_states);
    ll_test = nan(size(all_indices,1), max_states);
    lpbs = nan(size(all_indices,1), max_states);
    pa = nan(size(all_indices,1), max_states);
    
    for i = 1:size(all_indices,1)
        
        x_test = x(all_indices(i,:),:);
        y_test = y(all_indices(i,:));
        new_sess_test = false(1,size(all_indices,2));
        new_sess_test([1,cumsum(session_length)+1]) = true;
        new_sess_test = new_sess_test(1:end-1);
        
        train_indices = all_indices(setdiff(1:size(all_indices,1), i),:);
        
        x_train = x(train_indices(:), :);
        y_train = y(train_indices(:));
        new_sess_train = false(1, length(x_train));
        new_sess_train([1,(cumsum(session_length)*4)+1]) = true;
        new_sess_train = new_sess_train(1:end-1);

        for k = 1:max_states
            disp(strcat("CV ", num2str(i), ", States: ", num2str(k)))

            [model, ll_train(i,k)] = get_GLMHMM(x_train, y_train, 20, k, (new_sess_train), false, false);
            [gammas,~,ll_test(i,k)] = runBaumWelch(y_test,x_test', model, logical(new_sess_test));
            T = length(y_test);
            if k > 1
                lknot = ll_test(i,1);
                lbps(i,k) = mean(session_length) * ((ll_test(i,k) - lknot)/(T * log(2)));
            end
            
            pa(i,k) = determine_predictive_accuracy(y_test, x_test, gammas, model);
        end


    end

end


