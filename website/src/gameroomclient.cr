require "http/web_socket"

WS_URI = URI.parse("ws://0.0.0.0:8081/room/test")

ws = HTTP::WebSocket.new(WS_URI)

ws.on_message do |rcv|
  puts "Received message:\n#{rcv}\n\n"
end

spawn do
  loop do
    msg = gets.to_s
    ws.send msg
  end
end

ws.run
