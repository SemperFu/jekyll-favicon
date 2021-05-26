# frozen_string_literal: true

module Jekyll
  module Favicon
    module Utils
      module Configuration
        # Favicon configuration compact logic
        module Compact
          def self.included(klass)
            klass.extend(ClassMethods)
          end

          # Nil and empty remove from configurations
          module ClassMethods
            def compact(compactable)
              case compactable
              when Hash, Array
                compact_deep(compactable) || compactable.class[]
              else
                compactable
              end
            end

            private

            def compact_deep(compactable)
              case compactable
              when Hash then compact_hash compactable
              when Array then compact_array compactable
              else compactable
              end
            end

            def compact_hash(hash)
              compacted_hash = hash.each_with_object({}) do |(key, value), memo|
                next unless (compacted = compact_deep(value))

                memo[key] = compacted
              end
              compact_shallow compacted_hash
            end

            def compact_array(array)
              compacted_array = array.each_with_object([]) do |value, memo|
                next unless (compacted = compact_deep(value))

                memo << compacted
              end
              compact_shallow compacted_array
            end

            # :reek:UtilityFunction
            def compact_shallow(compactable)
              compactable.empty? ? nil : compactable.compact
            end
          end
        end
      end
    end
  end
end
