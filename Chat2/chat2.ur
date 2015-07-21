structure Room : sig
   type id
   val rooms : transaction (list {Id : id, Title : string})
   val chat : id -> transaction page
end = struct

   table room : { Id : int, Title : string }
   table message : { Room : int, When : time, Text : string }

   val rooms = queryL1 (SELECT * FROM room ORDER BY room.Title)

   fun chat id =
    let
        fun say r =
            (* dml Run a piece of SQL code for its side effect of mutating the db *)
            dml (INSERT INTO message (Room, When, Text)
                 VALUES ({[id]}, CURRENT_TIMESTAMP, {[r.Text]}));
            chat id
    in
        (* oneRowE1 Run an SQL query that should return just one result
           row containing just a single column *)
        title <- oneRowE1 (SELECT (room.Title) FROM room WHERE room.Id = {[id]});
        (* Run an SQL query that returns columns from a single table
           calling an argument function on every result row *)
        log <- queryX1 (SELECT message.Text FROM message
                        WHERE message.Room = {[id]} ORDER BY message.When)
                        (fn r => <xml>{[r.Text]}<br/></xml>);
        return <xml><body>
        <h1>Chat Room: {[title]}</h1>
        <form>
            Add message: <textbox{#Text}/>
            <submit value="Add" action={say}/>
        </form>
        <hr/>
        {log}
        </body></xml>
    end

end

fun main () =
   rooms <- Room.rooms;
   return <xml><body>
             <h1>List of Rooms</h1>
             {List.mapX (fn r => 
                            <xml><li><a link={Room.chat r.Id}>{[r.Title]}</a></li></xml>) 
                        rooms}
          </body></xml>


