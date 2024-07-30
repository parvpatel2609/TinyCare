import cv2
import time

faceCascade = cv2.CascadeClassifier("C:/Users/Parv Patel/Documents/GitHub/MyApp/flutter_application_1/lib/python_services/haarcascade_frontalface_default.xml")
eyesCascade = cv2.CascadeClassifier("C:/Users/Parv Patel/Documents/GitHub/MyApp/flutter_application_1/lib/python_services/haarcascade_eye.xml")

def draw_boundary(img, classifier, scaleFactor, minNeighbours, color, text):
    gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    features = classifier.detectMultiScale(gray_img, scaleFactor, minNeighbours)
    coords = []
    for (x, y, w, h) in features:
        cv2.rectangle(img, (x, y), (x+w, y+h), color, 2)
        cv2.putText(img, text, (x, y-4), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 1, cv2.LINE_AA)
        coords = [x, y, w, h]
    return coords

def detect(img, faceCascade, eyeCascade):
    color = {"blue": (255, 0, 0), "red": (0, 0, 255), "green": (0, 255, 0)}
    face_coord = draw_boundary(img, faceCascade, 1.1, 10, color['blue'], "Face")
    eyes_open = False

    if len(face_coord) == 4:
        roi_img = img[face_coord[1]:face_coord[1]+face_coord[3], face_coord[0]:face_coord[0]+face_coord[2]]
        eye_coord = draw_boundary(roi_img, eyeCascade, 1.1, 14, color['red'], "Eyes")

        # Check if eyes are detected
        if len(eye_coord) == 4:
            eyes_open = True
            # cv2.putText(img, "Eyes Open", (face_coord[0], face_coord[1] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color['green'], 2, cv2.LINE_AA)
        # else:
            # cv2.putText(img, "Eyes Closed", (face_coord[0], face_coord[1] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color['red'], 2, cv2.LINE_AA)

        # if eyes_open: 
        #     await asyncio.sleep(900)
    
    # if eyes_open:
    #     asyncio.sleep(900)  # 15 minutes delay if eyes are open
        
    return img, eyes_open

# checking condition with 
def monitor_eye(lock, frame, flag):
    # print("starting code of eye checking")
    try:
        # time.sleep(1)
        while True:
            with lock:
                stream = frame[0]
            # print(stream)
            if stream is None:
                continue
            cv2.imshow('Face', stream)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            _, open = detect(stream, faceCascade, eyesCascade)
            time.sleep(0.5)
            
            if open:
                print("Eye open!!")
                with lock:
                    flag.append(True)
                    print("true : ",flag)
                cv2.destroyAllWindows()
                time.sleep(1)
                monitor_eye(lock, frame, flag)
                
            else:
                with lock:
                    flag.append(False)
                    print("false : ", flag)
                cv2.destroyAllWindows()
                time.sleep(1)
                monitor_eye(lock, frame, flag)
            
            size = len(flag)
            if size>12:
                print("inside deleting cach memory")
                with lock:
                    del flag[0::10]
            
            # print("Eye checking condition result: ", open)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        print("we are outside the monitor_eye function")