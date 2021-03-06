module Rpush
  module Client
    module ActiveRecord
      class Notification < ::ActiveRecord::Base
        include Rpush::MultiJsonHelper
        include Rpush::Client::ActiveModel::Notification

        self.table_name = 'rpush_notifications'

        serialize :registration_ids
        serialize :url_args

        belongs_to :app, class_name: 'Rpush::Client::ActiveRecord::App'

        if Rpush.attr_accessible_available?
          attr_accessible :badge, :device_token, :sound, :alert, :data, :expiry, :delivered,
                          :delivered_at, :failed, :failed_at, :error_code, :error_description, :deliver_after,
                          :alert_is_json, :app, :app_id, :collapse_key, :delay_while_idle, :registration_ids,
                          :uri, :url_args, :category
        end

        def data=(attrs)
          return unless attrs
          attrs = JSON.parse(attrs) if attrs.is_a?(String)
          fail ArgumentError, "must be a Hash" unless attrs.is_a?(Hash)
          attrs = data.merge(attrs) if data
          write_attribute(:data, multi_json_dump(attrs))
        end

        def data
          multi_json_load(read_attribute(:data)) if read_attribute(:data)
        end

        def registration_ids=(ids)
          if ids && ids.is_a?(String)
            begin
              data = JSON.parse(ids)
              ids = data if data && data.is_a?(Array)
            rescue JSON::ParserError => e
              ids = ids.split(' ')
            end
          end
          ids = [ids] if ids && !ids.is_a?(Array)
          super
        end
      end
    end
  end
end
