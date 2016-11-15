module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class BankOfIrelandGateway < Gateway
      self.test_url = 'https://example.com/test'
      self.live_url = 'https://example.com/live'

      self.supported_countries = ['IE']
      self.default_currency    = 'EUR'
      self.supported_cardtypes = [:visa, :master]
      self.money_format        = :dollars

      self.homepage_url = 'http://www.example.net/'
      self.display_name = 'New Gateway'

      STANDARD_ERROR_CODE_MAPPING = {}

      TRANSLATION = {
        origin_url: 'allowOriginUrl',
        merchant_id: 'merchantId',
      }.freeze

      def initialize(options={})
        requires!(options, :merchant_id, :password, :origin_url)
        super
      end

      def tokenize(credit_card, options = {})
        post = {
          'merchantId' => @options[:merchant_id],
          'password' => @options[:password],
          'action' => 'TOKENIZE',
          'timestamp' => options[:timestamp],
          'customerId' => 'not present this one..'
          'allowOriginUrl' => @options[:origin_url]
        }

        # TODO: make a request for a session token and get it!
        # TODO: make the tokenize request.
      end

      def purchase(money, payment, options = {})
        post = {}
        add_invoice(post, money, options)
        add_payment(post, payment)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('sale', post)
      end

      def authorize(money, payment, options={})
        post = {}
        add_invoice(post, money, options)
        add_payment(post, payment)
        add_address(post, payment, options)
        add_customer_data(post, options)

        commit('authonly', post)
      end

      def capture(money, authorization, options={})
        commit('capture', post)
      end

      def refund(money, authorization, options={})
        commit('refund', post)
      end

      def void(authorization, options={})
        commit('void', post)
      end

      def verify(credit_card, options={})
        MultiResponse.run(:use_first_response) do |r|
          r.process { authorize(100, credit_card, options) }
          r.process(:ignore_result) { void(r.authorization, options) }
        end
      end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript
      end

      private

      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)
      end

      def add_invoice(post, money, options)
        post[:amount] = amount(money)
        post[:currency] = (options[:currency] || currency(money))
      end

      def add_payment(post, payment)
      end

      def parse(body)
        {}
      end

      def commit(action, parameters)
        url = (test? ? test_url : live_url)
        response = parse(ssl_post(url, post_data(action, parameters)))

        Response.new(
          success_from(response),
          message_from(response),
          response,
          authorization: authorization_from(response),
          avs_result: AVSResult.new(code: response["some_avs_response_key"]),
          cvv_result: CVVResult.new(response["some_cvv_response_key"]),
          test: test?,
          error_code: error_code_from(response)
        )
      end

      def success_from(response)
      end

      def message_from(response)
      end

      def authorization_from(response)
      end

      def post_data(action, parameters = {})
      end

      def error_code_from(response)
        unless success_from(response)
          # TODO: lookup error code for this response
        end
      end
    end
  end
end
