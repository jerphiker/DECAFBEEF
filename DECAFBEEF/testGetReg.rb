

require "./GetNextReg.rb"

g = GetNextReg.new

r9 = g.getNext
r10 = g.getNext
r11 = g.getNext

r0 = g.getNext
r1 = g.getNext
r2 = g.getNext
r3 = g.getNext
r4 = g.getNext
r5 = g.getNext
r6 = g.getNext
r7 = g.getNext
r8 = g.getNext

v0 = g.getNext
v1 = g.getNext
v2 = g.getNext

puts r9
puts r10
puts r11
puts r0
puts r1
puts r2
puts r3
puts r4
puts r5
puts r6
puts r7
puts r8
puts v0
puts v1
puts v2

g.free(r10)
g.free(r2)
g.free(r7)
g.free(v1)
g.free(v2)

rx = g.getNext
ry = g.getNext
rz = g.getNext
vx = g.getNext
vy = g.getNext
vz = g.getNext

puts rx
puts ry
puts rz
puts vx
puts vy
puts vz


