module ApiHelper
  def parsed_body
    JSON.parse(response.body)
  end
end
