class GoogleCalendarConnectionsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    current_user.disconnect_google
    redirect_to dashboard_path, notice: "Googleカレンダーとの連携を解除しました"
  end
end
