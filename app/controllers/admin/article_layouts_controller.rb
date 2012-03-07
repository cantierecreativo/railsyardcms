class Admin::ArticleLayoutsController < Admin::AdminController

  ## manual authorization
  before_filter do |controller|
    controller.check_roles(["admin", "article_writer"])
  end

  ## CanCan authorization - see Ability model
  authorize_resource

  def edit
    @admin_editing_language = admin_editing_language
    @article_layout = ArticleLayout.find_by_lang(params[:id])
    @snippets_available = Snippet.available
    theme = Theme.find!(cfg.theme_name)
    @layouts = theme.layouts
    @current_layout = theme.find_layout!(@article_layout.layout_name)
    @snippets = @article_layout.snippets.includes(:paste).order("pastes.position")
  end

  def apply_layout
    @article_layout = ArticleLayout.find(params[:id])
    if Layout.find(cfg.theme_name, params[:selected_layout])
      @article_layout.snippets.map{|s| s.update_attribute(:area, "limbo")}
      @article_layout.update_attribute(:layout_name, params[:selected_layout])
    end
    # Renders apply_layout.js.erb
  end

  def set_editing_language
    session[:admin_editing_language] = params[:admin_editing_language] unless params[:admin_editing_language].blank?
    @admin_editing_language = session[:admin_editing_language]
    # Renders set_editing_language.js.erb
  end

end
