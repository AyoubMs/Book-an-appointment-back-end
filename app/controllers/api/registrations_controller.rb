class Api::RegistrationsController < Devise::RegistrationsController
  def new
    @user = User.new
  end

  def create
    @user = User.new(sign_up_params)
    if @user.save!
      @token = generate_jwt(@user.id)
      access_token = AccessToken.new(token: @token, user: @user)
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
