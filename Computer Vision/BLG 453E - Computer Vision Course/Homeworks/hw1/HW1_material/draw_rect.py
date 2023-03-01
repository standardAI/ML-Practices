import numpy as np
import cv2
import os
import moviepy.editor as moviepy

planes = np.zeros((9,472,4,3))

for i in range(1,10):
	with open("Plane_"+str(i)+".txt") as f:
		content = f.readlines()
		for line_id in range(len(content)):
			sel_line = content[line_id]
			sel_line = sel_line.replace(')\n', '').replace("(", '').split(")")

			for point_id in range(4):
				sel_point = sel_line[point_id].split(" ")

				planes[i-1,line_id,point_id,0] = float(sel_point[0])
				planes[i-1,line_id,point_id,1] = float(sel_point[1])
				planes[i-1,line_id,point_id,2] = float(sel_point[2])

images_list = []

for i in range(472):
	blank_image = np.zeros((322,572,3), np.uint8)

	for j in range(9):

			pts = planes[j,i,:,:].squeeze()[:,0:2].astype(np.int32)

			temp = np.copy(pts[3,:])
			pts[3, :] = pts[2,:]
			pts[2, :] = temp

			pts = pts.reshape((-1, 1, 2))

			cv2.polylines(blank_image, [pts], True, (0, 255, 255))

	images_list.append(blank_image)


clip = moviepy.ImageSequenceClip(images_list, fps = 25)
clip.write_videofile("part1_vid.mp4", codec="libx264")

