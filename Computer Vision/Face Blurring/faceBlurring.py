import cv2
import face_recognition


cap = cv2.VideoCapture(0)
#faceCascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')

while True:
    _, img = cap.read()
    #faces = faceCascade.detectMultiScale(img, scaleFactor=1.05, minNeighbors=5)
    faceLoc = face_recognition.face_locations(img)
    if faceLoc:
        faceLoc = faceLoc[0]
        (x1, y1, x2, y2) = faceLoc[3], faceLoc[0], faceLoc[1], faceLoc[2]
        img[y1:y1+y2, x1:x1+x2] = cv2.blur(img[y1:y1+y2, x1:x1+x2], (23,23))
        cv2.imshow('Face Blurring', img)
    else:
        cv2.imshow('Face Blurring', img)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
