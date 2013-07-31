module GTA
  class TagFinder
    attr_reader :tag

    def initialize(tag)
      @tag = tag
    end

    def newest
      return unless tag
      tags.last
    end

    def tag_list
      `git tag -l #{tag}`
    end

    def tags
      tag_list.split(/\s/)
    end
  end
end