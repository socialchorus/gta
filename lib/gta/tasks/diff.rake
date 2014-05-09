namespace :gta do
  def gta_differ(args)
    @differ ||= GTA::Diff.new(args[:source_stage], args[:destination_stage], GTA::Manager.env_config)
  end

  namespace :diff do
    task :cherry_pick, :source_stage, :destination_stage do |t, args|
      gta_differ(args).cherry_pick
    end
  end

  desc "report commit differences between stages"
  task :report, :source_stage, :destination_stage do |t, args|
    gta_differ(args).report
  end
end
