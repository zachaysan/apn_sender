#!/usr/bin/ruby
# Based on http://stackoverflow.com/a/5873796

require "socket"
require "openssl"
require "thread"

listeningPort = Integer(ARGV[0] || 2195)

server = TCPServer.new(listeningPort)
sslContext = OpenSSL::SSL::SSLContext.new
sslContext.cert = OpenSSL::X509::Certificate.new(File.open("apn_production.pem"))
sslContext.key = OpenSSL::PKey::RSA.new(File.open("priv.pem"))
sslServer = OpenSSL::SSL::SSLServer.new(server, sslContext)

puts "Listening on port #{listeningPort}"

connections = []
threads = {}
break_a_leg = false

Thread.new {
  loop do
    _ = STDIN.getc
    puts "Breaking a connection"
    begin
      connection = connections.sample
      if connection
        connection.close
        threads[connection].terminate
        connections.delete(connection)
        threads.delete(connection)
      end
    rescue
      $stderr.puts $!
    end
  end
}

loop do
  connection = sslServer.accept
  connections.push(connection)

  $stdout.puts "Connection accepted"

  threads[connection] = Thread.new {
    begin
      while (lineIn = connection.gets)
        lineIn = lineIn.chomp
        $stdout.puts "=> " + lineIn
        lineOut = "You said: " + lineIn
        $stdout.puts "<= " + lineOut
        connection.puts lineOut
      end
    rescue
      $stderr.puts $!
      raise
    end
  }
end
