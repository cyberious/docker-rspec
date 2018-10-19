require 'docker-rspec'
require 'rake'
require 'rake/tasklib'

class DockerRspec
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :puppet_version
    attr_accessor :image
    attr_accessor :tty

    def initialize(*args, &task_block)
      @name  = args.shift || :dspec
      @image = 'cyberious/docker_rspec'
      @tag   = ENV['PUPPET_GEM_VERSION'] || '5.3'
      define(args, &task_block)
    end

    def define(*args, &task_block)
      desc 'Run rspec within the current context of a box'
      task @name do
        require 'docker'
        current_project = Dir.pwd
        if !Docker::Image.exist?("cyberious/rspec_puppet:#{@tag}")
          puts "Pulling docker image"
          Docker::Image.create('fromImage' => "cyberious/rspec_puppet:#{@tag}")
        end

        puts "Creating container"
        container = Docker::Container.create(
          'Env'        => ["TERM=xterm-256color"],
          'Image'      => "cyberious/rspec_puppet:#{@tag}",
          'HostConfig' => { 'Binds' => ["#{current_project}:/code:ro"] },
          'Tty'        => true)
        puts "Starting container #{container}"
        container.tap(&:start).attach(
          :stream => true,
          :stdin  => nil,
          :stdout => true,
          :stderr => true, :logs => true, :tty => true) do |stream, chunk|
          if stream =~ %r{Resolving deltas} || stream == '.' || stream =~ %r{Receiving objects} || %r{^remote:}
            msg = stream + "\r"
          else
            msg = stream
          end
          print "#{msg}" unless msg.empty?
        end

      end
    end


  end
end

DockerRspec::RakeTask.new
