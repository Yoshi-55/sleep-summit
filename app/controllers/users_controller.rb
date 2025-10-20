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
        if @user.errors[:avatar].present?
          flash[:alert] = I18n.t("profiles.update.avatar_error")
        elsif @user.errors[:name].include?(I18n.t("errors.messages.blank"))
          flash[:alert] = I18n.t("profiles.update.name_error")
        elsif @user.errors[:name].any? { |msg| msg.include?(I18n.t("errors.messages.too_long", count: 20)) }
          flash[:alert] = I18n.t("profiles.update.name_length_error")
        else
          flash[:alert] = I18n.t("profiles.update.error")
        end
      redirect_to edit_profile_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :avatar)
  end
end
