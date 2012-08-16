require 'thread'
require 'java'
require 'net/http'
require 'set'

class Webhooks

  @@mutex = Mutex.new
  @@listeners = Set.new

  puts "Starting worker pool"
  @@workers = java.util.concurrent.Executors.newFixedThreadPool(10)


  def self.add_listener(url)
    @@mutex.synchronize do
      @@listeners << url
    end
  end


  def self.notify(code, params = {})

    @@listeners.each do |url|

      job = Class.new do

        def self.setup(url, code, params)
          @url = url
          @code = code
          @params = params
        end

        def self.run
          begin
            uri = URI(@url)
            http = Net::HTTP.new(uri.host, uri.port)

            http.open_timeout = 2
            http.read_timeout = 2

            req = Net::HTTP::Post.new(uri.request_uri)
            req.form_data = {"code" => @code}.merge(@params)

            http.start do |http|
              http.request(req) do |response|
              end
            end
          rescue
            # Oh well!
          end
        end
      end

      job.setup(url, code, params)
      @@workers.execute(job)

    end
  end


  def self.shutdown
    @@workers.shutdown
  end

end
