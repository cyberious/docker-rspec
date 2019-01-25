require 'docker-rspec'
require 'rake'
require 'rake/tasklib'
require 'puppet'

# DockerRspec class definition for auto test
class DockerRspec
  ## Declare rake task for docker-rspec
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    attr_accessor :puppet_version
    attr_accessor :image
    attr_accessor :tty
    def parse_version
        ver = Puppet.version.gsub(/\.\d+$/, '')
    end

    def initialize(*args, &task_block)
      @name  = args.shift || :dspec
      @image = 'cyberious/rspec_puppet'
      @tag   = parse_version
      define(args, &task_block)
    end

    def define(*_args)
      image = "#{@image}:#{@tag}"
      desc 'Run rspec within the current context of a box'
      task @name do
        require 'docker'
        current_project = Dir.pwd
        container       = create_container(current_project, image)
        start_container(container)
      end
    end

    def pull_container(image)
      return false if Docker::Image.exist?(image)

      puts 'Pulling docker image'
      Docker::Image.create('fromImage' => image)
    end

    def create_container(project_dir, image)
      pull_container(image)
      puts 'Creating container'
      Docker::Container.create(
        'Env'        => ['TERM=xterm-256color'],
        'Image'      => image,
        'HostConfig' => { 'Binds' => ["#{project_dir}:/code:ro"] },
        'Tty'        => true
      )
    end

    def parse_stream(stream)
      msg = if stream =~ /(Resolving deltas|Receiving objects|^remote:|^\.$)/
              stream + "\r"
            else
              stream
            end

      msg
    end

    def start_container(container)
      puts "Starting container #{container}"
      container.tap(&:start).attach(
        stream: true, stdin: nil, stdout: true,
        stderr: true, logs: true, tty: true
      ) do |stream, _chunk|
        msg = parse_stream(stream)

        print msg.to_s unless msg.empty?
      end
    end
  end
end

DockerRspec::RakeTask.new
