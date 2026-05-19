function results = ber_simulation(varargin)
% BER_SIMULATION  BER comparison: fixed (133,171) vs chaos-driven TVCC.
%
%   results = ber_simulation()               % Default: AWGN, 0-10 dB, 1000 errors
%   results = ber_simulation('EbN0', 0:2:10) % Custom SNR range
%   results = ber_simulation('target_errors', 500, 'frame_len', 2000)
%
%   Name-value parameters:
%     'EbN0'          - Eb/N0 range in dB        (default: 0:1:10)
%     'target_errors' - Min errors per SNR point  (default: 1000)
%     'max_bits'      - Max bits per SNR point    (default: 100e6)
%     'frame_len'     - Information bits/frame    (default: 1000)
%     'chaos_seed'    - Logistic map initial cond (default: 0.3001)
%     'r'             - Logistic map parameter    (default: 3.99)
%     'desync_delta'  - Seed perturbation for desync test (default: 0)
%     'save_results'  - Save .mat file flag       (default: true)
%
%   Output structure 'results':
%     .EbN0_dB       - SNR points used
%     .BER_fixed     - BER for static (133,171) code
%     .BER_dynamic   - BER for chaos-driven TVCC (synchronized)
%     .BER_attacker  - BER for wrong-seed attacker (if desync_delta > 0)
%     .params        - Simulation parameters

    % --- Parse inputs ---
    p = inputParser;
    addParameter(p, 'EbN0',          0:1:10);
    addParameter(p, 'target_errors', 1000);
    addParameter(p, 'max_bits',      100e6);
    addParameter(p, 'frame_len',     1000);
    addParameter(p, 'chaos_seed',    0.3001);
    addParameter(p, 'r',             3.99);
    addParameter(p, 'desync_delta',  0);
    addParameter(p, 'save_results',  true);
    parse(p, varargin{:});
    opt = p.Results;

    EbN0_dB      = opt.EbN0;
    target_errs  = opt.target_errors;
    max_bits     = opt.max_bits;
    frame_len    = opt.frame_len;
    chaos_seed   = opt.chaos_seed;
    r            = opt.r;
    delta        = opt.desync_delta;
    wrong_seed   = chaos_seed + delta;   % Attacker's wrong seed

    M = length(EbN0_dB);
    BER_fixed    = zeros(1, M);
    BER_dynamic  = zeros(1, M);
    BER_attacker = zeros(1, M);

    fprintf('=== BER Simulation ===\n');
    fprintf('Target errors/point: %d | Frame len: %d | Chaos seed: %.4f | r: %.2f\n', ...
        target_errs, frame_len, chaos_seed, r);
    if delta ~= 0
        fprintf('Desync test: attacker seed = %.4e (delta = %.2e)\n', wrong_seed, delta);
    end
    fprintf('%s\n', repmat('-', 1, 80));

    for idx = 1:M
        EbN0_lin = 10^(EbN0_dB(idx) / 10);
        noise_var = 1 / (2 * EbN0_lin);   % Rate-1/2: Eb/N0 = Es/N0 / 2

        err_fixed    = 0;
        err_dynamic  = 0;
        err_attacker = 0;
        total_bits   = 0;

        while ((err_fixed < target_errs || err_dynamic < target_errs) ...
                && total_bits < max_bits)

            info = randi([0, 1], 1, frame_len);

            % --- Fixed encoder ---
            [e0f, e1f] = conv_encode_fixed(info);
            tx_f       = 2 * reshape([e0f; e1f], 1, []) - 1;
            rx_f       = tx_f + sqrt(noise_var) * randn(size(tx_f));
            hd_f       = rx_f > 0;
            dec_f      = viterbi_decode_fixed(hd_f(1:2:end), hd_f(2:2:end));
            err_fixed  = err_fixed + sum(info ~= dec_f);

            % --- Chaos-driven encoder (synchronized) ---
            [e0d, e1d] = conv_encode_dynamic(info, chaos_seed, r);
            tx_d       = 2 * reshape([e0d; e1d], 1, []) - 1;
            rx_d       = tx_d + sqrt(noise_var) * randn(size(tx_d));
            hd_d       = rx_d > 0;
            dec_d      = viterbi_decode_dynamic(hd_d(1:2:end), hd_d(2:2:end), chaos_seed, r);
            err_dynamic = err_dynamic + sum(info ~= dec_d);

            % --- Attacker (wrong seed) ---
            if delta ~= 0
                dec_a        = viterbi_decode_dynamic(hd_d(1:2:end), hd_d(2:2:end), wrong_seed, r);
                err_attacker = err_attacker + sum(info ~= dec_a);
            end

            total_bits = total_bits + frame_len;
        end

        BER_fixed(idx)   = err_fixed   / total_bits;
        BER_dynamic(idx) = err_dynamic / total_bits;
        if delta ~= 0
            BER_attacker(idx) = err_attacker / total_bits;
        end

        fprintf('Eb/N0=%4.1f dB | Fixed: %.2e (%4d err) | Dynamic: %.2e (%4d err)', ...
            EbN0_dB(idx), BER_fixed(idx), err_fixed, BER_dynamic(idx), err_dynamic);
        if delta ~= 0
            fprintf(' | Attacker: %.4f', BER_attacker(idx));
        end
        fprintf('\n');
    end

    % --- Store results ---
    results.EbN0_dB      = EbN0_dB;
    results.BER_fixed    = BER_fixed;
    results.BER_dynamic  = BER_dynamic;
    results.BER_attacker = BER_attacker;
    results.params       = opt;

    % --- Plot ---
    plot_ber(results);

    % --- Save ---
    if opt.save_results
        fname = sprintf('results/data/ber_%s.mat', datestr(now, 'yyyymmdd_HHMMSS'));
        save(fname, 'results');
        fprintf('Results saved to %s\n', fname);
    end
end

% ---- Internal plotting function ----
function plot_ber(res)
    figure('Position', [100 100 700 500]);

    % Theoretical BPSK BER (uncoded)
    EbN0_lin = 10.^(res.EbN0_dB / 10);
    BER_bpsk = qfunc(sqrt(2 * EbN0_lin));

    semilogy(res.EbN0_dB, BER_bpsk,       'k--', 'LineWidth', 1.2, 'DisplayName', 'Uncoded BPSK');
    hold on;
    semilogy(res.EbN0_dB, res.BER_fixed,  'b-o', 'LineWidth', 1.8, 'MarkerSize', 8, ...
        'DisplayName', 'Fixed (133,171)');
    semilogy(res.EbN0_dB, res.BER_dynamic,'r-s', 'LineWidth', 1.8, 'MarkerSize', 8, ...
        'DisplayName', 'Chaos-Driven TVCC');

    if any(res.BER_attacker > 0)
        semilogy(res.EbN0_dB, res.BER_attacker, 'm-^', 'LineWidth', 1.5, 'MarkerSize', 7, ...
            'DisplayName', sprintf('Attacker (\\Delta x_0=%.0e)', res.params.desync_delta));
    end

    grid on; grid minor;
    xlabel('E_b/N_0 (dB)', 'FontSize', 13);
    ylabel('Bit Error Rate (BER)', 'FontSize', 13);
    title('BER Performance: Fixed vs Chaos-Driven TVCC', 'FontSize', 13);
    legend('Location', 'southwest', 'FontSize', 11);
    ylim([1e-6 1]);
    set(gca, 'FontSize', 11);

    saveas(gcf, 'results/figures/ber_comparison.png');
    saveas(gcf, 'results/figures/ber_comparison.fig');
    fprintf('BER plot saved.\n');
end
