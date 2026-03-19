# lex-agentic-inference

**Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`

## What Is This Gem?

Domain consolidation gem for reasoning, inference, and belief management. Bundles 27 source extensions into one loadable unit under `Legion::Extensions::Agentic::Inference`.

**Gem**: `lex-agentic-inference`
**Version**: 0.1.1
**Namespace**: `Legion::Extensions::Agentic::Inference`

## Sub-Modules

| Sub-Module | Source Gem | Purpose |
|---|---|---|
| `Inference::Abductive` | `lex-abductive-reasoning` | Best-explanation inference — hypothesis generation and ranking |
| `Inference::Analogical` | `lex-analogical-reasoning` | Structural analogy mapping between domains |
| `Inference::ArgumentMapping` | `lex-argument-mapping` | Argument tree — premises, conclusions, objections, rebuttals |
| `Inference::Bayesian` | `lex-bayesian-belief` | Bayesian belief updating with likelihood ratios |
| `Inference::BeliefRevision` | `lex-belief-revision` | AGM-model contraction, expansion, and revision |
| `Inference::CausalAttribution` | `lex-causal-attribution` | Weiner's attribution model — internal/external, stable/unstable |
| `Inference::CausalReasoning` | `lex-causal-reasoning` | Causal graph inference, do-calculus |
| `Inference::Counterfactual` | `lex-counterfactual` | Nearest-world counterfactual simulation |
| `Inference::HypothesisTesting` | `lex-hypothesis-testing` | Scientific reasoning loop — generate, predict, test, evaluate |
| `Inference::Prediction` | `lex-prediction` | Forward-model prediction — four modes, rolling accuracy tracking |
| `Inference::PredictiveCoding` | `lex-predictive-coding` | Hierarchical predictive coding with precision-weighted error |
| `Inference::PredictiveProcessing` | `lex-predictive-processing` | Unified perception/action loop |
| `Inference::FreeEnergy` | `lex-free-energy` | Friston Free Energy Principle — minimize prediction error |
| `Inference::Intuition` | `lex-intuition` | Fast heuristic-based inference |
| `Inference::Schema` | `lex-schema` | Organized knowledge structures — schema activation |
| `Inference::ExpectationViolation` | `lex-expectation-violation` | Surprise from violated predictions |
| `Inference::UncertaintyTolerance` | `lex-uncertainty-tolerance` | Tolerance for ambiguity and incomplete information |
| `Inference::RealityTesting` | `lex-reality-testing` | Tests whether beliefs match available evidence |
| `Inference::Affordance` | `lex-affordance` | Gibson affordance theory — action possibilities from environment |
| `Inference::EnactiveCognition` | `lex-enactive-cognition` | Varela/Maturana enactivism — sensorimotor loops as meaning |
| `Inference::PerceptualInference` | `lex-perceptual-inference` | Bayesian perception — sensory likelihoods + priors |
| `Inference::Coherence` | `lex-cognitive-coherence` | Belief coherence assessment and maintenance |
| `Inference::Debugging` | `lex-cognitive-debugging` | Systematic diagnosis of cognitive errors |
| `Inference::Horizon` | `lex-cognitive-horizon` | Reasoning boundary and scope management |
| `Inference::Gravity` | `lex-cognitive-gravity` | Attractor patterns in belief space |
| `Inference::Momentum` | `lex-cognitive-momentum` | Inference momentum — continuation bias in reasoning chains |
| `Inference::Magnet` | `lex-cognitive-magnet` | Magnetic pull of salient attractors |

## Actors

- `Inference::Affordance::Actors::Scan` — interval actor, scans for available affordances
- `Inference::Horizon::Actors::Adjust` — interval actor, adjusts reasoning horizon bounds
- `Inference::Prediction::Actors::ExpirePredictions` — runs every 300s, expires stale predictions
- `Inference::PredictiveCoding::Actors::Decay` — interval actor, decays precision weights

## Tick Integration

`Inference::Prediction` maps to the `prediction_engine` tick phase.

## Development

```bash
bundle install
bundle exec rspec        # 2305 examples, 0 failures
bundle exec rubocop      # 0 offenses
```
