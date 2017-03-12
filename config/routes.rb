Rails.application.routes.draw do

  mount Facebook::Messenger::Server, at: '/bot'
  #post '/bot' , to: 'application#debug'

  get '/subscribe', to: 'application#subscribe'
  get '/cron', to: 'application#cron'
  get '/stats', to: 'statistics#stats'
  post '/stats/user', to: 'statistics#refresh_user_chart'
  post '/stats/request', to: 'statistics#refresh_request_chart'


  get '/date_picker', to: 'webview#date_picker'
  post '/submit', to: 'webview#submit'
end
