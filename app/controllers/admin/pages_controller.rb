class Admin::PagesController < Admin::AdminController

  ## manual authorization
  before_filter do |controller|
    controller.check_role("admin") unless (controller.action_name == "set_editing_language")
  end

  ## CanCan authorization - see Ability model
  authorize_resource
  skip_authorization_check :only => :set_editing_language

  def index
    @admin_editing_language = admin_editing_language
    @pages = Page.without_roots.where(:lang => @admin_editing_language).order("updated_at DESC")
    @root_page = Page.where(:title => @admin_editing_language, :ancestry => nil).first
  end

  def show
    @admin_editing_language = admin_editing_language
    @page = Page.find(params[:id])
    @snippets_available = Snippet.available_for_pages
    theme = Theme.find!(cfg.theme_name)
    @layouts = theme.layouts
    @current_layout = theme.find_layout!(@page.layout_name)
    @snippets = @page.snippets.includes(:paste).order("pastes.position")
  end

  def new
    @admin_editing_language = admin_editing_language
    @page = Page.new
    @page.meta_keywords = @cfg.default_page_keywords
    @page.meta_description = @cfg.default_page_desc
    @root_page = Page.where(:title => @admin_editing_language, :ancestry => nil).first
    @layouts = Layout.all(cfg.theme_name)
    @current_layout = @layouts.first
  end

  def create
    @admin_editing_language = admin_editing_language
    @page = Page.new(params[:page])
    @page.pretty_url = @page.pretty_url.urlify.blank? ? @page.title.urlify : @page.pretty_url.urlify
    @page.lang = @admin_editing_language
    @page.publish_at = Time.now if @page.published
    @page.meta_title = @page.title if @page.meta_title.blank?
    #@page.meta_keywords = @cfg.default_page_keywords if @page.meta_keywords.blank?
    #@page.meta_description = @cfg.default_page_desc if @page.meta_description.blank?
    @layouts = Layout.all(@cfg.theme_name)
    @current_layout = Layout.find(@cfg.theme_name, @page.layout_name)
    # TO-DO position selector inside pages tree
    if @page.parent.blank?
      lang_root_page = Page.find_by_title(@admin_editing_language)
      @page.parent = lang_root_page unless lang_root_page.blank?
    end

    if @page && @page.save && @page.errors.empty?
      redirect_to admin_pages_path()
    else
      render :action => "new"
    end
  end

  def edit
    @admin_editing_language = admin_editing_language
    @page = Page.find(params[:id])
    @root_page = Page.where(:title => @admin_editing_language, :ancestry => nil).first
    theme = Theme.find!(@cfg.theme_name)
    @layouts = theme.layouts
    @current_layout = theme.find_layout!(@page.layout_name)
  end

  def update
    @admin_editing_language = admin_editing_language
    @page = Page.find(params[:id])
    if @page
      @page.snippets.map{|s| s.update_attribute(:area, "limbo")} unless @page.layout_name == params[:page][:layout_name]
      @page.attributes = params[:page]
      @page.pretty_url = @page.pretty_url.urlify.blank? ? @page.title.urlify : @page.pretty_url.urlify
      @page.lang = @admin_editing_language
      @page.publish_at = Time.now if @page.published
      @page.meta_title = @page.title if @page.meta_title.blank?
      #@page.meta_keywords = @cfg.default_page_keywords if @page.meta_keywords.blank?
      #@page.meta_description = @cfg.default_page_desc if @page.meta_description.blank?
      @layouts = Layout.all(@cfg.theme_name)
      @current_layout = Layout.find(@cfg.theme_name, @page.layout_name)
      # TO-DO position selector inside pages tree
      if @page.parent.blank?
        lang_root_page = Page.find_by_title(@admin_editing_language)
        @page.parent = lang_root_page unless lang_root_page.blank?
      end
      if @page.save && @page.errors.empty?
        params[:save_and_close] ? (redirect_to admin_pages_path()) : (render :action => "edit")
      else
        render :action => "edit"
      end
    end
  end

  def destroy
    page = Page.find(params[:id])
    if page
      if !page.children.blank? && (lang_root_page = Page.find_by_title(page.lang))
        page.children.map do |c|
          c.parent = lang_root_page
          c.save
        end
      end
      page.destroy
      redirect_to admin_pages_path()
    end
  end

  def sort
    # TO-DO some checks and robust code
    error = false;
    root_page = Page.where(:title => params[:admin_editing_language], :ancestry => nil).first
    serialized_tree = params[:page]
    serialized_tree.split('&').each_with_index do |node, i|
      page_string = node[node.rindex('[')+1..node.rindex(']')-1]
      parent_string = node[node.rindex('=')+1..node.length]
      page = Page.where(:id => page_string.to_i).first
      page.parent_id = (parent_string == 'root' ? root_page.id : parent_string.to_i)
      page.position = i+1
      page.save
      error = true unless page.errors.empty?
    end
   @result = error ? "Error updating pages tree." : "Pages tree updated."
   # Renders sort.js.erb
  end

  def toggle
    @page = Page.find(params[:id])
    @error = true unless @page && @page.toggle
    # Renders toggle.js.erb
  end

  def set_editing_language
    session[:admin_editing_language] = params[:admin_editing_language] unless params[:admin_editing_language].blank?
    # Renders set_editing_language.js.erb
  end

  def apply_layout
    @page = Page.find(params[:id])
    layout = Theme.find!(cfg.theme_name).find_layout!(params[:selected_layout])
    if layout
      @page.snippets.map{|s| s.update_attribute(:area, "limbo")}
      @page.update_attribute(:layout_name, params[:selected_layout])
    end
    # Renders apply_layout.js.erb
  end

  def purge_limbo
    @page = Page.find(params[:id])
    @page.snippets.where(:area => "limbo").map{|s| s.destroy}
    redirect_to admin_page_path(@page)
  end

end
