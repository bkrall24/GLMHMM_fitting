function pa = determine_predictive_accuracy(y, x, gammas, model)

    for i = 1:length(y)

        [state_prob,state] = (max(gammas(:,i)));
        
        p(i) = 1./(1+exp(-model.w(:,state)'*x(i,:)'));
        pp(i) = p(i) * state_prob;

    end

    pa = sum(((y == 1).*(pp > 0.5)) + ((y == 0) .*(pp <= 0.5)))/ length(y);
end