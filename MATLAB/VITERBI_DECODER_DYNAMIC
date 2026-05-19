function decoded_bits = viterbi_decode_dynamic(rx0, rx1, chaos_seed, r)
% VITERBI_DECODE_DYNAMIC  Chaos-synchronized hard-decision Viterbi decoder.
%
%   decoded_bits = viterbi_decode_dynamic(rx0, rx1, chaos_seed, r)
%
%   The decoder regenerates the identical chaotic control sequence used during
%   encoding and applies a time-varying trellis accordingly. An uninformed receiver
%   without knowledge of (chaos_seed, r) cannot replicate this sequence and will
%   experience BER approaching 0.5.
%
%   Inputs:
%     rx0, rx1    - Hard-decision received bits (0 or 1)
%     chaos_seed  - Shared secret initial condition x0 (must match encoder)
%     r           - Logistic map parameter (must match encoder)
%
%   Output:
%     decoded_bits - Decoded information bit sequence
%
%   See also: viterbi_decode_fixed, conv_encode_dynamic, chaos_gen

    poly_taps = {
        {[1 3 4 6 7], [1 2 3 4 7]};
        {[1 2 4 6 7], [1 3 4 6 7]};
        {[1 3 4 6],   [1 3 4 5 6 7]};
        {[1 3 5 6 7], [1 3 4 5 7]};
    };

    T          = length(rx0);
    num_states = 64;

    [~, sel_bits] = chaos_gen(chaos_seed, r, T);

    path_metric = inf(1, num_states);
    path_metric(1) = 0;

    prev_state   = zeros(T, num_states, 'uint8');
    prev_input   = zeros(T, num_states, 'uint8');

    for t = 1:T
        idx      = sel_bits(t) + 1;
        taps_G1  = poly_taps{idx}{1};
        taps_G2  = poly_taps{idx}{2};

        new_metrics = inf(1, num_states);

        for cs = 0:(num_states - 1)
            if isinf(path_metric(cs + 1)), continue; end

            sr = dec2sr(cs);

            for inp = 0:1
                state_vec = [inp, sr(6), sr(5), sr(4), sr(3), sr(2), sr(1)];
                o0 = mod(sum(state_vec(taps_G1)), 2);
                o1 = mod(sum(state_vec(taps_G2)), 2);

                next_sr = [sr(2:6), inp];
                ns      = sr2dec(next_sr);

                bm        = (o0 ~= rx0(t)) + (o1 ~= rx1(t));
                candidate = path_metric(cs + 1) + bm;

                if candidate < new_metrics(ns + 1)
                    new_metrics(ns + 1)   = candidate;
                    prev_state(t, ns + 1) = cs;
                    prev_input(t, ns + 1) = inp;
                end
            end
        end
        path_metric = new_metrics;
    end

    [~, best_state] = min(path_metric);
    best_state      = best_state - 1;

    decoded_bits = zeros(1, T);
    state = best_state;
    for t = T:-1:1
        decoded_bits(t) = prev_input(t, state + 1);
        state           = prev_state(t, state + 1);
    end
end

% ---- Helper functions ----

function sr = dec2sr(s)
    sr = zeros(1, 6);
    for i = 1:6
        sr(7 - i) = mod(s, 2);
        s = floor(s / 2);
    end
end

function s = sr2dec(sr)
    s = 0;
    for i = 1:6
        s = s * 2 + sr(i);
    end
end
