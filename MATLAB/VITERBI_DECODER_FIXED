function decoded = viterbi_decode_fixed(rx0, rx1)
% VITERBI_DECODE_FIXED  Hard-decision Viterbi decoder for fixed (133,171) code.
%
%   decoded = viterbi_decode_fixed(rx0, rx1)
%
%   Inputs:
%     rx0, rx1 - Hard-decision received bits (0 or 1) for the two code streams
%
%   Output:
%     decoded  - Decoded information bit sequence
%
%   Uses Hamming distance branch metrics over 64 trellis states (K=7 => 2^6 states).
%
%   See also: viterbi_decode_dynamic, conv_encode_fixed

    taps_G1 = [1 3 4 6 7];
    taps_G2 = [1 2 3 4 7];

    T          = length(rx0);
    num_states = 64;

    path_metric = inf(1, num_states);
    path_metric(1) = 0;                    % Start from all-zeros state

    prev_state = zeros(T, num_states, 'uint8');
    prev_input = zeros(T, num_states, 'uint8');

    for t = 1:T
        new_metrics = inf(1, num_states);

        for cs = 0:(num_states - 1)
            if isinf(path_metric(cs + 1)), continue; end

            % Decode current state into shift register bits
            sr = dec2sr(cs);

            for inp = 0:1
                state_vec = [inp, sr(6), sr(5), sr(4), sr(3), sr(2), sr(1)];
                o0 = mod(sum(state_vec(taps_G1)), 2);
                o1 = mod(sum(state_vec(taps_G2)), 2);

                next_sr    = [sr(2:6), inp];
                ns         = sr2dec(next_sr);

                bm        = (o0 ~= rx0(t)) + (o1 ~= rx1(t));
                candidate = path_metric(cs + 1) + bm;

                if candidate < new_metrics(ns + 1)
                    new_metrics(ns + 1)      = candidate;
                    prev_state(t, ns + 1)    = cs;
                    prev_input(t, ns + 1)    = inp;
                end
            end
        end
        path_metric = new_metrics;
    end

    % Traceback
    [~, best] = min(path_metric);
    best      = best - 1;

    decoded = zeros(1, T);
    state   = best;
    for t = T:-1:1
        decoded(t) = prev_input(t, state + 1);
        state      = prev_state(t, state + 1);
    end
end

% ---- Helper functions ----

function sr = dec2sr(s)
% Convert integer state (0-63) to shift register bit array sr(1..6)
% sr(1) = MSB (oldest), sr(6) = LSB (newest)
    sr = zeros(1, 6);
    for i = 1:6
        sr(7 - i) = mod(s, 2);
        s = floor(s / 2);
    end
end

function s = sr2dec(sr)
% Convert shift register bit array to integer state
    s = 0;
    for i = 1:6
        s = s * 2 + sr(i);
    end
end
