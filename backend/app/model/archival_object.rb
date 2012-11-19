require 'securerandom'

class ArchivalObject < Sequel::Model(:archival_object)
  plugin :validation_helpers
  include ASModel
  include Subjects
  include Extents
  include Dates
  include ExternalDocuments
  include RightsStatements
  include Instances
  include Agents

  set_model_scope :repository


  def before_create
    super
    self.ref_id = SecureRandom.hex if self.ref_id.nil?
  end


  def self.set_hierarchy(obj, json, opts)

    if !obj.resource_id
      return
    end

    parent_id = json.parent ? JSONModel::parse_reference(json.parent, opts)[:id] : -1

    self.db[:archival_object_hierarchy].
         filter(:parent_id => parent_id,
                :archival_object_id => obj.id).delete


    # If the request includes a specific position, make sure it's free
    if json.position && self.db[:archival_object_hierarchy].
           filter(:parent_id => parent_id,
                  :position => json.position).count > 0

      self.db[:archival_object_hierarchy].
           filter(:parent_id => parent_id).
           filter{|row| row.position >= json.position}.
           update(:position => :position + 1)
    end


    position = json.position || self.db[:archival_object_hierarchy].
                    filter(:parent_id => parent_id).
                    count

    while true
      position += 1

      begin
        self.db[:archival_object_hierarchy].
             insert(:archival_object_id => obj.id,
                    :parent_id => parent_id,
                    :position => position)

        return
      rescue Sequel::DatabaseError => e
        if DB.is_integrity_violation(e)
          Log.info("Integrity conflict when setting position of new record.  Retrying...")
          sleep rand * 5
        else
          raise e
        end
      end
    end
  end


  def children
    ArchivalObject.this_repo.join(:archival_object_hierarchy, :archival_object_id => :id).
                   filter(:parent_id => self.id).
                   order(:position).all
  end


  def has_children?
    self.class.db[:archival_object_hierarchy].
         filter(:parent_id => self.id).count > 0
  end


  def self.set_resource(json, opts)
    opts["resource_id"] = nil

    if json.resource
      opts["resource_id"] = JSONModel::parse_reference(json.resource, opts)[:id]
    end
  end


  def self.create_from_json(json, opts = {})
    set_resource(json, opts)
    obj = super
    set_hierarchy(obj, json, opts)

    obj
  end


  def update_from_json(json, opts = {})
    # don't allow ref_id to be updated
    json.ref_id = self.ref_id

    self.class.set_resource(json, opts)
    obj = super
    self.class.set_hierarchy(obj, json, opts)

    obj
  end


  def self.sequel_to_jsonmodel(obj, type, opts = {})
    json = super

    if obj.resource_id
      json.resource = uri_for(:resource, obj.resource_id)

      hierarchy = self.db[:archival_object_hierarchy].
                       filter(:archival_object_id => obj.id).first

      if hierarchy && hierarchy[:parent_id] > 0
        json.parent = uri_for(:archival_object, hierarchy[:parent_id])
      end
    end

    json
  end


  def validate
    validates_unique([:resource_id, :ref_id],
                     :message => "An Archival Object Ref ID must be unique to its resource")
    map_validation_to_json_property([:resource_id, :ref_id], :ref_id)
    super
  end


  def self.records_matching(query, max)
    self.this_repo.where(Sequel.like(Sequel.function(:lower, :title),
                                     "#{query}%".downcase)).first(max)
  end

end
