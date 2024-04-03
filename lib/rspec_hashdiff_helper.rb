# frozen_string_literal: true

require 'hashdiff'

module RSpec
  module Support
    class Differ # rubocop:disable Style/Documentation
      def strip_matchers(expected)
        if expected.respond_to?(:expected)
          strip_matchers(expected.expected)
        elsif expected.instance_of?(Hash)
          expected.transform_values { |v| strip_matchers(v) }
        elsif expected.instance_of?(Array)
          expected.map { |v| strip_matchers(v) }
        else
          expected
        end
      end

      def find_contain_nodes(object, current_path = [])
        if object.instance_of?(RSpec::Matchers::BuiltIn::Match)
          find_contain_nodes(object.expected, current_path)
        elsif object.instance_of?(RSpec::Matchers::BuiltIn::ContainExactly)
          paths = [current_path.dup]
          find_contain_nodes(object.expected, current_path).each { |p| paths << p }
          paths
        elsif object.instance_of?(Hash)
          paths = []
          object.each { |key, value| find_contain_nodes(value, current_path.dup << key).each { |p| paths << p } }
          paths
        elsif object.instance_of?(Array)
          paths = []
          object.each_with_index { |value, index| find_contain_nodes(value, current_path.dup << index).each { |p| paths << p } }
          paths
        else
          []
        end
      end

      def format_hashes_for_diff(actual, expected)
        paths_to_contain_nodes = find_contain_nodes(expected)
        expected = strip_matchers(expected)

        paths_to_contain_nodes.each do |full_path|
          actual_target = actual
          expected_target = expected
          full_path.each do |step|
            actual_target = actual_target.respond_to?(:[]) ? actual_target[step] : nil
            expected_target = expected_target[step]
          end

          actual_target&.sort_by! { |v| v.instance_of?(Hash) ? v.to_s : v }
          expected_target.sort_by! { |v| v.instance_of?(Hash) ? v.to_s : v }
        end

        [actual, expected]
      end

      def diff_as_object(actual, expected)
        if actual.instance_of?(Hash) && expected.instance_of?(Hash)
          mod_actual, mod_expected = format_hashes_for_diff(actual, expected)
          diff = Hashdiff.diff(mod_actual,
                               mod_expected,
                               delimiter: ':',
                               array_path: true,
                               similarity: 1,
                               strict: false,
                               use_lcs: false,
                               indifferent: true)

          diff_str = diff.sort_by { |x| x[1].map(&:to_s) }.map do |diff_line|
            keys = diff_line[1]
            case diff_line[0]
            when '~'
              "+ #{keys.map { |key| "{#{key}:" }.join} #{diff_line[2]} #{Array.new(keys.length) { '}' }.join}\n" \
                "- #{keys.map { |key| "{#{key}:" }.join} #{diff_line[3]} #{Array.new(keys.length) { '}' }.join}\n"
            when '+', '-'
              "#{diff_line[0]} #{keys.map { |key| "{#{key}:" }.join}"\
                " #{diff_line[2]} #{Array.new(keys.length) { '}' }.join}\n"
            end
          end.join
          color_diff "\n#{diff_str}"
        else
          actual_as_string = object_to_string(actual)
          expected_as_string = object_to_string(expected)
          diff_as_string(actual_as_string, expected_as_string)
        end
      end
    end
  end
end
