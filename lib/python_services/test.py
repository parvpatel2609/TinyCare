import asyncio
import websockets
import cv2
import base64

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
    print("Server started")
    async with websockets.serve(send_video, "0.0.0.0", 8765):
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
