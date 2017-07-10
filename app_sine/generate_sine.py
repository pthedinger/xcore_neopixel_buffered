import math

num_colors = 256
num_gaps = 9
gap_size = 256

ys = []
for i in range(0,num_colors):
	ys.append(int( (math.sin(i* 2 * math.pi / num_colors) + 1)/2.0 * gap_size * num_gaps))

print "{ %s }" % ", ".join(["%4d" % y for y in ys])
