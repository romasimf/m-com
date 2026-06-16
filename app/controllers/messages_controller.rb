class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = Conversation.for_user(current_user).find(params[:conversation_id])

    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      redirect_to conversation_path(@conversation), alert: "Сообщение не может быть пустым"
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end
end