{
  :schema => {
    "$schema" => "http://www.archivesspace.org/archivesspace.json",
    "type" => "object",
    "properties" => {
      "instance_type" => {"type" => "string", "minLength" => 1, "required" => true, "enum" => ["audio", "books", "computer_disks", "digital_object", "digital_object_link", "graphic_materials", "maps", "microform", "mixed_materials", "moving_images", "realia", "text"]},

      "container" => {"type" => "object", "type" => "JSONModel(:container) object"},
    },

    "additionalProperties" => false,
  },
}
