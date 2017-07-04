import math

num_cols = 256

ys = []
for i in range(0,num_cols):
	ys.append(int( (math.sin(i* 2 * math.pi / num_cols) + 1)/2.0 * 255))

print "{ %s }" % ", ".join(["SCALE(%3d)" % y for y in ys])
