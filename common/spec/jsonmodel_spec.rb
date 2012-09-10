require_relative "spec_helper.rb"

describe 'JSON model' do

  before(:all) do

    JSONModel.create_model_for("testschema",
                               {
                                 "type" => "object",
                                 "uri" => "/repositories/:repo_id/tests",
                                 "properties" => {
                                   "uri" => {"type" => "string", "required" => false},
                                   "elt_0" => {"type" => "string", "required" => true, "minLength" => 1, "pattern" => "^[a-zA-Z0-9 ]*$"},
                                   "elt_1" => {"type" => "string", "required" => false, "default" => "", "pattern" => "^[a-zA-Z0-9]*$"},
                                   "elt_2" => {"type" => "string", "required" => false, "default" => "", "pattern" => "^[a-zA-Z0-9]*$"},
                                   "elt_3" => {"type" => "string", "required" => false, "default" => "", "pattern" => "^[a-zA-Z0-9]*$"},
                                 },
    
                                 "additionalProperties" => false
                               })


  end
  
  before(:each) do
    make_test_repo
  end

  after(:all) do
    JSONModel.destroy_model(:testschema)
  end

  it "Accepts a simple record" do
    JSONModel(:testschema).from_hash({
                                       "elt_0" => "helloworld",
                                       "elt_1" => "thisisatest"
                                     })
  end
  
  it "Accepts a simple record with symbols as keys" do
    JSONModel(:testschema).from_hash({
                                       :elt_0 => "helloworld",
                                       :elt_1 => "thisisatest"
                                     })
  end


  it "Flags errors on invalid values" do
    lambda {
      JSONModel(:testschema).from_hash({"elt_0" => "/!$"})
    }.should raise_error(ValidationException)
  end


  it "Provides accessors for non-schema properties but doesn't serialise them" do
    obj = JSONModel(:testschema).from_hash({
                                             "elt_0" => "helloworld",
                                             "special" => "some string"
                                           })

    obj.elt_0.should eq ("helloworld")
    obj.special.should eq ("some string")

    obj.to_hash.has_key?("special").should be_false
    JSON[obj.to_json].has_key?("special").should be_false
  end


  it "Allows for updates" do
    obj = JSONModel(:testschema).from_hash({
                                             "elt_0" => "helloworld",
                                           })

    obj.elt_0 = "a new string"

    JSON[obj.to_json]["elt_0"].should eq("a new string")
  end


  it "Throws an exception with some useful accessors" do
    exception = false
    begin
      JSONModel(:testschema).from_hash({"elt_0" => "/!$"})
    rescue ValidationException => e
      exception = e
    end

    exception.should_not be_false

    # You can still get at your invalid object if you really want.
    exception.invalid_object.elt_0.should eq("/!$")

    # And you can get a list of its problems too
    exception.errors["elt_0"][0].should eq "Did not match regular expression: ^[a-zA-Z0-9 ]*$"
  end


  it "Warns on missing properties instead of erroring" do
    JSONModel::strict_mode(false)
    model = JSONModel(:testschema).from_hash({})

    model._warnings.keys.should eq(["elt_0"])
    JSONModel::strict_mode(true)
  end


  it "Supports the 'ifmissing' definition" do
    JSONModel.create_model_for("strictschema",
                               {
                                 "type" => "object",
                                 "properties" => {
                                   "container" => {
                                     "type" => "object",
                                     "required" => true,
                                     "properties" => {
                                       "strict" => {"type" => "string", "ifmissing" => "error"},
                                     }
                                   }
                                 },
                               })

    JSONModel::strict_mode(false)

    model = JSONModel(:strictschema).from_hash({:container => {}}, false)

    model._exceptions[:errors].keys.should eq(["strict"])
    JSONModel::strict_mode(true)
    JSONModel.destroy_model(:strictschema)
  end
  
  it "Determines the uri for a hypothetical instance given an id and a repo_id" do  
      JSONModel(:testschema).uri_for(500, :repo_id => "1").should match(/repositories\/1\/tests\/[0-9]*/)
  end
  
  it "Will save an instance of a model supported by the backend" do
    resource = JSONModel(:resource).from_hash(:title => "a resource", :id_0 => "abc123")
    resource.save.to_s.should match(/[0-9]*/)
  end
  
  it "Will set the URI for an instance on save" do
    resource = JSONModel(:resource).from_hash(:title => "a resource", :id_0 => "abc123")
    resource.uri.should be_nil
    resource.save
    resource.uri.should match(/\/repositories\/[0-9]*\/resources\/[0-9]*/)
  end
  
  it "Returns the backend url" do
    JSONModel(:testschema).backend_url.should eq('http://example.com')
  end
  
  it "Finds an instance of a model given an id" do
    id = JSONModel(:resource).from_hash(:title => "a resource", :id_0 => "abc123").save
    JSONModel(:resource).find(id).id_0.should eq("abc123")
  end

  it "Finds all instances of a model" do
    JSONModel(:resource).from_hash(:title => "resource 0", :id_0 => "abc123").save
    JSONModel(:resource).from_hash(:title => "resource 1", :id_0 => "def345").save
    JSONModel(:resource).all.count.should eq(2)
  end  
end

