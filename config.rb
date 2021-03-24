activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

activate :sprockets

page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
  activate :relative_assets
  set :relative_links, true
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.deploy_method = :git
end

class ZapContentLength < Struct.new(:app)
  def call(env)
    s, h, b = app.call(env)
    # The URL rewriters in Middleman do not update Content-Length correctly,
    # which makes Rack-Lint flag the responses as having a wrong Content-Length.
    # For building assets this has zero importance because the Content-Length
    # header will be discarded - it is the server that recomputes it. But
    # it does prevent the site from building correctly.
    #
    # The fastest way out of this is to let Rack recompute the Content-Length
    # forcibly, for every response, at retrieval time.
    #
    # See https://github.com/middleman/middleman/issues/2309
    # and https://github.com/rack/rack/issues/1472
    h.delete('Content-Length')
    [s, h, b]
  end
end

app.use ::Rack::ContentLength
app.use ZapContentLength
