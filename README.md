# Proof of knowledge of discrete logarithm, using sigma protocol and fiat-shamir transformation

Non-interactive Schnorr ZK DLOG Proof scheme with a Fiat-Shamir transformation
Protocol:
The prover knows a number(Scalar) x so that Y = x*G, and they want to prove they know it without revealing x
The base Schnorr proof protocol works as follows:
1. Commitment: The prover generates a random number r, compute T = rG
2. Challenge: The verifier geenerates a random number c, sends it to the prover
3. Response: The prover computes s = (r + c * x) % q, sends s to the verifier
4. Verification: The verifier checks that s * G == T + (Y * c), sends true or false to the prover
   Indeed if y=xG then (r + cx)G == rG + cxG == T + cY
   Basically the prover has "hidden" the details of x by transforming both sides of the equation with an "affine" function (in the curve space): N -> T+cN

Making the protocol non-interactive:
Instead of the verifier having to "send" the challenge c to the prover, the challenge is a deterministic, pseudo-random function of [ public problem variables + public proof ]
That deterministic function can be any hash, we choose Sha256
That way both the prover and verifier can derive the challenge c independently (without communicating with each other)

## Developer quickstart

Setup using `nix develop` (needs Nix) or `direnv allow` (needs Nix and nix-direnv).

> Alternatively, install dependencies manually: `Rust stable 1.80+`, `cargo-nextest`, `python3`, and any dependency listed in `./flake.nix`

Then, you can use these commands:

| Description                    | via Nix | Command without nix                                                                                                                      |
| ------------------------------ | ------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Run all unit tests             | `utest` | `cargo nextest run --workspace --nocapture -- `                                                                                          |


## Library interface

The type DlogProof has the same public interface as the python type:
- prove
- verify