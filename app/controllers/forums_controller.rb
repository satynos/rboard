class ForumsController < ApplicationController
  before_filter :store_location, :only => :show
  
  def index
    @forums = Forum.without_parent

    @forums = if logged_in? 
      @forums.viewable_to(current_user)
    else
      @forums.viewable_to_anonymous
    end
    
    @lusers = User.recent.map { |u| u.to_s }.to_sentence
    @users = User.count
    @posts = Post.count
    @topics = Topic.count
    @ppt = @posts > 0 ? @posts / @topics : 0
  end
  
  def show
    @forum = Forum.find(params[:id], :include => [{ :topics => :posts }, :moderations])
    if !@forum.viewable?(current_user)
      flash[:notice] = t(:forum_permission_denied)
      redirect_to forums_path
    else
      @topics = @forum.topics.sorted.paginate :page => params[:page], :per_page => 30, :order => "sticky DESC"
      @forums = @forum.children
      @all_forums = Forum.all(:select => "id, title", :order => "title ASC") - [@forum] if is_moderator?
      @moderated_topics_count = @forum.moderations.topics.for_user(current_user).count
    end
  end
  
end
