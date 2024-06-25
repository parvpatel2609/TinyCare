import asyncio
import base64
import cv2
import websockets
# from flask import Flask, render_template
# from flask_socketio import SocketIO, emit

# faceCascade = cv2.CascadeClassifier("C:/Users/Parv Patel/Documents/GitHub/MyApp/flutter_application_1/lib/python_services/haarcascade_frontalface_default.xml")
# eyesCascade = cv2.CascadeClassifier("C:/Users/Parv Patel/Documents/GitHub/MyApp/flutter_application_1/lib/python_services/haarcascade_eye.xml")

# app = Flask(__name__)
# socketio = SocketIO(app)

# @socketio.on('connect')
# def handle_connect():
#     print('Client connected with socketio server')

# @socketio.on('disconnect')
# def handle_disconnect():
#     print('Client disconnected with socketio server')


# def draw_boundary(img, classifier, scaleFactor, minNeighbours, color, text):
#     gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
#     features = classifier.detectMultiScale(gray_img, scaleFactor, minNeighbours)
#     coords = []
#     for (x, y, w, h) in features:
#         cv2.rectangle(img, (x, y), (x+w, y+h), color, 2)
#         cv2.putText(img, text, (x, y-4), cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 1, cv2.LINE_AA)
#         coords = [x, y, w, h]
#     return coords

# def detect(img, faceCascade, eyeCascade):
#     color = {"blue": (255, 0, 0), "red": (0, 0, 255), "green": (0, 255, 0)}
#     face_coord = draw_boundary(img, faceCascade, 1.1, 10, color['blue'], "Face")
#     if len(face_coord) == 4:
#         roi_img = img[face_coord[1]:face_coord[1]+face_coord[3], face_coord[0]:face_coord[0]+face_coord[2]]
#         eye_coord = draw_boundary(roi_img, eyeCascade, 1.1, 14, color['red'], "Eyes")
#     return img


async def send_video(websocket, path):
        print("Client connected")
        cap = cv2.VideoCapture(0)  # Open the default camera

        try:
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                
                # Encode the frame as JPEG
                _, buffer = cv2.imencode('.jpg', frame)
                
                # Convert to base64
                jpg_as_text = base64.b64encode(buffer).decode('utf-8')
                
                # Send the frame over the websocket
                await websocket.send(jpg_as_text)
                
                # Small delay to control frame rate
                await asyncio.sleep(0.1)
        except Exception as e:
            print(f"Error: {e}")
        finally:
            cap.release()
            print("Client disconnected")

async def main():
    print("Server stared")
    async with websockets.serve(send_video, "0.0.0.0", 8765):
        await asyncio.Future()  # run forever




# sending alert message to the dart project about eye are open
# @app.route('/do_something', methods=['POST'])
# def do_something():
#     video_capture = cv2.VideoCapture(0)
#     if not video_capture.isOpened():
#         return jsonify({'error': 'Could not open video device'})
    
#     while True:
#         ret, img = video_capture.read()
#         if not ret:
#             break  # Exit the loop if the frame is not captured successfully

#         img = detect(img, faceCascade, eyesCascade)
#         cv2.imshow("Face detection", img)

#         if cv2.waitKey(1) & 0xFF == ord('q'):
#             break
#     video_capture.release()
#     cv2.destroyAllWindows()
#     return jsonify({'Program is closed'})




#sending just video feed to app 
# socketio.on('video_feed')
# def video():    
#     print("Hello we are in video_feed")
#     cap = cv2.VideoCapture(0)
#     while True:
#         ret, frame = cap.read()
#         if ret:
#             cv2.imshow("Face detection", frame)
#             if cv2.waitKey(1) & 0xFF == ord('q'):
#                 break

#             _, encoded_image = cv2.imencode('.jpg', frame)
#             frame_data = encoded_image.tobytes()
#             # print("Frame Data: ", frame_data)
#             # Send the frame to the client
#             emit('frame', frame_data)
#         else:
#             print("Error capturing frame")
#             cap.release()
#             cv2.destroyAllWindows()
#             break

    # cap.release()
    # cv2.destroyAllWindows()


if __name__ == '__main__':
    asyncio.run(main())
    # socketio.run(app, debug=True)
    # app.run(host='0.0.0.0', port=8030, debug=False)