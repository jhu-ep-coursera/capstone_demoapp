module ApiHelper
  def parsed_body
    JSON.parse(response.body)
  end

  # automates the passing of payload bodies as json
  ["post", "put", "patch", "get", "head", "delete"].each do |http_method_name|
    define_method("j#{http_method_name}") do |path,params={},headers={}| 
      if ["post","put","patch"].include? http_method_name
        headers=headers.merge('content-type' => 'application/json') if !params.empty?
        params = params.to_json
      end
      self.send(http_method_name, 
            path, 
            params,
            headers.merge(access_tokens))
    end
  end

  def signup registration, status=:ok
    jpost user_registration_path, registration
    expect(response).to have_http_status(status)
    payload=parsed_body
    if response.ok?
      registration.merge(:id=>payload["data"]["id"],
                         :uid=>payload["data"]["uid"])
    end
  end

  def login credentials, status=:ok
    jpost user_session_path, credentials.slice(:email, :password)
    expect(response).to have_http_status(status)
    return response.ok? ? parsed_body["data"] : parsed_body
  end
  def logout status=:ok
    jdelete destroy_user_session_path
    @last_tokens={}
    expect(response).to have_http_status(status)
  end

  def access_tokens?
    !response.headers["access-token"].nil?  if response
  end
  def access_tokens
    if access_tokens?
      @last_tokens=["uid","client","token-type","access-token"].inject({}) {|h,k| h[k]=response.headers[k]; h}
    end
    @last_tokens || {}
  end
end

RSpec.shared_examples "resource index" do |model|
  let!(:resources) { (1..5).map {|idx| FactoryGirl.create(model) } }
  let(:payload) { parsed_body }

  it "returns all #{model} instances" do
    jget send("#{model}s_path"), {}, {"Accept"=>"application/json"}
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq("application/json")

    expect(payload.count).to eq(resources.count)
    response_check if respond_to?(:response_check)
  end
end

RSpec.shared_examples "show resource" do |model|
  let(:resource) { FactoryGirl.create(model) }
  let(:payload) { parsed_body }
  let(:bad_id) { 1234567890 }

  it "returns Foo when using correct ID" do
    jget send("#{model}_path", resource.id)
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq("application/json")
    response_check if respond_to?(:response_check)
  end

  it "returns not found when using incorrect ID" do
    jget send("#{model}_path", bad_id)
    expect(response).to have_http_status(:not_found)
    expect(response.content_type).to eq("application/json") 

    payload=parsed_body
    expect(payload).to have_key("errors")
    expect(payload["errors"]).to have_key("full_messages")
    expect(payload["errors"]["full_messages"][0]).to include("cannot","#{bad_id}")
  end
end

RSpec.shared_examples "create resource" do |model|
  let(:resource_state) { FactoryGirl.attributes_for(model) }
  let(:payload)        { parsed_body }
  let(:resource_id)    { payload["id"] }

  it "can create valid #{model}" do
    jpost send("#{model}s_path"), resource_state
    expect(response).to have_http_status(:created)
    expect(response.content_type).to eq("application/json") 

    # verify payload has ID and delegate for addition checks
    expect(payload).to have_key("id")
    response_check if respond_to?(:response_check)

    # verify we can locate the created instance in DB
    jget send("#{model}_path", resource_id)
    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples "modifiable resource" do |model|
  let(:resource) { resource=FactoryGirl.create(model) }
  let(:new_state) { FactoryGirl.attributes_for(model) }

  it "can update #{model}" do
      # change to new state
      jput send("#{model}_path", resource.id), new_state
      expect(response).to have_http_status(:no_content)

      update_check if respond_to?(:update_check)
    end

  it "can be deleted" do
    jhead send("#{model}_path", resource.id)
    expect(response).to have_http_status(:ok)

    jdelete send("#{model}_path", resource.id)
    expect(response).to have_http_status(:no_content)
    
    jhead send("#{model}_path", resource.id)
    expect(response).to have_http_status(:not_found)
  end
end
