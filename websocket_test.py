import asyncio, websockets

async def on_connect(websocket):
    print(">>> 有客户端连上了")
    async for msg in websocket:              # 持续收消息
        print("收到消息:", msg)
        await websocket.send("服务端已收到: " + msg)  # 回一条
    print("<<< 客户端已断开")

async def main():
    async with websockets.serve(on_connect, "localhost", 8765):
        print("WebSocket 服务已启动 ws://localhost:8765")
        await asyncio.Future()               # 一直跑着

if __name__ == "__main__":
    asyncio.run(main())