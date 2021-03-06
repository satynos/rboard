class Admin::ForumsController < Admin::ApplicationController
  before_filter :store_location, :only => [:index, :show]
  before_filter :find_forum, :except => [:new, :create, :index]
  
  # Shows all top-level forums.
  def index
    @forums = Forum.find_all_without_parent
  end
  
  # Initializes a new forum.
  def new
    @forum = Forum.new
    @forums = Forum.find(:all, :order => "title")
    @user_levels = UserLevel.find(:all, :order => "position ASC")
  end
  
  # Creates a new forum.
  def create
    @forum = Forum.new(params[:forum])
    if @forum.save
      flash[:notice] = t(:forum_created)
      redirect
    else
      flash[:notice] = t(:forum_not_created)
      @forums = Forum.find(:all, :order => "title")
      @user_levels = UserLevel.find(:all, :order => "position ASC")
      render :action => "new"
    end
  end
  
  # Edits a forum.  
  def edit
    # We do this so we can't make a forum a sub of itself, or any of its descendants...
    # As this would cause circular references which just aren't cool.
    @forums = Forum.find(:all, :order => "title") - [@forum] - @forum.descendants
    @user_levels = UserLevel.find(:all, :order => "position ASC")
    
  end
  
  # Updates a forum.
  def update
    if @forum.update_attributes(params[:forum])
      flash[:notice] = t(:forum_updated)
      redirect
    else
      @forums = Forum.find(:all, :order => "title") - [@forum] - @forum.descendants
      @user_levels = UserLevel.find(:all, :order => "position ASC")
      flash[:notice] = t(:forum_not_updated)
      render :action => "edit"
    end
  end
  
  # Deletes a forum.
  def destroy
    @forum.destroy
    flash[:notice] = t(:forum_deleted)
    redirect
  end
  
  # Moves a forum one space up using an acts_as_list provided method.
  def move_up
    @forum.move_higher
    flash[:notice] = t(:forum_moved_higher, :forum => @forum)
    redirect
  end
  
  # Moves a forum one space down using an acts_as_list provided method.
  def move_down
    @forum.move_lower
    flash[:notice] = t(:forum_moved_lower, :forum => @forum)
    redirect
  end
  
  # Moves a forum to the top using an acts_as_list provided method.
  def move_to_top
    @forum.move_to_top
    flash[:notice] = t(:forum_moved_to_top, :forum => @forum)
    redirect
  end
  
  # Moves a forum to the bottom using an acts_as_list helper.
  def move_to_bottom
    @forum.move_to_bottom
    flash[:notice] = t(:forum_moved_to_bottom, :forum => @forum)
    redirect
  end
  
  private
  
  # Calls redirect_back_or_default to the index action.
  # Got tired of writing it all out for the move_* actions
  def redirect
    redirect_back_or_default(admin_forums_path)
  end
  
  # Find a forum. Most of the actions in this controller need a forum object.
  def find_forum
    @forum = Forum.find(params[:id]) unless params[:id].nil?
    rescue ActiveRecord::RecordNotFound
      not_found
  end
  
  # Called when the forum could not be found.
  def not_found
    flash[:notice] = t(:forum_not_found)
    redirect
  end
end