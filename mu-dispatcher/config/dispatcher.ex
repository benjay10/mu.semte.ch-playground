defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ],
    any:  ["*/*"]
  ]

  @html %{ accept: %{ html: true } }
  @json %{ accept: %{ json: true } }
  @any  %{ accept: %{ any:  true } }

  ## Resources for the webapp: JavaScript, CSS, images, ...
  match "/assets/*path", @any do
    forward conn, path, "http://webapp:4200/assets/"
  end
  #match "/public/*path", @any do
  #  forward conn, path, "http://webapp:4200/public/"
  #end

  ## JSON api requests, mainly from Ember webapps
  match "/api/*path", @json do
    #IO.inspect(conn, label: "conn for /api")
    forward conn, path, "http://resource/"
  end

  ## The login service should be accessible on its own path for the Ember webapp
  match "/sessions/*path", @any do
    forward conn, path, "http://login/sessions/"
  end

  ## Something about CORS. See docs of the mu-identifier
  options "*_path" do
    send_resp( conn, 200, "Option calls are accepted by default" )
  end

  match "/mockaccess/*path", @any do
    forward conn, path, "http://mockaccess/"
  end

  ## All HTML requests should be responded (as last resort) with the serving of the Ember webapp's HTML page
  match "/*path", @html do
    #IO.inspect( conn, label: "conn for /webapp" )
    #forward conn, [], "http://webapp:4200/index.html"
    forward conn, path, "http://webapp:4200/"
  end
	
end
