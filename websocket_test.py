#!/usr/bin/env python3
import asyncio, json, random, signal, sys
import websockets

URI = "ws://127.0.0.1:9080"

async def sender(ws):
    while True:
        msg = {"cmd": "heartbeat", "value": random.randint(0, 100)}
        await ws.send(json.dumps(msg))
        print("-> sent:", msg)
        await asyncio.sleep(2)

async def receiver(ws):
    async for raw in ws:
        print("<- recv:", raw)

async def main():
    # 1. 正确写法：websockets.connect
    async with websockets.connect(URI) as ws:
        print("Connected to", URI)
        # 2. 用 asyncio.gather 即可
        await asyncio.gather(sender(ws), receiver(ws))

def exit_handler(sig, frame):
    print("\nShutting down...")
    sys.exit(0)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, exit_handler)   # 3. 正确常量：SIGINT
    asyncio.run(main())