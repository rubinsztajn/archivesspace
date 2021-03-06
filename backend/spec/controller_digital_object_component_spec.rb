require 'spec_helper'

describe 'Digital Object Component controller' do

  it "lets you create an digital object component and get it back" do
    opts = {:title => 'The digital object component title'}

    created = create(:json_digital_object_component, opts).id
    JSONModel(:digital_object_component).find(created).title.should eq(opts[:title])
  end


  it "lets you list all digital object components" do
    create_list(:json_digital_object_component, 5)
    JSONModel(:digital_object_component).all(:page => 1)['results'].count.should eq(5)
  end


  it "lets you create an digital object component with a parent" do
    digital_object = create(:json_digital_object)

    parent = create(:json_digital_object_component, :digital_object => digital_object.uri)

    child = create(:json_digital_object_component, {:title => 'Child', :parent => parent.uri, :digital_object => digital_object.uri})

    get "#{$repo}/digital_object_components/#{parent.id}/children"
    last_response.should be_ok

    children = JSON(last_response.body)
    children[0]['title'].should eq('Child')
  end


  it "handles updates for an existing digital object component" do
    created = create(:json_digital_object_component)

    opts = {:title => 'A brand new title'}

    doc = JSONModel(:digital_object_component).find(created.id)
    doc.title = opts[:title]
    doc.save

    JSONModel(:digital_object_component).find(created.id).title.should eq(opts[:title])
  end


  it "lets you reorder sibling digital object components" do
    digital_object = create(:json_digital_object)

    doc_1 = create(:json_digital_object_component, :digital_object => digital_object.uri, :title=> "DOC1")
    doc_2 = create(:json_digital_object_component, :digital_object => digital_object.uri, :title=> "DOC2")

    tree = JSONModel(:digital_object_tree).find(nil, :digital_object_id => digital_object.id)

    tree.children[0]["title"].should eq("DOC1")
    tree.children[1]["title"].should eq("DOC2")

    doc_1 = JSONModel(:digital_object_component).find(doc_1.id)
    doc_1.position = 1
    doc_1.save

    tree = JSONModel(:digital_object_tree).find(nil, :digital_object_id => digital_object.id)

    tree.children[0]["title"].should eq("DOC2")
    tree.children[1]["title"].should eq("DOC1")
  end


end
