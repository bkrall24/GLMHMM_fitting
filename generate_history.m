function regressor = generate_history(r, num_previous, sessions)
    
    session_change = diff(sessions);
    new_sess = logical([1 session_change(1:end)]);

    regressor(:,1) = r;
    for i = 1:num_previous
        
        if i > length(r)
            error('Fewer trials than history requested')
        end
        regressor(:,i+1) = [0; regressor(1:end-1, i)];
        regressor(new_sess,i+1) = 0;
    end
    
    regressor = regressor(:,2:end);  
    
    
end