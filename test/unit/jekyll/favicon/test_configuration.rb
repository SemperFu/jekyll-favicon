# frozen_string_literal: true

require 'unit_helper'
require 'jekyll/favicon/configuration'

module Jekyll
  module Favicon
    # test favicon configuration
    class TestConfiguration < Minitest::Test
      def setup
        @site = MiniTest::Mock.new
      end

      def test_has_from_user_method
        assert_respond_to Favicon::Configuration, :from_user
      end

      def test_from_user_retrieves_nothing_when_invalid_site
        from_user = Favicon::Configuration.from_user nil
        assert_nil from_user
      end

      def test_from_user_retrieves_empty_when_site_config_does_not_have_favicon
        @site.expect :config, {}
        from_user = Favicon::Configuration.from_user @site
        refute_nil from_user
        assert_kind_of Hash, from_user
        assert_empty from_user
      end

      def test_from_user_retrieves_empty_when_site_config_has_favicon
        favicon_config = { 'source' => 'from_user-config' }
        @site.expect :config, 'favicon' => favicon_config
        from_user = Favicon::Configuration.from_user @site
        refute_nil from_user
        assert_kind_of favicon_config.class, from_user
        refute_empty from_user
        assert_equal favicon_config, from_user
      end

      def test_has_stardardize_method
        assert_respond_to Favicon::Configuration, :standardize
      end

      def test_standardize_expands_source
        input = { 'source' => 'custom-config', 'something' => 'else' }
        standardized = Favicon::Configuration.standardize input
        refute_nil standardized
        assert_equal Hash['dir' => '.', 'name' => input['source']],
                     standardized['source']
        assert_equal Favicon::Utils.except(input, 'source'),
                     Favicon::Utils.except(standardized, 'source')
      end

      def test_has_merged_method
        assert_respond_to Favicon::Configuration, :merged
      end

      def test_merged_retrieves_defaults_when_site_is_invalid
        merged = Favicon::Configuration.merged nil
        refute_nil merged
        assert_equal Favicon.defaults, merged
      end

      def test_merged_retrieves_defaults_when_custom_config_is_empty
        @site.expect :config, {}
        merged = Favicon::Configuration.merged nil
        assert_kind_of Hash, merged
        assert_equal Favicon.defaults, merged
      end

      def test_merged_merges_defaults_when_site_has_favicon_config
        custom_key = 'source'
        favicon_config = { custom_key => 'custom-config' }
        @site.expect :config, 'favicon' => favicon_config
        merged = Favicon::Configuration.merged @site
        assert_kind_of Hash, merged
        assert_equal Hash['dir' => '.', 'name' => favicon_config[custom_key]],
                     merged[custom_key]
        assert_equal Favicon::Utils.except(Favicon::Configuration.from_defaults, custom_key),
                     Favicon::Utils.except(merged, custom_key)
      end
    end
  end
end
