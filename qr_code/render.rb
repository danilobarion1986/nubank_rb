# frozen_string_literal: true

require 'erb'
require 'launchy'

module QrCode
  # Render a QR Code page from its data
  class Render
    FILENAME = 'qr_code.html'

    class << self
      def call(qr_code, uuid)
        @qr_code = qr_code
        @uuid = uuid
        result = ERB.new(template).result(binding)

        file = "#{File.expand_path(__dir__)}/#{FILENAME}"
        File.open(file, 'w') { |file| file.write(result) }
        Launchy.open("file:///#{file}")
      end

      private

      def template
        File.open("#{File.expand_path(__dir__)}/template.erb", 'rb', &:read)
      end
    end
  end
end
