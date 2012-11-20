require 'spec_helper'

describe 'Collection Management model' do

  it "supports creating a new Collection Management record" do
    create(:json_collection_management, :cataloged_note => "An optional note")
    cm = CollectionManagement.find(:cataloged_note => "An optional note")
    cm.should_not be_nil
  end


  it "enforces one linked accession or resource, or one or more digital objects" do

    expect {
      create(:json_collection_management, :linked_records => [])
    }.to raise_error(JSONModel::ValidationException)

  end

end
