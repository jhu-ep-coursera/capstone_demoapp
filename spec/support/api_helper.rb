module ApiHelper
  def parsed_body
    JSON.parse(response.body)
  end

  # automates the passing of payload bodies as json
  ["post", "put"].each do |http_method_name|
    define_method("j#{http_method_name}") do |path,params={},headers={}| 
      headers=headers.merge('content-type' => 'application/json') if !params.empty?
      self.send(http_method_name, path, params.to_json, headers)
    end
  end
end
