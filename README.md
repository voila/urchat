### UrChat

A simple web chat implemented with Ur/Web.
This code is extracted from the following paper: [Ur/Web: A Simple Model for Programming the Web](http://adam.chlipala.net/papers/UrWebPOPL15/).

It compiles with the Ur/Web compiler, version 20150520.
Download it from the [Ur/Web website](http://www.impredicative.com/ur/).

#### Building the code

#####with sqlite

````$ urweb -dbms sqlite -db chat1.db chat1````

````$ cat chat1.sql | sqlite3 chat1.db````

````$ ./chat1.exe````

Go to http://localhost:8080/Chat1/main
