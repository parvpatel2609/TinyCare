import cv2
from flask import Flask, Response, jsonify

faceCascade = cv2.CascadeClassifier("C:/Users/Parv Patel/Documents/GitHub/MyApp/flutter_application_1/lib/python_services/haarcascade_frontalface_default.xml")
eyesCascade = cv2.CascadeClassifier("C:/Users/Parv Patel/Documents/GitHub/MyApp/flutter_application_1/lib/python_services/haarcascade_eye.xml")

app = Flask(__name__)

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
    # eye_detected = False;

    if len(face_coord) == 4:
        roi_img = img[face_coord[1]:face_coord[1]+face_coord[3], face_coord[0]:face_coord[0]+face_coord[2]]
        eye_coord = draw_boundary(roi_img, eyeCascade, 1.1, 14, color['red'], "Eyes")
        # if len(eye_coord) == 4:
        #     eye_detected = True
    return img


@app.route('/do_something', methods=['POST'])
def do_something():
    video_capture = cv2.VideoCapture(0)
    if not video_capture.isOpened():
        return jsonify({'error': 'Could not open video device'})
    
    # eye_detected = False
    
    while True:
        ret, img = video_capture.read()
        if not ret:
            break  # Exit the loop if the frame is not captured successfully

        img = detect(img, faceCascade, eyesCascade)
        cv2.imshow("Face detection", img)

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

        # if eye_detected:
        #     return jsonify({'message': 'Eyes detected'})
        # else:
        #     return jsonify({'message': 'Eyes not detected'})

    video_capture.release()
    cv2.destroyAllWindows()
    return jsonify({'Program is closed'})



#sending just video feed to app 
cap = cv2.VideoCapture(0)
def video():    
    if not cap.isOpened():
        return jsonify({'error': 'Could not open video device'})
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        # print("Frame: ", frame)
        flag, encodedImage = cv2.imencode(".jpg", frame)
        # print("EncodedImages : " , encodedImage)
        if not flag:
            continue
        yield(b'--frame\r\n' b'Content-Type: image/jpeg\r\n\r\n' + bytearray(encodedImage) + b'\r\n')

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()


@app.route("/video_feed")
def video_feed():
    str =  Response(video(), mimetype="multipart/x-mixed-replace; boundary=frame")
    print("We are in video_feed function: ",str)
    return str



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8030, debug=False)