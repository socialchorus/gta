module GTA
  class Stage
    include Sh

    attr_reader :name, :repository, :source_name, :branch, :tag, :manager,
      :final, :hotfixable, :restorable

    def initialize(name, manager, opts)
      @name = name
      @manager = manager
      @repository =   opts['repository']
      @source_name =  opts['source']
      @branch =       opts['branch'] || 'master'
      @tag =          opts['tag']
      @final =        opts['final']
      @hotfixable =   opts['hotfixable']
      @restorable =   opts['restorable']
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

      sh("git remote add #{name} #{repository}")
    end

    def checkout
      delete_existing_branch if existing_branch?
      sh(checkout_command)
    end

    def checkout!
      delete_existing_branch if existing_branch?
      sh!(checkout_command)
    end

    def checkout_command
      "git checkout -b #{name} -t #{name}/#{branch}"
    end

    def push(s=source, forced=nil)
      sh!(push_command(source_from(s), forced))
    end

    def force_push(s=source)
      sh!(push_command(source_from(s), :force))
    end

    def fetch
      sh(fetch_command)
    end

    def fetch!
      sh!(fetch_command)
    end

    def fetch_command
      "git fetch #{name}"
    end

    def delete_existing_branch
      sh("git checkout master") # in case already on branch
      sh("git branch -D #{name}")
    end

    def existing_branch?
      sh('git branch').include?(name)
    end

    def ==(other)
       other.is_a?(self.class) &&
        name == other.name &&
        branch == other.branch &&
        tag == other.tag
    end

    def final?
      !!final
    end

    def restorable?
      !!restorable
    end

    def hotfixable?
      !!hotfixable
    end

    # -----------

    def source_from(s)
      s.respond_to?(:source_ref) ? s.source_ref : s
    end

    def source_ref
      TagFinder.new(tag).newest || "#{name}"
    end

    def push_command(source_ref, forced=nil)
      force = forced == :force ? " -f" : ""
      "git push#{force} #{name} #{source_ref}:#{branch}"
    end
  end
end
