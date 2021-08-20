# Game Room Protocol

This document described the possible messages that are passed between client and server to implement the game rooms. **The specification is not finished and will be expanded in the future.** All messages are in the following format

```<COMMAND>:<PAYLOAD>```

---

## From client to server

---

```START_ROUND:```

**GAME ROOM OWNER ONLY**. This is sent to the server to start a new round.

---

```SUBMIT:<code submission as JSON>```

This is sent to the server when finishing a submission. The format of the JSON is as of yet unspecified.

---

## From server to client

---

```ERROR:<description>```

Sent to the client when receiving a message that could not be handled.

---

```JOIN:<player name>```

This is broadcasted to ALL clients whenever a new player joins the game room.

---

```OWNER:<player name>```

This is broadcasted to ALL clients whenever the room owner changes.

---

```PROBLEM:<the problem as JSON>```

This is broadcasted to ALL clients whenever a new round starts. It is also sent to clients when they first join the room if a round is in progress.

---

```QUIT:<player name>```

This is broadcasted to ALL clients whenever a player leaves the room.

---

```ROUND_END:<results as JSON>```

This is broadcasted to ALL clients when a round ends. The format of the JSON is as of yet unspecified.

---

```SUBMITTED:<code submission as JSON>```

This is broadcasted to ALL clients after a submission is confirmed. The format of the JSON is as of yet unspecified.

---

```TIME_LEFT:<time left to solve the round (integer representing seconds)>```

This is broadcasted to ALL clients when a round starts. It is also sent to clients when they first join the room if a round is in progress.

---

