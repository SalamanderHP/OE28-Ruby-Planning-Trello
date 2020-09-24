class TagsController < ApplicationController
  def edit
    @tag = Tag.find_by id: params[:id]
  end
end
