function [model, ll_fit] =  get_GLMHMM(x, y, nstarts, nz, new_sess, all, verbose)

    % NOTE: want to add functionality to be able to input w0 and A0
    nx = size(x, 2);
    model_tmp = cell(1,nstarts);
    ll_tmp = nan(1,nstarts);
    
    for start_i = 1:nstarts
        if verbose
            fprintf(['start ',num2str(start_i),'\n']);
        end
        
        % initial weight matrix
        w0 = normrnd(0,1,nx,nz);
        
        % initial transition matrix
        rs = betarnd(20,2,1,nz);
        A0 = nan(nz);
        for zi = 1:nz
            A0(zi,:) = (1-rs(zi))/(nz-1);
            A0(zi,zi) = rs(zi);
        end
        
        % (optional) l2 penalty
        l2_penalty = true;
        
        % if set to "true", you'll need to provide an array "theta"
        % containing the standard deviations. you'll need one for each
        % feature in the design matrix
        theta = ones(1, size(x,2)) * 4; % we already know that we drew weights from a normal dist. with s.d. 1
        
        % fitting the model
        model_tmp{start_i} = fitGlmHmm(y,x',w0,A0,'new_sess',new_sess,'tol',1e-6,'l2_penalty',l2_penalty,'theta',theta);
        [~,~,ll_tmp(start_i)] = runBaumWelch(y,x',model_tmp{start_i},new_sess);
        
    end
    
    if all
        model = model_tmp;
        ll_fit = ll_tmp;
    else
        [~,best_fit] = max(ll_tmp);
        model = model_tmp{best_fit};
        ll_fit = ll_tmp(best_fit);
    end
   
    
end