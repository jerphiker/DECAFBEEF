

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

puts r9			#	R9
puts r10		#	R10
puts r11		#	R11
puts r0			#	R0
puts r1			#	R1
puts r2			#	R2
puts r3			#	R3
puts r4			#	R4
puts r5			#	R5
puts r6			#	R6
puts r7			#	R7
puts r8			#	R8
puts v0			#	V0
puts v1			#	V1
puts v2			#	V2

g.free(r10)
r10 = nil
g.free(r2)
r2 = nil
g.free(r7)
r7 = nil
g.free(v1)
v1 = nil
g.free(v2)
v2 = nil

rx = g.getNext
ry = g.getNext
rz = g.getNext
vx = g.getNext
vy = g.getNext
vz = g.getNext

puts rx			#	R10
puts ry			#	R2
puts rz			#	R7
puts vx			#	V1
puts vy			#	V2
puts vz			#	V3


