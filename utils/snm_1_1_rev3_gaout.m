% output function: saves population + scores to .mat files every 50
% generations
function [state,options,optchanged] = snm_1_1_rev3_gaout(options,state,flag)
persistent history scores
optchanged = false;
switch flag
    case 'init'
        history(:,:,1) = state.Population;
        scores(:,:,1) = state.Score;
        assignin('base','gapopulationhistory',history);
        assignin('base','gapopulationscores',scores);
    case 'iter'
        % Update the history every 50 generations, and write to file
        fprintf('Completed Generation %d: Best Score = %.4f \n', ...
            state.Generation,state.Best(end))
        if rem(state.Generation,50) == 0
            fprintf('Saving Generation %d Data...\n',state.Generation)
            ss = size(history,3);
            history(:,:,ss+1) = state.Population;
            scores(:,:,ss+1) = state.Score;
            assignin('base','gapopulationscores',history);
            assignin('base','gapopulationscores',scores);
            filename = strcat('ga_history_gen',string(state.Generation),'.mat');
            save(filename,'history');
            filename = strcat('ga_scores_gen',string(state.Generation),'.mat');
            save(filename,'scores');
        end
    case 'done'
        % Include the final population in the history, and write to file
        ss = size(history,3);
        history(:,:,ss+1) = state.Population;
        scores(:,:,ss+1) = state.Score;
        assignin('base','gapopulationhistory',history);
        assignin('base','gapopulationscores',scores);
        filename = strcat('ga_history_genfinal.mat');
        save(filename,'history');
        filename = strcat('ga_scores_genfinal.mat');
        save(filename,'scores');
end