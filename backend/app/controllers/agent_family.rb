class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/agents/families')
    .description("Create a family agent")
    .params(["agent", JSONModel(:agent_family), "The family to create", :body => true],
            ["repo_id", :repo_id])
    .returns([200, :created],
             [400, :error]) \
  do
    handle_create(AgentFamily, :agent)
  end


  Endpoint.post('/repositories/:repo_id/agents/families/:agent_id')
    .description("Update a family agent")
    .params(["agent_id", Integer, "The ID of the agent to update"],
            ["agent", JSONModel(:agent_family), "The family to create", :body => true],
            ["repo_id", :repo_id])
    .returns([200, :updated],
             [400, :error]) \
  do
    handle_update(AgentFamily, :agent_id, :agent,
                    :repo_id => params[:repo_id])
  end


  Endpoint.get('/repositories/:repo_id/agents/families/:id')
    .description("Get a family by ID")
    .params(["id", Integer, "ID of the family agent"],
            ["repo_id", :repo_id])
    .returns([200, "(:agent)"],
             [404, '{"error":"Agent not found"}']) \
  do
    json_response(AgentFamily.to_jsonmodel(AgentFamily.get_or_die(params[:id]),
                                           :agent_family,
                                           params[:repo_id]))
  end

end
