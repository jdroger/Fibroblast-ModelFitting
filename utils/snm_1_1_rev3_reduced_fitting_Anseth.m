% SNM Model Fitting: Genetic Algorithm
% 10.29.2019 JR
% edited 12.18.2019: changed scaling of input/output data
% edited 12.16.2019: using Anseth lab's input/output data for fitting (MSE)
% edited 12.05.2019: added binning method to fitness fcn, added method arg
% edited 11.04.2019: added reduced model fitness fcn, added output fcn
% edited 11.04.2019: increased population size/max generations for HPC
% edited 11.05.2019: changed upper bounds for input rxns (w(1:11))
% edited 11.17.2019: changed fitness fcn to reflect delta(Activity) errors,
%                    and changed normalization of expt_out


% Purpose: approximate reaction weights (w) for signaling network
% model (SNM) using genetic algorithm (ga)
% 
% This script sets up ga function by defining a fitness function and
% dependencies (stimulus doses, experimental data), as well as other
% settings for the solver (# of generations, upper/lower bounds for (w),
% parallelization for HPC, and population/fitness score output.
% 
% Required files:
% Fitness function: snm_1_1_rev3_reduced_fitness_Anseth.m
%                   -runs SNM for each (w) across 14 perturbations
%                   -calculates mean-squared error (MSE) of predictions
%                    compared to (normalized) experimental data
% Output function: snm_1_1_rev3_gaout.m
%                   -initializes arrays to store population (history) and
%                    MSE (scores)
%                   -saves every 10th population/MSE to arrays, and exports
%                    to .mat file

parpool
% rng('default')  %for reproducibility

% set fitness fcn inputs: stimulus doses, experimental perturbation data
exptin = 'trainingdata_inputs_Anseth_12192019.mat';
exptout = 'trainingdata_outputs_Anseth_12192019.mat';
method = 'MSE';
fitnessfcn = @(w) snm_1_1_rev3_reduced_fitness_Anseth(w,exptin,exptout,method);

% set other ga inputs: length of w, lower/upper bounds
n_vals = 158;
lb = zeros(1,n_vals);
ub = ones(1,n_vals);
% change upper bounds for inputs such that w + hd <= 1
% ub(1:11) = 0.25;

% set ga options: parallelization, max # of generations, population size,
% output function
options = optimoptions('ga','UseParallel', true, ...    
    'UseVectorized', false, ...
    'MaxGenerations', 200, ...
    'PopulationSize', 200, ...
    'OutputFcn', @snm_1_1_rev3_gaout);
%     'PlotFcn', 'gaplotbestf');

% run ga function
fprintf('<<<<<<<<<<<<< Starting Genetic Algrorithm >>>>>>>>>>>>>\n')
[x,fval,exitFlag,output,population,scores] = ga(fitnessfcn,n_vals,[],[],[],[],lb,ub,[],[],options);

fprintf('<<<<<<<<<<<<<<<<< Algrorithm Finished >>>>>>>>>>>>>>>>>\n')
fprintf('The number of generations was : %d\n', output.generations);
fprintf('The best function value found was : %g\n', fval);

delete(gcp)
