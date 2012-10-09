require 'spec_helper'

describe 'Software agent controller' do


  before(:each) do
    make_test_repo
  end


  def create_software
    JSONModel(:agent_software).from_hash(:names => [{
                                                    "rules" => "local",
                                                    "manufacturer" => "Magoo Software",
                                                    "software_name" => "Eggplant car steering system",
                                                    "version" => "2.0",
                                                    "sort_name" => "Software, Magoo"
                                                  }],
                                       :agent_contacts => [{
                                                              "name" => "Business hours contact",
                                                              "telephone" => "0011 1234 1234"
                                                            }]
                                       ).save
  end


  it "lets you create a software agent and get them back" do
    id = create_software
    JSONModel(:agent_software).find(id).names.first['manufacturer'].should eq('Magoo Software')
  end

  it "lets you update a software agent" do
    id = create_software

    software = JSONModel(:agent_software).find(id)

    software.agent_contacts << {
      "name" => "A separate contact",
      "telephone" => "0118 999 881 999 119 725 3"
    }

    software.save

    JSONModel(:agent_software).find(id).agent_contacts[1]['name'].should eq("A separate contact")

  end


  it "lets you update a the primary name" do
    id = JSONModel(:agent_software).from_hash(:names => [{
                                                           "rules" => "local",
                                                           "manufacturer" => "Magoo Software",
                                                           "software_name" => "Eggplant car steering system",
                                                           "version" => "2.0",
                                                           "sort_name" => "Software, Magoo"
                                                         },
                                                         {
                                                           "rules" => "local",
                                                           "manufacturer" => "Another name for this manufacturer",
                                                           "software_name" => "Another name for this software",
                                                           "version" => "2.0",
                                                           "sort_name" => "Software, Magoo"
                                                         }]).save

    software = JSONModel(:agent_software).find(id)
    software.names[0]["software_name"].should eq("Eggplant car steering system")

    another_repo = Repository.create(:repo_code => "ANOTHER_REPO",
                             :description => "Another repository")
    JSONModel::set_repository(another_repo.id)

    software = JSONModel(:agent_software).find(id)
    software.names = [
               {
                 "rules" => "local",
                 "manufacturer" => "Another name for this manufacturer",
                 "software_name" => "Another name for this software",
                 "version" => "2.0",
                 "sort_name" => "Software, Magoo"
               },
               {
                 "rules" => "local",
                 "manufacturer" => "Magoo Software",
                 "software_name" => "Eggplant car steering system",
                 "version" => "2.0",
                 "sort_name" => "Software, Magoo"
               }]

    software.save

    software = JSONModel(:agent_software).find(id)
    software.names[0]["software_name"].should eq("Another name for this software")

    JSONModel::set_repository(@repo_id)

    software = JSONModel(:agent_software).find(id)
    # NOT THIS ONE.. as we names are currently global
    #software.names[0]["software_name"].should eq("Eggplant car steering system")
    software.names[0]["software_name"].should eq("Another name for this software")
  end

end
