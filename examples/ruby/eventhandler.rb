#!/usr/bin/env ruby

require 'websocket-eventmachine-client'
require 'json'
require 'date'

EM.run do

  ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://localhost:3000/ws')

  ws.onopen do
    puts "Connected"
  end

  ws.onmessage do |msg, type|
    puts "Received message: #{msg}"
    event = JSON.parse(msg)

    case event['name']
    when 'check-domain'
      sleep(1)
      results = event['data'].map do |domain_name|
        {name: domain_name, availability: 'available'}
      end
      message = JSON.generate({name: 'check-domain-completed', data: results})
      ws.send message
    when 'register-domain'
      received_data = event['data']
      sleep(2)
      results = {
        name: received_data['name'],
        registered: true,
        expiration: (Date.today + 365).rfc3339
      }
      message = JSON.generate({name: 'register-domain-completed', data: results})
      ws.send message
    end
  end

  ws.onclose do |code, reason|
    puts "Disconnected with status code: #{code}"
  end

end
