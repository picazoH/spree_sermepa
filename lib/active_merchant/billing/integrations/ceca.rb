# encoding: utf-8
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      # See the BbvaTpv::Helper class for more generic information on usage of
      # this integrated payment method.
      module Ceca
        extend ActiveSupport::Autoload

        eager_autoload do
          autoload :Helper, 'active_merchant/billing/integrations/ceca/helper.rb'
        end

        mattr_accessor :service_test_url
        self.service_test_url = "http://tpv.ceca.es:8000/cgi-bin/tpv"
        mattr_accessor :service_production_url
        self.service_production_url = "https://pgw.ceca.es/cgi-bin/tpv"


        def self.service_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
            when :production
              self.service_production_url
            when :test
              self.service_test_url
            else
              raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end

        def self.notification(post)
          Notification.new(post)
        end


        def self.currency_code( name )
          row = supported_currencies.assoc(name)
          row.nil? ? supported_currencies.first[1] : row[1]
        end

        def self.currency_from_code( code )
          row = supported_currencies.rassoc(code)
          row.nil? ? supported_currencies.first[0] : row[0]
        end

        def self.language_code(name)
          row = supported_languages.assoc(name.to_s.downcase.to_sym)
          row.nil? ? supported_languages.first[1] : row[1]
        end

        def self.language_from_code( code )
          row = supported_languages.rassoc(code)
          row.nil? ? supported_languages.first[0] : row[0]
        end

        def self.transaction_code(name)
          row = supported_transactions.assoc(name.to_sym)
          row.nil? ? supported_transactions.first[1] : row[1]
        end
        def self.transaction_from_code(code)
          row = supported_transactions.rassoc(code.to_s)
          row.nil? ? supported_languages.first[0] : row[0]
        end

        def self.supported_currencies
          [ ['EUR', '978'] ]
        end

        def self.supported_languages
          [
              [:es, '1'],
              [:en, '6'],
              [:ca, '2'],
              [:fr, '7'],
              [:pt, '9']
          ]
        end

        def self.supported_transactions
          [
              [:authorization,              '0'],
              [:preauthorization,           '1'],
              [:confirmation,               '2'],
              [:automatic_return,           '3'],
              [:reference_payment,          '4'],
              [:recurring_transaction,      '5'],
              [:successive_transaction,     '6'],
              [:authentication,             '7'],
              [:confirm_authentication,     '8'],
              [:cancel_preauthorization,    '9'],
              [:deferred_authorization,             'O'],
              [:confirm_deferred_authorization,     'P'],
              [:cancel_deferred_authorization,      'Q'],
              [:inicial_recurring_authorization,    'R'],
              [:successive_recurring_authorization, 'S']
          ]
        end

        def self.response_code_message(code)
          case code.to_i
            when 0..99
              nil
            when 900
              "Transacción autorizada para devoluciones y confirmaciones"
            when 101
              "Tarjeta caducada"
            when 102
              "Tarjeta en excepción transitoria o bajo sospecha de fraude"
            when 104
              "Operación no permitida para esa tarjeta o terminal"
            when 116
              "Disponible insuficiente"
            when 118
              "Tarjeta no registrada o Método de pago no disponible para su tarjeta"
            when 129
              "Código de seguridad (CVV2/CVC2) incorrecto"
            when 180
              "Tarjeta no válida o Tarjeta ajena al servicio o Error en la llamada al MPI sin controlar."
            when 184
              "Error en la autenticación del titular"
            when 190
              "Denegación sin especificar Motivo"
            when 191
              "Fecha de caducidad errónea"
            when 202
              "Tarjeta en excepción transitoria o bajo sospecha de fraude con retirada de tarjeta"
            when 912,9912
              "Emisor no disponible"
            when 913
              "Pedido repetido"
            else
              "Transacción denegada"
          end
        end

      end
    end
  end
end
