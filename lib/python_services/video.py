import cv2

def send_video(lock,frame):    
    print("Client connected with baby video streaming function")
    cap = cv2.VideoCapture(0)  # Open the default camera
    if not cap.isOpened():
        print("Error: Could not open camera.")
        return
    while True:
        ret, frame_data = cap.read()
        if not ret:
            print("Error: Failed to grab frame.")
            break
        with lock:
            frame[0] = frame_data
            # print("video.py - Frame captured")
        # Display the resulting frame
        # cv2.imshow('Camera Feed', frame_data)
        # Press 'q' on the keyboard to exit the loop
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cap.release()
    cv2.destroyAllWindows()
    print("Client disconnected with baby video streaming function")