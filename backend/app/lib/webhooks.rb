require 'thread'
require 'java'
require 'net/http'
require 'set'

class Webhooks

  @@mutex = Mutex.new

  def self.add_listener(url)
    DB.open do |db|
      begin
        db[:webhook_endpoints].insert(:url => url)
      rescue
      end
    end
  end


  def self.notify(code, params = {})

    listeners = DB.open do |db|
      db[:webhook_endpoints].select(:url).map {|row| row[:url] }
    end

    listeners.each do |url|
      Thread.new do
        begin
          uri = URI(url)
          http = Net::HTTP.new(uri.host, uri.port)

          http.open_timeout = 2
          http.read_timeout = 2

          req = Net::HTTP::Post.new(uri.request_uri)
          req.form_data = {"code" => code}.merge(params)

          http.start do |http|
            http.request(req) do |response|
            end
          end
        rescue
          # Oh well!
        end
      end
    end
  end

end
