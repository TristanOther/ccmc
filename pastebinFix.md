1. Open computer (not to be confused with OpenComputers).
2. Open Lua by typing `lua`.
3. Paste the following:
```
local r = http.get("https://pastebin.com/raw/jCfCfBPn"); local f = fs.open( shell.resolve( "pastebin" ), "w" ); f.write( r.readAll() ); f.close(); r.close()
```
4. Fixed.

Credit BookerTheGeek on mineyourmind.net.