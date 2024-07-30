import asyncio
import base64
import cv2
import websockets

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
        
    return img, eyes_open


async def monitor_eye(websocket, self):
    print("Client connected with eye open or not checking function")
    moni = cv2.VideoCapture(0)  #open the default camera 
    try: 
        while moni.isOpened():
            ret, frame = moni.read()  #read the frame from the camera
            if not ret:
                break

            _, open = detect(frame, faceCascade, eyesCascade)
            cv2.imshow('Face', frame)
            
            if open: 
                print("Eye checking condition result: ", open)
                await websocket.send(str(open))
                moni.release()
                cv2.destroyAllWindows()
                await asyncio.sleep(900)  # 15 minutes delay if eyes are open
                await monitor_eye(websocket, self)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
            print("Eye checking condition result: ", open)
            
            
            # Check for incoming messages from the Flutter app
            message = websocket.recv()
            if message == 'stop_monitor_eye':
                print("Received stop_monitor_eye message, stopping monitor_eye function")
                # monitoring_eye_function = False
                break
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        moni.release()
        cv2.destroyAllWindows()
        print("Client disconnected with eye open or not checking function")


# streaming video feed of baby to their parents phone
async def send_video(websocket, path):    
    print("Client connected with baby video streaming function")
    cap = cv2.VideoCapture(0)  # Open the default camera

    try:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break            
            cv2.imshow("baby monitoring", frame)    
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
        print("Client disconnected with baby video streaming function")



async def main():
    print("Server stared")    
    async with websockets.serve(monitor_eye, "0.0.0.0", 8760):
        await asyncio.Future()  # run forever
    async with websockets.serve(send_video, "0.0.0.0", 8765):
        await asyncio.Future()  # run forever
    


if __name__ == '__main__':
    asyncio.run(main())
    # socketio.run(app, debug=True)
    # app.run(host='0.0.0.0', port=8030, debug=False)