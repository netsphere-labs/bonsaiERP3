
# Rails 6.1 brings back the feature that allows loading external route files from the router.

BonsaiErp::Application.routes.draw do
  # namespace :api
  draw :api
  
  draw :app

end
