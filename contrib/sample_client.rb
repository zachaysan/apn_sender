require 'apn'
require 'thread'

ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
CONFIG = {
  certificate: "cert.pem"
}

APN.root = File.join(ROOT, "contrib")
APN.pool_size = 5
APN.logger.level = Logger::DEBUG
APN.host = "127.0.0.1"

t = nil

5.times do
  t = Thread.new do
    loop do
      begin
        APN.notify_sync("to ken", CONFIG.dup.merge(alert: "hi" * 100))
      rescue
        $stderr.puts $!
      end
    end
  end
end

t.join
