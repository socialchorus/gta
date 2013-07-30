namespace :gta do
  namespace :hotfix do
    desc "Checkout a stage for hotfix change and future deploy"
    task :checkout, :stage_name do |t, args|
      hotfix = GTA::Hotfix.new(GTA::Manager.env_config)
      hotfix.checkout(args[:stage_name])
    end

    desc "deploy checked out branch to that remote"
    task :deploy, :stage_name do |t, args|
      hotfix = GTA::Hotfix.new(GTA::Manager.env_config)
      hotfix.deploy(args[:stage_name])
    end
  end
end
