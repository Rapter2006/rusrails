class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  has_many :discussions, :as => :author
  has_many :says, :as => :author

  def name
    read_attribute(:name) || email.split('@').first
  end

  def self.find_or_create_for_github(response)
    data = response['extra']['user_hash']
    if user = User.where(:oauth_id => data["id"], :oauth => 'github').first
      user
    else
      user = User.new :email => "#{data["email"]}.github", :password => Devise.friendly_token[0,20], :name => data["name"]
      user.oauth_id = data["id"]
      user.oauth = 'github'
      user.save
      user
    end
  end

  def self.find_or_create_for_twitter(response)
    debugger
    data = response['extra']['user_hash']
    if user = User.where(:oauth_id => data["id"], :oauth => 'twitter').first
      user
    else
      user = User.new :email => "#{data["id"]}@#{data['screen_name']}.twitter", :password => Devise.friendly_token[0,20], :name => data["name"]
      user.oauth_id = data["id"]
      user.oauth = 'twitter'
      user.save
      user
    end
  end
end
