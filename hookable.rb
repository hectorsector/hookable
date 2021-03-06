require "bundler/setup"
ENV["RACK_ENV"] ||= "development"
Bundler.require(:default, ENV["RACK_ENV"].to_sym)
Dotenv.load

require "./hook_delivery"

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOLAB_URI']}}, 'production')
end

post "/" do
  headers = {
    "X-GitHub-Event"    => env["HTTP_X_GITHUB_EVENT"],
    "X-GitHub-Delivery" => env["HTTP_X_GITHUB_DELIVERY"],
    "X-Hub-Signature"   => env["HTTP_X_HUB_SIGNATURE"]
  }.to_json
  payload = request.body.read

  HookDelivery.create(
    :payload => payload,
    :headers => headers
  )

  status 200
end

get "/" do
  @hook_deliveries = HookDelivery.sort(:created_at.desc).limit(8)
  erb :index
end

delete "/" do
  HookDelivery.destroy_all
  status 200
end

####
# Simple presentation helper
####

helpers do
  def seconds_ago(number)
    if number == 1
      "#{number} second ago"
    else
      "#{number} seconds ago"
    end
  end
end
