# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Kakao < OmniAuth::Strategies::OAuth2
      DEFAULT_REDIRECT_PATH = '/oauth'

      option :name, 'kakao'

      option :client_options,
             site: 'https://kauth.kakao.com',
             authorize_path: '/oauth/authorize',
             token_url: '/oauth/token'

      uid { raw_info['id'].to_s }

      info do
        {
          'name' => raw_properties['nickname'],
          'image' => raw_properties['thumbnail_image'],
          'email' => raw_info['kaccount_email']
        }
      end

      extra do
        { 'properties' => raw_properties }
      end

      def initialize(app, *args, &block)
        super
        options[:callback_path] = options[:redirect_path] || DEFAULT_REDIRECT_PATH
      end

      def callback_url
        options[:callback_url] || (full_host + script_name + callback_path)
      end

      private

      def raw_info
        @raw_info ||= access_token.get('https://kapi.kakao.com/v2/user/me', {}).parsed || {}
      end

      def raw_properties
        @raw_properties ||= raw_info['properties']
      end
    end
  end
end

OmniAuth.config.add_camelization 'kakao', 'Kakao'
