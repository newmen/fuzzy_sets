require 'set'

class LinguisticVariable
  def self.min_max_range(min, max)
    @@min = min
    @@max = max
  end

  def self.range_step(value)
    @@range_step = value
  end

  def self.labels
    @@total_number ||= (@@max - @@min) / @@range_step
    labels_hash = {0 => @@min.to_s, @@total_number - 1 => @@max.to_s}
    [4, 2, 1.333333].each do |r|
      labels_hash[(@@total_number / r).to_i] = (@@min + @@range_step * @@total_number / r).to_i.to_s
    end
    labels_hash
  end

  attr_reader :name

  def initialize(name)
    @name = name
    @ranges = []
    @keys = Set.new
  end

  def add_expert_range(min, max)
    @ranges << (min..max)
    @keys << min
    @keys << max
  end

  def degrees_of_membership
    degrees = []
    degrees << compliance_degree_with_key(pre_min) unless pre_min == @@min
    @keys.to_a.sort.each { |key| degrees << compliance_degree_with_key(key) }
    degrees << compliance_degree_with_key(post_max) unless post_max == @@max
    degrees
  end

  def gruff_line
    @@total_number ||= (@@max - @@min) / @@range_step
    min_degree = compliance_degree(pre_min)
    max_degree = compliance_degree(post_max)
    line_arr = Array.new(@@total_number)
    @@total_number.times do |i|
      if i < @keys.min then line_arr[i] = min_degree
      elsif i > @keys.max then line_arr[i] = max_degree
      else line_arr[i] = compliance_degree(i) end
    end
    line_arr
  end

  private

  def pre_min
    @keys.min - @@range_step > @@min ? @keys.min - @@range_step : @@min
  end

  def post_max
    @keys.max + @@range_step < @@min ? @keys.max + @@range_step : @@max
  end

  def compliance_degree(key)
    num = 0
    @ranges.each { |range| num += 1 if range.cover?(key) }
    num.to_f / @ranges.size
  end

  def compliance_degree_with_key(key)
    "#{key}/#{compliance_degree(key)}"
  end
end