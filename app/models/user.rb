class User < ApplicationRecord
  validates :google_uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by(google_uid: auth.uid) do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.avatar_url = auth.info.image
    end
  end
end
