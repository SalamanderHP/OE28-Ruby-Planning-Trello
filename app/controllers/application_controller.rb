class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :set_locale

  private

  def rescue_404_exception
    render file: Rails.root.join("public", "404.html").to_s, layout: false,
           status: :not_found
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def user_board
    opened_board = Board.opened
    @favorite_boards = opened_board.favorite current_user.id
    @my_boards = opened_board.nonfavorite current_user.id
  end

  def user_params
    params.require(:user).permit User::USER_PARAMS
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t ".please_log_in"
    redirect_to login_url
  end

  def load_notifications
    @notifications = @board.notifications.order_created
  end

  def find_user_boards
    @user_boards = UserBoard.find_by user_id: current_user.id,
                                     board_id: @board.id
    return if @user_boards

    flash[:danger] = t ".nomember"
    redirect_to @board
  end

  def check_permission
    permission = UserBoard.find_by user_id: current_user.id, board_id: @board.id
    if permission
      return if permission.leader? || permission.member?

      flash[:danger] = t ".permission_denied"
      redirect_to @board
    else
      flash[:danger] = t ".user_not_in_board"
      redirect_to root_url
    end
  end
end
