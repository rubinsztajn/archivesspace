class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/agents/people')
    .description("Create a person agent")
    .params(["agent", JSONModel(:agent_person), "The person to create", :body => true],
            ["repo_id", :repo_id])
    .returns([200, :created],
             [400, :error]) \
  do
    handle_create(AgentPerson, :agent)
  end


  Endpoint.post('/repositories/:repo_id/agents/people/:agent_id')
    .description("Update a person agent")
    .params(["agent_id", Integer, "The ID of the agent to update"],
            ["agent", JSONModel(:agent_person), "The person to create", :body => true],
            ["repo_id", :repo_id])
    .returns([200, :updated],
             [400, :error]) \
  do
    handle_update(AgentPerson, :agent_id, :agent,
                    :repo_id => params[:repo_id])
  end


  Endpoint.get('/repositories/:repo_id/agents/people/:id')
    .description("Get a person by ID")
    .params(["id", Integer, "ID of the person agent"],
            ["repo_id", :repo_id])
    .returns([200, "(:agent)"],
             [404, '{"error":"Agent not found"}']) \
  do
    json_response(AgentPerson.to_jsonmodel(AgentPerson.get_or_die(params[:id]),
                                           :agent_person,
                                           params[:repo_id]))
  end

end
