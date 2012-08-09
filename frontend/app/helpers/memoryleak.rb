require 'atomic'

module MemoryLeak

  class Repositories

    @@repositories = Atomic.new(nil)

    def self.get
      if @@repositories.value.nil?
        self.refresh
      end

      @@repositories.value
    end


    def self.refresh
      @@repositories.swap(JSONModel(:repository).all)
    end

  end

end
