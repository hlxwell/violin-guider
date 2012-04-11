# -*- encoding : utf-8 -*-
require 'rubygems'
require 'parslet'
require 'json'
include Parslet

# Constructs a parser using a Parser Expression Grammar
class Notedown < Parslet::Parser
  rule(:notes)          { tune.maybe >> note_group.as(:group).repeat(1) }
  rule(:note_group)     { note.repeat(1) >> (comma | eof) } # take care of repeat(x) and repeat is diff
  rule(:note)           { bow_direction? >> lbracket >> note_number >> string_name.maybe >> finger_index.maybe >> rbracket }
  rule(:bow_direction?) { match("[v\^]").as(:bow_direction).maybe } # diff from ...maybe.as(:bow_direction)
  rule(:tune)           { lbbracket >> tune_action >> str("|") >> note_numbers.as(:note_numbers) >> rbbracket >> comma }
  rule(:tune_action)    { match("[#b]").as(:tune_action) }
  rule(:note_numbers)   { note_number.repeat(1) }
  rule(:note_number)    { match("[\\d\\+\\-]").repeat(1).as(:note) >> (str(":") >> tune_action).maybe >> str(",").maybe }
  rule(:string_name)    { str('@') >> match("[gdae]").as(:string_name) }
  rule(:finger_index)   { str('|') >> match("\\d").as(:finger_index) }

  rule(:space)          { match('\s').repeat(1) }
  rule(:space?)         { space.maybe }
  rule(:lbracket)       { str('[') >> space? }
  rule(:rbracket)       { str(']') >> space? }
  rule(:lbbracket)      { str('{') >> space? }
  rule(:rbbracket)      { str('}') >> space? }
  rule(:comma)          { str(",") >> space? }
  rule(:eof)            { any.absent? }

  root(:notes)

  NOTE_ON_POSITION = {
    c: %w{-1 3+ +2 +5+},
    d: %w{-1+ 4 +2+ +6},
    e: %w{1 4+ +3 +6+},
    f: %w{1+ 5 +3+ +7},
    g: %w{-3+ 2 5+ +4},
    a: %w{-2 2+ +1 +4+},
    b: %w{-2+ 3 +1+ +5}
  }

  ### GDAE start from note
  # G = [-3+,]
  # D = [-1+,]
  # A = [2+,]
  # E = [4+,]

  def self.parse_from_file_to file_path, format = :json
    notedown = File.read(file_path)
    send("parse_to_#{format}", notedown)
  end

  def self.parse_to_array notedown
    self.new.parse_to_array(notedown)
  end

  def self.parse_to_json notedown
    parse_to_array(notedown).to_json
  end

  def parse_to_array notedown
    @raw_parse_result = parse(notedown)
    last_group_bow_direction = last_note_bow_direction = nil

    note_groups.map do |group|
      group.map do |note_info|
        last_note_bow_direction ||= note_info[:bow_direction]
        [
          note_info[:bow_direction] || last_note_bow_direction || current_group_bow_direction(last_group_bow_direction),
          apply_the_global_tune_action(note_info[:note], note_info[:tune_action]),
          note_info[:finger_index].to_s,
          note_info[:string_name].to_s,
        ]
      end.tap {
        last_group_bow_direction = last_note_bow_direction
        last_note_bow_direction = nil
      }
    end.flatten(1) # flatten groups
  end

  # {:tune_action=>"#"@1, :note_numbers=>[{:note=>"3+"@3}, {:note=>"5"@6}]}
  def tune_info
    @tune_info ||= @raw_parse_result.first if @raw_parse_result.first[:tune_action]
  end

  # {:group=>[{:bow_direction=>"^"@27, :note=>"+2"@29, :tune_action=>"#"@32, :string_name=>"d"@34, :finger_index=>"3"@36}]}
  def note_groups
    @groups ||= begin
      start_from = tune_info ? 1 : 0
      @raw_parse_result[start_from..-1].map {|group| group[:group]}
    end
  end

  def current_group_bow_direction last_group_bow_direction
    last_group_bow_direction == "v" ? '^' : 'v'
  end

  def apply_the_global_tune_action note, note_action = nil
    action = note_action || get_current_note_tune_action(note)
    action.nil? ? note : "#{note}:#{action}"
  end

  def tune_note_numbers
    tune_info[:note_numbers].map {|n| n[:note].to_s }
  end

  def get_current_note_tune_action note
    same_tune_notes = NOTE_ON_POSITION.select { |k, v| v.include?(note) }.values.flatten
    tune_info[:tune_action] if (same_tune_notes & tune_note_numbers).size > 0
  end
end
