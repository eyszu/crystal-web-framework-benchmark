require "lucky"

Log.setup(ENV["BENCH_DEBUG"]? ? Log::Severity::Debug : Log::Severity::None)

struct Person
  include JSON::Serializable
  getter name : String
  getter age : Int32
end

abstract class BaseAction < Lucky::Action
  accepted_formats [:plain_text, :json], default: :json

  # Build with `-Dnocookies` for the "cookies disabled" variant (Lucky's documented
  # opt-out for stateless API actions: no flash/session encryption, no Set-Cookie).
  {% if flag?(:nocookies) %}
    disable_cookies
  {% end %}
end

class Home::Index < BaseAction
  get "/" do
    plain_text "Hello, World!"
  end
end

class Users::Show < BaseAction
  get "/users/:id" do
    raw_json({id: id, name: "user#{id}"}.to_json)
  end
end

class People::Create < BaseAction
  post "/people" do
    p = Person.from_json(request.body.not_nil!.gets_to_end)
    raw_json({name: p.name, age: p.age + 1}.to_json)
  end
end

class Errors::Show < Lucky::ErrorAction
  default_format :json

  def default_render(error : Exception) : Lucky::Response
    STDERR.puts error.inspect_with_backtrace if ENV["BENCH_DEBUG"]?
    json({error: error.message}, status: 500)
  end

  def report(error : Exception) : Nil
    STDERR.puts error.inspect_with_backtrace if ENV["BENCH_DEBUG"]?
  end
end

class AppServer < Lucky::BaseAppServer
  def middleware : Array(HTTP::Handler)
    [
      Lucky::ErrorHandler.new(action: Errors::Show),
      Lucky::RouteHandler.new,
      Lucky::RouteNotFoundHandler.new,
    ] of HTTP::Handler
  end

  def listen
    server.listen(host, port, reuse_port: false)
  end
end

Lucky::Server.configure do |settings|
  settings.secret_key_base = "0" * 64
  settings.host = "0.0.0.0"
  settings.port = ENV.fetch("PORT", "3000").to_i
end

Lucky::Session.configure do |settings|
  settings.key = "_bench_session"
end

Lucky::ErrorHandler.configure do |settings|
  settings.show_debug_output = false
end

AppServer.new.listen
