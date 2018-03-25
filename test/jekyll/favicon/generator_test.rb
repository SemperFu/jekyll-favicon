require 'test_helper'

describe Jekyll::Favicon::Generator do
  before do
    @options = {}
    @options['quiet'] = true
    @options['destination'] = Dir.mktmpdir
    @options['favicon'] = {
      'sizes' => ['48x48', '32x32', '16x16'],
      'svg' => {
        'density' => '72',
        'dimensions' => '64x64'
      },
      'png' => {
        'dimensions' => '64x64'
      },
      'ico' => { 'sizes' => [32, 16] }
    }
  end

  after do
    FileUtils.remove_entry @site.config['destination']
  end

  describe 'when favicon source exists' do
    before do
      @options['quiet'] = false
      @options['source'] = fixture 'sites', 'empty'
      @config = Jekyll.configuration @options
      @site = Jekyll::Site.new @config
    end

    it 'should not generate files' do
      skip
      assert_output(nil, /Jekyll::Favicon: Missing favicon.svg/) { @site.process }
    end
  end

  describe 'when favicon source exists' do
    before do
      @options['source'] = fixture 'sites', 'default'
      @config = Jekyll.configuration @options
      @site = Jekyll::Site.new @config
      @site.process
    end

    it 'should generate icons' do
      assert File.exist? File.join(@options['destination'], 'favicon.ico')
      generated_files = Dir.glob File.join(@options['destination'], '**', '*.png')
      defaults = Jekyll::Favicon::DEFAULTS
      @options['favicon']['sizes'].each do |size|
        icon = File.join @options['destination'], defaults['path'], "favicon-#{size}.png"
        assert_includes generated_files, icon
      end
    end
  end
end
