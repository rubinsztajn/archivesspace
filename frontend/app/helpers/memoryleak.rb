require 'atomic'

module MemoryLeak

  class Resources

    @@resources = {
      :repository => Atomic.new(nil),
      :vocabulary => Atomic.new(nil)
    }


    def self.get(resource)
      if @@resources[resource].value.nil?
        self.refresh(resource)
      end

      @@resources[resource].value
    end


    def self.refresh(resource)
      @@resources[resource].swap(JSONModel(resource).all)
    end

  end

end
