Rails.application.routes.draw do
  root 'welcome#index'
  post 'user/sendMessage'
end
