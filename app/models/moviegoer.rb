class Moviegoer < ActiveRecord::Base
  has_many :reviews
  has_many :movies, :through => :reviews
  # Include default devise modules. Others available are: , :through
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable , omniauth_providers: [:google_oauth2]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.full_name = auth.info.name # assuming the user model has a name
      user.avatar_url = auth.info.image # assuming the user model has an image
      end
  end
end

# gloria = Moviegoer.where(:name => 'Gloria')
# gloria_movies = gloria.movies
# # MAY work, but a bad idea - see caption:
# gloria.movies << Movie.where(:title => 'Inception') # Don't do this!
