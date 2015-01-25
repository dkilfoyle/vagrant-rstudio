module Test_webmin =

let conf = "port=20000
realm=Usermin Server
denyfile=\.pl$
"

test Usermin.lns get conf =
   { "port" = "20000" }
   { "realm" = "Usermin Server" }
   { "denyfile" = "\.pl$" }
