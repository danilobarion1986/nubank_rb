# frozen_string_literal: true

require 'pry'
require 'securerandom'
require_relative './qr_code/creator'
require_relative './qr_code/render'
require_relative './xlsx/creator'
require_relative './request/discovery_url'
require_relative './request/discovery_app_url'
require_relative './request/bills'
require_relative './request/bill_detail'
require_relative './request/auth/qr_code'
require_relative './request/auth/password'

# # 0) Get login and password from environment variables
login = if ENV['NUBANK_LOGIN']
          ENV['NUBANK_LOGIN']
        else
          puts 'Enter you login: '
          gets
        end

password = if ENV['NUBANK_PASSWORD']
             ENV['NUBANK_PASSWORD']
           else
             puts 'Enter you password: '
             gets.chomp
           end

puts 'Login/password cannot be blank!' if login&.empty? || password&.empty?

# 1) Obtain valid URL's via discovery
puts '====> Discovering Nubank API endpoints...'
urls = Request::DiscoveryUrl.call
app_urls = Request::DiscoveryAppUrl.call

# 2) Generate UUID and QR Code from it
puts '====> Generating QR Code...'
uuid = SecureRandom.uuid
qr_code = QrCode::Creator.call(uuid)
QrCode::Render.call(qr_code, uuid)

# 3) Call login URL, to obtain an access_token
puts '====> Authenticating login and password...'
login_response = Request::Auth::Password.call(urls[:login], login, password)

# 4) Call QR Code login URL to obtain a new access_token
puts '====> Authenticating QR Code...'
login_qr_code_response = Request::Auth::QrCode.call(app_urls[:lift], uuid, login_response[:access_token])
qr_code_access_token = login_qr_code_response[:access_token]
features_urls = login_qr_code_response[:_links]

# 5) Get bills summary
puts '====> Retrieving Bills Summary...'
bills_url = features_urls.dig(:bills_summary, :href)
bills = Request::Bills.call(bills_url, qr_code_access_token).fetch(:bills)

# 6) Select one or more bills to get detailed information
puts
puts 'Choose bill to get data from (enter "999" for all bills):'
bills.reject! { |bill| bill[:state] == 'future' }
Array(bills).each_with_index do |bill, index|
  state = bill[:state]
  effective_due_date = bill.dig(:summary, :effective_due_date)
  total_balance = (BigDecimal(bill[:summary].fetch(:total_balance, 0))/BigDecimal(100)).to_s("F")
  puts "#{index}) [#{state}] R$ #{total_balance}, effective due date: #{effective_due_date}"
end
chosen_bill_index = gets.chomp.to_i

if chosen_bill_index == 999
  # 7) Get details of all the bills
  bills.each do |bill|
    bill = Request::BillDetail.call(bill, qr_code_access_token).fetch(:bill)

    # 8) Save bill details to a .xlsx file
    Xlsx::Creator.call(bill)
    sleep 5 # Avoid too many requests per second
  end
else
  # 7) Get details of the chosen bill
  bill = Request::BillDetail.call(bills[chosen_bill_index], qr_code_access_token).fetch(:bill)

  # 8) Save bill details to a .xlsx file
  Xlsx::Creator.call(bill)
end
