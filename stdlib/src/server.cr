require "json"
require "http/server"

struct Person
  include JSON::Serializable
  getter name : String
  getter age : Int32
end

# Baseline: Crystal's HTTP::Server with hand-written routing, no framework.
server = HTTP::Server.new do |ctx|
  path = ctx.request.path
  case {ctx.request.method, path}
  when {"GET", "/"}
    ctx.response.content_type = "text/plain"
    ctx.response.print "Hello, World!"
  when {"POST", "/people"}
    ctx.response.content_type = "application/json"
    p = Person.from_json(ctx.request.body.not_nil!.gets_to_end)
    ctx.response.print({name: p.name, age: p.age + 1}.to_json)
  else
    if ctx.request.method == "GET" && path.starts_with?("/users/")
      id = path[7..]
      ctx.response.content_type = "application/json"
      ctx.response.print({id: id, name: "user#{id}"}.to_json)
    else
      ctx.response.status = :not_found
      ctx.response.print "Not Found"
    end
  end
end
server.bind_tcp "0.0.0.0", ENV.fetch("PORT", "3000").to_i
server.listen
