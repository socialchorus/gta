module GTA
  class Stage
    include Sh

    attr_reader :name, :repository, :source_name, :branch, :tag, :manager

    def initialize(name, manager, opts)
      @name = name
      @manager = manager
      @repository =   opts['repository']
      @source_name =  opts['source']
      @branch =       opts['branch'] || 'master'
      @tag =          opts['tag']
    end

    def stages
      manager.stages
    end

    def source
      @source ||= manager.stage!(source_name)
    end

    def add_remote
      raise "no name defined for #{self}" unless name
      raise "no repository defined for #{name}" unless repository

      sh "git remote add #{name} #{repository}"
    end

    def checkout
      sh "git checkout -b #{name} -t #{name}/#{branch}"
    end

    def push(s=source, forced=nil)
      sh push_command(source_from(s), forced)
    end

    def force_push(s=source)
      sh push_command(source_from(s), :force)
    end

    def fetch
      sh "git fetch #{name}"
    end

    def ==(other)
      name == other.name &&
        branch == other.branch &&
        tag == other.tag
    end

    # -----------

    def source_from(s)
      s.respond_to?(:source_ref) ? s.source_ref : s
    end

    def source_ref
      tag || "#{name}/#{branch}"
    end

    def push_command(source_ref, forced=nil)
      force = forced == :force ? " -f" : ""
      "git push#{force} #{name} #{source_ref}:#{branch}"
    end
  end
end
