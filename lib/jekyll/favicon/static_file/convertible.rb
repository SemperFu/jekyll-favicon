# frozen_string_literal: true

require "jekyll/favicon/configuration/defaults"
require "jekyll/favicon/utils"

module Jekyll
  module Favicon
    class StaticFile < Jekyll::StaticFile
      # Create static file based on a source file
      module Convertible
        include Configuration::Defaults

        def convertible?
          convert.any? || convert_allow_empty?
        end

        def convert
          convert_defaults = convertible_defaults.dig File.extname(path), @extname
          convert_normalized = convert_normalize convert_spec
          convert_consolidated = Utils.merge convert_defaults, convert_normalized
          patch convert_patch(convert_consolidated || {})
        end

        def convertible_patch(configuration)
          Utils.patch configuration do |value|
            case value
            when :sizes then sizes.join " "
            else value
            end
          end
        end

        def convert_odd_source?
          img = MiniMagick::Image.open path
          Utils.odd? img.dimensions
        end

        def convert_size(size, separator = "x")
          return size unless convert_odd_source? || Utils.odd?(size)
          min_dimension = size.split(separator).min
          [min_dimension, min_dimension].join(separator)
        end

        def sizes
          if (match = Utils.name_to_size(name)) then [match[1]]
          elsif (define = Utils.define_to_size(convert_spec["define"])) then define
          elsif (resize = convert_spec["resize"]) then [resize]
          elsif (size = convert_spec["size"]) then [size]
          end
        end

        # Jekyll::StaticFile method
        # asks if dest mtime is older than source mtime after original modified?
        def modified?
          super || self.class.mtimes.fetch(href, -1) < mtime
        end

        # Jekyll::StaticFile method
        # adds dest mtime to list after original write
        def write(dest)
          super(dest) && self.class.mtimes[href] = mtime
        end

        private

        # Jekyll::StaticFile method
        # add file creation instead of copying
        def copy_file(*args)
        dest_path = args.last
      
        # Log for debugging purposes
        Jekyll.logger.info "Attempting to copy file. Number of arguments received: #{args.size}"
      
        if args.size == 1
          case @extname
          when ".svg"
            super(dest_path)
          when ".ico", ".png"
            Utils.convert path, dest_path, convert
          else
            Jekyll.logger.warn "Jekyll::Favicon: Can't generate " \
                               " #{dest_path}. Extension not supported."
          end
        elsif args.size == 2
          source_path = args.first
          # Log the paths for debugging
          Jekyll.logger.info "Source: #{source_path}, Destination: #{dest_path}"
          FileUtils.mkdir_p(File.dirname(dest_path))
          FileUtils.cp(source_path, dest_path)
        end
      end

        def convert_allow_empty?
          @extname == ".svg" && @extname == File.extname(path)
        end

        def convert_spec
          spec.fetch "convert", {}
        end

        def convertible_keys
          convertible_defaults["defaults"].keys
        end

        def convert_normalize(options)
          return {} unless options

          Utils.slice_and_compact options, convertible_keys
        end

        def convert_patch(options)
          patched_options = convert_patch_options options
          Utils.slice_and_compact patched_options, convertible_keys
        end

        def convert_patch_options(options)
          %w[size extent].each_with_object(options) do |name, memo|
            method = "convert_patch_option_#{name}".to_sym
            memo[name] = send(method, options[name])
          end
        end

        def convert_patch_option_size(size)
          case size
          when :auto
            convert_size size if (size = sizes.first)
          else size
          end
        end

        def convert_patch_option_extent(extent)
          case extent
          when :auto
            if (size = sizes.first)
              width, height = size.split "x"
              size if width != height
            end
          else extent
          end
        end
      end
    end
  end
end
