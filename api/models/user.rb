require 'data_mapper'
require 'digest/sha2'
require 'dm-validations'
require 'uuidtools'
require 'sinatra'

class User
  # enable :sessions

  include DataMapper::Resource

  property :id,                   Serial
  property :first_name,           String
  property :last_name,            String
  property :email,                String, length: (3..40), index: true
  property :hashed_password,      Text
  property :salt,                 String
  # property :image_url,            String
  # property :user_type,            Enum[ :regular_user, :superuser ], default: :regular_user
  # property :registered,           Boolean, default: false
  # property :invite,               String, default: UUIDTools::UUID.random_create.hexdigest
  # property :sms_opt_in_status,    Enum[ :not_sent, :sent, :opted_in ], default: :not_sent
  # property :sms_opt_in_code,      String


  # validates_presence_of :email
  # validates_presence_of :first_name
  # validates_presence_of :last_name
  # validates_uniqueness_of :email

  # has n, :user_group_tags, constraint: :destroy
  # has n, :user_groups, through: :user_group_tags
  has n, :comments
  # has n, :messages, through: :user_messages, constraint: :destroy
  # has n, :task_users, constraint: :destroy
  # has n, :hands,      constraint: :destroy


  def self.random_string(num)
    str = []
    num.times { str << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
    str.join()
  end

  def password=(pass)
    @password = pass
    self.salt = User.random_string(48) unless self.salt
    self.hashed_password = User.encrypt(@password, self.salt)
  end

  def self.encrypt(pass, salt)
    Digest::SHA2.hexdigest(pass + salt)
  end

  def self.authenticate(email, pass)
    user = User.first(:email => email)
    return false if user.nil?
    return user if User.encrypt(pass, user.salt) == user.hashed_password
    false
  end

end
