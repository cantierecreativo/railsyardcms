Railsyard2::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  root :to => "site#show"
  themes_for_rails
  
  ## Devise routes
  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'signup'}
  
  ## The following named routes are not working - maybe a Devise issue
  #match 'login' => 'devise/sessions#new', :via => :get
  #match 'logout' => 'devise/sessions#destroy', :via => :get
  #match 'signup' => 'devise/registrations#new', :via => :get
  ## The redirects instead are working...
  match "/login" => redirect("/users/login")
  match "/logout" => redirect("/users/logout")
  match "/signup" => redirect("/users/signup")
  match "/admin" => redirect("/admin/pages")
  
  # Admin routes
  namespace :admin do 
    resources :pages do
      put 'sort', :on => :collection
      put 'set_editing_language', :on => :collection
      post 'toggle', :on => :member
      post 'apply_template', :on => :member
      put 'apply_layout', :on => :member
      get 'purge_limbo', :on => :member
      resources :snippets do
        put 'sort', :on => :collection
        post 'toggle', :on => :member
      end
    end
    resources :users do
      post 'toggle', :on => :member
    end
    resources :articles do
      post 'toggle', :on => :member
    end
    resources :article_layouts do
      put 'apply_layout', :on => :member
      put 'set_editing_language', :on => :collection
      resources :snippets do
        put 'sort', :on => :collection
        post 'toggle', :on => :member
      end
    end
    resources :categories do
      post 'quick_create', :on => :collection
    end
    resource :settings
    resources :uploads
    resources :comments do
      post 'toggle', :on => :member
    end
    resources :tags, :only => [:index]
  end
  
  # Public routes
  # resources :users, :only => [:index, :show]
  resources :users
  resources :comments
  match ':lang/article/:year/:month/:day/:pretty_url' => 'articles#show', :as => 'show_article', :constraints => {:lang => $AVAILABLE_LANGUAGES, :year => /\d+/, :month => /\d+/, :day => /\d+/}
  match ':lang/feed' => 'articles#feed', :as => :feed, :defaults => { :format => 'atom' }

  # Main public pages globbing route
  match '/:lang' => "site#show", :constraints => {:lang => /[a-z]{2}/}
  scope "/:lang" do
    match "*page_url" => "site#show", :constraints => {:lang => /[a-z]{2}/}
  end
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
