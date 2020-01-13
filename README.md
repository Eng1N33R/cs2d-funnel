# CS2D Funnel

Funnel is a CS2D utility that receives external messages and directs them to a
CS2D server for processing. The Funnel project is split into two parts: the
Funnel companion app itself, written in Go, and the Lua module for use on the
CS2D server.

The Funnel companion app is designed for use with Docker, and the Docker image
is in turn designed to be as minimal as possible: it is a single layer only
7.59 MB in size.

CS2D JIT is **not required** for the Lua module to work.

## Installation

Copy the contents of the `lua` directory to your server installation's `sys/lua`
directory.

### Docker

```
$ docker run --always -v path/to/cs2d:/out -p XXXX:8090 engin33r/cs2d-funnel:latest
```

### Docker compose

```
version: '3.1'

services:
  funnel:
    image: engin33r/cs2d-funnel:latest
    restart: always
    ports:
      - 46963:8090
    volumes:
      - serverdata:/out
  server:
    image: engin33r/cs2d-server-xch:latest
    restart: always
    ports:
      - 36963:36963/udp
    volumes:
      - serverdata:/cs2d
      - luarocks:/root/rocks

volumes:
  serverdata:
  luarocks:
```

### From source

```
$ make
```

#### PowerShell

```
$ ./build
```

#### Other
```
$ go build src/funnel.go
```

## Usage

If you're using the Docker image, make sure the host directory for `/out` is the
root directory of your CS2D server (containing `cs2d_dedicated`).

If you're running Funnel using the binary, set the `CS2DFUNNEL_ROOT` environment
variable to the root directory of your CS2D installtion.

### Examples

```lua
require("xch")

xch.on("test", function(data)
    msg("recvd: " .. data)
end)
```

HTTP request:
```
GET /recv?chan=test&data=hello
```

In-game:
```
recvd: hello
```

### Funnel API

| Request | Parameters | Description |
| ------- | ---------- | ----------- |
| `GET /recv` | `chan=[CHANNEL]&data=[DATA]` | Send message to server. |

### XCH Lua API

| Function | Returns | Description |
| -------- | ------- | ----------- |
| `xch.on(chan:string, cb:function)` | None | Calls `cb(data:string)` when a message is received on channel `chan`. |