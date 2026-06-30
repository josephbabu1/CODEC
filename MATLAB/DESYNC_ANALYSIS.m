function desync_analysis(varargin)
% DESYNC_ANALYSIS  Security experiment: BER vs. initial condition error.
%
%   Demonstrates that any deviation in the chaos seed causes BER -> 0.5,
%   validating the security claim of the chaos-driven TVCC system.
%
%   Usage:
%     desync_analysis()
%     desync_analysis('EbN0_dB', 4, 'n_bits', 1e6)

    p = inputParser;
    addParameter(p, 'EbN0_dB',    4);        % Fixed SNR for security test
    addParameter(p, 'n_bits',     2e5);      % Total bits per delta point
    addParameter(p, 'chaos_seed', 0.3001);
    addParameter(p, 'r',          3.99);
    addParameter(p, 'frame_len',  1000);
    parse(p, varargin{:});
    opt = p.Results;

    % Seed perturbations from exact match to large mismatch
    deltas = [0, 1e-15, 1e-12, 1e-9, 1e-6, 1e-4, 1e-3, 1e-2, 0.1];
    n_delta = length(deltas);

    EbN0_lin  = 10^(opt.EbN0_dB / 10);
    noise_var = 1 / (2 * EbN0_lin);

    BER_sync   = zeros(1, n_delta);
    frames     = floor(opt.n_bits / opt.frame_len);

    fprintf('=== Desynchronization Security Analysis ===\n');
    fprintf('Eb/N0 = %.1f dB | Frames = %d | Frame len = %d\n\n', ...
        opt.EbN0_dB, frames, opt.frame_len);

    for di = 1:n_delta
        delta     = deltas(di);
        att_seed  = opt.chaos_seed + delta;

        % Clamp attacker seed to valid range
        if att_seed <= 0 || att_seed >= 1
            att_seed = mod(att_seed, 1);
            if att_seed == 0, att_seed = 0.001; end
        end

        err = 0;
        tot = 0;

        for f = 1:frames
            info = randi([0, 1], 1, opt.frame_len);

            % Encode with correct seed
            [e0, e1] = conv_encode_dynamic(info, opt.chaos_seed, opt.r);
            tx = 2 * reshape([e0; e1], 1, []) - 1;
            rx = tx + sqrt(noise_var) * randn(size(tx));
            hd = rx > 0;

            % Decode with (possibly wrong) seed
            dec = viterbi_decode_dynamic(hd(1:2:end), hd(2:2:end), att_seed, opt.r);
            err = err + sum(info ~= dec);
            tot = tot + opt.frame_len;
        end

        BER_sync(di) = err / tot;

        if delta == 0
            label = 'SYNCHRONIZED (delta=0)';
        else
            label = sprintf('delta = %.1e', delta);
        end
        fprintf('  %-35s  BER = %.4f\n', label, BER_sync(di));
    end

    % --- Plot ---
    figure('Position', [100 100 700 450]);
    semilogx([1e-16, deltas(2:end)], BER_sync, 'r-o', 'LineWidth', 2, 'MarkerSize', 8);
    hold on;
    yline(0.5, 'k--', 'BER = 0.5 (random guessing)', 'LineWidth', 1.2, 'FontSize', 11);
    % Mark the synchronized point separately
    semilogx(1e-16, BER_sync(1), 'b*', 'MarkerSize', 14, 'LineWidth', 2, ...
        'DisplayName', 'Synchronized receiver');
    grid on;
    xlabel('Seed Perturbation \delta', 'FontSize', 13);
    ylabel('Bit Error Rate', 'FontSize', 13);
    title(sprintf('Desynchronization BER (E_b/N_0 = %.0f dB)', opt.EbN0_dB), 'FontSize', 13);
    legend({'Attacker BER', 'Random BER = 0.5', 'Synchronized receiver'}, ...
        'Location', 'best', 'FontSize', 11);
    ylim([0 0.6]);
    set(gca, 'FontSize', 11);

    saveas(gcf, 'results/figures/desync_ber.png');
    saveas(gcf, 'results/figures/desync_ber.fig');
    fprintf('\nDesync plot saved.\n');
end
