# CODEC: Chaos-Driven Time-Varying Convolutional Encoder

**Chaos-Driven Time-Varying Convolutional Coding for Physical Layer Security**
*IEEE Paper Submission — Draft v1.0*

---

## Overview

This repository implements a **chaos-driven time-varying convolutional coding (CD-TVCC)** scheme for physical layer security. The encoder dynamically switches generator polynomials at each bit epoch under control of a synchronized logistic map sequence, providing physical layer obfuscation without degrading forward error correction performance.

| Parameter | Value |
|---|---|
| Constraint length K | 7 |
| Code rate | 1/2 |
| Modulation | BPSK |
| Channel | AWGN (Rayleigh: future work) |
| Chaos map | Logistic map (r = 3.99) |
| Polynomial library size | 4 pairs |
| Trellis states | 64 |

---

## Repository Structure

```
CODEC/
├── MATLAB/
│   ├── chaos_gen.m                  # Logistic map chaos generator
│   ├── conv_encode_fixed.m          # Fixed (133,171) NASA encoder
│   ├── conv_encode_dynamic.m        # Chaos-driven time-varying encoder
│   ├── viterbi_decode_fixed.m       # Fixed-code Viterbi decoder
│   ├── viterbi_decode_dynamic.m     # Chaos-synchronized Viterbi decoder
│   ├── ber_simulation.m             # BER comparison simulation
│   ├── desync_analysis.m            # Security / desynchronization experiment
│   ├── chaos_statistical_analysis.m # Chaos sequence statistics
│   └── run_all_experiments.m        # Master reproducibility script
├── VERILOG/
│   └── [RTL modules: encoder, logistic map, polynomial MUX]
├── results/
│   ├── figures/                     # Generated plots (PNG, FIG)
│   └── data/                        # Simulation data (.mat files)
└── docs/
    └── IEEE_Paper_CD_TVCC.docx      # Full paper draft
```

---

## Quick Start (MATLAB)

### Requirements
- MATLAB R2019b or later (no toolboxes required)

### Run All Experiments
```matlab
cd MATLAB
run_all_experiments
```

This runs four experiments and saves all figures to `results/figures/`:
1. BER comparison (fixed vs. chaos-driven, 0–10 dB AWGN)
2. Desynchronization security analysis
3. Chaos statistical characterization
4. Entropy vs. logistic map parameter r

### Individual Functions
```matlab
% Test chaos generator
[seq, sel] = chaos_gen(0.3001, 3.99, 100);

% Encode with fixed code
[e0, e1] = conv_encode_fixed(randi([0,1], 1, 1000));

% Encode with chaos-driven code
[e0, e1] = conv_encode_dynamic(randi([0,1],1,1000), 0.3001, 3.99);

% BER simulation (fast test: 200 errors)
ber_simulation('target_errors', 200, 'EbN0', 0:2:8);

% Desynchronization security test
desync_analysis('EbN0_dB', 4, 'n_bits', 1e5);
```

---

## System Model

```
                    ┌──────────────────────────────────────────────┐
                    │            TRANSMITTER                        │
   Info bits ──────►│  Chaos Gen (x0,r) ──► Poly Selector          │
                    │                           │                   │
                    │           K=7 Encoder ◄──┘                   │
                    │               │                               │
                    │         BPSK Modulator                        │
                    └──────────────┬────────────────────────────────┘
                                   │  AWGN Channel
                    ┌──────────────▼────────────────────────────────┐
                    │            RECEIVER                            │
                    │  Chaos Gen (x0,r) ──► Poly Selector           │
                    │                           │                   │
                    │     Viterbi Decoder  ◄────┘                   │
                    │               │                               │
                    └──────────────►│ Decoded bits                  │
                                    └──────────────────────────────-┘
```

The shared secret is the pair **(x0, r)**. Both sides independently generate the identical chaos sequence using IEEE 754 double-precision arithmetic — no chaos synchronization channel required.

---

## Key Results

| Metric | Fixed (133,171) | CD-TVCC | Eavesdropper |
|---|---|---|---|
| BER at 6 dB Eb/N0 | ~10^-4 | ~10^-4 | ~0.5 |
| BER at 8 dB Eb/N0 | ~10^-5 | ~10^-5 | ~0.5 |
| FEC overhead | None | None | N/A |
| Key space | N/A | ~2^52 | Must search |

---

## Security Notes

- This scheme provides **computational obfuscation**, not cryptographic security
- The logistic map is **not** a CSPRNG; do not use x0 as a cryptographic key without additional hardening
- For stronger security: drive polynomial selection with AES-CTR using (x0, r) as a session key seed
- Any seed perturbation delta > 0 drives eavesdropper BER → 0.5 within ~40 iterations (Lyapunov exponent λ ≈ ln 2)

---

## Bug Fixes Applied (vs. Original Upload)

The original repository files contained non-standard MATLAB function names. All are corrected in this version:

| Original | Corrected | File |
|---|---|---|
| `combined(...)` | `sum(...)` | BER_simulation, viterbi_decoder |
| `minimum(...)` | `[~,x]=min(...)` | BER_simulation |
| `least(...)` | `[~,x]=min(...)` | viterbi_decoder |
| `accumulator(...)` | `sum(...)` | dynamic_encoder |
| `\total` | `\n` | BER_simulation (fprintf) |
| No `.m` extension | `.m` added to all files | All MATLAB files |

---

## Citation

If you use this work, please cite:

```
@article{babu2026cdtvcc,
  title={Chaos-Driven Time-Varying Convolutional Coding for Physical Layer Security: 
         A Logistic Map Approach with Synchronized Viterbi Decoding},
  author={Babu, Joseph},
}
```

---

## License

MIT License — see LICENSE file.
