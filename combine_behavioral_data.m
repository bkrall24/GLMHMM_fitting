
function [animal, training] = combine_behavioral_data(path, get_training)

    % Rebecca Krall 12/1/22
    
    % Function designed to combine multiple aspects of behavioral data into
    % one structure. First version designed to just add latency with the
    % option to also return the training data for each animal. Future
    % functionality could be designed to add the pupil data or other lick
    % raster data.
    
    % Inputs:
    %   path: pathfile to the folder containing a single
    %   animal/experiment's data
    %   get_training: boolean to determine if training struct will be
    %   returned
    
    % Outputs:
    %   animal: animal struct (analyze_animal) with added field of
    %   'earlyRxn' which returns the time of the first lick following sound
    %   onset
    %   training: training struct (analyze_training)

    animal = analyze_animal(path);
    ttl2 = analyze_trial_info(true, path);
    [~, rxnTime] = rescore_animal(ttl2,750:1750);

    animal.earlyRxn = rxnTime;
    
    if get_training
        training = analyze_training(animal);
    end
end

