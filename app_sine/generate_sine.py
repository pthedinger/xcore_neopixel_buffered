import math

num_cols = 100

ys = []
for i in range(0,num_cols):
	ys.append(int((math.sin(i* 2 * math.pi / num_cols) + 1) * 20))

print "{ %s }" % ", ".join([str(y) for y in ys])
