# JobProcessing

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Request Format

  * In order to get json response, please run the following curl request with application/json accept header

`curl -d '{"tasks": [ { "name": "task-1", "command": "rm /tmp/file1" }, { "name": "task-2", "command": "rm /tmp/file2" } ] }' -H "Content-Type: application/json" -H "Accept: application/json" -X POST http://localhost:4000/process-jobs`


  * Also service returns text response, please run the following curl request with text/plain accept header

`curl -d '{"tasks": [ { "name": "task-1", "command": "rm /tmp/file1" }, { "name": "task-2", "command": "rm /tmp/file2" } ] }' -H "Content-Type: application/json" -H "Accept: text/plain" -X POST http://localhost:4000/process-jobs`

