import cv2
import mediapipe as mp
import os
import numpy as np


# Source: https://stackoverflow.com/questions/40895785/using-opencv-to-overlay-transparent-image-onto-another-image
def add_transparent_image(background, foreground, x_offset=None, y_offset=None):
    bg_h, bg_w, bg_channels = background.shape
    fg_h, fg_w, fg_channels = foreground.shape

    assert bg_channels == 3, f'background image should have exactly 3 channels (RGB). found:{bg_channels}'
    assert fg_channels == 4, f'foreground image should have exactly 4 channels (RGBA). found:{fg_channels}'

    # center by default
    if x_offset is None: x_offset = (bg_w - fg_w) // 2
    if y_offset is None: y_offset = (bg_h - fg_h) // 2

    w = min(fg_w, bg_w, fg_w + x_offset, bg_w - x_offset)
    h = min(fg_h, bg_h, fg_h + y_offset, bg_h - y_offset)

    if w < 1 or h < 1: return

    # clip foreground and background images to the overlapping regions
    bg_x = max(0, x_offset)
    bg_y = max(0, y_offset)
    fg_x = max(0, x_offset * -1)
    fg_y = max(0, y_offset * -1)
    foreground = foreground[fg_y:fg_y + h, fg_x:fg_x + w]
    background_subsection = background[bg_y:bg_y + h, bg_x:bg_x + w]

    # separate alpha and color channels from the foreground image
    foreground_colors = foreground[:, :, :3]
    alpha_channel = foreground[:, :, 3] / 255  # 0-255 => 0.0-1.0

    # construct an alpha_mask that matches the image shape
    alpha_mask = np.dstack((alpha_channel, alpha_channel, alpha_channel))

    # combine the background with the overlay image weighted by alpha
    composite = background_subsection * (1 - alpha_mask) + foreground_colors * alpha_mask

    # overwrite the section of the background image that has been updated
    background[bg_y:bg_y + h, bg_x:bg_x + w] = composite



cap = cv2.VideoCapture(0)

while True:
    success, img = cap.read()
    img = cv2.resize(img, (1280, 960))
    mpDraw = mp.solutions.drawing_utils
    mpPose = mp.solutions.pose
    pose = mpPose.Pose(static_image_mode=False,
                                smooth_landmarks=True,
                                min_detection_confidence=0.5,
                                min_tracking_confidence=0.5)
    imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    results = pose.process(imgRGB)
    if results.pose_landmarks:
        mpDraw.draw_landmarks(img, results.pose_landmarks,
                                mpPose.POSE_CONNECTIONS)
    
    lmList = []
    bboxInfo = {}
    if results.pose_landmarks:
        for id, lm in enumerate(results.pose_landmarks.landmark):
            h, w, c = img.shape
            cx, cy, cz = int(lm.x * w), int(lm.y * h), int(lm.z * w)
            lmList.append([id, cx, cy, cz])
    if lmList:
        x11, y11 = lmList[11][1:3]
        x12, y12 = lmList[12][1:3]
        x_shirt = (x11 + x12) // 2
        y_shirt = (y11 + y12) // 2
        
        x5, y5 = lmList[5][1:3]
        x2, y2 = lmList[2][1:3]
        x_g = (x5 + x2) // 2
        y_g = (y2 + y5) // 2
        
        s_img = cv2.imread("shirt2.png", cv2.IMREAD_UNCHANGED)  # To read transparent image
        s_img = cv2.resize(s_img, (int((3.8/2)*abs(x11 - x12)), 500))
        g_img = cv2.imread("g7.png", cv2.IMREAD_UNCHANGED)
        g_img = cv2.resize(g_img, (int((5/2)*abs(x5 - x2)), 100))
        x_g -= g_img.shape[1] // 2
        y_g -= g_img.shape[0] // 2
        x_shirt -= s_img.shape[1] // 2 + 30
        y_shirt -= s_img.shape[0] // 4
        s_img = cv2.cvtColor(s_img, cv2.COLOR_BGR2BGRA)
        g_img = cv2.cvtColor(g_img, cv2.COLOR_BGR2BGRA)
        add_transparent_image(img, g_img, x_g, y_g)
        add_transparent_image(img, s_img, x_shirt, y_shirt)
        
    cv2.imshow("Virtual Try-On", img)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
