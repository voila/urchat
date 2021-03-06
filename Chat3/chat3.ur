structure Room : sig
   type id
   val rooms : transaction (list {Id : id, Title : string})
   val chat : id -> transaction page
end = struct

   table room : { Id : int, Title : string }
   table message : { Room : int, When : time, Text : string }

   val rooms = queryL1 (SELECT * FROM room ORDER BY room.Title)

   (* New code w.r.t. Figure 2 starts here. *)
   fun chat id =
       let
           fun say text lastSeen =
               dml (INSERT INTO message (Room, When, Text)
                    VALUES ({[id]}, CURRENT_TIMESTAMP, {[text]}));
               queryL1 (SELECT message.Text, message.When
                        FROM message
                        WHERE message.Room = {[id]}
                        AND message.When > {[lastSeen]}
                        ORDER BY message.When DESC)

           val maxTimestamp =
               List.foldl (fn r acc => max r.When acc) minTime
           in
               title <- oneRowE1 (SELECT (room.Title) FROM room
                                   WHERE room.Id = {[id]});
               initial <- queryL1 (SELECT message.Text, message.When FROM message
                                   WHERE message.Room = {[id]}
                                   ORDER BY message.When DESC);
               text <- source "";
               log <- Log.create;
               lastSeen <- source (maxTimestamp initial);
               return <xml><body onload={
                   List.app (fn r => Log.append log r.Text) initial}>
                   <h1>Chat Room: {[title]}</h1>
                   Add message: <ctextbox source={text}/>
                   <button value="Add" onclick={fn _ =>
                      txt <- get text; 
                      set text "";  
                      lastSn <- get lastSeen;
                      newMsgs <- rpc (say txt lastSn);
                      set lastSeen (maxTimestamp newMsgs);
                      List.app (fn r => Log.append log r.Text)
                      newMsgs}/>
                      <hr/>
                      {Log.render log}
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
