# lex-agentic-inference

**Parent**: `../CLAUDE.md`

## What Is This Gem?

Domain consolidation gem for reasoning, inference, and belief management. Bundles 27 source extensions into one loadable unit under `Legion::Extensions::Agentic::Inference`.

**Gem**: `lex-agentic-inference`
**Version**: 0.1.8
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

| Actor | Interval | Target Method |
|-------|----------|---------------|
| `Abductive::Actor::UpdateAbductiveReasoning` | Every 60s | `update_abductive_reasoning` on `Abductive::Runners::AbductiveReasoning` |
| `Affordance::Actors::Scan` | interval | `scan_affordances` on `Affordance::Runners::Affordance` |
| `BeliefRevision::Actor::UpdateBeliefRevision` | Every 120s | `update_belief_revision` on `BeliefRevision::Runners::BeliefRevision` |
| `Coherence::Actor::UpdateCognitiveCoherence` | Every 120s | `update_cognitive_coherence` on `Coherence::Runners::CognitiveCoherence` |
| `ExpectationViolation::Actor::DecayViolations` | Every 300s | `decay_violations` on `ExpectationViolation::Runners::ExpectationViolation` |
| `FreeEnergy::Actor::UpdateFreeEnergy` | Every 30s | `update_free_energy` on `FreeEnergy::Runners::FreeEnergy` |
| `Horizon::Actors::Adjust` | interval | `adjust_horizon` on `Horizon::Runners::CognitiveHorizon` |
| `Momentum::Actor::UpdateCognitiveMomentum` | Every 60s | `update_cognitive_momentum` on `Momentum::Runners::CognitiveMomentum` |
| `Prediction::Actors::ExpirePredictions` | Every 300s | `expire_predictions` on `Prediction::Runners::Prediction` |
| `PredictiveCoding::Actors::Decay` | interval | decays precision weights |
| `RealityTesting::Actor::DecayBeliefs` | Every 300s | `decay_beliefs` on `RealityTesting::Runners::RealityTesting` |

## Tick Integration

`Inference::Prediction` maps to the `prediction_engine` tick phase. Returns `{ accuracy:, confidence:, ... }` which is read by `Core::Runners::Homeostasis#regulate` and `Motivation::Runners::Motivation#update_motivation`.

## Dependencies

**Runtime** (from gemspec):
- `legion-cache` >= 1.3.11
- `legion-crypt` >= 1.4.9
- `legion-data` >= 1.4.17
- `legion-json` >= 1.2.1
- `legion-logging` >= 1.3.2
- `legion-settings` >= 1.3.14
- `legion-transport` >= 1.3.9

## Development

```bash
bundle install
bundle exec rspec        # 2293 examples, 0 failures
bundle exec rubocop      # 0 offenses
```
