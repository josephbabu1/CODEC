function chaos_stats = chaos_statistical_analysis(varargin)
% CHAOS_STATISTICAL_ANALYSIS  Statistical characterization of the chaotic control sequence.
%
%   Performs: histogram uniformity, autocorrelation, Lyapunov exponent estimate,
%   polynomial selection balance, and sensitivity to initial conditions.
%
%   Usage: chaos_statistical_analysis()

    p = inputParser;
    addParameter(p, 'seed', 0.3001);
    addParameter(p, 'r',    3.99);
    addParameter(p, 'N',    1e5);
    parse(p, varargin{:});
    opt = p.Results;

    N = opt.N;
    fprintf('=== Chaos Statistical Analysis (N=%d) ===\n\n', N);

    [chaos_seq, sel_bits] = chaos_gen(opt.seed, opt.r, N);

    % --- 1. Polynomial selection histogram ---
    counts = histc(sel_bits, 0:3);   %#ok<HISTC>
    freqs  = counts / N;
    fprintf('Polynomial Selection Distribution:\n');
    labels = {'(133,171)', '(135,173)', '(151,177)', '(163,171)'};
    for k = 1:4
        fprintf('  s=%d [%s]: %.2f%%\n', k-1, labels{k}, freqs(k)*100);
    end
    chi2 = sum((counts - N/4).^2 / (N/4));
    fprintf('Chi-squared statistic (df=3, critical=7.81 at p=0.05): %.4f\n\n', chi2);

    % --- 2. Normalized chaos values distribution ---
    x_seq = chaos_seq / 255;   % Normalize to [0,1]

    % --- 3. Autocorrelation of selection sequence ---
    max_lag = 50;
    ac = xcorr(double(sel_bits) - mean(double(sel_bits)), max_lag, 'normalized');
    ac_one_sided = ac(max_lag+1:end);

    % --- 4. Lyapunov exponent estimate ---
    eps = 1e-8;
    x1 = opt.seed;
    x2 = opt.seed + eps;
    lyap_sum = 0;
    for k = 1:N
        x1 = opt.r * x1 * (1 - x1);
        x2 = opt.r * x2 * (1 - x2);
        d  = abs(x2 - x1);
        if d > 0
            lyap_sum = lyap_sum + log(d / eps);
            % Renormalize
            x2 = x1 + eps * sign(x2 - x1);
        end
    end
    lyapunov = lyap_sum / N;
    fprintf('Estimated Lyapunov Exponent: %.4f (theoretical for r=4: %.4f)\n', ...
        lyapunov, log(2));

    % --- 5. Sensitivity: two nearby seeds diverge ---
    fprintf('\nSensitivity analysis (two seeds differing by 1e-10):\n');
    x_a = opt.seed;
    x_b = opt.seed + 1e-10;
    for k = 1:50
        x_a = opt.r * x_a * (1 - x_a);
        x_b = opt.r * x_b * (1 - x_b);
        if k <= 5 || k == 10 || k == 20 || k == 50
            fprintf('  Step %2d: |x_a - x_b| = %.6e\n', k, abs(x_a - x_b));
        end
    end

    % --- Store results ---
    chaos_stats.freqs      = freqs;
    chaos_stats.chi2       = chi2;
    chaos_stats.lyapunov   = lyapunov;
    chaos_stats.ac         = ac_one_sided;

    % --- Figures ---
    figure('Position', [100 100 1200 800]);

    subplot(2,2,1);
    bar(0:3, freqs*100, 'FaceColor', [0.3 0.5 0.8]);
    hold on; yline(25, 'r--', 'Expected 25%', 'LineWidth', 1.5);
    xlabel('Polynomial Index s'); ylabel('Selection Frequency (%)');
    title('Polynomial Selection Uniformity'); grid on;

    subplot(2,2,2);
    histogram(x_seq, 50, 'Normalization', 'pdf', 'FaceColor', [0.8 0.4 0.3]);
    hold on;
    xp = linspace(0,1,200);
    % Theoretical arcsine distribution for logistic map at r=4
    yp = 1 ./ (pi * sqrt(xp .* (1 - xp)));
    plot(xp, yp, 'k-', 'LineWidth', 2);
    xlabel('x_n (normalized)'); ylabel('PDF');
    title('Chaos Sequence Distribution (Arcsine Law)');
    legend('Empirical', 'Arcsine PDF');
    grid on;

    subplot(2,2,3);
    stem(0:max_lag, ac_one_sided, 'filled', 'MarkerSize', 4, 'Color', [0.2 0.6 0.2]);
    hold on; yline(2/sqrt(N), 'r--', '95% CI'); yline(-2/sqrt(N), 'r--');
    xlabel('Lag'); ylabel('Autocorrelation');
    title('Autocorrelation of s_n Sequence'); grid on;

    subplot(2,2,4);
    n_iter = 1:100;
    x_a = opt.seed; x_b = opt.seed + 1e-10;
    div = zeros(1,100);
    for k = 1:100
        x_a = opt.r * x_a * (1 - x_a);
        x_b = opt.r * x_b * (1 - x_b);
        div(k) = abs(x_a - x_b);
    end
    semilogy(n_iter, div, 'b-', 'LineWidth', 1.5);
    xlabel('Iteration n'); ylabel('|x_a(n) - x_b(n)|');
    title('Sensitive Dependence on Initial Conditions'); grid on;

    sgtitle(sprintf('Chaos Statistical Properties (seed=%.4f, r=%.2f, N=%d)', ...
        opt.seed, opt.r, N), 'FontSize', 13);
    saveas(gcf, 'results/figures/chaos_statistics.png');
    fprintf('\nChaos statistics plot saved.\n');
end
