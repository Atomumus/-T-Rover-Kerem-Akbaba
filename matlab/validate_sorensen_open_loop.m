% VALIDATE_SORENSEN_OPEN_LOOP
% Student 3 deliverable: open-loop fasting steady-state validation.
%
% What this script proves:
%   1. No PID/controller is connected.
%   2. No external insulin is given.
%   3. No meal or glucose disturbance is given.
%   4. Starting from the basal fasting state, the ODE derivative is near
%      zero and the simulated trajectory stays flat.

clear; clc; close all;

script_dir = fileparts(mfilename('fullpath'));
repo_dir = fileparts(script_dir);
results_dir = fullfile(repo_dir, 'results');
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

addpath(script_dir);

fprintf('============================================================\n');
fprintf(' Sorensen Open-Loop Fasting Steady-State Validation\n');
fprintf(' Student 3: ode45, no PID, no meal, no external insulin\n');
fprintf('============================================================\n\n');

p = sorensen_parameters();
[y0, state_names, units] = sorensen_initial_conditions(p);

t_span = [0 300];      % 5 hours, minutes
u_ins = 0;             % open loop: no external insulin
meal_input = 0;        % fasting: no oral glucose input

opts = odeset( ...
    'RelTol', 1e-7, ...
    'AbsTol', 1e-9, ...
    'MaxStep', 1.0, ...
    'NonNegative', 1:numel(y0));

initial_derivative = sorensen_odes(0, y0, p, u_ins, meal_input);
max_abs_derivative = max(abs(initial_derivative));
max_scaled_derivative = max(abs(initial_derivative) ./ max(abs(y0), 1));

fprintf('Initial derivative check at basal fasting state:\n');
fprintf('  max(abs(dy/dt))              = %.6e\n', max_abs_derivative);
fprintf('  max(abs(dy/dt)/max(|y0|,1))  = %.6e\n\n', max_scaled_derivative);

fprintf('Running ode45 for %.0f minutes...\n', t_span(2));
[t_sol, y_sol] = ode45(@(t, y) sorensen_odes(t, y, p, u_ins, meal_input), ...
    t_span, y0, opts);
fprintf('ode45 completed with %d time points.\n\n', numel(t_sol));

final_values = y_sol(end, :)';
abs_delta = abs(final_values - y0);
pct_delta = 100 * abs_delta ./ max(abs(y0), eps);
max_abs_deviation = max(abs(bsxfun(@minus, y_sol, y0')), [], 1)';
max_pct_deviation = 100 * max_abs_deviation ./ max(abs(y0), eps);

summary_table = table( ...
    state_names, units, y0, final_values, abs_delta, pct_delta, ...
    max_abs_deviation, max_pct_deviation, ...
    'VariableNames', {'State', 'Unit', 'Initial', 'Final', ...
    'AbsDeltaFinal', 'PctDeltaFinal', 'MaxAbsDeviation', 'MaxPctDeviation'});

disp('Open-loop fasting validation table:');
disp(summary_table);

main_idx = [3 10 16];
main_names = {'GH blood glucose', 'IH plasma insulin', 'Gamma glucagon'};
main_final_pct = pct_delta(main_idx);
main_max_pct = max_pct_deviation(main_idx);

fprintf('\nMain clinical outputs:\n');
for k = 1:numel(main_idx)
    idx = main_idx(k);
    fprintf('  %-18s initial=%10.4f %-5s final=%10.4f %-5s final_error=%9.4g%%%% max_error=%9.4g%%%%\n', ...
        main_names{k}, y0(idx), units{idx}, final_values(idx), units{idx}, ...
        main_final_pct(k), main_max_pct(k));
end

final_pct_tol = 1.0;       % percent, report-level criterion
max_pct_tol = 1.0;         % percent, report-level criterion
scaled_derivative_tol = 1e-6;

passed = max(main_final_pct) <= final_pct_tol ...
    && max(main_max_pct) <= max_pct_tol ...
    && max_scaled_derivative <= scaled_derivative_tol;

fprintf('\nAcceptance criteria:\n');
fprintf('  Main final percent error <= %.2f%%%%\n', final_pct_tol);
fprintf('  Main max percent deviation <= %.2f%%%%\n', max_pct_tol);
fprintf('  Scaled initial derivative <= %.1e\n', scaled_derivative_tol);

if passed
    fprintf('\nRESULT: PASS - fasting open-loop model remains at steady state.\n');
else
    fprintf('\nRESULT: CHECK NEEDED - model moved away from basal steady state.\n');
end

csv_file = fullfile(results_dir, 'student3_open_loop_summary.csv');
mat_file = fullfile(results_dir, 'student3_open_loop_results.mat');
plot_file = fullfile(results_dir, 'student3_open_loop_validation.png');

writetable(summary_table, csv_file);
validation_results = struct();
validation_results.t = t_sol;
validation_results.y = y_sol;
validation_results.y0 = y0;
validation_results.state_names = state_names;
validation_results.units = units;
validation_results.summary_table = summary_table;
validation_results.initial_derivative = initial_derivative;
validation_results.max_abs_derivative = max_abs_derivative;
validation_results.max_scaled_derivative = max_scaled_derivative;
validation_results.passed = passed;
validation_results.criteria.final_pct_tol = final_pct_tol;
validation_results.criteria.max_pct_tol = max_pct_tol;
validation_results.criteria.scaled_derivative_tol = scaled_derivative_tol;
save(mat_file, 'validation_results');

fig = figure('Name', 'Student 3 Open-Loop Validation', ...
    'NumberTitle', 'off', 'Color', 'w', 'Position', [100 100 1100 700]);

subplot(2, 2, 1);
plot(t_sol, y_sol(:, 3), 'b-', 'LineWidth', 2.0); hold on;
line(t_span, [p.GH0 p.GH0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.2);
line(t_span, [70 70], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.0);
line(t_span, [120 120], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1.0);
xlabel('Time [min]');
ylabel('GH [mg/dL]');
title('Blood glucose stays at basal value');
legend({'GH', 'Basal GH', '70 mg/dL', '120 mg/dL'}, 'Location', 'best');
grid on;

subplot(2, 2, 2);
plot(t_sol, y_sol(:, 10), 'r-', 'LineWidth', 2.0); hold on;
line(t_span, [p.IH0 p.IH0], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.2);
xlabel('Time [min]');
ylabel('IH [mU/L]');
title('Plasma insulin stays at basal value');
legend({'IH', 'Basal IH'}, 'Location', 'best');
grid on;

subplot(2, 2, 3);
plot(t_sol, y_sol(:, 16), 'k-', 'LineWidth', 2.0); hold on;
line(t_span, [p.Gamma0 p.Gamma0], 'Color', [0.4 0.4 0.4], ...
    'LineStyle', '--', 'LineWidth', 1.2);
xlabel('Time [min]');
ylabel('Gamma [pg/mL]');
title('Glucagon stays at basal value');
legend({'Gamma', 'Basal Gamma'}, 'Location', 'best');
grid on;

subplot(2, 2, 4);
plot(t_sol, y_sol(:, 1:8), 'LineWidth', 1.1);
xlabel('Time [min]');
ylabel('Glucose states [mg/dL]');
title('All glucose compartments');
legend(state_names(1:8), 'Location', 'best');
grid on;

if exist('sgtitle', 'file') || exist('sgtitle', 'builtin')
    sgtitle('Sorensen model: open-loop fasting steady-state test');
end
saveas(fig, plot_file);

fprintf('\nSaved outputs:\n');
fprintf('  %s\n', csv_file);
fprintf('  %s\n', mat_file);
fprintf('  %s\n', plot_file);
