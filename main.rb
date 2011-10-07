require 'rubygems'
require 'gruff'
require File.dirname(__FILE__) + '/linguistic_variable'

input_filename = 'input.txt'
variables = {}
fuzzy_set = []

File.open(File.dirname(__FILE__) + '/' + input_filename) do |f|
  while !f.eof
    line = f.gets
    if line =~ /=\d+/
      var, val = line.split('=').map { |part| part.strip }
      variables[var] = val.to_i
    else
      name = line.scan(/".+"/).first.gsub('"', '')
      cols = line.split(/".+"/).last.strip.split(/\s+/)
      lv = LinguisticVariable.new(name)
      cols.each do |col|
        range = col.split('-').map do |value|
          if value !~ /\d+/
            raise "#{value} is undefined variable" unless variables[value]
            variables[value]
          else
            value.to_i
          end
        end
        lv.add_expert_range(range[0], range[1])
      end
      fuzzy_set << lv
    end
  end
end

LinguisticVariable.min_max_range(variables['Tmin'], variables['Tmax'])
LinguisticVariable.range_step(variables['Step'])

gruff = Gruff::Line.new
gruff.title = 'Fuzzy sets'
fuzzy_set.each do |lv|
  puts "#{lv.name}: #{lv.degrees_of_membership.join(', ')}"
  gruff.data(lv.name, lv.gruff_line)
end
#p LinguisticVariable.labels
gruff.labels = LinguisticVariable.labels
gruff.write