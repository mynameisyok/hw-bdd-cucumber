source 'https://rubygems.org'

ruby '2.6.10'
gem 'rails', '5.2'


gem 'sass-rails', '~> 5.0.3'
gem 'uglifier', '>= 2.7.1'

gem 'jquery-rails'
gem 'dotenv-rails', groups: [:development, :test]

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

# for Heroku deployment - as described in Ap. A of ELLS book
group :development, :test do
  gem 'dotenv-rails'
  gem 'byebug'
  gem 'database_cleaner'
  gem 'cucumber-rails', require: false
  gem 'rspec-rails'

  gem 'pry'
  gem 'pry-byebug'

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '~> 1.3.6'
end

group :production do
  gem 'pg', '~> 0.2'
  gem 'rails_12factor'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'cucumber-rails-training-wheels' # คำสั่งทดสอบพื้นฐานสำหรับ Cucumber scenarios
  gem 'database_cleaner' # ใช้เพื่อล้างฐานข้อมูลทดสอบของ Cucumber ระหว่างการรัน
  gem 'capybara'         # ให้ Cucumber ทำงานเสมือนเป็นเบราว์เซอร์
  gem 'launchy'          # เครื่องมือช่วยในการดีบักเพื่อดูหน้าเว็บที่ Cucumber "เห็น"
end

gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem "omniauth-rails_csrf_protection", "~> 1.0"
