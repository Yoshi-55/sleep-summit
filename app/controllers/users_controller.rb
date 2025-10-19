class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: I18n.t("profiles.update.success")
    else
      redirect_to edit_profile_path, alert: I18n.t("profiles.update.error")
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :avatar)
  end
end
