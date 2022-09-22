#!/usr/bin/env ruby
require "csv"
require "matrix"
require 'bigdecimal'
require 'bigdecimal/util'

CSV::Converters[:micros] = ->(x) { x.to_d * 1e-6 }
csv = CSV.read("/tmp/BOO", converters: :micros)
m = Matrix[*csv]

d = m.each.each_cons(2).map {|x| x[1] - x[0] }
if d.each.any? {|x| x < 0 }
  puts <<EOF
WARNING: reload() concurrency

  If things were run in sequence, consecutive timestamps should never be
  decreasing, but there's at least one instance in which they are, which
  means that reload() must be running concurrently. 

EOF
end

d = Matrix[*(m.row_vectors.map do |row|
  row.each_cons(2).map do |x|
    x[1] - x[0]
  end
end)]
d.each do |x|
  abort("something terrible happened :(") if x < 0
end

puts " global delta = #{(m.each.to_a.last - m.each.to_a.first).to_f}s"
puts "sum of deltas = #{d.sum.to_f}s"
