# frozen_string_literal: true

USER_SERVICE =  ENV['USER_SERVICE'].to_s || 'http://user:9000'
COMMENT_SERVICE = ENV['COMMENT_SERVICE'].to_s || 'http://comment:9001'
PAYMENT_SERVICE = ENV['PAYMENT_SERVICE'].to_s || 'http://payment:9002'
INVENTORY_SERVICE = ENV['INVENTORY_SERVICE'].to_s || 'http://inventory:9003'
