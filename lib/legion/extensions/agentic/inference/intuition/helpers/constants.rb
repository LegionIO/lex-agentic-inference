# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Intuition
          module Helpers
            module Constants
              MAX_PATTERNS = 200
              MAX_HEURISTICS = 50
              MAX_HISTORY = 300

              # Recognition threshold: pattern match score needed to trigger recognition
              RECOGNITION_THRESHOLD = 0.6

              # Confidence: how much the agent trusts its intuitions
              DEFAULT_CONFIDENCE = 0.5
              CONFIDENCE_FLOOR = 0.05
              CONFIDENCE_CEILING = 0.95

              # Reinforcement: how fast patterns strengthen/weaken
              REINFORCEMENT_RATE = 0.1
              DECAY_RATE = 0.01

              # Speed advantage: intuition is N times faster than deliberation
              SPEED_MULTIPLIER = 5

              PATTERN_STATES = %i[nascent developing reliable expert].freeze

              HEURISTIC_TYPES = %i[
                recognition take_the_best satisficing
                fast_and_frugal anchored gaze
              ].freeze

              INTUITION_MODES = %i[
                gut_feeling pattern_match heuristic_shortcut
                recognition_primed compiled_expertise
              ].freeze

              CONFIDENCE_LABELS = {
                (0.8..)     => :strong_hunch,
                (0.6...0.8) => :leaning,
                (0.4...0.6) => :uncertain,
                (0.2...0.4) => :weak_signal,
                (..0.2)     => :noise
              }.freeze

              STATE_THRESHOLDS = {
                expert:     0.85,
                reliable:   0.65,
                developing: 0.35
              }.freeze
            end
          end
        end
      end
    end
  end
end
