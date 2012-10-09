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

    puts "SAVE: #{software.save}"
    puts software.inspect
    puts "***"
    puts JSONModel(:agent_software).find(id).inspect
    JSONModel(:agent_software).find(id).agent_contacts[1]['name'].should eq("A separate contact")

  end


end
