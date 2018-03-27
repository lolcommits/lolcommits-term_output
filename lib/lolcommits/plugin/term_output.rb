require 'base64'
require 'lolcommits/plugin/base'

module Lolcommits
  module Plugin
    class TermOutput < Base

      ## Prompts the user to configure the plugin's options. The default
      #superclass method will ask for the `enabled` option to be set.
      #
      # @return [Hash] hash of configured options `{ enabled: true/false }`
      # @return [Nil] if this terminal does not support this plugin
      #
      def configure_options!
        if terminal_supported?
          super
        else
          puts "Sorry, this terminal does not support this plugin (requires iTerm2)"
          {}
        end
      end

      ##
      # Post-capture hook, runs after lolcommits captures a snapshot. If the
      # terminal is supported (and we have commits) the lolcommit image is
      # rendered inline to the terminal output (with the commit message).
      #
      # See here for more details: https://iterm2.com/documentation-images.html
      #
      def run_capture_ready
        if terminal_supported?
          if !runner.vcs_info || runner.vcs_info.repo.empty?
            debug 'repo is empty, skipping term output'
          else
            base64 = Base64.encode64(open(runner.main_image, &:read).to_s)
            puts "#{begin_escape}1337;File=inline=1:#{base64};alt=#{runner.message};#{end_escape}\n"
          end
        else
          debug 'Terminal not supported (requires iTerm2)'
        end
      end

      private

      ##
      # Generate starting escape character sequence. Terminals running Tmux
      # sessions require a different escape code.
      #
      # @return [String] escape char sequence for inline images
      #
      def begin_escape
        tmux? ? "\033Ptmux;\033\033]" : "\033]"
      end

      ##
      # Generate ending escape character sequence. Terminals running Tmux
      # sessions require a different escape code.
      #
      # @return [String] escape char sequence for inline images
      #
      def end_escape
        tmux? ? "\a\033\\" : "\a"
      end

      ##
      # Determine if the terminal is running a Tmux session (checks for the TMUX
      # env var to be set).
      #
      # @return [Boolan] true when running within a Tmux session
      #
      def tmux?
        !ENV['TMUX'].nil?
      end

      ##
      # Determine if the terminal is supported by this plugin.
      #
      # @return [Boolan] true when terminal identifies as iTerm
      #
      def terminal_supported?
        ENV['TERM_PROGRAM'] =~ /iTerm/
      end
    end
  end
end
