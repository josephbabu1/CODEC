% RUN_ALL_EXPERIMENTS.m
% Master script to reproduce all results from:
%   "Chaos-Driven Time-Varying Convolutional Coding for Physical Layer Security"
%
% Runtime estimate:
%   Experiment 1 (BER):    ~20-40 min (1000 errors, 0-10 dB)
%   Experiment 2 (Desync): ~10-20 min
%   Experiment 3 (Stats):  ~1 min
%   Experiment 4 (Tests):  ~5 min
%
% All figures saved to results/figures/
% All data  saved to results/data/

clear; clc; close all;

% Add MATLAB folder to path
addpath(fileparts(mfilename('fullpath')));

% Create output directories if needed
if ~exist('results/figures', 'dir'), mkdir('results/figures'); end
if ~exist('results/data',    'dir'), mkdir('results/data');    end

fprintf('========================================\n');
fprintf('  CODEC Paper: Reproducibility Suite\n');
fprintf('========================================\n\n');

%% ---- Global Parameters ----
CHAOS_SEED = 0.3001;
R_MAP      = 3.99;

%% ---- Experiment 1: BER Performance ----
fprintf('[1/4] Running BER comparison simulation...\n');
res_ber = ber_simulation( ...
    'EbN0',          0:1:10, ...
    'target_errors', 1000, ...
    'frame_len',     1000, ...
    'chaos_seed',    CHAOS_SEED, ...
    'r',             R_MAP, ...
    'save_results',  true);
save('results/data/exp1_ber.mat', 'res_ber');
fprintf('[1/4] DONE.\n\n');

%% ---- Experiment 2: Desynchronization Security Analysis ----
fprintf('[2/4] Running desynchronization analysis...\n');
desync_analysis( ...
    'EbN0_dB',    4, ...
    'n_bits',     2e5, ...
    'chaos_seed', CHAOS_SEED, ...
    'r',          R_MAP, ...
    'frame_len',  1000);
fprintf('[2/4] DONE.\n\n');

%% ---- Experiment 3: Chaos Statistical Properties ----
fprintf('[3/4] Running chaos statistical analysis...\n');
stats = chaos_statistical_analysis( ...
    'seed', CHAOS_SEED, ...
    'r',    R_MAP, ...
    'N',    1e6);
save('results/data/exp3_chaos_stats.mat', 'stats');
fprintf('[3/4] DONE.\n\n');

%% ---- Experiment 4: Polynomial Selection Bias Test ----
fprintf('[4/4] Running polynomial bias analysis across r values...\n');
r_values = [3.80, 3.90, 3.95, 3.99, 4.00];
entropy_vals = zeros(1, length(r_values));

for ri = 1:length(r_values)
    [~, sb] = chaos_gen(CHAOS_SEED, r_values(ri), 1e5);
    p = histc(sb, 0:3) / 1e5; %#ok<HISTC>
    p(p == 0) = eps;
    entropy_vals(ri) = -sum(p .* log2(p));
end

figure('Position', [100 100 600 400]);
plot(r_values, entropy_vals, 'ko-', 'LineWidth', 2, 'MarkerSize', 8);
hold on; yline(2, 'r--', 'Max entropy = 2 bits', 'LineWidth', 1.5);
xlabel('Logistic Map Parameter r', 'FontSize', 13);
ylabel('Entropy H(s_n) (bits)', 'FontSize', 13);
title('Selection Entropy vs. r Parameter', 'FontSize', 13);
grid on; set(gca, 'FontSize', 11);
saveas(gcf, 'results/figures/entropy_vs_r.png');

save('results/data/exp4_entropy.mat', 'r_values', 'entropy_vals');
fprintf('[4/4] DONE.\n\n');

fprintf('========================================\n');
fprintf('  All experiments complete.\n');
fprintf('  Figures: results/figures/\n');
fprintf('  Data:    results/data/\n');
fprintf('========================================\n');
