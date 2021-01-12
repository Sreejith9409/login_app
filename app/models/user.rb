class User < ApplicationRecord

  GENDER_ARR = [['Male', 'male'], ['Female', 'female']]

  def authenticate(params)
    return true
  end
end
