module AgentPrimaryNameMixin

  def self.sequel_to_jsonmodel(obj, type, opts = {})
    json = super
    puts "TYPE: #{type.inspect}"
    if obj.names.length > 1
      agent_type = json.agent_type.split("_")[1]
      primary_name_id = self.class.db[:"#{agent_type}_primary_name_map"].
            filter(:"agent_#{agent_type}_id" => self.id).
            filter(:repo_id => opts[:repo_id])
            select(:"name_#{agent_type}_id")

      obj.names.sort! {|a,b| a.id === primary_name_id}
    end

    json
  end


  def update_from_json(json, opts = {})
    obj = super

    # delete all primary_name_map rows
    self.class.db[:"#{json.agent_type}_primary_name_map"].where(:repo_id => opts[:repo_id]).where(:"agent_id" => obj.id).delete

    if obj.send(:"name_#{json.agent_type.sub("agent_", "")}").length > 0
      self.class.db[:"#{json.agent_type}_primary_name_map"].insert(:repo_id => opts[:repo_id], :"agent_id" => obj.id, :"name_id" => obj.send(:"name_#{json.agent_type.sub("agent_", "")}")[0].id)
    end

    obj
  end


  def self.create_from_json(json, opts = {})
    obj = super

    if obj.send(:"name_#{json.agent_type.sub("agent_", "")}").length > 0
      self.class.db[:"#{agent_type}_primary_name_map"].insert(:repo_id => opts[:repo_id], :"agent_id" => obj.id, :"name_id" => obj.send(:"name_#{json.agent_type.sub("agent_", "")}")[0].id)
    end

    obj
  end

end
