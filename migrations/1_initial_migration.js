const Migrations = artifacts.require("Migrations");

module.exports =  async (deployer) => {
  let visible = await deployer.deploy(Migrations);
}
