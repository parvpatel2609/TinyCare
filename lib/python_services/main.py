import asyncio
import base64
from threading import Thread, Lock
from video import send_video
from motion import monitor_eye
import websockets
import cv2
import time

lock = Lock()
local_count = Lock()
frame = [None]
flag = []

#video streaming to client
async def stream_camera_feed(websocket, path):
    try:
        print("streaming started")
        while True:
            with lock:
                _, buffer = cv2.imencode('.jpg', frame[0])  
            # print(buffer) 
            jpg_as_text = base64.b64encode(buffer).decode('utf-8')
            await websocket.send(jpg_as_text)
            await asyncio.sleep(0.1)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        print("streaming camera feed function is closed here")
        
async def start_server():
    print("Server for video streaming stared") 
    async with websockets.serve(stream_camera_feed, "0.0.0.0", 8760):
        await asyncio.Future()  # run forever
        
def run_server():
    asyncio.run(start_server())
    
    
#sending alert message to client
async def alert_send_to_client(websocket, self):
    try:
        count = 0
        print("We are inside alert_send_to_client function")
        while True:
            if flag[len(flag)-1] != flag[len(flag)-2]:
                local_count.acquire()    
                count = 1
                local_count.release()
            time.sleep(0.5)
            if flag[len(flag)-1] != flag[len(flag)-2] and count==1:
                local_count.acquire()
                count = 0
                local_count.release()
                await websocket.send(str(flag[len(flag)-1]))                    
                await asyncio.sleep(0.9)
    except Exception as e:
        print(f"Error in alert sending: {e}")
    finally:
        print("end of the alert sending function")
        
            
async def server_alert():
    print("Server_alert function started")
    async with websockets.serve(alert_send_to_client, "0.0.0.0", 8765):
        await asyncio.Future()    #run forever


def run_alert_server():
    asyncio.run(server_alert())



if __name__ == '__main__':
    print("Server started")
    #capture the video frame from the camera thread
    t1 = Thread(target=send_video, args=(lock, frame, ))
    #start the server and send that capture video frame to client device
    t2 = Thread(target=run_server)
    #checking baby's eye are open or not
    t3 = Thread(target=monitor_eye, args=(lock, frame, flag, ))
    #send alert to the client for sending notification 
    t4 = Thread(target=run_alert_server)
    t1.start()
    t2.start()
    t3.start()
    t4.start()
    # asyncio.run(start_server())