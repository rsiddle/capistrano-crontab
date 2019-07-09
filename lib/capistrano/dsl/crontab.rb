require "tempfile"
require "securerandom"

module Capistrano
  module DSL
    module Crontab
      @@tmp_dir = nil

      def self.tmp_dir(f = nil)
        if !f.nil?
          @@tmp_dir = f
        else
          @@tmp_dir
        end
      end
    end

    def crontab_get_content
      capture(:crontab, "-l")
    end

    def crontab_set_content(content)
      tempfile = Tempfile.new
      tempfile.write("#{content}\n")
      tempfile.close

      tmp_upload_file = tempfile.path
      if !Capistrano::DSL::Crontab.tmp_dir.nil?
        tmp_upload_file = File.join(Capistrano::DSL::Crontab.tmp_dir, SecureRandom.hex)
      end

      begin
        upload!(tempfile.path, tmp_upload_file)
        execute(:crontab, tmp_upload_file)
      ensure
        execute(:rm, "-f", tmp_upload_file)
        tempfile.unlink
      end
    end

    def crontab_puts_content
      puts crontab_get_content
    end

    def crontab_add_line(content, marker = nil)
      old_crontab = crontab_get_content
      marker = crontab_marker(marker)
      crontab_set_content("#{old_crontab.rstrip}\n#{content}#{marker}")
    end

    def crontab_remove_line(marker)
      marker = crontab_marker(marker)

      lines = crontab_get_content.split("\n")
        .reject { |line| line.end_with?(marker) }

      crontab_set_content(lines.join("\n"))
    end

    def crontab_update_line(content, marker)
      crontab_remove_line(marker)
      crontab_add_line(content, marker)
    end

    private

    def crontab_marker(marker = nil)
      marker.nil? ? "" : " # MARKER:%s" % [marker]
    end
  end
end
