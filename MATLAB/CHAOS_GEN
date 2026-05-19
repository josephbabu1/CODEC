function [chaos_seq, sel_bits] = chaos_gen(seed, r, len)
% CHAOS_GEN  Logistic map chaos generator for polynomial selection.
%
%   [chaos_seq, sel_bits] = chaos_gen(seed, r, len)
%
%   Inputs:
%     seed      - Initial condition x0, must satisfy 0 < seed < 1, seed ~= 0.5
%     r         - Logistic map parameter, use r = 3.99 for chaotic regime
%     len       - Number of samples to generate
%
%   Outputs:
%     chaos_seq - 8-bit quantized logistic map output (values 0-255)
%     sel_bits  - Top 2 bits of chaos_seq (values 0-3), polynomial selector
%
%   Equation: x_{n+1} = r * x_n * (1 - x_n)
%   Quantization: chaos_seq(n) = floor(x_n * 256), clamped to 255
%   Selection:    sel_bits(n)  = chaos_seq(n) >> 6  (top 2 bits => 0..3)
%
%   SECURITY NOTE: Both transmitter and receiver must use identical seed and r
%   with identical floating-point arithmetic (IEEE 754 double) to ensure
%   perfect synchronization.
%
%   See also: conv_encode_dynamic, viterbi_decode_dynamic

    % Validate inputs
    assert(seed > 0 && seed < 1 && seed ~= 0.5, ...
        'chaos_gen: seed must be in (0,1) and not equal to 0.5');
    assert(r >= 3.57 && r <= 4.0, ...
        'chaos_gen: r must be in [3.57, 4.0] for chaotic behavior');
    assert(len > 0 && floor(len) == len, ...
        'chaos_gen: len must be a positive integer');

    x = seed;
    chaos_seq = zeros(1, len);

    for k = 1:len
        x = r * x * (1 - x);               % Logistic map iteration
        q = floor(x * 256);                  % Quantize to 8 bits
        if q == 256
            q = 255;                         % Clamp boundary case
        end
        chaos_seq(k) = q;
    end

    % Extract top 2 bits (bits 7-6 of 8-bit value) => range 0..3
    if nargout > 1
        sel_bits = bitshift(chaos_seq, -6);  % Right-shift by 6
    end
end
