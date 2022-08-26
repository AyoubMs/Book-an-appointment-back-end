class Api::RegistrationsController < Devise::RegistrationsController
  def new
    @user = User.new
  end

  def create
    @user = User.new(sign_up_params)
    p @user
    if @user.save!
      @token = JWT.encode({ id: @user.id, exp: 60.days.from_now.to_i }, ENV['SECRET_KEY_BASE'])
      p @token
      access_token = AccessToken.new(token: @token, user: @user)
      p access_token
      if access_token.save!
        render json: { user: @user, token: @token }, status: :ok
      else
        @user.destroy
        render json: { errors: 'User could not be created' }, status: :unprocessable_entity
      end
    else
      render json: { errors: 'User could not be created' }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require('user').permit(:name)
  end

  def generate_jwt(user_id)
    JWT.encode({ id: user_id, exp: 60.days.from_now.to_i }, ENV['SECRET_KEY_BASE'])
  end
end
