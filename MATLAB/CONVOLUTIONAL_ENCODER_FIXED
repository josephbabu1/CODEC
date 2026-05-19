function [out0, out1] = conv_encode_fixed(in_bits)
% CONV_ENCODE_FIXED  Rate-1/2, K=7 convolutional encoder with NASA polynomials.
%
%   [out0, out1] = conv_encode_fixed(in_bits)
%
%   Generator polynomials (octal): G1 = 133, G2 = 171
%   Tap indices (1-based, MSB first):
%     G1 = 1011011 => taps at positions [1, 3, 4, 6, 7]
%     G2 = 1111001 => taps at positions [1, 2, 3, 4, 7]
%
%   State vector: [current_bit, D^1, D^2, D^3, D^4, D^5, D^6]
%   Shift register sr(1)=D^1 (oldest), sr(6)=D^6 (newest before input)
%
%   Inputs:
%     in_bits - Row vector of binary input bits
%
%   Outputs:
%     out0, out1 - Encoded output streams (same length as in_bits)
%
%   See also: conv_encode_dynamic, viterbi_decode_fixed

    taps_G1 = [1 3 4 6 7];   % G1 = 1011011 (octal 133)
    taps_G2 = [1 2 3 4 7];   % G2 = 1111001 (octal 171)

    N   = length(in_bits);
    sr  = zeros(1, 6);        % Shift register: sr(1)=D^6 ... sr(6)=D^1
    out0 = zeros(1, N);
    out1 = zeros(1, N);

    for k = 1:N
        d = in_bits(k);
        % State vector: [current_input, sr reversed so position 1 = D^1]
        state_vec = [d, sr(6), sr(5), sr(4), sr(3), sr(2), sr(1)];

        out0(k) = mod(sum(state_vec(taps_G1)), 2);
        out1(k) = mod(sum(state_vec(taps_G2)), 2);

        % Shift register update
        sr = [sr(2:6), d];
    end
end
