class Extent < Sequel::Model(:extent)
  include ASModel
  set_model_scope :repository

  plugin :validation_helpers
  
  def self.create_from_json(json, opts = {})

    # Assume the Extent statement applies to the more granular
    # thing.
    if opts["resource_id"] and opts[:archival_object_id]
      opts.delete("resource_id")
    end
    
    super
  end
end
