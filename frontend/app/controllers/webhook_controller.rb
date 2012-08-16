class WebhookController < ApplicationController
  def notify
    JSONModel::notify(params)

    render :text => "Thanks"
  end
end
