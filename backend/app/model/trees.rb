module Trees

  def self.included(base)
    base.extend(ClassMethods)
  end


  # FIXME: refactor digital objects to remove tree_inline
  def tree
    if self.class.db.table_exists? "#{self.class.node_type}_hierarchy".intern
      tree_external
    else
      tree_inline
    end
  end

  def tree_external
    links = {}
    properties = {}

    root_type = self.class.root_type
    node_type = self.class.node_type
    node_type_id = "#{node_type}_id".intern
    hierarchy_table = "#{node_type}_hierarchy".intern

    top_nodes = []
    Kernel.const_get(node_type.to_s.camelize).this_repo.filter("#{root_type}_id".intern => self.id).each do |node|
      parent_id = self.class.db[hierarchy_table].filter(node_type_id => node.id).get(:parent_id)

      if parent_id && parent_id > 0
        links[parent_id] ||= []
        links[parent_id] << node.id
      else
        top_nodes << node.id
      end

      properties[node.id] = {
        :title => node.title,
        :id => node.id,
        :record_uri => self.class.uri_for(node_type, node.id),
        :node_type => node_type.to_s
      }
    end

    # Order the top-level nodes by their position
    top_nodes = self.class.db[hierarchy_table].
                     filter(node_type_id => top_nodes).
                     order(:position).
                     select(node_type_id).
                     map {|row| row[node_type_id]}

    result = {
      :title => self.title,
      :id => self.id,
      :node_type => root_type.to_s,
      :children => top_nodes.map {|node| self.class.assemble_tree(node, links, properties)},
      :record_uri => self.class.uri_for(root_type, self.id)
    }

    result
  end



  def tree_inline
    links = {}
    properties = {}

    root_type = self.class.root_type
    node_type = self.class.node_type

    top_nodes = []
    Kernel.const_get(node_type.to_s.camelize).this_repo.filter("#{root_type}_id".intern => self.id).each do |node|
      if node.parent_id
        links[node.parent_id] ||= []
        links[node.parent_id] << node.id
      else
        top_nodes << node.id
      end

      properties[node.id] = {
        :title => node.title,
        :id => node.id,
        :record_uri => self.class.uri_for(node_type, node.id),
        :node_type => node_type.to_s
      }
    end

    result = {
      :title => self.title,
      :id => self.id,
      :node_type => root_type.to_s,
      :children => top_nodes.map {|node| self.class.assemble_tree(node, links, properties)},
      :record_uri => self.class.uri_for(root_type, self.id)
    }

    result
  end


  module ClassMethods

    def tree_of(root_type, node_type)
      @root_type = root_type
      @node_type = node_type
    end


    def root_type
      @root_type
    end


    def node_type
      @node_type
    end


    def assemble_tree(node, links, properties)
      result = properties[node].clone

      if links[node]
        result['children'] = links[node].map do |child_id|
          assemble_tree(child_id, links, properties)
        end
      else
        result['children'] = []
      end

      result
    end

  end

end
