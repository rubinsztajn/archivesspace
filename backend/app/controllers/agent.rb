class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/repositories/:repo_id/agents')
    .params( ["repo_id", :repo_id])
    .description("Get all agent records")
    .returns([200, "[(:agent)]"]) \
  do
    agents = [[AgentPerson, :agent_person],
              [AgentFamily, :agent_family],
              [AgentCorporateEntity, :agent_corporate_entity],
              [AgentSoftware, :agent_software]].map do |model, type|

      model.all.collect {|agent| model.to_jsonmodel(agent, type, params[:repo_id]).to_hash}
    end

    json_response(agents.flatten)
  end

end
