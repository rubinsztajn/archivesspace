require "jsonmodel"

JSONModel::init(:client_mode => true,
                :url => ArchivesSpace::Application.config.backend_url)

JSONModel::add_error_handler do |error|
  if error["code"] == "SESSION_GONE"
    raise ArchivesSpace::SessionGone.new("Your backend session was not found")
  end
end


JSONModel::add_notification_handler("REPOSITORY_CHANGED") do |msg|
  MemoryLeak::Resources.refresh(:repository)
end


JSONModel::add_notification_handler("VOCABULARY_CHANGED") do |msg|
  MemoryLeak::Resources.refresh(:vocabulary)
end


puts "Registering with backend"
JSONModel::webhook_register("http://localhost:3000/webhook/notify")

include JSONModel

