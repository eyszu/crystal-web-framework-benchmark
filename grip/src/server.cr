require "grip"

struct Person
  include JSON::Serializable
  getter name : String
  getter age : Int32
end

class IndexController
  include Grip::Controllers::HTTP

  def get(context : Context) : Context
    context.text("Hello, World!").halt
  end
end

class UserController
  include Grip::Controllers::HTTP

  def get(context : Context) : Context
    id = context.fetch_path_params["id"]
    context.json({id: id, name: "user#{id}"}).halt
  end
end

class PeopleController
  include Grip::Controllers::HTTP

  def post(context : Context) : Context
    p = Person.from_json(context.request.body.not_nil!.gets_to_end)
    context.json({name: p.name, age: p.age + 1}).halt
  end
end

class Application
  include Grip::Application

  # Request logging is left out on purpose: no framework logs in this benchmark.
  property handlers : Array(HTTP::Handler) = [
    Grip::Handlers::HTTP.new,
  ] of HTTP::Handler

  property environment : String = "PRODUCTION"
  property port : Int32 = ENV.fetch("PORT", "3000").to_i

  def initialize
    get "/", IndexController
    get "/users/:id", UserController
    post "/people", PeopleController
  end
end

Application.new.run
