class TagUsersController < ApplicationController
  before_action :find_board, :find_tag
  before_action :find_relation, only: :destroy

  def create
    user_ids = params[:user]
    new_relations = []
    user_ids.each do |item|
      new_relations << TagUser.new(user_id: item, tag_id: params[:tag_id])
    end
    if TagUser.import new_relations
      flash[:success] = t ".success"
    else
      flash[:danger] = t ".fail"
    end
    respond_to :js
  end

  def destroy
    if @relation.destroy
      flash[:warning] = t ".success"
    else
      flash[:danger] = t ".fail"
    end
    respond_to :js
  end

  private

  def find_board
    @board = Board.find params[:board_id]
  end

  def find_relation
    @relation = TagUser.find_by tag_id: params[:tag_id],
                                user_id: params[:user_id]
    return if @relation

    flash[:danger] = t ".cant_delete"
    redirect_to root_path
  end

  def find_tag
    @edited_tag = Tag.find params[:tag_id]
    @tag_users = @edited_tag.users
  end
end
