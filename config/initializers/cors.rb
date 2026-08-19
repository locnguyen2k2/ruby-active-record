Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "http://localhost:3000"
        resource "*",
          headers: [ "Content-Type", "Authorization" ],
          methods: [ :post, :get ],
          max_age: 86400,
          debug: true,
          credentials: true
      end
end
