class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
      :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  validates_presence_of :name
  has_many :authorizations
  has_many :articles

  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.from_omniauth(auth, current_user)
    authorization = Authorization.where(:provider => auth.provider, :uid => auth.uid.to_s, :token => auth.credentials.token, :secret => auth.credentials.secret).first_or_initialize
    if authorization.user.blank?
      user = current_user.nil? ? User.where('email = ?', auth["info"]["email"]).first : current_user
      if user.blank?
        user = User.new
        user.password = Devise.friendly_token[0,10]
        user.name = auth.info.name
        if auth.provider == "twitter"
          user.email = auth.info.nickname + '_' + (0...8).map { (65 + rand(26)).chr }.join + '@gmail.com'
        else
          user.email = auth.info.email
        end
          auth.provider == "twitter" ?  user.save(:validate => false) :  user.save
      end
      authorization.username = auth.info.nickname
      authorization.user_id = user.id
      authorization.save
    end
    authorization.user
  end

end
