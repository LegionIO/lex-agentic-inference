# Changelog

## [0.1.7] - 2026-04-15
### Changed
- Set `mcp_tools?`, `mcp_tools_deferred?`, and `transport_required?` to `false` — internal cognitive pipeline extension

## [Unreleased]

### Fixed
- add rolling_accuracy, error_rate, and resolved keys to predict return hash
- wire schema outcome-learning loop by providing resolved predictions array

## [0.1.5] - 2026-03-30

### Changed
- update to rubocop-legion 0.1.7, resolve all offenses

## [0.1.4] - 2026-03-26

### Changed
- fix remote_invocable? to use class method for local dispatch

## [0.1.3] - 2026-03-26

### Changed
- Migrate prediction runner from `Legion::Extensions::Memory::Runners::Traces` to `Legion::Extensions::Agentic::Memory::Trace::Runners::Traces`

## [0.1.2] - 2026-03-22

### Changed
- Add 7 runtime dependencies to gemspec: legion-cache, legion-crypt, legion-data, legion-json, legion-logging, legion-settings, legion-transport
- Replace direct Legion::Logging.* calls in all runner files with log.* via Legion::Logging::Helper
- Add Legion::Logging::Helper include to RealityEngine, MagnetEngine, and PerceptualField helper classes
- Add Legion::Extensions::Helpers::Lex include to AnalogicalReasoning runner module
- Update spec_helper to use real sub-gem helpers (TIER 1 pattern)

## [0.1.1] - 2026-03-18

### Changed
- Enforce IDEA_TYPES validation in Momentum::MomentumEngine#create_idea (returns nil for invalid types)

## [0.1.0] - 2026-03-18

### Added
- Initial release as domain consolidation gem
- Consolidated source extensions into unified domain gem under `Legion::Extensions::Agentic::<Domain>`
- All sub-modules loaded from single entry point
- Full spec suite with zero failures
- RuboCop compliance across all files
