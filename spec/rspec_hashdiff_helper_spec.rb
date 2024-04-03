# frozen_string_literal: true

require 'rspec'
require 'rspec/support/spec/string_matcher'
require 'rspec_hashdiff_helper'

RSpec.describe 'RspecHashDiff' do # rubocop:disable Metrics/BlockLength
  let(:differ) { RSpec::Support::Differ.new }

  it 'returns the correct diff' do
    expected_diff = <<~'DIFFTEXT'
      \+ {b: goodbye }
      \- {b: 3 }
      \+ {c:{f:{g: a word }}}
      \- {c:{f:{g: diff word }}}
    DIFFTEXT
    actual = { a: 'hello', b: 'goodbye', c: { d: 'movei', e: 'another', f: { g: 'a word' } } }
    expected = { a: 'hello', b: 3, c: { d: 'movei', e: 'another', f: { g: 'diff word' } } }
    diff = differ.diff(actual, expected)
    expect(diff).to match(expected_diff)
  end

  it 'handles non matching actual and expected structures' do
    expected_diff = <<~'DIFFTEXT'
      \+ {c: {:d=>"movei", :e=>"another", :f=>{:g=>"a word"}} }
      \- {h: {:d=>"movei", :e=>"another", :f=>{:g=>"a word"}} }
    DIFFTEXT
    actual = { a: 'hello', b: 'goodbye', h: { d: 'movei', e: 'another', f: { g: 'a word' } } }
    expected = { a: 'hello', b: 'goodbye', c: { d: 'movei', e: 'another', f: { g: 'a word' } } }
    diff = differ.diff(actual, expected)
    expect(diff).to match(expected_diff)
  end

  it 'handles common array matchers in expected structures' do
    expected_diff = <<~'DIFFTEXT'
      \+ {c:{2:{g: diff word }}}
      \- {c:{2:{g: a word }}}
    DIFFTEXT
    actual = { a: 'hello', b: { d: 'goodbye' }, c: ['movei', 'another', { g: 'diff word' }] }
    expected = { a: 'hello', b: match('d' => 'goodbye'), c: contain_exactly('movei', 'another', { g: 'a word' }) }
    diff = differ.diff(actual, expected)
    expect(diff).to match(expected_diff)
  end
end
