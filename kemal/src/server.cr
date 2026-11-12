require "kemal"

struct Person
  include JSON::Serializable
  getter name : String
  getter age : Int32
end

Kemal.config.logging = false
Kemal.config.port = ENV.fetch("PORT", "3000").to_i

get "/" do |env|
  env.response.content_type = "text/plain"
  "Hello, World!"
end

get "/users/:id" do |env|
  env.response.content_type = "application/json"
  id = env.params.url["id"]
  {id: id, name: "user#{id}"}.to_json
end

post "/people" do |env|
  env.response.content_type = "application/json"
  p = Person.from_json(env.request.body.not_nil!.gets_to_end)
  {name: p.name, age: p.age + 1}.to_json
end

Kemal.run
