require "kemal"

module Website
  VERSION = "0.1.0"
  PORT    = 8081

  get "/" do |env|
    env.redirect("/index.html")
  end

  Kemal.run(PORT)
end
