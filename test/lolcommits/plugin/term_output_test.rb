require "test_helper"

describe Lolcommits::Plugin::TermOutput do

  include Lolcommits::TestHelpers::GitRepo
  include Lolcommits::TestHelpers::FakeIO

  # initialize and reset env vars before tests run
  before do
    @old_tmux = ENV['TMUX']
    @old_term_program = ENV['TERM_PROGRAM']
    ENV['TERM_PROGRAM'] = "iTerm"
    ENV['TMUX'] = nil
  end

  after do
    ENV['TERM_PROGRAM'] = @old_term_program
    ENV['TMUX'] = @old_tmux
  end

  def plugin_name
    "term_output"
  end

  it "should have a name" do
    ::Lolcommits::Plugin::TermOutput.name.must_equal plugin_name
  end

  it "should run on capture ready" do
    ::Lolcommits::Plugin::TermOutput.runner_order.must_equal [:capture_ready]
  end

  describe "with a runner" do
    def runner
      # a simple lolcommits runner with an empty configuration Hash
      @runner ||= Lolcommits::Runner.new(
        main_image: Tempfile.new('main_image.jpg'),
        config: OpenStruct.new(
          read_configuration: {},
          loldir: File.expand_path("#{__dir__}../../../images")
        )
      )
    end

    def plugin
      @plugin ||= Lolcommits::Plugin::TermOutput.new(runner: runner)
    end

    def valid_enabled_config
      @config ||= OpenStruct.new(
        read_configuration: { plugin_name => { "enabled" => true } }
      )
    end

    describe "#enabled?" do
      it "is false by default" do
        plugin.enabled?.must_equal false
      end

      it "is true when configured" do
        plugin.config = valid_enabled_config
        plugin.enabled?.must_equal true
      end
    end

    describe "run_capture_ready" do
      before { commit_repo_with_message("first commit!") }
      after { teardown_repo }

      def check_plugin_output(matching_regex)
        in_repo do
          plugin.config = valid_enabled_config
          output = fake_io_capture { plugin.run_capture_ready }
          output.must_match matching_regex
        end
      end

      it "outputs lolcommits image inline to terminal" do
        check_plugin_output(/^\e\]1337;File=inline=1\:.*\n;alt=first commit!;\a\n$/)
      end

      describe "when running in a Tmux session" do
        before do
          ENV['TMUX'] = 'true'
        end

        it "outputs lolcommits image inline to terminal with Tmux escape sequence" do
          check_plugin_output(/^\ePtmux;\e\e\]1337;File=inline=1\:.*\n;alt=first commit!;\a\e\\\n$/)
        end
      end

      describe "when using an unsupported terminal" do
        before do
          ENV['TERM_PROGRAM'] = "konsole"
        end

        it "outputs nothing to the terminal" do
          check_plugin_output ""
        end
      end
    end

    describe "configuration" do
      it "allows plugin options to be configured" do
        inputs = %w( true )  # enabled option
        configured_plugin_options = {}

        fake_io_capture(inputs: inputs) do
          configured_plugin_options = plugin.configure_options!
        end

        configured_plugin_options.must_equal({ "enabled" => true })
      end

      describe "when terminal not supported" do
        before do
          ENV['TERM_PROGRAM'] = "konsole"
        end

        it "does not allow options to be configured" do
          inputs = %w( true )  # enabled option
          configured_plugin_options = {}

          output = fake_io_capture(inputs: inputs) do
            configured_plugin_options = plugin.configure_options!
          end

          assert_equal configured_plugin_options, {}
          output.must_match(/Sorry, this terminal does not support the term_output plugin/)
        end
      end
    end
  end
end
