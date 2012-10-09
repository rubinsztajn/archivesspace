{
  :schema => {
    "$schema" => "http://www.archivesspace.org/archivesspace.json",
    "type" => "object",
    "parent" => "abstract_agent",
    "uri" => "/repositories/:repo_id/agents/software",
    "properties" => {
      "names" => {
        "type" => "array",
        "items" => {"type" => "JSONModel(:name_software) uri_or_object"},
        "ifmissing" => "error",
        "minItems" => 1
      },
    },
  },
}