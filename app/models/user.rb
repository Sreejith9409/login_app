class User < ApplicationRecord
  GENDER_ARR = [['Male', 'male'], ['Female', 'female']]
  CONTACT_NUMBER_FORMAT_WITH_SPCL_CHRS = /^(\(?\+?[0-9]*\)?)?[0-9_\- \(\/\\.,)]*$/
  EMAIL_FORMAT  = /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i

  validates_presence_of :login, :first_name, :last_name, :email, :mobile_number, :crypted_password
  validates_length_of :crypted_password, :minimum => 6
  validates_uniqueness_of :login, :email, :mobile_number
  validates_format_of :mobile_number, :with => User::CONTACT_NUMBER_FORMAT_WITH_SPCL_CHRS, :message => :should_be_valid_number,:multiline => true
  validates_format_of :work_number, :with => User::CONTACT_NUMBER_FORMAT_WITH_SPCL_CHRS, :message => :should_be_valid_number,:multiline => true
  validates_format_of :home_number, :with => User::CONTACT_NUMBER_FORMAT_WITH_SPCL_CHRS, :message => :should_be_valid_number, :allow_nil => true,:multiline => true
  validate :validate_email
  before_save :encrypt_password

  def name
    "#{first_name} #{last_name}"
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, auth_token)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), auth_token, password + "-SrEe")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, auth_token)
  end

  def encrypt_password
    return if crypted_password.blank?
    self.auth_token = Digest::SHA1.hexdigest(rand_key) if new_record?
    self.crypted_password = encrypt(crypted_password)
  end

  def rand_key
    Digest::SHA1.hexdigest("-SrEe-#{Time.now.to_s.split(//).sort_by {rand}.join}--#{login}-TeSt-")
  end

  def authenticate?(password)
    crypted_password == encrypt(password)
  end

  def get_encrypted_auth_token
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), self.auth_token, "#{self.login}-#{self.email}")
  end

  def validate_email
    is_valid_email = []
    email.split(",").each{|e| is_valid_email << User::EMAIL_FORMAT.match(e.strip).nil?}
    errors[:base] << "#{self.email} is not valid"  if is_valid_email.include?(true)
  end
end
